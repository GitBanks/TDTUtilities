function [batchParams] = mouseDelirium_getBatchParamsByAnimal(animalName)
% test info
% animalName = 'DREADD07'

batchParams = struct;
outPath = '\\MEMORYBANKS\Data\mouseEEG\videoScoring\';
disp(['Data will be saved to `' outPath '`']);
defaultPath = '\\144.92.218.131\Data\Data\PassiveEphys\EEG animal data\';
pars.windowLength = 4; %sec
pars.windowOverlap = 0.25; %fractional overlap


sponRecForAnimal = getExperimentsByAnimal(animalName,'Spon');
electrodeInfo = getElectrodeLocationFromDateIndex(sponRecForAnimal{1,1}(1:5),sponRecForAnimal{1,1}(7:9));
ephysInfo.recMode = 'EEG'; % !!! WARNING !!! this is hardcoded, assumes we're looking at EEG.  Channel descriptions will
% be in 'electrodeInfo' if we want to chage this, add features, etc.

electrodeInfo






unique(a{:,2});
animalID = fetch(S.dbConn,['SELECT animalID FROM animals WHERE animalName=''' S.animalName '''']);
exptDate = fetch(S.dbConn,['SELECT exptDate FROM masterexpt WHERE exptID=' num2str(lastEntryID{1})]);
exptIndex = fetch(S.dbConn,['SELECT exptIndex FROM masterexpt WHERE exptID=' num2str(lastEntryID{1})]);
experimenterID = fetch(S.dbConn,['SELECT experimenterID FROM masterexpt WHERE exptID= ''' num2str(lastEntryID{1}) '''']);




ephysInfo.chanNums = 1:4; %brain ephys channels

ephysInfo.EMGchan = 5;
ephysInfo.EMGchan = [];
ephysInfo.chanLabels = {'AR','PR','PL','AL'}; %Labels for EEG channels

salineDate = '15826';
pars.expt(1).dataPath = [defaultPath animalName filesep salineDate filesep];
pars.expt(1).exptDate = ['date' salineDate];
pars.expt(1).exptIndex = {'000','001','002','003','004'};
pars.expt(1).timeReInj = [-1:3];
pars.expt(1).treatment = 'saline';
pars.expt(1).dose = 0;

LPSDate = '15828';
pars.expt(2).dataPath = [defaultPath animalName filesep LPSDate filesep];
pars.expt(2).exptDate = ['date' LPSDate];
% pars.expt(2).exptIndex = {'000','001','002','003','004','005'};
% pars.expt(2).timeReInj = [-1:4]; %hours re injection
pars.expt(2).exptIndex = {'000','001','002','003','004'};
pars.expt(2).timeReInj = [-1:3]; %hours re injection
pars.expt(2).treatment = 'LPS';
pars.expt(2).dose = 125;
batchParams.(animalName) = fillBatchParams(pars,ephysInfo);
clear pars ephysInfo

