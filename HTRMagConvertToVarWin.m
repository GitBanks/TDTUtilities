
%  windowLength = 0.225; %seconds -most HTR will be around 175ms.  adding a small margin and a 50% overlap seems to contain them well
%  windowOverlap = 0.5; %overlap

function [localVar,windowedVarTimes] = HTRmagConvertToVarWin(magData,magDT)
% TODO parameterize this
windowLength = 0.225;
windowOverlap = 0.5;
magTime = 0:magDT:length(magData)*magDT;

while length(magTime) > length(magData) %sometimes time is a mystery
    magTime = magTime(1:end-1);
end
        
data.label{1,1} = 'Mag-Ch1'; % data.label is a 1xnChans cell-array containing string labels for each channel
data.fsample = 1/magDT; % sampling frequency in Hz, single number
data.sampleinfo = [1, size(magData)]; %n points
data.trial{1} = magData; % cell-array containing a data matrix for each trial (1 X Ntrial), each data matrix is a Nchan*Nsamples matrix
data.time{1} = magTime;
% Segment data into trials of length trialLength with overlap
cfg         = [];
cfg.length  = windowLength;
cfg.overlap = windowOverlap;
data = ft_redefinetrial(cfg, data);

% get "middle" of the windowed time arrays
nWindows = length(data.trial);
for iTimes = 1:length(data.time)
    windowedVarTimes(iTimes) = data.time{1,iTimes}(round(length(data.time{1,1})/2)); 
end
%calculate variance
for iVar = 1:length(data.trial)
    localVar(iVar) = var(data.trial{:,iVar});
end


