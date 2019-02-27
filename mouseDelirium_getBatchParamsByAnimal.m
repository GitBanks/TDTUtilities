function [batchParams] = mouseDelirium_getBatchParamsByAnimal(animalName)
% STUB/WIP: mouseDelirium_getBatchParamsByAnimal
% original method is a cumbersome nightmare.  All this info *should* be in
% database! Using this script, we can call 'batchParams' as desired.
% test info: animalName = 'EEG55'

% !!WARNING!! % the only question remaining is 'timeReInj', which may
% change if an index is skipped.  We can fix this later by creating a
% master table of experiments in the database.

batchParams = struct;
% outPath = '\\MEMORYBANKS\Data\mouseEEG\videoScoring\';
% disp(['Data will be saved to `' outPath '`']);
defaultPath = '\\144.92.218.131\Data\Data\PassiveEphys\EEG animal data\'; %W: drive, where downsampled data lives

pars.windowLength = 4; %sec
pars.windowOverlap = 0.25; %fractional overlap

timeReInj = -1:3; %hardcoded PLEASE FIX
% the following prevents evoked stuff from being read in.
clear recForAnimal %19107 ZS
%if contains(animalName,'LFP') || contains(animalName,'DREADD')
% if ~isempty(strfind(animalName,'LFP')) ||
% ~isempty(strfind(animalName,'DREADD')) ZS 19107
recForAnimal = getExperimentsByAnimal(animalName,'Spon'); %grab only spon indices

%Set electrode location
electrodeInfo = getElectrodeLocationFromDateIndex(recForAnimal{1,1}(1:5),recForAnimal{1,1}(7:9));

%the following line is appealing for EEG & LFP animals b/c less hardcoding,
%but not DREADD or anything else with unique name. Reconsider.
ephysInfo.recMode = animalName(1:3); 

% !!! WARNING !!! this is hardcoded, assumes we're looking at EEG.  Channel descriptions will
% be in 'electrodeInfo' if we want to change this, add features, etc.
tempIndexer = 1;
for k = 1:length(electrodeInfo)
    if strfind(electrodeInfo{k},ephysInfo.recMode)
        ephysInfo.chanNums(tempIndexer) = k; %brain ephys channels
        ephysInfo.chanLabels{tempIndexer,1} = electrodeInfo{k}([5,7]); %Labels for EEG channels
        tempIndexer = tempIndexer+1;
    end
end
ephysInfo.EMGchan = [];
% timeReInj = -1:0.5:3.5; %commented out ZS 1/17/2019
% end

% 1. find unique dates.
descForAnimal = recForAnimal(:,2);
recForAnimal = recForAnimal(:,1);
dateList = unique(cellfun(@(recForAnimal){recForAnimal(1:5)},recForAnimal),'stable')';
% 2. step through each and verify drug info (global param)
% for i = 1:length(recForAnimal)
%     [nVals(i),parNames(i),parVals(i)] = getGlobalStimParams(recForAnimal{i}(1:5),recForAnimal{i}(7:9));
% end
% !WARNING! % if more than one drug was used, nVals will be 2 (or more)
% if sum(nVals(:))==0
%     error('No drug information has been entered for this animal!')
% end
% uniqueDrugs = unique(parNames,'stable');

for iDate=1:length(dateList)
    tempIndex = 1;
    pars.expt(iDate).exptDate = ['date' dateList{iDate}];
    pars.expt(iDate).dataPath = [defaultPath animalName filesep dateList{iDate} filesep];
    exptList = getExperimentsByAnimalAndDate(animalName,dateList{iDate});
    for j = 1:size(exptList,1)
        [nVals(j),parNames(j),parVals(j)] = getGlobalStimParams(exptList{j}(1:5),exptList{j}(7:9));
    end
    %!WARNING! % if more than one drug was used, nVals will be 2 (or more)
    if sum(nVals(:)) < size(exptList,1)
        error('Incomplete drug information has been entered for this animal!')
    end
    uniqueDrugs = unique(parNames,'stable');
    pars.expt(iDate).treatment = uniqueDrugs{:};
    pars.expt(iDate).dose = max(parVals(strcmp(parNames,uniqueDrugs))); %WARNING! Not ready for 2-drug experiments!! 19102
    pars.expt(iDate).timeReInj = timeReInj;
    for j = 1:length(recForAnimal)
        if strfind(recForAnimal{j}(1:5),dateList{iDate})
            pars.expt(iDate).exptIndex{tempIndex} = recForAnimal{j}(7:9);
            tempIndex = tempIndex+1;
        end
    end
    clear nVals parNames parVals uniqueDrugs
end

batchParams.(animalName) = fillBatchParams(pars,ephysInfo);
