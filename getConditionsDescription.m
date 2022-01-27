function [conditionsDescription,electrodeType,drugDesc,timeInj,exptType] = getConditionsDescription(exptDate,exptIndex)


% given a date and an index, get the treatment info and description, and
% come up with a consistant, cogent, *standard* way of describing
% experiment

% some things we want to distinguish:
% EEG/LFP
% drug manipulation
% stimulation vs spontaneous
% for future: headfixed, or any other wacky conditions we can think of???

% test params
% exptDate = '22120'
% exptIndex = '005'

conditionsDescription = '';

% 1. step through the list  above
% 1a. EEG vs LFP vs whatever
animalName = getAnimalByDateIndex(exptDate,exptIndex);
if contains(animalName,'ZZ')
    electrodeType = 'LFP';
elseif contains(animalName,'EEG')
    electrodeType = 'EEG';
elseif contains(animalName,'Mag')
    electrodeType = 'MAG';
else
    electrodeType = '';
end
conditionsDescription = electrodeType;

% 1b. drug manipulation
[~,parNames,~] = getGlobalStimParams(exptDate,exptIndex);
if isempty(parNames)
    drugDesc = 'NoDrug';
    conditionsDescription = [conditionsDescription '.' drugDesc];
else
	for i = 1:size(parNames,1)
        drugDesc = parNames{i,1};
        if contains(drugDesc,'Anlg_')
            drugDesc = erase(drugDesc,'Anlg_');
        end
        if contains(drugDesc,'_conc')
            drugDesc = erase(drugDesc,'_conc');
        end
        if contains(drugDesc,'_vol')
            drugDesc = erase(drugDesc,'_vol');
        end
        if contains(drugDesc,'0p9')
            drugDesc = erase(drugDesc,'0p9');
        end
        if contains(drugDesc,'_')
            drugDesc = strrep(drugDesc,'_','-');
        end
        conditionsDescription = [conditionsDescription '.' drugDesc];
    end
end

% 1c. preinj vs post inj
dbConn = dbConnect();
[exptID] = getIDfromDateIndex( exptDate, exptIndex );
desc = fetchAdjust(dbConn,['SELECT notebookDesc FROM masterexpt WHERE exptID =''' num2str(exptID) '''']);
close(dbConn);

timeInj = '';
if contains(desc,'pre')
    timeInj = 'PreInj';
end
if contains(desc,'Pre-Inj')
    timeInj = 'PreInj';
end
if contains(desc,'Post-Inj')
    timeInj = 'PostInj';
end
if contains(desc,'post injection')
    timeInj = 'PostInj';
end
if contains(drugDesc,'NoDrug')
    timeInj = '';
end
    
conditionsDescription = [conditionsDescription '.' timeInj];

% 1d. stimulation vs spontaneous
exptType = '';

if contains(desc,'stim/resp')
    exptType = 'StimResp';
else
    if contains(desc,'stim')
        exptType = 'Stim';
    end
    if contains(desc,'Stim')
        exptType = 'Stim';
    end
end
if contains(desc,'spon -')
    exptType = 'Spon';
end
if contains(desc,'Spon -')
    exptType = 'Spon';
end
conditionsDescription = [conditionsDescription '.' exptType];




% 3. return description








