function movementsPreStim = plotStimAndMovement(exptDate,exptIndex)

% openEphys
% Zarmeen give me expt IDs
% computer for Chuck


%Given an *ephys* expt date and index (ID)
%1. fetch magnet data
%2. fetch stim times
%3. return the movement values associated 

% clear all
% 
% exptDate = '21630';
% % exptIndex = '003'; % stim/resp curve 
% % exptIndex = '005'; % single stim type
% exptIndex = '009'; % single stim type
% % exptIndex = '013'; % single stim type
tPreStim = 0.02; %sec % required input for existing data fetch function
tPostStim = 0.2; %sec % required input for existing data fetch function
preStimMovementWindow = 2; %seconds; can't be longer than the time till first stim!

%1. fetch magnet data
exptID = [exptDate '-' exptIndex];
[magData,magDT] = HTRMagLoadData(exptID);
magTimeArray = 0:magDT:length(magData)/(1/magDT);
magTimeArray = magTimeArray(1:length(magData));
moveData = abs(magData-mean(magData));
magTimeArray = magTimeArray(1:length(moveData));
movementWindowInSamples = round(preStimMovementWindow*(1/magDT));

%2. fetch stim times
[~,indexOut,isTank] = getIsTank(exptDate,exptIndex);
try
    [dataTemp,~] = getSynapseSingleStimData(exptDate,indexOut,tPreStim,tPostStim,isTank);
    stimTimes = dataTemp.stimTimes;
catch
    [~,~,~,stimTimes] = getSynapseStimSetData(exptDate,indexOut,tPreStim,tPostStim,isTank);
end

for iStim = 1:length(stimTimes)
    magEvent = find(magTimeArray>stimTimes(iStim),1);
    movementsPreStim(iStim) = mean(moveData(magEvent-movementWindowInSamples:magEvent));
end


figure;
subtightplot(2,1,1)
scatter(stimTimes/60,movementsPreStim);
subtightplot(2,1,2)
plot(magTimeArray/60,moveData);


