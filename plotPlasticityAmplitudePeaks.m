
% this is a rewrite of the PlasticityPlots script and should be broken into
% discrete sections for readability and modularity reasons.


tPreStim = 0.02;
tPostStim = 0.2;
%timeSpans = 4.9*60; %time in seconds (min*60) to group responses into

indexLabels = {'Baseline','LTP','LTD'}; % these correspond to each stimset we load below

% % % % =========  load data in this block  ========= % % % %
exptDate = '21515';
exptIndices = {'003','009','012'};
nExpts = length(exptIndices);
for iExpt = 1:nExpts
    exptIndex = exptIndices{iExpt};
    [dataTemp,dTRec] = getSynapseSingleStimData(exptDate,exptIndex,tPreStim,tPostStim);
    evDataSet(iExpt) = dataTemp;
end

% Get gaps between data files in seconds
recDelay = zeros(1,nExpts);
for iExpt = 2:nExpts
    t2 = evDataSet(iExpt).info.utcStartTime;
    t1 = evDataSet(iExpt-1).info.utcStopTime;
    recDelay(iExpt) = synapseTimeSubtraction(t2,t1);
end

%%
relevantROIs = {'PFC','CA1','Hipp'}; % labels in database can be any of these
animalName = getAnimalByDateIndex(exptDate,exptIndices{1});
electrodeLocs = getElectrodeLocationFromDateIndex(exptDate,exptIndices{1});
%%%%NOTE: The following assumes that channels are arranged in pairs and
%%%%that the channels are ordered in Synapse as they are in eNotebook
ROILabels = electrodeLocs(contains(electrodeLocs,relevantROIs,'IgnoreCase',true));
ROILabels = unique(ROILabels,'stable');

%%
% Plot out averaged traces
% Start searching for peaks and troughs of responses after this time
artifactEnd = 5.e-3; %sec;
[nROIs,nDataPts] = size(evDataSet(1).subMean);
preStimIndex = floor(tPreStim/dTRec);
postStimIndex = ceil(tPostStim/dTRec);
startSearchIndex = ceil(artifactEnd/dTRec); %Start search for plot min and max after artifact

plotTimeArray = dTRec*(-preStimIndex:postStimIndex);
FigName = ['Avg responses - ' animalName '_' exptDate];
thisFig = figure('Name',FigName);
for iROI = 1:nROIs
    plotMax = -1.e10;
    plotMin = 1.e10;
    for iSet = 1:nExpts
        plotMax = max([plotMax,max(evDataSet(iSet).subMean(iROI,preStimIndex+startSearchIndex:end))]);
        plotMin = min([plotMin,min(evDataSet(iSet).subMean(iROI,preStimIndex+startSearchIndex:end))]);
    end
    % Plot avg traces
    subplot(1,nROIs,iROI)
    hold on
    for iSet = 1:nExpts
        plot(plotTimeArray,evDataSet(iSet).subMean(iROI,:));
    end
    ax = gca;
    ax.XLim = [-tPreStim,tPostStim];
    ax.YLim = [1.05*plotMin,1.05*plotMax];
    ax.XLabel.String = 'time(sec)';
    if iROI == 1
        ax.YLabel.String = 'avg dataSub (V)';
    end
    ax.Title.String = ROILabels{iROI};
    if iROI == nROIs
        legend(exptIndices);
    end
end

%%
% % % % ============ plot peak amplitude time series ============= % % % %
iChan = 1; % loop through this?
plotTimeArray = -tPreStim:dTRec:tPostStim;
beginTimeWindow = .005; %this is start of time window
endTimeWindow = .02; %this is end of time window
searchWindow = plotTimeArray>beginTimeWindow&plotTimeArray<endTimeWindow;

allCorrectedPeaks = []; % cat peaks for all hours
allStimTimes = []; % cat event times for all hours
timeElapsed = 0;
for iSet = 1:size(evDataSet,2)
    % peak min
    % searchWindow = plotTimeArray>beginTimeWindow&plotTimeArray<endTimeWindow
    startIndex = find(plotTimeArray>beginTimeWindow,1,'First');

    %tracePeaks = zeros(1,size(stimSet(iSet).sub,2));
    for iIndex = 1:size(evDataSet(iSet).sub,2)
        [~,Imin] = min(evDataSet(iSet).sub(1,iIndex,searchWindow)); % this finds the lowest point within a range
        minPeakIndex = startIndex+Imin;
        indexRange = minPeakIndex-4:minPeakIndex+4;
        tracePeaks(iIndex) = mean(evDataSet(iSet).sub(1,iIndex,indexRange),3);
    end

    traceBaseline = mean(evDataSet(iSet).sub(1,:,1:100),3);
    allCorrectedPeaks = cat(2,allCorrectedPeaks,tracePeaks-traceBaseline);

    timeElapsed = timeElapsed+recDelay(iSet);
    allStimTimes = cat(2,allStimTimes,(evDataSet(iSet).stimOnset'+timeElapsed));
    timeElapsed = timeElapsed+evDataSet(iSet).stimOnset(end);
    npoints(iSet) = size(evDataSet(iSet).sub,2);
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

traceBaseline = mean(evDataSet.sub(1,:,1:100),3);

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
