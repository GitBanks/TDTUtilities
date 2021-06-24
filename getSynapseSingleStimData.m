function [evData,dTRec] = getSynapseSingleStimData(exptDate,tankIndex,tPreStim,tPostStim,isTank)
%Returns stimulus-related data from TDT software organized according to
%channel and snipped into segments of length tPreStim_tPostStim


% the only difference in data analysis is if we should grab the first or second LFP set
if isTank
    dataType = 'LFP1';
else
    dataType = 'LFP2';
end


% load saved trial pattern
dataPath = ['W:\Data\PassiveEphys\20' exptDate(1:2) '\' exptDate '-' tankIndex '\'];
% load([saveFileRoot  'stimSet-' exptDate '-' exptIndex],'stimArray','trialPattern');
% nStims = length(stimArray);

data = TDTbin2mat(dataPath); % load the raw data
% TODO! % % % % % % % % % % %  4/27/21 note: above is the first choice we need to make - do we really
% want to load in raw data here, or depend on the imported data?

% the 'Snc_' is the new (as of 4/27/21) method of finding stim times.  We still
% want the old method in case we need to look at older data ('else' section)
% if isfield(data.epocs,'stim') % this is the stim presentation info, we are getting this from the epocs
%      streamName = 'stim';
% end
if isfield(data.epocs,'Snc_') % this is the stim presentation info, we are getting this from the epocs
    streamName = 'Snc_'; % this is the synchronization into the RZ5 - better than 'stim out' time
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
nChans = size(data.streams.(dataType).data,1);
nROIs = floor(nChans/2); %Assuming twisted pair and local bipolar rereferencing
nTrials = length(stimTimes); % we want to know how long the expected stim pattern lasts in case erroneous pulses (at end) are found.
stimIndex = round(stimTimes/dTRec);
preStimIndex = floor(tPreStim/dTRec);
postStimIndex = ceil(tPostStim/dTRec);

% Create the structure: evData, with different arrays of channels x trials x dataPoints
evData = struct();
for iTrial = 1:nTrials
    iStart = stimIndex(iTrial)-preStimIndex;
    iStop = stimIndex(iTrial)+postStimIndex;
    for iChan = 1:nChans
        evData.data(iChan,iTrial,:) = data.streams.(dataType).data(iChan,iStart:iStop);
    end
end
for iSub = 1:nROIs
    evData.sub(iSub,:,:) = evData.data(iSub*2,:,:) - evData.data(iSub*2-1,:,:);
end

evData.dataMean = squeeze(mean(evData.data,2));
evData.subMean = squeeze(mean(evData.sub,2));
evData.info = data.info;
evData.stimTimes = stimTimes;
