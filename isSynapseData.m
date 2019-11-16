function [synapseData,frameTimeStamps] = isSynapseData(vidFileName)

% Synapse version also stores timestamps from TDT file
try
    delims = strfind(vidFileName,filesep);
    rawPath = vidFileName(1:delims(end));
    data = TDTbin2mat(rawPath,'TYPE',{'epocs'}); % only need epocs - this saves a ton of time.
    frameTimeStamps = data.epocs.Cam2.onset; % this makes assumptions about the structure.  will need to change if we change 'Cam1' e.g.
    synapseData = true;
catch
    if contains(vidFileName,'Cam2') %if cam2, then we know the datastream is the second stream and we will need to check the block location
        blockIndex = str2double(vidFileName(delims(5)-2:delims(5)-1))-1;
        if length(num2str(blockIndex)) < 2
            blockIndex = [vidFileName(delims(4)+1:delims(4)+5) '-00' num2str(blockIndex)];
        else
            blockIndex = [vidFileName(delims(4)+1:delims(4)+5) '-0' num2str(blockIndex)];
        end
        blockFileName = [vidFileName(1:delims(4)) blockIndex];
        data = TDTbin2mat(blockFileName,'TYPE',{'epocs'}); % only need epocs - this saves a ton of time.
        frameTimeStamps = data.epocs.Cam2.onset; % this makes assumptions about the structure.  will need to change if we change 'Cam1' e.g.
        synapseData = true;
    else
        warning('non-synapse data detected.');
        frameTimeStamps = [];
        synapseData = false;
    end
    
end