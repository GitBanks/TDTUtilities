function [loadedData,fs,metaData,rescaleFS] = loadMouseDataForPipeline(params)

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

metaData = struct('blockTime',struct(),'stateData',struct(),'stageKey',cell(1));


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
fixParamsOnce = 1;
for iFile = 1:size(blocks,2)
    file = [getPathGlobal('importedData') '20' blocks{iFile}(1:2) '\' blocks{iFile} '\'  blocks{iFile} '_data0'];
    disp(['Loading ' blocks{iFile}]);
    load(file);
    
    thisBlock = ['blk' strrep(blocks{iFile},'-','_')];
    
    % this is for the bipolar subtraction channels - toggled in analysisOptions
    if subtractionFlag
        newArrayIterator = 1;
        for ii = 1:2:size(ephysData,1)
            newArray(newArrayIterator,:) = ephysData(ii+1,:) - ephysData(ii,:);
            newArrayIterator = newArrayIterator+1;
        end
        ephysData = newArray;
        clear newArray;
        % we only need to adjust the params once
        if fixParamsOnce
            newArrayIterator = 1;
            for ii = 1:2:size(ephysData,1)   
                newECoGchannels(newArrayIterator) = params.ECoGchannels{1}(ii);
                newECoGchannels(newArrayIterator).chanNum = newArrayIterator;
                newArrayIterator = newArrayIterator+1;
            end
            params.ECoGchannels = {newECoGchannels};
            fixParamsOnce = 0;
        end
    end
    
    
    loadedData.(['blk' strrep(blocks{iFile},'-','_')]) = ephysData';
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
        
        
%         chanDataNames = params.ECoGchannels{1};
%         params.dataPrefix
%         double(loadedData.(chanDataNames(iChan,:)).dat(t));
        
        if decimate
            tempLoadedData.(thisBlock)(:,iChan) = resample(double(loadedData.(thisBlock)(:,iChan)),fsres,fsorig);
        else
            tempLoadedData.(thisBlock)(:,iChan) = double(loadedData.(thisBlock)(:,iChan));
        end
    end
    
    loadedData.(thisBlock) = tempLoadedData.(thisBlock);
    
    if ~isnat(params.blockTime{1}(iFile))
        metaData.blockTime.(thisBlock) = params.blockTime{1}(iFile);% + seconds(params.startMin * 60);
    else
        metaData.blockTime.(thisBlock) = NaT;
    end
    
end









