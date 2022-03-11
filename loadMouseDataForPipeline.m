function [loadedData,fs,metaData,rescaleFS,params] = loadMouseDataForPipeline(params)

% Given params -
% params = metaData(1,:);

% return the following
%   loadedData = struct; fieldnames are equal to params.block (string
%   split on commas), contents are samples x channels double
%   fs = sampling frequency, in Hz, after downsampling (if relevant)
%   metaData = struct; metaData.blockTime is struct with the same
%   fieldnames as loadedData, contents are datetime for start of each block
%   metaData.stateData and metaData.stageKey are used for sleep sorting
%   only and do not need to be set except for sleep data.
% we are expecting output from 
% metaData = getMetaDataSetByFilters(drugSelection,recordingSelection,animalName,overWrite);


blocks = strsplit(params.block{:},',');
conditions = strsplit(params.conditions{:},',');
if length(blocks) ~= length(conditions), error('Mismatch between blocks and conditions'), end

dsFs = params.analysisOptions.dsFs; %downSampleSetting 
subtractionFlag = params.analysisOptions.subtractionFlag;


% if ~exist('subtractionFlag','var')  % should now be set in the analysisOptions file
%     subtractionFlag = false;
% end



%  plan to have just one day for now
if size(params,1) > 1
    error('only one entry expected!');
end

% step 1: break params into specified blocks
blocks = strsplit(params.block{:},',');
conditions = strsplit(params.conditions{:},',');

% step 2: load in the data0 files representing each block
for i = 1:size(blocks,2)
    file = [getPathGlobal('importedData') '20' blocks{i}(1:2) '\' blocks{i} '\'  blocks{i} '_data0'];
    disp(['Loading ' blocks{i}]);
    load(file);
    
    % this is for the bipolar subtraction channels - toggled in analysisOptions
    if subtractionFlag
        newArrayIterator = 1;
        for ii = 1:2:size(ephysData,1)
            newArray(newArrayIterator,:) = ephysData(ii+1,:) - ephysData(ii,:);
            newArrayIterator = newArrayIterator+1;
        end
        ephysData = newArray;
        clear newArray;
        %  TODO!!   NEED TO CORRECT ROIs IF WE CHANGED THE CHANNEL COUNT!
        % DO THAT HERE
    end
    
    loadedData.(['blk' strrep(blocks{i},'-','_')]) = ephysData';
    clear ephysData;
    
    fs = 1/dT;
    rescaleFS = 1;

    if round(fs) ~= fs && abs(round(fs)-fs)<0.01
        warning('fs is within 0.01 of integer value; rounding fs');
        fs = round(fs);
    elseif round(fs) ~= fs
        fs = round(1000*fs)/1000;
        rescaleFS = 1000; % Scale factor we have to undo later to make things integers
    end
    
    nChan = length(params.ECoGchannels{:});
    % Downsample?
    if isfield(params.analysisOptions,'SVDultrahigh') && params.analysisOptions.SVDultrahigh>0
        % Decimate later
        decimate = false;
    else
        if dsFs < fs
            decimate = true;
            [fsorig, fsres] = rat(round(fs*rescaleFS)/(dsFs*rescaleFS)); % get nearest ratio
            oldFs = fs;
            fs = fs*(fsres/fsorig);
        else
            decimate = false;
        end
    end
    fs = round(fs);
    for iChan = 1:nChan
        if decimate
            loadedData.(thisBlock){iFile,iChan} = resample(extractFcn(iChan,:),fsres,fsorig);
        else
            loadedData.(thisBlock){iFile,iChan} = extractFcn(iChan,:);
        end
    end

end

















metaData = params;


