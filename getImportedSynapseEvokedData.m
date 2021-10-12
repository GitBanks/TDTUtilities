function dataOut = getImportedSynapseEvokedData(exptDate,exptIndex,tPreStim,tPostStim)

% test params
%exptDate = '21616';
%exptIndex = '010';

if ~exist('tPreStim','var')
    tPreStim = 0.02; %sec % these really should match some config file for standardization
end
if ~exist('tPostStim','var')
    tPostStim = 0.2; %sec % 
end

fileString = [exptDate '-' exptIndex];
dataPath = ['M:\PassiveEphys\20' exptDate(1:2) '\' fileString '\' ];

load([dataPath '\' fileString '_data0']);
load([dataPath '\' fileString '_peakData']);
nChans = size(ephysData,1);
nROIs = floor(nChans/2);
timeArray = (0:dT:length(ephysData)*dT-dT);
    
temp = struct();
for iTrial = 1:size(peakData.stimTimes,1)
    iStart = find(timeArray>peakData.stimTimes(iTrial)-tPreStim,1);
    iStop = find(timeArray>peakData.stimTimes(iTrial)+tPostStim,1);
    for iChan = 1:nChans
        temp.data(iChan,iTrial,:) = ephysData(iChan,iStart:iStop);
    end
end
dataOut = struct();
for iSub = 1:nROIs
    dataOut.sub(iSub,:,:) = temp.data(iSub*2,:,:) - temp.data(iSub*2-1,:,:);
end