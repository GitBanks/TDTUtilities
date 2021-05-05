function Experiment = synapseExptBlockSetup(animalName,experimentDrugManipulation,nHoursPre,nHoursPost)
% given an experiment type e.g., alternating 'flash sequence' and 
% 'spontaneous' create the experimental plan for the day. For now, it's set
% to create alternating indices.
% TODO: pull experimental plans from the database? for now, create them here
% nHoursPre = 1; % refers to number of hours pre time zero manipulation
% nHoursPost = 4;
% forceStimPresentation = false; % rule: alternate between stim and spon
% animalName = 'EEG70';
% animalName = 'LFP18';
% experimentDrugManipulation = 'LPS'; 
% experimentDrugManipulation = 'ISO'; 
% animalName = 'ZZ05';
% experimentDrugManipulation = 'ctrl'; 

% %% !!! WARNING !!! %%
% updated 3/12/2019 to use nHoursPre and nHoursPost to generate
% indexDescriptionSequence. Vision below is still a goal. 

% as of 10/4/18 nHoursPre and nHoursPost don't do anything.  This whole
% process needs a rewrite.  Consider using a table lookup for each paradigm
% . In this state, it works for a limited set of experiments (described
% below), but is extremely inflexible.

if ~contains(animalName,'ZZ')
    error('synapseExptBlockSetup is only set to handle LTP / LTD protocols');
end


indexDescriptionRECtype = {'Spon'};
indexTrialPerStimSequence = 1;
indexStimCountSequence = -1;
exptStepsPerHour = 1;

nIndexStepsPerHour = size(indexDescriptionRECtype,1)*exptStepsPerHour;
nIndexSteps = nIndexStepsPerHour*(nHoursPre+nHoursPost);
for iStep = 1:nIndexSteps
    Experiment.nTrialsIndexArray(iStep) = indexTrialPerStimSequence(rem(iStep,length(indexDescriptionRECtype))+1);
    Experiment.nStimsIndexArray(iStep) = indexStimCountSequence(rem(iStep,length(indexDescriptionRECtype))+1);
end
Experiment.exptDescriptionText = {
    [experimentDrugManipulation ' Baseline / spon - pre manipulation' ]
    [experimentDrugManipulation ' Baseline / stim - pre LTP/LTD' ]
    [experimentDrugManipulation ' LTP / stim ' ]
    [experimentDrugManipulation ' Post LTP / stim ' ]
    [experimentDrugManipulation ' LTD / stim ' ]
    [experimentDrugManipulation ' Post LTD / stim ' ]
    [experimentDrugManipulation ' Post LTD / stim ' ]
    [experimentDrugManipulation ' Baseline / spon - post injection 1' ]
    [experimentDrugManipulation ' Baseline / spon - post injection 2' ]
    [experimentDrugManipulation ' Baseline / spon - post injection 3' ]
    [experimentDrugManipulation ' Baseline / spon - post injection 4' ]
};

end
