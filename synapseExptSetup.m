function Experiment = synapseExptSetup(animalName,experimentDrugManipulation,nHoursPre,nHoursPost,forceStimPresentation)
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

% %% !!! WARNING !!! %%
% as of 10/4/18 nHoursPre and nHoursPost don't do anything.  This whole
% process needs a rewrite.  Consider using a table lookup for each paradigm
% . In this state, it works for a limited set of experiments (described
% below), but is extremely inflexible.

if nargin < 5
    forceStimPresentation = 0;
end

if isempty(strfind(animalName,'LFP')) && isempty(strfind(animalName,'DREADD')) && isempty(strfind(animalName,'EEG'))
    error('We''re only set to handle LFP, EEG, and DREADD animals so far');
end
useStims = false;
if forceStimPresentation == true && ~isempty(strfind(animalName,'EEG'))
    useStims = true;
end
usesIso = false;
if ~isempty(strfind(experimentDrugManipulation,'ISO'))
    usesIso = true;
end

if ~usesIso || (useStims && ~usesIso)
    indexSubdivisions = {'a','b','c','d'};
    indexDescriptionSequence = {
    'Pre-Inj'
    'Post-Inj'
    'Post-Inj'
    'Post-Inj'
    'Post-Inj'
    };
    indexDescriptionRECtype = {
    'Spon'
    'Stim'
    };
    indexTrialPerStimSequence = [
    1
    100
    ];
    indexStimCountSequence = [
    -1 % for no stim
    5
    ];
    exptStepsPerHour = 2;  
end

if ~isempty(strfind(animalName,'EEG')) && ~useStims
    indexDescriptionRECtype = {'Spon'};
    indexTrialPerStimSequence = 1;
    indexStimCountSequence = -1;
    exptStepsPerHour = 1;
end

if ~usesIso
    nIndexStepsPerHour = size(indexDescriptionRECtype,1)*exptStepsPerHour;
    nIndexSteps = nIndexStepsPerHour*(nHoursPre+nHoursPost);
    for iStep = 1:nIndexSteps
        Experiment.exptDescriptionText{iStep} = [experimentDrugManipulation ' '...
        indexDescriptionSequence{ceil(iStep/nIndexStepsPerHour)} ' '];
        Experiment.exptDescriptionText{iStep} = [Experiment.exptDescriptionText{iStep}...
        num2str(ceil(iStep/nIndexStepsPerHour))...
        indexSubdivisions{rem(iStep-1,nIndexStepsPerHour)+1} ' '...
        indexDescriptionRECtype{rem(iStep,length(indexDescriptionRECtype))+1} ' '...        
        '[' experimentDrugManipulation ' paradigm]'...
        ];
        Experiment.nTrialsIndexArray(iStep) = indexTrialPerStimSequence(rem(iStep,length(indexDescriptionRECtype))+1);
        Experiment.nStimsIndexArray(iStep) = indexStimCountSequence(rem(iStep,length(indexDescriptionRECtype))+1);
    end
    Experiment.exptDescriptionText = Experiment.exptDescriptionText';
end

if usesIso || (useStims && usesIso) % we should move towards this sort of setup, or better, a table for each paradigm
    Experiment.nStimsIndexArray = [5 5 -1 5 -1 -1 5 -1 -1 5 -1 -1 5 5 5 -1 5 -1 -1 -1 -1 -1 -1];
    Experiment.nTrialsIndexArray = [100 100 1 100 1 1 100 1 1 100 1 1 100 100 100 1 100 1 1 1 1 1 1];
    Experiment.exptDescriptionText = {
    [experimentDrugManipulation ' Ctrl Stim 1 [' experimentDrugManipulation ' paradigm]' ]
    [experimentDrugManipulation ' Ctrl Stim 2 [' experimentDrugManipulation ' paradigm]' ]
    [experimentDrugManipulation ' Ctrl Spon [' experimentDrugManipulation ' paradigm]' ]
    [experimentDrugManipulation ' Ctrl Stim 3 [' experimentDrugManipulation ' paradigm]' ]
    [experimentDrugManipulation ' Subhypnotic Equilibration [' experimentDrugManipulation ' paradigm]' ]
    [experimentDrugManipulation ' Subhypnotic Spon [' experimentDrugManipulation ' paradigm]' ]
    [experimentDrugManipulation ' Subhypnotic Stim [' experimentDrugManipulation ' paradigm]' ]
    [experimentDrugManipulation ' Hypnotic Equilibration [' experimentDrugManipulation ' paradigm]' ]
    [experimentDrugManipulation ' Hypnotic Spon [' experimentDrugManipulation ' paradigm]' ]
    [experimentDrugManipulation ' Hypnotic Stim [' experimentDrugManipulation ' paradigm]' ]
    [experimentDrugManipulation ' Subhypnotic Rev Equilibration [' experimentDrugManipulation ' paradigm]' ]
    [experimentDrugManipulation ' Subhypnotic Rev Spon [' experimentDrugManipulation ' paradigm]' ]
    [experimentDrugManipulation ' Subhypnotic Rev Stim [' experimentDrugManipulation ' paradigm]' ]
    [experimentDrugManipulation ' Recovery Stim 1 [' experimentDrugManipulation ' paradigm]' ]
    [experimentDrugManipulation ' Recovery Stim 2 [' experimentDrugManipulation ' paradigm]' ]
    [experimentDrugManipulation ' Recovery Spon [' experimentDrugManipulation ' paradigm]' ]
    [experimentDrugManipulation ' Recovery Stim 3 [' experimentDrugManipulation ' paradigm]' ]
    [experimentDrugManipulation ' placeholder - extra Equilibration [' experimentDrugManipulation ' paradigm]' ]
    [experimentDrugManipulation ' placeholder - extra Equilibration [' experimentDrugManipulation ' paradigm]' ]
    [experimentDrugManipulation ' placeholder - extra Equilibration [' experimentDrugManipulation ' paradigm]' ]
    [experimentDrugManipulation ' placeholder - extra Equilibration [' experimentDrugManipulation ' paradigm]' ]
    [experimentDrugManipulation ' placeholder - extra Equilibration [' experimentDrugManipulation ' paradigm]' ]
    [experimentDrugManipulation ' placeholder - extra Equilibration [' experimentDrugManipulation ' paradigm]' ]
    };
end

end
