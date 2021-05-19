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
% Start searching for peaks and troughs of responses after this time
artifactDur = 2.e-3; %sec;
% Average over this window to get estimate of peak value
avgWinTime = 1.e-3; %sec; 
% Time window re stim time to calculate baseline value that is subtracted from peak values
baseWin = [-5,-0.5]*1.e-3; %sec; 
% pkAvgWin = 8; % Average over this window to estimate peak
exptIndexLabels = {'Baseline','postLTP','postLTD'}; % these correspond to each stimset we load below

%% =========  load data in this block  ========= % % % %
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
[nROIs,nDataPts] = size(evDataSet(1).subMean);
preStimIndex = floor(tPreStim/dTRec);
postStimIndex = ceil(tPostStim/dTRec);

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

%% Ugly kludge alert!
% Need to account for delay between stim times as saved by Synapse and stim
% times as they appear in data. Do this by averaging across stimuli and
% finding first peak after t=0 (i.e. after what Synapse thinks is the stim
% time).
pkThresh = 1.e-6;
actualStimIndices = zeros(1,nROIs);
tempData = zeros(size(evDataSet(1).subMean));
for iExpt = 1:nExpts
    tempData = tempData+evDataSet(iExpt).subMean/nExpts;
end
% figure()
for iROI = 1:nROIs
%     subplot(1,nROIs,iROI);
%     plot(abs(tempData(iROI,:)));
%     [tempPks,tempIndex] = findpeaks(abs(tempData(iROI,preStimIndex:end)),'Threshold',pkThresh);
%     hold on
%     plot(tempIndex(1)+preStimIndex,tempPks(1),'+');
    [~,tempIndex] = findpeaks(abs(tempData(iROI,preStimIndex:end)),'Threshold',pkThresh);
    actualStimIndices(iROI) = tempIndex(1)+preStimIndex;
end

%% Plot out averaged traces
% Start searching for peaks and troughs of responses after this time
startSearchIndex = actualStimIndices(iROI)+ceil(artifactDur/dTRec); ; %Start search for plot min and max after artifact

plotTimeArray = dTRec*(-preStimIndex:postStimIndex);
figureName = ['Avg responses - ' animalName '_' exptDate];
thisFigure = figure('Name',figureName);
for iROI = 1:nROIs
    plotMax = -1.e10;
    plotMin = 1.e10;
    for iExpt = 1:nExpts
        plotMax = max([plotMax,max(evDataSet(iExpt).subMean(iROI,startSearchIndex:end))]);
        plotMin = min([plotMin,min(evDataSet(iExpt).subMean(iROI,startSearchIndex:end))]);
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

%% Have user click on peaks in each subplot to inform peak search windows
msgFig = msgbox({'Click once in each subplot to indicate approximate location of peak.';...
    'Proceed from left to right. '});
uiwait(msgFig);
figure(thisFigure);
opts.Default = 'Yes'; % Can just hit enter to proceed
opts.Interpreter = 'Tex'; % Apparently it is necessary to set this option
if exist('pkSearchData','var')
    clear pkSearchData;
end
for iROI = 1:nROIs
    subplot(subPlt(iROI));
    proceed = 0;
    while ~proceed
        [temp_tPk,temp_yPk] = ginput(1); % Gets single click input
        hand = plot(temp_tPk,temp_yPk,'+r','MarkerSize',12);
        answer = questdlg(['Accept pk for ' ROILabels{iROI} ' ?'], ...
        [ROILabels{iROI} 'peak estimate'], ...
        'Yes','No',opts);
        % Handle response
        switch answer
            case 'Yes'
                pkSearchData(iROI).tPk = temp_tPk;
                pkSearchData(iROI).pkSign = sign(temp_yPk);
                proceed = 1;
            case 'No'
                delete(hand); % Removes erroneous peak marker
                proceed = 0;
        end
    end
end

%% Measure peaks

avgWinIndex = floor(avgWinTime/dTRec);
baseWinIndex = floor(baseWin/dTRec);
pkVals = struct();
allAdjPeaks = zeros(nROIs,nTotalTrials); % contains peaks for all recorded trials
allStimTimes = zeros(nROIs,nTotalTrials); % contains stim times for all recorded trials
for iROI = 1:nROIs
    timeElapsed = 0;
    lastTrial = 0;
    %Start and stop indices of time window re stim time to search for peak minimum resp
    this_tPk = pkSearchData(iROI).tPk;
    pkSearchIndices = ceil([this_tPk - this_tPk/2,this_tPk + this_tPk/2]/dTRec);
    tempIndA = actualStimIndices(iROI)+pkSearchIndices;

    for iExpt = 1:nExpts
        for iTrial = 1:nTrials(iExpt)
            tempMn = squeeze(evDataSet(iExpt).sub(iROI,iTrial,:));
            if pkSearchData(iROI).pkSign<0
                % If it's a negative-going peak, find the minimum
                [~,pkIndex] = min(tempMn(tempIndA(1):tempIndA(2))); 
            else
                % If it's a postitive-going peak, find the maximum
                [~,pkIndex] = max(tempMn(tempIndA(1):tempIndA(2))); 
            end
            baseVal = ...
                mean(tempMn(preStimIndex + baseWinIndex(1):preStimIndex + baseWinIndex(2)));
            tempIndB(1) = actualStimIndices(iROI)+pkSearchIndices(1)+pkIndex-avgWinIndex;
            tempIndB(2) = actualStimIndices(iROI)+pkSearchIndices(1)+pkIndex+avgWinIndex;
            tracePeaks(iTrial) = mean(tempMn(tempIndB(1):tempIndB(2))) - baseVal;
        end

        allAdjPeaks(iROI,lastTrial+1:lastTrial+nTrials(iExpt)) = tracePeaks;
        timeElapsed = timeElapsed+recDelay(iExpt);
        allStimTimes(iROI,lastTrial+1:lastTrial+nTrials(iExpt)) = evDataSet(iExpt).stimTimes'+timeElapsed;
        timeElapsed = timeElapsed+evDataSet(iExpt).stimTimes(end);
        lastTrial = lastTrial+nTrials(iExpt);
        clear tracePeaks
    end
end

%% Plot out time series of peak amplitudes
figureName = ['Plasticity peaks time series - ' animalName '_' exptDate];
thisFigure = figure('Name',figureName);
for iROI = 1:nROIs
    plotColor = {'or','ob','ok'};
    subplot(nROIs,1,iROI);
    allStimTimes = allStimTimes/60; %Convert seconds to minutes
    plot(allStimTimes(iROI,1:nTrials(1)),allAdjPeaks(iROI,1:nTrials(1)),'o'); 
    hold on
    plot(allStimTimes(iROI,nTrials(1)+1:nTrials(1)+nTrials(2)),allAdjPeaks(iROI,nTrials(1)+1:nTrials(1)+nTrials(2)),'o');
    plot(allStimTimes(iROI,nTrials(1)+nTrials(2)+1:end),allAdjPeaks(iROI,nTrials(1)+nTrials(2)+1:end),'o');
    baseMn = mean(allAdjPeaks(iROI,1:nTrials(1)));
    plot([allStimTimes(iROI,1),allStimTimes(iROI,end)],[baseMn,baseMn],'--');
    ax = gca;
    ax.Title.String = ROILabels{iROI};
    if iROI == nROIs
        ax.XLabel.String = 'Time (min)';
        ax.YLabel.String = 'Pk ampl';
    end
end
saveas(thisFigure,[outPath figureName]);
