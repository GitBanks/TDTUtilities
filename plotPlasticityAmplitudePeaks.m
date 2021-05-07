
% this is a rewrite of the PlasticityPlots script and should be broken into
% discrete sections for readability and modularity reasons.


tPreStim = 0.2;
tPostStim = 0.5;
%timeSpans = 4.9*60; %time in seconds (min*60) to group responses into

indexLabels = {'Baseline','LTP','LTD'}; % these correspond to each stimset we load below

% % % % =========  load data in this block  ========= % % % %
exptDate = '21506';
exptIndex = '007';
[stimSet(1)] = getPlasticityData(exptDate,exptIndex,tPreStim,tPostStim);

exptDate = '21506';
exptIndex = '010';
[stimSet(2)] = getPlasticityData(exptDate,exptIndex,tPreStim,tPostStim);

exptDate = '21506';
exptIndex = '012';
[stimSet(3)] = getPlasticityData(exptDate,exptIndex,tPreStim,tPostStim);

recDelay(1) = 0;
recDelay(2) = synapseTimeSubtraction(stimSet(2).timeOfDayStart,stimSet(1).timeOfDayStop);
recDelay(3) = synapseTimeSubtraction(stimSet(3).timeOfDayStart,stimSet(2).timeOfDayStop);



% % % % ============ plot peak amplitude time series ============= % % % %
iChan = 1; % loop through this?
dTRec = stimSet.dT;
plotTimeArray = -tPreStim:dTRec:tPostStim;
beginTimeWindow = .005; %this is start of time window
endTimeWindow = .02; %this is end of time window
searchWindow = plotTimeArray>beginTimeWindow&plotTimeArray<endTimeWindow;


allCorrectedPeaks = []; % cat peaks for all hours
allStimTimes = []; % cat event times for all hours
timeElapsed = 0;
for iSet = 1:size(stimSet,2)
% peak min
% searchWindow = plotTimeArray>beginTimeWindow&plotTimeArray<endTimeWindow
startIndex = find(plotTimeArray>beginTimeWindow,1,'First');

%tracePeaks = zeros(1,size(stimSet(iSet).sub,2));
for iIndex = 1:size(stimSet(iSet).sub,2)
    [~,Imin] = min(stimSet(iSet).sub(1,iIndex,searchWindow)); % this finds the lowest point within a range
    minPeakIndex = startIndex+Imin;
    indexRange = minPeakIndex-4:minPeakIndex+4;
    tracePeaks(iIndex) = mean(stimSet(iSet).sub(1,iIndex,indexRange),3);
end

traceBaseline = mean(stimSet(iSet).sub(1,:,1:100),3);
allCorrectedPeaks = cat(2,allCorrectedPeaks,tracePeaks-traceBaseline);

timeElapsed = timeElapsed+recDelay(iSet);
allStimTimes = cat(2,allStimTimes,(stimSet(iSet).stimOnset'+timeElapsed));
timeElapsed = timeElapsed+stimSet(iSet).stimOnset(end);
npoints(iSet) = size(stimSet(iSet).sub,2);
clear tracePeaks
end


%This will plot out time series of every averaged peak




plotColor = {'or','ob','ok'};
figure();

allStimTimes = allStimTimes/60;

plot(allStimTimes(1:npoints(1)),allCorrectedPeaks(1:npoints(1)),'o'); %This step corrects for the baseline and also plots the time series
hold on
plot(allStimTimes(npoints(1)+1:npoints(1)+npoints(2)),allCorrectedPeaks(npoints(1)+1:npoints(1)+npoints(2)),'o');
plot(allStimTimes(npoints(1)+npoints(2)+1:end),allCorrectedPeaks(npoints(1)+npoints(2)+1:end),'o');
xlabel('Time')
ylabel('Adjusted min amplitude')

% minY = 0;
% maxY = 0;







%compute baseline for each trace and subtract from peak

%index that corresponds to time before stim

traceBaseline = mean(stimSet.sub(1,:,1:100),3);

figure()
plot(minPeaks-traceBaseline,'o');

%can add the data from baseline LTP and LTD












% Plot
% plotTimeArrayRec = -tPreStim:dTRec:tPostStim;
% 
% 
% figure()
% plot(plotTimeArrayRec,stimSet.dataMean(1,1:end-1))
% 
% 
% 
% 
% figure()
% plot(timeArrayRec,data.streams.LFP1.data(3,:))
% 
% figure()
% plot(plotTimeArrayRec,squeeze(stimSet.sub(1,3:359,:)))
% plot(plotTimeArrayRec,squeeze(mean(stimSet.sub(1,1:359,:),2)),'LineWidth',3)
% 
% figure()
% plot(squeeze(stimSet.sub(1,1,:)))
% 
% plot(plotTimeArrayRec,squeeze(stimSet.sub(1,1,:)))
