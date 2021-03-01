function [batchParams] = getBatchParamsByAnimal(animalName)
% STUB/WIP: mouseDelirium_getBatchParamsByAnimal
% original method is a cumbersome nightmare.  All this info *should* be in
% database! Using this script, we can call 'batchParams' as desired.
% test info: animalName = 'EEG55'

% !!WARNING!! % the only question remaining is 'timeReInj', which may
% change if an index is skipped.  We can fix this later by creating a
% master table of experiments in the database.

batchParams = struct;
% disp(['Data will be saved to `' outPath '`']);
defaultPath = '\\144.92.218.131\Data\Data\PassiveEphys\EEG animal data\'; %W: drive, where downsampled data lives

% the following prevents evoked stuff from being read in.

%if contains(animalName,'LFP') || contains(animalName,'DREADD')
% if ~isempty(strfind(animalName,'LFP')) ||
% ~isempty(strfind(animalName,'DREADD')) ZS 19107
recForAnimal = getExperimentsByAnimal(animalName,'Spon'); %grab only spon indices

if isempty(recForAnimal{1})
    recForAnimal = getExperimentsByAnimal(animalName); %rerun above line without the 'Spon' query
end

%Set electrode location
electrodeInfo = getElectrodeLocationFromDateIndex(recForAnimal{1,1}(1:5),recForAnimal{1,1}(7:9));

%the following line is appealing for EEG & LFP animals b/c less hardcoding,
%but not DREADD or anything else with unique name. Reconsider.
ephysInfo.recMode = animalName(1:3); 
tempEphysTypes = {'EEG','LFP'};
if strcmp(ephysInfo.recMode,'LFP')
   ephysInfo.recMode = {'EEG','LFP'}; %just hardcoding for now... EEK!! 
end

% !!! WARNING !!! this is hardcoded, assumes we're looking at EEG.  Channel descriptions will
% be in 'electrodeInfo' if we want to change this, add features, etc.
tempIndexer = 1;
for k = 1:length(electrodeInfo)
    if contains(electrodeInfo{k},tempEphysTypes)
        ephysInfo.chanNums(tempIndexer) = k; %brain ephys channels
        ephysInfo.chanLabels{tempIndexer,1} = electrodeInfo{k}([5,7]); %Labels for EEG channels
        tempIndexer = tempIndexer+1;
    end
end
ephysInfo.EMGchan = []; % set to ignore EMG chans for now

% find unique dates.
descForAnimal = recForAnimal(:,2);
recForAnimal = recForAnimal(:,1);
dateList = unique(cellfun(@(recForAnimal){recForAnimal(1:5)},recForAnimal),'stable')';

for iDate=1:length(dateList)
    thisDate = dateList{iDate};
    tempIndex = 1;
    pars.expt(iDate).exptDate = ['date' thisDate];
    pars.expt(iDate).dataPath = [defaultPath animalName filesep thisDate filesep];
    exptList = getExperimentsByAnimalAndDate(animalName,thisDate);
    %need to add fix for multiple drugs... 
    try
        for jj = 1:size(exptList,1)
            [nVals(jj,:),parNames(jj,:),parVals(jj,:)] = getGlobalStimParams(exptList{jj}(1:5),exptList{jj}(7:9));
        end
    catch
        %!WARNING! % if more than one drug was used, nVals will be 2 (or more)
        if sum(nVals(:)) < size(exptList,1)
            warning('Incomplete drug information has been entered for this animal!')
            nVals = nan;
            parNames = '';
            parVals = nan;
        end
    end
    
    if size(parNames) > 1
        for ii = 1:size(parNames,2)
            pars.expt(iDate).treatment(ii) = unique(parNames(:,ii));
            pars.expt(iDate).dose{ii} = max(parVals(:,ii));
        end
    else
        % fill with dummies if no treatment info entered
        pars.expt(iDate).treatment = '';
        pars.expt(iDate).dose = nan;
    end
    
    
    %set timeReInj based on number of experiments! WIP
    descsThisDate = [exptList{:,2}];
    nPreInj = sum(cellfun(@(c)contains(c,'Pre'),descsThisDate)); %count number of pre-injection periods
    timeReInj = (1:size(exptList,1))-(nPreInj+1);
    pars.expt(iDate).timeReInj = timeReInj;
       
    pars.expt(iDate).exptIndex = unique(cellfun(@(x) x(7:9), exptList(:,1), 'UniformOutput',false),'stable');
    
    try
        pars.expt(iDate).indexPostInj = getInjectionIndex(animalName,thisDate);
        
        % loop thru each index, get duration and time of day
        indexDur = cell(length(exptList),1); timeOfDay = cell(length(exptList),1);
        for iIndex = 1:length(pars.expt(iDate).exptIndex)
            thisIndex = pars.expt(iDate).exptIndex{iIndex};
            [indexDur{iIndex},timeOfDay{iIndex}] = getTimeAndDurationFromIndex(thisDate,thisIndex);
        end
        pars.expt(iDate).indexDur = indexDur;
        pars.expt(iDate).timeOfDay = timeOfDay;
    catch why
        warning(why.message);
        warning('i.e. injection and/or time of day info not entered into batchparams for this date');
    end

    clear nVals parNames parVals uniqueDrugs indexDur timeOfDay
end

batchParams.(animalName) = fillBatchParams(pars,ephysInfo);
end