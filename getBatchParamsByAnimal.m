function [batchParams] = getBatchParamsByAnimal(animalName)
% STUB/WIP: mouseDelirium_getBatchParamsByAnimal
% original method is a cumbersome nightmare.  All this info *should* be in
% database! Using this script, we can generate 'batchParams' programmatically.
% test info: animalName = 'EEG55'

% TODO! Streamline how getInjectionIndex and getTimeAndDurationFromIndex
% operate. Accessing the eNotebook repeatedly and loading the tank files
% slows things down. 

batchParams = struct;
defaultPath = '\\144.92.218.131\Data\Data\PassiveEphys\EEG animal data\'; %W: drive, where downsampled data lives

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
ephysInfo.EMGchan = []; % ignore EMG chans for now

% find unique dates.
recForAnimal = recForAnimal(:,1);
dateList = unique(cellfun(@(recForAnimal){recForAnimal(1:5)},recForAnimal),'stable')';

for iDate=1:length(dateList)
    thisDate = dateList{iDate};
    tempIndex = 1;
    pars.expt(iDate).exptDate = ['date' thisDate];
    pars.expt(iDate).dataPath = [defaultPath animalName filesep thisDate filesep];
    exptList = getExperimentsByAnimalAndDate(animalName,thisDate);
    
    % Search globalstimparams for this date and index. In most cases this will be the drug treatment name and dose 
    try
        for jj = 1:size(exptList,1)
            [nVals(jj,:),parNames(jj,:),parVals(jj,:)] = getGlobalStimParams(exptList{jj}(1:5),exptList{jj}(7:9));
        end
    catch
        %!WARNING! % if more than one drug was used, nVals will be 2 (or more)
        if sum(nVals(:)) < size(exptList,1)
            warning(['Incomplete drug information has been entered for ' animalName ' ' thisDate])
            nVals = nan;
            parNames = '';
            parVals = nan;
        end
    end
    
    % set drug treatment and dose information
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
        
    % set timeReInj based on number of pre-injection periods
    
    % NOTE: we are increasingly moving away from this method of calculating
    % timeReInj, as this assumes each index represents an hour of data
    descsThisDate = [exptList{:,2}];
    nPreInj = sum(cellfun(@(c)contains(c,'Pre'),descsThisDate)); %count number of pre-injection periods
    
    timeReInj = (1:size(exptList,1))-(nPreInj+1);
    pars.expt(iDate).timeReInj = timeReInj; 
    pars.expt(iDate).exptIndex = unique(cellfun(@(x) x(7:9), exptList(:,1), 'UniformOutput',false),'stable');
    
    try
        % determine which indices occurred directly after injection period
        pars.expt(iDate).indexPostInj = getInjectionIndex(animalName,thisDate);
        
        % loop thru each index, get duration and time of day
        indexDur = cell(length(exptList),1); timeOfDay = cell(length(exptList),1);
        for iIndex = 1:length(pars.expt(iDate).exptIndex)
            thisIndex = pars.expt(iDate).exptIndex{iIndex};
            [indexDur{iIndex},timeOfDay{iIndex}] = getTimeAndDurationFromIndex(thisDate,thisIndex);
        end
        pars.expt(iDate).indexDur = indexDur; % duration of index
        pars.expt(iDate).timeOfDay = timeOfDay; % time of day index began
        
    catch 
        warning(['injection and/or time of day info not entered for date' thisDate]);
    end

    clear nVals parNames parVals uniqueDrugs indexDur timeOfDay
end

batchParams.(animalName) = fillBatchParams(pars,ephysInfo);
end
