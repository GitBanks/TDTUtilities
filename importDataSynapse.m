function importDataSynapse(exptDate,exptIndex)

%test only!  remove when done!
% exptDate = '18820';
% exptIndex = '001';

maxFileSize = 1.e9; %parameter eh?


% !!!TODO!!! don't hardcode any of this section
signalTypes = {'EEG','LFP'}; % !!!TODO!!! don't hardcode this 
% not great to hard code... add as parameter?
dirStrRawData = ['W:\Data\PassiveEphys\' '20' exptDate(1:2) '\' exptDate '-' exptIndex '\']; %input
dirStrAnalysis = ['M:\PassiveEphys\20' exptDate(1:2) '\' exptDate '-' exptIndex '\']; %output
preStim = 500; % delay in ms.  With Synapse, each epoch 'prestimulus' period is an arbitrary division between end of a stim and start of the next.
postStim = 500;
% !!TODO!! don't hardcode any of the above! establish as parameters, or a
% config file or something


% loading ephys data
display('Loading in raw data.  This sometimes takes a while.');
data = TDTbin2mat(dirStrRawData); % this step may take a while depending on how long the recording is.  We can limit the length if necessary,
display('Loading complete.');

% %not sure if necessary? cross verify with whether it found trials or spon
dbConn = dbConnect(); %handle this better?  close db at end?
exptID = getIDfromDateIndex(exptDate,exptIndex);
SQLdescription = fetch(dbConn,['SELECT notebookDesc FROM masterexpt WHERE exptID= ''' num2str(exptID) '''']);
close(dbConn);


% find which channels are EEG, LFP, etc. from database
% obviously, will only work if this has been entered (will be empty
% otherwise - add check?)
[channelMap] = getElectrodeLocationFromDateIndex(exptDate,exptIndex);

streamList = fields(data.streams);

% look to see if 'data.scalars' is populated.  If not, it's just a
% 'continuous' recording/stream, and array should be chan X samples
% if scalars has values in it, it's 'evoked' data and should be saved as
% chan X samples X trials
if ~isempty(data.scalars) %not empty, is evoked, so should save as chan X samples X trials
    stimName = fields(data.scalars); %there should not be any more than one stim... right?
    stimTimes = data.scalars.(stimName{1}).ts;
    % data.scalars.(stimName{1}).data %this contains stim info like n
    % pulses and inter pulse interval (or stim specific stuff).
    % !!!TODO!!! do we need this for trial0 stuff
    stimDur = (data.scalars.(stimName{1}).data(3,1)-1)*data.scalars.(stimName{1}).data(4,1);
    for iTrial = 1:length(stimTimes)
        trialList(iTrial).uniqueStimID = 1; % NOOOOOOOOOOOOOOO  find and sort!
        trialList(iTrial).dataFile = data.info.blockname;
        trialList(iTrial).origTrialNum = iTrial;
        trialList(iTrial).trialTime = stimTimes(iTrial);
        trialList(iTrial).gain(1:16) = 10000; % NOOOOOOOOOOOOOOO  find from database
        trialList(iTrial).offset(1:16) = 0;
    end
else %handle spontaneous/non-evoked recorded data
    stimTimes = data.streams.(streamList{1}).startTime; %first sample
    trialList(1).uniqueStimID = 15619; % NOOOOOOOOOOOOOOO  find and sort!
    trialList(1).dataFile = data.info.blockname;
    trialList(1).origTrialNum = 1;
    trialList(1).trialTime = stimTimes;
    trialList(1).gain(1:16) = 10000; % NOOOOOOOOOOOOOOO  find from database
    trialList(1).offset(1:16) = 0;
    stimDur = -1;
end
trialFileName = [dirStrAnalysis exptDate '-' exptIndex '_' 'trial0'];
if ~exist(dirStrAnalysis,'dir')
    mkdir(dirStrAnalysis)
end
save(trialFileName,'trialList');


% Warning! this approach assumes we're recording strictly with this latest
% paradigm: 8 channels of twisted electrodes, and 4 EEGs.  This greatly
% reduces data storage and computational overhead.  If we implement 16 
% channel electrodes (full sample rates) we need to finish the size limit
% calculator (and load accordingly)


% step through signalTypes and find which match streams
for iSignal = 1:length(signalTypes)
    for iList = 1:length(streamList)
        if ~isempty(strfind(streamList{iList},signalTypes{iSignal})) % only handle the streams we have written to
            tempdT = 1/data.streams.(streamList{iList}).fs;
            %timeseries
            tempTS = zeros(1,length(data.streams.(streamList{iList}).data));
            tempTS(1) = tempdT;
            for iTimes = 2:length(tempTS)
               tempTS(iTimes) = tempTS(iTimes-1)+tempdT;
            end
            nChans = size(data.streams.(streamList{iList}).data,1);
            if stimDur>0
                sampPreStim = ceil(preStim/tempdT/1000);
                sampStim = ceil(stimDur/tempdT/1000); 
                sampPostStim = ceil(postStim/tempdT/1000);
    %             sampTrialLength = sampPreStim+sampStim+sampPostStim;
                sampStimTime = find(tempTS>stimTimes(1),1);
                stimRange = sampStimTime-sampPreStim:sampStimTime+sampStim+sampPostStim;
    %             length(stimRange)-sampTrialLength
            else
                stimRange = 1:length(data.streams.(streamList{iList}).data);
            end
            ephysData = zeros(nChans,length(stimRange),length(stimTimes));
            justDataTrialSize_dec = (size(ephysData,2)*size(ephysData,1))+100; % length of each array single trial in bytes
            nTrialsPerFile = floor(2*maxFileSize/justDataTrialSize_dec/nChans);
            if nTrialsPerFile<length(stimTimes); display('warning! size of ephysData larger than reccommended!'); end; % !!!TODO!!! check size before load, then load as appropriate.
            for iStim = 1:length(stimTimes)
                ephysData(:,:,iStim) = data.streams.(streamList{iList}).data(:,stimRange);
            end
            dT = tempdT;
            if strcmp(signalTypes{iSignal},'EEG') % 0 is hard coded because EEG data will be small, or should otherwise taken from the data.stream on it's own
                dataFileName = [dirStrAnalysis exptDate '-' exptIndex '_' signalTypes{iSignal} 'data0'];
            end
            if strcmp(signalTypes{iSignal},'LFP') % 0 is hard coded because these data will be small, or should otherwise taken from the data.stream on it's own
                dataFileName = [dirStrAnalysis exptDate '-' exptIndex '_' 'data0'];
            end
            save(dataFileName,'ephysData','dT');
            clear ephysData dT;
        end
    end
end


% % % % all video stuff % % % !!!TODO!!!
% videoFrameTimeStamps = data.epocs.Cam1.onset; %relative to start of ephys
% videoFile = dir([dirStrRawData '*.avi']);
% vidData = mmread([dirStrRawData videoFile.name]); % !!TODO!! do we really want to pull video here?
% %vidData.times; % will start at 0
% %stimOnsetTimeSeries(1); % will start at some time afterwards, when it syncs up completly
% videoFrameStart = find(vidData.times <= stimOnsetTimeSeries(1),1,'last');
% trialLength = mean(diff(stimOnsetTimeSeries));
% trialsEndTime = stimOnsetTimeSeries(end)+trialLength;
% videoFrameEnd = find(vidData.times <= trialsEndTime,1,'last');
% finalFrames = vidData.frames(videoFrameStart:videoFrameEnd);
% finalTimes = vidData.times(videoFrameStart:videoFrameEnd);
% activity = zeros(1,length(finalFrames));
% for iFrame = 1:length(finalFrames)
%     activity(iFrame) = mean(mean(mean(finalFrames(iFrame).cdata(:,:,:))));
% end
% activityDiff = diff(activity);
% activityDiff(end+1) = activityDiff(end);
% activityDiff = abs(activityDiff);







%test
% figure;
% plot(finalTimes,activityDiff);
% hold on;
% plot(EEGts,data.streams.EEGw.data(1,:))

% % 2. video
% vidPath = 'W:\Data\PassiveEphys\2018\18803-002\2018_18803-002_Cam1.avi';
% vidData = mmread(vidPath);
% 
% vidData.frames(10).cdata
% image(vidData.frames(10).cdata);
% for i=1:length(vidData.frames)
%     frameSum(i) = sum(sum(sum(vidData.frames(i).cdata(:,:,:))));
% end
% for i=2:length(frameSum)
%     frameSubt(i) = abs(frameSum(i)-frameSum(i-1));
% end
% figure
% plot(frameSubt); % this works.  but continue to test across other vids.


