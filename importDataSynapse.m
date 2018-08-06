function importDataSynapse(date,index)
%test
date = '18803';
index = '002';


dirStrRecSource = ['\\' '144.92.237.187' '\e\Data\' '20' date(1:2) '\' date '-' index ];
dirStrRawData = ['W:\Data\PassiveEphys\' '20' date(1:2) '\' date '-' index ];
%dirStrAnalysis = ['M:\PassiveEphys\20' date(1:2) '\' date '-' index '\'];

% a = TDT2mat(dirStrRecSource);
b = TDT2mat(dirStrRawData);

% legacy analysis expects 16 channels.  proceed carefully! Shouldn't be a 
% total re-write, but will need each step tested throughly!
% 
% 
%MyTank = ['\\' '144.92.237.187' '\e\Data\' '20' date(1:2) '\'];

MyTank = ['W:\Data\PassiveEphys\' '20' date(1:2)];
MyBlock = [date '-' index];
fullpath = [MyTank MyBlock];
TTX = actxcontrol('TTank.X');
TTX.ConnectServer('local','Me');
TTX.OpenTank(MyTank,'R')

TTX.SelectBlock(MyBlock)
% TT.OpenTank('C:\TDT\OpenEx\Tanks\MyTank','R')

% a = TDT2mat(MyTank,MyBlock,'TTX',TTX);
% b = TDT2mat(MyTank,MyBlock);
% c = TDT2mat(fullpath);

TTX.AddTank('2018',['REGISTER@W:\Data\PassiveEphys\'])




stimName = 'eS1p';

%b.streams.EEGw


% figure out video time stamps here.  need video grid?
vidPath = '';





timeSeries = b.scalars.(stimName).ts;
vidFrameTimeStamps = b.epocs.Cam1.onset;
vidData = mmread(vidPath);

vidData.times; % will start at 0
timeSeries; % will start at some time afterwards, when it syncs up completly
videoFrameStart = find(vidData.times <= timeSeries(1),1,'last');
stimTimes = b.scalars.eS1p.ts;
trialLength = mean(diff(stimTimes));
trialsEndTime = stimTimes(end)+trialLength;
videoFrameEnd = find(vidData.times <= trialsEndTime,1,'last');

finalFrames = vidData.frames(videoFrameStart:videoFrameEnd);
finalTimes = vidData.times(videoFrameStart:videoFrameEnd);

%create EEG time series
dT = 1/b.streams.Wav1.fs;
EEGts = zeros(1,length(b.streams.EEGw.data));
EEGts(1) = dT;
for iTimes = 2:length(EEGts)
   EEGts(iTimes) = EEGts(iTimes-1)+dT;
end

activity = zeros(1,length(finalFrames));
for iFrame = 1:length(finalFrames)
    activity(iFrame) = mean(mean(mean(finalFrames(iFrame).cdata(:,:,:))));
end

activityDiff = diff(activity);
activityDiff(end+1) = activityDiff(end);
activityDiff = abs(activityDiff);


figure;
plot(finalTimes,activityDiff);
hold on;
plot(EEGts,b.streams.EEGw.data(1,:))





