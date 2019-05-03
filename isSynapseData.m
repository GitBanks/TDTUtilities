function [synapseData,frameTimeStamps] = isSynapseData(vidFileName)

% Synapse version also stores timestamps from TDT file
try
    delims = strfind(vidFileName,filesep);
    rawPath = vidFileName(1:delims(end));
    data = TDTbin2mat(rawPath,'TYPE',{'epocs'}); % only need epocs - this saves a ton of time.
    frameTimeStamps = data.epocs.Cam1.onset; % this makes assumptions about the structure.  will need to change if we change 'Cam1' e.g.
    synapseData = true;
catch
    warning('non-synapse data detected.');
    frameTimeStamps = [];
    synapseData = false;
end