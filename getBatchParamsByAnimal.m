function [batchParams] = getBatchParamsByAnimal(animalName)
% Using this script, we can generate 'batchParams' programmatically by accessing database.
% test info: animalName = 'EEG55'

batchParams = struct;
defaultPath = '\\144.92.237.185\Data\PassiveEphys\'; % changed 3/9/2021 %'\\144.92.218.131\Data\Data\PassiveEphys\EEG animal data\'; % W: drive, where downsampled data lives
exptList = getExperimentsByAnimal(animalName,'Spon'); %grab only spon indices

if isempty(exptList{1})
    exptList = getExperimentsByAnimal(animalName); %rerun above line without the 'Spon' query
end

% Set electrode location
electrodeInfo = getElectrodeLocationFromDateIndex(exptList{1,1}(1:5),exptList{1,1}(7:9));

% get recMode from electrode locations
empties = cellfun(@isempty, electrodeInfo(:,1), 'UniformOutput',true); % get elements that are empty
electrodeInfo(empties | contains(electrodeInfo(:,1),'Occ')) = []; % remove empty entries and occipital ref
ephysInfo.recMode = unique(cellfun(@(x) x(1:3), electrodeInfo(:,1), 'UniformOutput',false),'stable'); % get unique types of recording mode

% Channel descriptions are in 'electrodeInfo' if we want to change this, add features, etc.
tempIndexer = 1;
for ii = 1:length(electrodeInfo)
    if contains(electrodeInfo{ii},'EEG')
        ephysInfo.chanNums(tempIndexer) = ii; % brain ephys channels
        ephysInfo.chanLabels{tempIndexer,1} = electrodeInfo{ii}([5,7]); %Labels for EEG channels
        tempIndexer = tempIndexer+1;
    else
        ephysInfo.chanNums(tempIndexer) = ii; %brain ephys channels
        ephysInfo.chanLabels{tempIndexer,1} = electrodeInfo{ii}; %Labels for other channels
        tempIndexer = tempIndexer+1;
    end
end
ephysInfo.EMGchan = []; % ignore EMG chans for now

% get list of dates
dateList = unique(cellfun(@(recForAnimal){recForAnimal(1:5)},exptList(:,1)),'stable')';

for iDate = 1:length(dateList)
    thisDate = dateList{iDate};
    
    exptsThisDate = exptList(contains(exptList(:,1),thisDate),:); % filter only the experiments this date
    indices = unique(cellfun(@(x) x(7:9), exptsThisDate(:,1), 'UniformOutput',false),'stable'); % get list of 3-digit indices
    
    pars.expt(iDate).exptDate = ['date' thisDate];
    pars.expt(iDate).dataPath = [defaultPath '20' thisDate(1:2) filesep thisDate]; % edited 3/9/2021
    pars.expt(iDate).exptIndex = indices;
    
    % Search globalstimparams for this date and index. In most cases this will be the drug treatment name and dose 
    try
        nIndx = size(indices,1);
        for jj = 1:nIndx
            [nVals(jj,:),parNames(jj,:),parVals(jj,:)] = getGlobalStimParams(exptsThisDate{jj}(1:5),exptsThisDate{jj}(7:9));
        end
    catch
        % !WARNING! % if more than one drug was used, nVals will be 2 (or more)
        if sum(nVals(:)) < nIndx
            warning(['Incomplete drug information has been entered for ' animalName ' ' thisDate])
        end
    end
    
    if exist('parVals','var')
        % set drug treatment and dose information
        isDiff = false(size(parVals)); % logical array for whether next element differs from subsequent element
        
        if size(parNames) > 1
            for ii = 1:size(parNames,2)
                pars.expt(iDate).treatment(ii) = unique(parNames(:,ii));
                pars.expt(iDate).dose{ii} = max(parVals(:,ii));
                
                % determine which indices occurred directly after injection period
                % look through parVals and see when dose changed -> this
                % indicates that an injection occurred just before this index
                for jj = 2:size(parVals,1) % loop through number of indices
                    isDiff(jj,ii) = parVals(jj,ii) ~= parVals(jj-1,ii);
                end
                if sum(isDiff(:,1))~=0
                    pars.expt(iDate).indexPostInj(ii) = indices(isDiff(:,ii)); % index post injection
                else
                    % if no injection...
                    pars.expt(iDate).indexPostInj(ii) = {''};
                    warning('detected treatment info but no change in drug dose was detected');
                end
            end
        else
            % fill with dummy variables if no treatment info entered
            pars.expt(iDate).treatment = '';
            pars.expt(iDate).dose = nan;
        end
    else
        warning(['parVals not found ' animalName ' ' thisDate]);
    end
        
    % set timeReInj based on number of pre-injection periods
    % NOTE: we are increasingly moving away from this method of calculating
    % timeReInj, as this assumes each index represents an hour of data
    descsThisDate = [exptsThisDate{:,2}];
    nPreInj = sum(cellfun(@(c)contains(c,'Pre'),descsThisDate)); %count number of pre-injection periods
    
    timeReInj = (1:nIndx)-(nPreInj+1);
    pars.expt(iDate).timeReInj = timeReInj; 
    
    try        
        % loop thru each index, get duration and time of day
        indexDur = cell(nIndx,1); timeOfDay = cell(nIndx,1);
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
