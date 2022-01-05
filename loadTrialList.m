function tempEphysTrialTime = loadTrialList(ephysDirName)
% DESCRIPTION: loads trial info files and concatenates them if necessary to create
% cohesive list of trial times. -ZS 4/10/2019

% EXAMPLE: 
% ephysFileName = '\\MEMORY BANKS\Data\PassiveEphys\\2018\18410-000\';

trialInfoFiles = dir([ephysDirName '*trial*']);
tempEphysTrialTime = [];
for i = 1:length(trialInfoFiles)
    load([ephysDirName filesep trialInfoFiles(i).name]);
    if i == 1
        tempEphysTrialTime(1,1:length(trialList)) = cat(2,trialList.trialTime);
    else
        tempEphysTrialTime = cat(2,tempEphysTrialTime,trialList.trialTime);
    end
end