function Experiment = synapseExptSetup(animalName,experimentDrugManipulation,nHoursPre,nHoursPost,forceStimPresentation)


%setup Synapse experiment

% given an experiment type 
% e.g., alternating 'flash sequence' and 'spontaneous'
% create the experimental plan for the day.  
% DECIDE!! Should this be recorded as discrete indices or the whole day,
% continuously?
% for now, let's set it up the way we expect alternating indices.
% TODO: pull experimental plans from the database?
% for now, create them here?
% creating lists of them, do we prefer a structure?


% nHoursPre = 1; % refers to number of hours pre time zero manipulation
% nHoursPost = 4;
% forceStimPresentation = false; % rule: alternate between stim and spon
% animalName = 'EEG70';
% animalName = 'LFP70';
% experimentDrugManipulation = 'LPS'; %make this a selection?


% experimentDrugManipulation = {
%     'Saline'
%     'LPS'
%     'Iso'
%     };

if nargin < 5
    forceStimPresentation = 0;
end

indexSubdivisions = {'a','b','c','d'};
indexDescriptionSequence = {
    'Pre-Inj'
    'Post-Inj'
    };


%TODO are these rules certain?
if ~isempty(strfind(animalName,'LFP')) || ~isempty(strfind(animalName,'DREADD')) || forceStimPresentation
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
elseif strfind(animalName,'EEG')
    indexDescriptionRECtype = {'Spon'};
    indexTrialPerStimSequence = 1;
    indexStimCountSequence = -1;
    exptStepsPerHour = 1;
else
    error('We''re only set to handle LFP and EEG animals so far');
end


nIndexStepsPerHour = size(indexDescriptionRECtype,1)*exptStepsPerHour;
nIndexSteps = nIndexStepsPerHour*(nHoursPre+nHoursPost);


for iStep = 1:nIndexSteps
    if iStep <= nIndexStepsPerHour
        Experiment.exptDescriptionText{iStep} = [experimentDrugManipulation ' '...
        indexDescriptionSequence{1} ' '];
    end
    if iStep > nIndexStepsPerHour
        Experiment.exptDescriptionText{iStep} = [experimentDrugManipulation ' '...
        indexDescriptionSequence{2} ' '];
    end
    Experiment.exptDescriptionText{iStep} = [Experiment.exptDescriptionText{iStep}...
    num2str(ceil(iStep/nIndexStepsPerHour))...
    indexSubdivisions{rem(iStep-1,nIndexStepsPerHour)+1} ' '...
    indexDescriptionRECtype{rem(iStep,length(indexDescriptionRECtype))+1} ' '...        
    '[' experimentDrugManipulation ' paradigm]'...
    ];
    Experiment.nTrialsIndexArray(iStep) = indexTrialPerStimSequence(rem(iStep,length(indexDescriptionRECtype))+1);
    Experiment.nStimsIndexArray(iStep) = indexStimCountSequence(rem(iStep,length(indexDescriptionRECtype))+1);
    Experiment.exptDescriptionText = Experiment.exptDescriptionText';
end










end
