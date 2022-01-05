function [stimSet,dTRec] = getPlasticityData(exptDate,exptIndex,tPreStim,tPostStim)
%  exptDate = '21428';
%  exptIndex = '015';

% load saved trial pattern
saveFileRoot = [getPathGlobal('W') 'PassiveEphys\20' exptDate(1:2) '\' exptDate '-' exptIndex '\'];
%load([saveFileRoot  'stimSet-' exptDate '-' exptIndex],'stimArray','trialPattern');
%ampLabel = stimArray;

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
iType = 'LFP1';
nChans = size(data.streams.LFP1.data,1);
dTRec = 1/data.streams.(iType).fs; % get sample rate and recording times
timeArrayRec = (0:dTRec:length(data.streams.(iType).data)*dTRec-dTRec);


% Take channel averages
stimSet = struct();
if ~exist('trialPattern','var')
    trialPattern = ones(1,length(stimTimes));
end
nStims = length(trialPattern); % we want to know how long the expected stim pattern lasts in case erroneous pulses (at end) are found.
%create the structure: stimSet, with different arrays of channels x trials x dataPoints
for iStim = 1:length(nStims)
    for iChannel = 1:size(data.streams.(iType).data,1)
        trialIterator = 1;
        for iTrial = 1:length(stimTimes)-1
            % look to be sure it's the correct stim type according to the trialPattern       
            % !!...test this..!!          
            if isequal(iStim,trialPattern(iTrial))
                thisStim = find(timeArrayRec>stimTimes(iTrial),1);
                %trialsInSpan(iTrial) = find(spansT>thisStim,1);
                stimSet(iStim).data(iChannel,trialIterator,:) = data.streams.(iType).data(iChannel,thisStim-round(tPreStim*data.streams.(iType).fs):round(tPostStim*data.streams.(iType).fs)+thisStim);
                if mod(iChannel,2)==0
                    stimSet(iStim).sub(iChannel/2,trialIterator,:) = stimSet(iStim).data(iChannel,trialIterator,:) - stimSet(iStim).data(iChannel-1,trialIterator,:);
                end
                trialIterator = trialIterator +1;
            end
        end
    end
end

%find the mean for both the raw data and the subtraction
for iSet = 1:length(stimSet)
    stimSet(iSet).dataMean = squeeze(mean(stimSet(iSet).data,2));
    stimSet(iSet).subMean = squeeze(mean(stimSet(iSet).sub,2));
end
