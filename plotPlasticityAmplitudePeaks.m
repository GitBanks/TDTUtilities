function plotPlasticityAmplitudePeaks(exptDate,exptIndices,description)
% Function to plot out time series of evoked response amplitudes during
% LTP/LTD expts. Allows user to choose time and sign of peaks from averqage
% traces.
% this is a rewrite of the PlasticityPlots script and should be broken into
% discrete sections for readability and modularity reasons.

if ~exist('exptDate','var') || ~exist('exptIndices','var') 
%     exptDate = '21527';
%     exptIndices = {'001','003','005'};
    exptDate = '21616'; 
    exptIndices = {'009','017','021'};
%     exptDate = '21616'; noTank = true;
%     exptIndices = {'010','018','022'};
end
nExpts = length(exptIndices);

outPath = ['M:\PassiveEphys\20' exptDate(1:2) '\' exptDate '-' exptIndices{1} '\'];
if ~exist(outPath,'dir')
    mkdir(outPath);
end
animal = getAnimalByDateIndex(exptDate,exptIndices{1});
outPath2 = ['M:\PassiveEphys\AnimalData\' animal '\'];
if ~exist(outPath2,'dir')
    mkdir(outPath2);
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
%exptIndexLabels = {'Baseline','postLTP','postLTD'}; % these correspond to each stimset we load below
exptIndexLabels = {'Baseline','postLTP','postLTD'};
smFac = 15; %smoothing window for time series plots

%%





%% =========  load data in this block  ========= % % % %
if exist('evDataSet','var')
    clear evDataSet
end
nTrials = zeros(1,nExpts);
for iExpt = 1:nExpts
    [~,indexOut,isTank] = getIsTank(exptDate,exptIndices{iExpt});
    [dataTemp,dTRec] = getSynapseSingleStimData(exptDate,indexOut,tPreStim,tPostStim,isTank);
    evDataSet(iExpt) = dataTemp;
    nTrials(iExpt) = size(evDataSet(iExpt).sub,2); 
    [~,movementsPreStim(iExpt).events] = plotStimAndMovement(exptDate,exptIndices{iExpt},false);
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
% we can assemble the movement data similar to the time series data since
% we now have time offsets
moveStimTimes = zeros(1,nTotalTrials); % contains stim times for all recorded trials
moveStimVals = zeros(1,nTotalTrials);
timeElapsed = 0;
lastTrial = 0;
for iExpt = 1:nExpts
    timeElapsed = timeElapsed+recDelay(iExpt);
    moveStimTimes(lastTrial+1:lastTrial+nTrials(iExpt)) = evDataSet(iExpt).stimTimes'+timeElapsed;
    moveStimVals(lastTrial+1:lastTrial+nTrials(iExpt)) = movementsPreStim(iExpt).events;
    timeElapsed = timeElapsed+evDataSet(iExpt).stimTimes(end);
    lastTrial = lastTrial+nTrials(iExpt);
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
pkThresh = 5.e-6;
tempData = zeros(size(evDataSet(1).subMean));
for iExpt = 1:nExpts
    tempData = tempData+evDataSet(iExpt).subMean/nExpts;
end
% figure()
saveIndex = zeros(1,nROIs);
for iROI = 1:nROIs
%     subplot(1,nROIs,iROI);
%     plot(abs(tempData(iROI,:)));
%     [tempPks,tempIndex] = findpeaks(abs(tempData(iROI,preStimIndex:end)),'Threshold',pkThresh);
%     if isempty(tempIndex)
%         tempIndex(1) = 0;
%         tempPks(1) = 0;
%     end
%     saveIndex(iROI) = tempIndex(1);
%     hold on
%     plot(tempIndex(1)+preStimIndex,tempPks(1),'+');
    [~,tempIndex] = findpeaks(abs(tempData(iROI,preStimIndex:end)),'Threshold',pkThresh);
    if isempty(tempIndex)
        tempIndex(1) = 0;
    end
    saveIndex(iROI) = tempIndex(1);
end
if sum(saveIndex) == 0
    actualStimIndex = preStimIndex;
else
    indexAdjust = floor(mean(saveIndex(saveIndex>0)));
    actualStimIndex = preStimIndex + indexAdjust;
end
%% Plot out averaged traces
% Start searching for peaks and troughs of responses after this time
startSearchIndex = actualStimIndex+ceil(artifactDur/dTRec); %Start search for plot min and max after artifact

plotTimeArray = dTRec*(-preStimIndex:postStimIndex);
figureName = ['Avg responses - ' animalName '_' exptDate];
thisFigure = figure('Name',figureName);
for iROI = 1:nROIs
    plotMax(iROI) = -1.e10;
    plotMin(iROI) = 1.e10;
    for iExpt = 1:nExpts
        plotMax(iROI) = max([plotMax(iROI),prctile(evDataSet(iExpt).subMean(iROI,startSearchIndex:end),99)]);
        plotMin(iROI) = min([plotMin(iROI),prctile(evDataSet(iExpt).subMean(iROI,startSearchIndex:end),1)]);
    end
    % Plot avg traces
    subPlt(iROI) = subplot(1,nROIs,iROI);
    hold on
    for iExpt = 1:nExpts
        plot(plotTimeArray,evDataSet(iExpt).subMean(iROI,:));
    end
    ax = gca;
    ax.XLim = [-tPreStim,tPostStim];
    ax.YLim = [3*plotMin(iROI),3*plotMax(iROI)];
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


saveas(thisFigure,[outPath figureName]);
saveas(thisFigure,[outPath2 figureName]);

% fileName = ['M:\PassiveEphys\AnimalData\' animal '\' figureName];
% print('-painters',fileName,'-r300','-dpng');
% try
%     desc = figureName;
%     sendSlackFig(desc,[fileName '.png']);
% catch
%     disp(['failed to upload ' fileName ' to Slack']);
% end

%% Measure response magnitude of single trial via peak amplitude

avgWinIndex = floor(avgWinTime/dTRec);
baseWinIndex = floor(baseWin/dTRec);
allAdjPeaks = zeros(nROIs,nTotalTrials); % contains peaks for all recorded trials
allStimTimes = zeros(nROIs,nTotalTrials); % contains stim times for all recorded trials

for iROI = 1:nROIs
    timeElapsed = 0;
    lastTrial = 0;
    %Start and stop indices of time window re stim time to search for peak minimum resp
    this_tPk = pkSearchData(iROI).tPk;
    pkSearchIndices = ceil([this_tPk - this_tPk/2,this_tPk + this_tPk/2]/dTRec);
    % Account for mystery delay in Synapse by adding on the actual stim
    % indices here, i.e. shift the time origin just for estimating the peak.
    tempIndA = actualStimIndex+pkSearchIndices;

    for iExpt = 1:nExpts
        for iTrial = 1:nTrials(iExpt)
            tempData = squeeze(evDataSet(iExpt).sub(iROI,iTrial,:));
            if pkSearchData(iROI).pkSign<0
                % If it's a negative-going peak, find the minimum
                [~,pkIndex] = min(tempData(tempIndA(1):tempIndA(2))); 
            else
                % If it's a postitive-going peak, find the maximum
                [~,pkIndex] = max(tempData(tempIndA(1):tempIndA(2))); 
            end
            baseVal = ...
                mean(tempData(preStimIndex + baseWinIndex(1):preStimIndex + baseWinIndex(2)));
            tempIndB(1) = actualStimIndex+pkSearchIndices(1)+pkIndex-avgWinIndex;
            tempIndB(2) = actualStimIndex+pkSearchIndices(1)+pkIndex+avgWinIndex;
            % Multiply by sign of peak so that all data are magnitudes.
            % Also correct for baseline.
            tracePeaks(iTrial) = ...
                pkSearchData(iROI).pkSign*mean(tempData(tempIndB(1):tempIndB(2))) - baseVal;
        end
        % concatenate the data from each experiment to get one long time
        % series covering the whole recording session.
        allAdjPeaks(iROI,lastTrial+1:lastTrial+nTrials(iExpt)) = tracePeaks;
        timeElapsed = timeElapsed+recDelay(iExpt);
        allStimTimes(iROI,lastTrial+1:lastTrial+nTrials(iExpt)) = evDataSet(iExpt).stimTimes'+timeElapsed;
        timeElapsed = timeElapsed+evDataSet(iExpt).stimTimes(end);
        lastTrial = lastTrial+nTrials(iExpt);
        tempStruct(iExpt).saveThesePeaks(iROI,:) = tracePeaks;
        clear tracePeaks
    end
end

%% Measure response magnitude of single trial via inner product of single 
% trials with average trace from baseline condition

avgWinIndex = floor(avgWinTime/dTRec);
baseWinIndex = floor(baseWin/dTRec);
allAdjIPAmpls = zeros(nROIs,nTotalTrials); % contains peaks for all recorded trials

for iROI = 1:nROIs
    timeElapsed = 0;
    lastTrial = 0;
    %Start and stop indices of time window re stim time to search for peak minimum resp
    this_tPk = pkSearchData(iROI).tPk;
    pkSearchIndices = ceil([this_tPk - this_tPk/2,this_tPk + this_tPk/2]/dTRec);
    % Account for mystery delay in Synapse by adding on the actual stim
    % indices here, i.e. shift the time origin just for estimating the peak.
    tempIndA = actualStimIndex+pkSearchIndices;
    thisMn = squeeze(evDataSet(1).subMean(iROI,:));

    for iExpt = 1:nExpts
        traceIPAmpl = zeros(1,nTrials(iExpt));
        for iTrial = 1:nTrials(iExpt)
            tempData = squeeze(evDataSet(iExpt).sub(iROI,iTrial,:))';
            baseVal = ...
                mean(tempData(preStimIndex + baseWinIndex(1):preStimIndex + baseWinIndex(2)));
            tempData = tempData-baseVal;
            % Also correct for baseline.
            traceIPAmpl(iTrial) = dot(tempData(tempIndA(1):tempIndA(2)),thisMn(tempIndA(1):tempIndA(2)))...
                /norm(thisMn(tempIndA(1):tempIndA(2)));
        end
        % concatenate the data from each experiment to get one long time
        % series covering the whole recording session.
        allAdjIPAmpls(iROI,lastTrial+1:lastTrial+nTrials(iExpt)) = traceIPAmpl;
        AdjIPAmplsByExpt(iExpt).data(iROI,:) = traceIPAmpl;
        lastTrial = lastTrial+nTrials(iExpt);
    end
end




%%





% we will save 
% Time of peak re stim time
% Response magnitude (pk, inner product)
% Time of stim relative to start of file
% this was developed in the evokedStimResp_userInput program, and both bits
% of code should be adjusted if we change things.  The other version will
% track multiple stim types.  This version will only have one, but we'll
% keep the same variables and structure for compatability reasons
% also just found out we need to save a peakData file for each index, so
% loop through them:

for iExpt = 1:size(exptIndices,2) 
    fileString = [exptDate '-' exptIndices{iExpt}];
    outPath = ['M:\PassiveEphys\20' exptDate(1:2) '\' fileString '\'];
    peakData = struct;
    peakData.pkSearchData = pkSearchData; % user selected Time of peak re stim time
    peakData.ROILabels = ROILabels; %corresponding labels
    % peakData.stimArrayNumeric = stimArrayNumeric; % here's our first difference from the evokedStimResp_userInput
    peakData.stimArrayNumeric = ones(1,nTrials(iExpt));
    peakData.pkVals = tempStruct(iExpt).saveThesePeaks; % Response magnitude 
    peakData.stimTimes = evDataSet(iExpt).stimTimes; % Time of stim relative to start of file
    peakData.plotMin = plotMin;
    peakData.plotMax = plotMax;
    avgTraces = struct;
    avgTraces.stimSet = evDataSet(iExpt).subMean;
    avgTraces.stimArrayNumeric = ones(1,nTrials(iExpt));
    avgTraces.ampLabel = ' ';
    save([outPath fileString '_peakData'],'peakData','plotTimeArray','avgTraces');
end

% % also save long term data
% % 
% if ~exist('peakDataOverTime','var')
%     peakDataOverTime = struct;
% end
% peakDataOverTime.(['expt' strrep(fileString,'-','')]).peakData = peakData;
% save([outPath2 animal '_peakDataOverTime'],'peakDataOverTime');


%% Plot out time series of peak amplitudes
figureName = ['Plasticity peaks time series - ' animalName '_' exptDate '_' description];
thisFigure = figure('Name',figureName);
plotStimTimes = allStimTimes/60; %Convert seconds to minutes

%movementsPreStim(iExpt).events

for iROI = 1:nROIs
    plotColor = {'or','ob','ok'};
    subplot(nROIs+1,1,iROI);
    hold on
    plot(plotStimTimes(iROI,1:nTrials(1)),allAdjPeaks(iROI,1:nTrials(1)),'o'); 
    plot(plotStimTimes(iROI,1:nTrials(1)),smooth(allAdjPeaks(iROI,1:nTrials(1)),smFac),'-k','LineWidth',2);
    plot(plotStimTimes(iROI,nTrials(1)+1:nTrials(1)+nTrials(2)),allAdjPeaks(iROI,nTrials(1)+1:nTrials(1)+nTrials(2)),'o');
    plot(plotStimTimes(iROI,nTrials(1)+1:nTrials(1)+nTrials(2)),...
        smooth(allAdjPeaks(iROI,nTrials(1)+1:nTrials(1)+nTrials(2)),smFac),'-k','LineWidth',2);
    plot(plotStimTimes(iROI,nTrials(1)+nTrials(2)+1:end),allAdjPeaks(iROI,nTrials(1)+nTrials(2)+1:end),'o');
    plot(plotStimTimes(iROI,nTrials(1)+nTrials(2)+1:end),...
        smooth(allAdjPeaks(iROI,nTrials(1)+nTrials(2)+1:end),smFac),'-k','LineWidth',2);
    baseData = allAdjPeaks(iROI,1:nTrials(1));
    baseData = baseData(baseData>prctile(baseData,1)&baseData<prctile(baseData,99));
    baseMn = mean(baseData);
    plot([plotStimTimes(iROI,1),plotStimTimes(iROI,end)],[baseMn,baseMn],'--');
    ax = gca;
    ax.YLim = [1.05*prctile(allAdjPeaks(iROI,:),1),1.05*prctile(allAdjPeaks(iROI,:),99)];
    ax.Title.String = ROILabels{iROI};
    if iROI == nROIs
        ax.YLabel.String = '|Pk ampl|';
    end
end
subplot(nROIs+1,1,iROI+1);
scatter(moveStimTimes/60,moveStimVals);
hold on
plot(moveStimTimes(1:nTrials(1))/60,smooth(moveStimVals(1:nTrials(1)),smFac),'-k','LineWidth',2);
plot(moveStimTimes(nTrials(1)+1:nTrials(1)+nTrials(2))/60,smooth(moveStimVals(nTrials(1)+1:nTrials(1)+nTrials(2)),smFac),'-k','LineWidth',2);
plot(moveStimTimes(nTrials(1)+nTrials(2)+1:end)/60,smooth(moveStimVals(nTrials(1)+nTrials(2)+1:end),smFac),'-k','LineWidth',2);
% plot(moveStimTimes/60,smooth(moveStimVals,smFac),'-k','LineWidth',2);
ax = gca;
ax.Title.String = 'Movement';
ax.YLabel.String = 'Mv ampl';
ax.XLabel.String = 'Time (min)';

saveas(thisFigure,[outPath figureName]);
saveas(thisFigure,[outPath2 figureName]);


%Send to slack
% fileName = ['M:\PassiveEphys\AnimalData\' animal '\' figureName];
% print('-painters',fileName,'-r300','-dpng');
% try
%     desc = figureName;
%     sendSlackFig(desc,[fileName '.png']);
% catch
%     disp(['failed to upload ' fileName ' to Slack']);
% end


%% Plot out time series of inner products
% figureName = ['Plasticity IP time series - ' animalName '_' exptDate];
% thisFigure = figure('Name',figureName);
% plotStimTimes = allStimTimes/60; %Convert seconds to minutes
% for iROI = 1:nROIs
%     plotColor = {'or','ob','ok'};
%     subplot(nROIs,1,iROI);
%     hold on
%     plot(plotStimTimes(iROI,1:nTrials(1)),allAdjIPAmpls(iROI,1:nTrials(1)),'o'); 
%     plot(plotStimTimes(iROI,1:nTrials(1)),smooth(allAdjIPAmpls(iROI,1:nTrials(1)),smFac),'-k','LineWidth',2);
%     plot(plotStimTimes(iROI,nTrials(1)+1:nTrials(1)+nTrials(2)),allAdjIPAmpls(iROI,nTrials(1)+1:nTrials(1)+nTrials(2)),'o');
%     plot(plotStimTimes(iROI,nTrials(1)+1:nTrials(1)+nTrials(2)),...
%         smooth(allAdjIPAmpls(iROI,nTrials(1)+1:nTrials(1)+nTrials(2)),smFac),'-k','LineWidth',2);
%     plot(plotStimTimes(iROI,nTrials(1)+nTrials(2)+1:end),allAdjIPAmpls(iROI,nTrials(1)+nTrials(2)+1:end),'o');
%     plot(plotStimTimes(iROI,nTrials(1)+nTrials(2)+1:end),...
%         smooth(allAdjIPAmpls(iROI,nTrials(1)+nTrials(2)+1:end),smFac),'-k','LineWidth',2);
%     baseData = allAdjIPAmpls(iROI,1:nTrials(1));
%     baseData = baseData(baseData>prctile(baseData,1)&baseData<prctile(baseData,99));
%     baseMn = mean(baseData);
%     plot([plotStimTimes(iROI,1),plotStimTimes(iROI,end)],[baseMn,baseMn],'--');
%     ax = gca;
%     ax.YLim = [1.05*prctile(allAdjIPAmpls(iROI,:),1),1.05*prctile(allAdjIPAmpls(iROI,:),99)];
%     ax.Title.String = ROILabels{iROI};
%     if iROI == nROIs
%         ax.XLabel.String = 'Time (min)';
%         ax.YLabel.String = '|IP ampl|';
%     end
% end
% saveas(thisFigure,[outPath figureName]);
% saveas(thisFigure,[outPath2 figureName]);
% 
% fileName = ['M:\PassiveEphys\AnimalData\' animal '\' figureName];
% print('-painters',fileName,'-r300','-dpng');
% try
%     desc = figureName;
%     sendSlackFig(desc,[fileName '.png']);
% catch
%     disp(['failed to upload ' fileName ' to Slack']);
% end

%%


%movement = [movementsPreStim(1).events movementsPreStim(2).events movementsPreStim(3).events];

maxYbyROI = [nan,nan,nan;nan,nan,nan;nan,nan,nan];
minYbyROI = [nan,nan,nan;nan,nan,nan;nan,nan,nan];
% stdYbyROI = [nan,nan,nan];
figureName = ['response peak vs movement - ' animalName '_' exptDate '_' description];
figure('Name',figureName);
for iExpt = 1:nExpts
    for iROI = 1:nROIs
        subtightplot(nExpts,nROIs,(iExpt-1)*nExpts+iROI);
        scatter(movementsPreStim(iExpt).events,AdjIPAmplsByExpt(iExpt).data(iROI,:));
        %scatter(movement,allAdjIPAmpls(iROI,:));
        if iROI == 1; ylabel(exptIndexLabels{iExpt}); end 
        stdYbyROI(iROI,iExpt) = std(AdjIPAmplsByExpt(iExpt).data(iROI,:));
        xlabel('movement/magnet magnitude');
        ax = gca;
        ax.XScale = 'log';
        if iExpt == 1; ax.Title.String = ROILabels{iROI}; end
    end
end
outlierMove = mean(mean(stdYbyROI,2))*3;
for iExpt = 1:nExpts
    for iROI = 1:nROIs
        if outlierMove > stdYbyROI(iROI,iExpt)
            scaleThisPlot(iROI,iExpt) = true;
            maxYbyROI(iROI,iExpt) = max(AdjIPAmplsByExpt(iExpt).data(iROI,:));
            minYbyROI(iROI,iExpt) = min(AdjIPAmplsByExpt(iExpt).data(iROI,:));
        else
            scaleThisPlot(iROI,iExpt) = false;
        end
    end
end
for iExpt = 1:nExpts
    for iROI = 1:nROIs
        if scaleThisPlot(iROI,iExpt) == true
            subtightplot(nExpts,nROIs,(iExpt-1)*nExpts+iROI);
            ax = gca;
            ax.YLim = [min(minYbyROI(iROI,:))*1.05,max(maxYbyROI(iROI,:))*1.05];
        else
            disp('Warning! Noise detected. Inspect traces.');
            subtightplot(nExpts,nROIs,(iExpt-1)*nExpts+iROI);
            scatter(movementsPreStim(iExpt).events,AdjIPAmplsByExpt(iExpt).data(iROI,:),'r');
        end
    end
end
% fileName = ['M:\PassiveEphys\AnimalData\' animal '\' figureName];
% print('-painters',fileName,'-r300','-dpng');
% try
%     desc = figureName;
%     sendSlackFig(desc,[fileName '.png']);
% catch
%     disp(['failed to upload ' fileName ' to Slack']);
end








