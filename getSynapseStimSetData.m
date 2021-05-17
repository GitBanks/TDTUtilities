function [stimSet,dTRec,stimArray] = getSynapseStimSetData(exptDate,exptIndex,tPreStim,tPostStim)

dataType = 'LFP1';

% load saved trial pattern
saveFileRoot = ['W:\Data\PassiveEphys\20' exptDate(1:2) '\' exptDate '-' exptIndex '\'];
load([saveFileRoot  'stimSet-' exptDate '-' exptIndex],'stimArray','trialPattern');
nStims = length(stimArray);

data = TDTbin2mat(saveFileRoot); % TDT loads the raw data
% TODO! % % % % % % % % % % %  4/27/21 note: above is the first choice we need to make - do we really
% want to load in raw data here, or depend on the imported data?

% the 'Snc_' is the new (as of 4/27/21) method of finding stim times.  We still
% want the old method in case we need to look at older data ('else' section)
% if isfield(data.epocs,'stim') % this is the stim presentation info, we are getting this from the epocs
%      streamName = 'stim';
% end
if isfield(data.epocs,'Snc_') % this is the stim presentation info, we are getting this from the epocs
    streamName = 'Snc_'; % this is the synchronization in to the RZ5 - better than 'stim out' time
    stimTimes = data.epocs.(streamName).onset;
else
    % one of the following will be true (otherwise error out)
    if isfield(data.streams,'eS1r')
        streamName = 'eS1r';
    end
    if isfield(data.streams,'eSmr')
        streamName = 'eSmr';
    end
    triggerPulses = data.streams.(streamName).data > 0;
    if ~exist('triggerPulses','var')
        error('problem finding stream or loading data');
    end
    % % % % %  4/27/21 note: below, here, we're still using the old way to get
    % the stim times. 
    % This should find all the pulse times according to Synapse
    tStimArray = [];
    triggerIterator = 1;
    while triggerIterator < length(triggerPulses)
        if triggerPulses(triggerIterator) == true
            tStimArray = [tStimArray triggerIterator];
            triggerIterator = triggerIterator+(5*round(data.streams.(streamName).fs));
           % triggerIterator = triggerIterator+(5*round(data.streams.(streamName).fs));
        end
        triggerIterator = triggerIterator+1;
    end
    dTStim = 1/data.streams.(streamName).fs;
    %dTStim = 1/data.streams.(streamName).fs;
    timeArrayStim = (0:dTStim:length(data.streams.(streamName).data)*dTStim-dTStim);
    %timeArrayStim = (0:dTStim:length(data.streams.(streamName).data)*dTStim-dTStim);
    % % show detected stim times
    % figure();
    % plot(timeArrayStim,data.streams.eS1r.data)
    % hold on
    % plot(timeArrayStim(uniqueTTL),zeros(length(uniqueTTL),1),'*')
    stimTimes = timeArrayStim(tStimArray);
end

% data are stored like this:
% data.streams.LFP1.data(4,:)
% data.streams.EEGw.data(4,:)
% 1. step through rec types (data.streams.LFP1,data.streams.EEGw)
dTRec = 1/data.streams.(dataType).fs; % get sample rate and recording times
timeArrayRec = (0:length(data.streams.(dataType).data)-1)*dTRec;
nChans = size(data.streams.(dataType).data,1);
nROIs = floor(nChans/2); %Assuming twisted pair and local bipolar rereferencing
nTrials = length(stimTimes); % we want to know how long the expected stim pattern lasts in case erroneous pulses (at end) are found.
stimIndex = round(stimTimes/dTRec);
% stimIndex = zeros(1,nTrials);
% for iTrial = 1:nTrials
%     stimIndex(iTrial) = find(timeArrayRec>stimTimes(iTrial),1,'first');
% end
preStimIndex = floor(tPreStim/dTRec);
postStimIndex = ceil(tPostStim/dTRec);

if nTrials ~= length(trialPattern)
    disp(['WARNING! Number of trials in Synapse data file = ' num2str(nTrials)...
        ' but length of trialPattern = ' num2str(length(trialPattern))]);
    if nTrials<length(trialPattern)
        disp('Truncating trialPattern to match nTrials...')
        trialPattern = trialPattern(1:nTrials);
    else
        disp('Padding trialPattern to match nTrials...')
        temp(1:length(trialPattern)-nTrials) = trialPattern(end);
        temp = [trialPattern temp];
    end
end

% Create the structure: stimSet, with different arrays of channels x trials x dataPoints
stimSet = struct();
for iStim = 1:nStims %Loop over all stim levels. These are indexed as integers 1:nStim
    % First grab all trials on which this stim was presented
    trialLgcl = trialPattern==iStim; % = true only when trialPattern is this stim
    theseStim = stimIndex(trialLgcl);
    for iTrial = 1:length(theseStim)
        iStart = theseStim(iTrial)-preStimIndex;
        iStop = theseStim(iTrial)+postStimIndex;
        for iChan = 1:nChans
            stimSet(iStim).data(iChan,iTrial,:) = ...
                data.streams.(dataType).data(iChan,iStart:iStop);
        end
    end
    for iSub = 1:nROIs
        stimSet(iStim).sub(iSub,:,:) = stimSet(iStim).data(iSub*2,:,:) - stimSet(iStim).data(iSub*2-1,:,:);
    end
end

for iStim = 1:nStims
    stimSet(iStim).dataMean = squeeze(mean(stimSet(iStim).data,2));
    stimSet(iStim).subMean = squeeze(mean(stimSet(iStim).sub,2));
end
