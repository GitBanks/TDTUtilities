function plotPlasticityAmplitudePeaks(exptDate,exptIndices)
% Function to plot out time series of evoked response amplitudes during
% LTP/LTD expts. Allows user to choose time and sign of peaks from averqage
% traces.
% this is a rewrite of the PlasticityPlots script and should be broken into
% discrete sections for readability and modularity reasons.
if ~exist('exptDate','var') || ~exist('exptIndices','var') 
    exptDate = '21515';
    exptIndices = {'003','009','012'};
end
nExpts = length(exptIndices);

outPath = ['M:\PassiveEphys\20' exptDate(1:2) '\' exptDate '-' exptIndices{1} '\'];
if ~exist(outPath,'dir')
    mkdir(outPath);
end

tPreStim = 0.02;
tPostStim = 0.2;
pkAvgWin = 8; % Average over this window to estimate peak
exptIndexLabels = {'Baseline','postLTP','postLTD'}; % these correspond to each stimset we load below

% % % % =========  load data in this block  ========= % % % %
if exist('evDataSet','var')
    clear evDataSet
end
nTrials = zeros(1,nExpts);
for iExpt = 1:nExpts
    exptIndex = exptIndices{iExpt};
    [dataTemp,dTRec] = getSynapseSingleStimData(exptDate,exptIndex,tPreStim,tPostStim);
    evDataSet(iExpt) = dataTemp;
    nTrials(iExpt) = size(evDataSet(iExpt).sub,2);
end
nTotalTrials = sum(nTrials);

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
figureName = ['Avg responses - ' animalName '_' exptDate];
thisFigure = figure('Name',figureName);
for iROI = 1:nROIs
    plotMax = -1.e10;
    plotMin = 1.e10;
    for iExpt = 1:nExpts
        plotMax = max([plotMax,max(evDataSet(iExpt).subMean(iROI,preStimIndex+startSearchIndex:end))]);
        plotMin = min([plotMin,min(evDataSet(iExpt).subMean(iROI,preStimIndex+startSearchIndex:end))]);
    end
    % Plot avg traces
    subPlt(iROI) = subplot(1,nROIs,iROI);
    hold on
    for iExpt = 1:nExpts
        plot(plotTimeArray,evDataSet(iExpt).subMean(iROI,:));
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
        legLabs = cell(1,nExpts);
        for iExpt = 1:nExpts
            legLabs{iExpt} = [exptIndices{iExpt} '-' exptIndexLabels{iExpt}];
        end
        legend(legLabs);
    end
end
saveas(thisFigure,[outPath figureName]);
%%
% Have user click on peaks in each subplot to inform peak search windows
msgFig = msgbox({'Click once in each subplot to indicate approximate location of peak.';...
    'Proceed from left to right!'});
uiwait(msgFig);
figure(thisFigure);
tPk = zeros(1,nROIs);
yPk = zeros(1,nROIs);
opts.Default = 'Yes'; % Can just hit enter to proceed
opts.Interpreter = 'Tex'; % Apparently it is necessary to set this option
for iROI = 1:nROIs
    subplot(subPlt(iROI));
    proceed = 0;
    while ~proceed
        [tPk(iROI),yPk(iROI)] = ginput(1); % Gets single click input
        hand = plot(tPk(iROI),yPk(iROI),'+r','MarkerSize',12);
        answer = questdlg(['Accept pk for ' ROILabels{iROI} ' OK?'], ...
        [ROILabels{iROI} 'peak estimate'], ...
        'Yes','No',opts);
        % Handle response
        switch answer
            case 'Yes'
                proceed = 1;
            case 'No'
                delete(hand); % Removes erroneous peak marker
                proceed = 0;
        end
    end
end

%%
% % % % ============ plot peak amplitude time series ============= % % % %
figureName = ['Plasticity peaks time series - ' animalName '_' exptDate];
thisFigure = figure('Name',figureName);
for iROI = 1:nROIs
    beginTimeWindow = tPk(iROI) - tPk(iROI)/2; %this is start of time window
    endTimeWindow = tPk(iROI) + tPk(iROI)/2; %this is end of time window
    searchWindow = plotTimeArray>beginTimeWindow&plotTimeArray<endTimeWindow;
    startIndex = find(plotTimeArray>beginTimeWindow,1,'First');

    allAdjPeaks = zeros(1,nTotalTrials); % contains peaks for all recorded trials
    allStimTimes = zeros(1,nTotalTrials); % contains stim times for all recorded trials
    timeElapsed = 0;
    lastTrial = 0;
    for iExpt = 1:nExpts
        for iTrial = 1:nTrials(iExpt)
            if yPk(iROI)<0
                % If it's a negative-going peak, find the minimum
                [~,tempPkIndex] = min(evDataSet(iExpt).sub(iROI,iTrial,searchWindow)); 
            else
                % If it's a postitive-going peak, find the maximum
                [~,tempPkIndex] = max(evDataSet(iExpt).sub(iROI,iTrial,searchWindow));
            end
            pkIndex = startIndex+tempPkIndex;
            indexRange = pkIndex-pkAvgWin/2:pkIndex+pkAvgWin/2;
            tracePeaks(iTrial) = mean(evDataSet(iExpt).sub(iROI,iTrial,indexRange),3);
        end
        traceBaseline = mean(evDataSet(iExpt).sub(iROI,:,1:100),3);
        allAdjPeaks(lastTrial+1:lastTrial+nTrials(iExpt)) = tracePeaks-traceBaseline;
        timeElapsed = timeElapsed+recDelay(iExpt);
        allStimTimes(lastTrial+1:lastTrial+nTrials(iExpt)) = evDataSet(iExpt).stimTimes'+timeElapsed;
        timeElapsed = timeElapsed+evDataSet(iExpt).stimTimes(end);
        lastTrial = lastTrial+nTrials(iExpt);
        clear tracePeaks
    end

%Plot out time series of peak amplitudes
    plotColor = {'or','ob','ok'};
    subplot(nROIs,1,iROI);
    allStimTimes = allStimTimes/60; %Convert seconds to minutes
    plot(allStimTimes(1:nTrials(1)),allAdjPeaks(1:nTrials(1)),'o'); 
    hold on
    plot(allStimTimes(nTrials(1)+1:nTrials(1)+nTrials(2)),allAdjPeaks(nTrials(1)+1:nTrials(1)+nTrials(2)),'o');
    plot(allStimTimes(nTrials(1)+nTrials(2)+1:end),allAdjPeaks(nTrials(1)+nTrials(2)+1:end),'o');
    baseMn = mean(allAdjPeaks(1:nTrials(1)));
    plot([allStimTimes(1),allStimTimes(end)],[baseMn,baseMn],'--');
    ax = gca;
    ax.Title.String = ROILabels{iROI};
    if iROI == nROIs
        ax.XLabel.String = 'Time (min)';
        ax.YLabel.String = 'Pk ampl';
    end
end
saveas(thisFigure,[outPath figureName]);
