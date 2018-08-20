function importDataSynapse(exptDate,exptIndex)

%test
exptDate = '18802';
exptIndex = '001';

signalTypes = {'EEG','LFP'}; % !!!TODO!!! don't hardcode this 

% not great to hard code... add as parameter?
dirStrRawData = ['W:\Data\PassiveEphys\' '20' exptDate(1:2) '\' exptDate '-' exptIndex '\']; %input
dirStrAnalysis = ['M:\PassiveEphys\20' exptDate(1:2) '\' exptDate '-' exptIndex '\']; %output
data = TDTbin2mat(dirStrRawData);

% % % % stuff not established perfectly % % %

% find which channels are EEG, LFP, etc. from database
% obviously, will only work if this has been entered (will be empty
% otherwise - add check?)
[channelMap] = getElectrodeLocationFromDateIndex(exptDate,exptIndex);

% 2. stream detection from saved data: data.streams
% if this isn't an 'evoked' set, we should handle it differently - 1
% continuous trial?  are other analyses able to handle that?

%not sure if necessary?
dbConn = dbConnect(); %handle this better?  close db at end?
exptID = getIDfromDateIndex(exptDate,exptIndex);
SQLdescription = fetch(dbConn,['SELECT notebookDesc FROM masterexpt WHERE exptID= ''' num2str(exptID) '''']);
close(dbConn);

%use this 



streamList = fields(data.streams);
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
            
            
            
            
            % assign as appropriate
            if strfind(signalTypes{iSignal},'LFP') %not happy with this. the alternative is to establish a config file that has info like this but will need a bit of setup

            end
            
        end
    end
end


stimName = 'eS1p'; % !!TODO!! auto detect scalars that have been read in.  match to existing stims in DB
stimOnsetTimeSeries = data.scalars.(stimName).ts;






% % % % all video stuff
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
figure;
plot(finalTimes,activityDiff);
hold on;
plot(EEGts,data.streams.EEGw.data(1,:))


% !!TODO!! SAVE, etc!





% solved!



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