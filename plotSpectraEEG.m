function summaryData = plotSpectraEEG(animalName,exptDate,chansToExclude,setName,reportPlot,skipTheActualPlotting)
% test params
% animalName = 'EEG200';
% exptDate = '22614';
% chansToExclude = NaN;
% chansToExclude = 4;
if ~exist('reportPlot','var')
    reportPlot = true;
end
if ~exist('skipTheActualPlotting','var')
    skipTheActualPlotting = false;
end

if contains(setName,'ZZ') 
    error('This code only set up for EEG mice, not LFP / ZZ mice');
end
saveFolder = getPathGlobal([setName '-savePath']);


if iscell(chansToExclude)
    chansToExclude = chansToExclude{:};
end
if ischar(chansToExclude)
    chansToExclude = str2num(chansToExclude);
end

% save some specific data for Matt
summaryData = struct;

%legLabels = {'Ch1','Ch2','Ch3','Ch4','Ch5','Ch6'};
legLabels = {'Pre inj 1','Pre inj 2','Post inj 1','Post inj 2','Post inj 3','Post inj 4'};
plotTitleLabels = {'R Anterior','R Posterior','L Posterior','L Anterior'};
% no, do better.  load this from database!
% we're also going to run into trouble if this isn't the EEG.  What we need
% to do is reference the mapping files we make for each animal, then base
% which subplots to make on that...

folder = [getPathGlobal('pipelineSaves') animalName '\']; % data from the pipeline 
chanEEGRemap = [2,4,3,1]; % direct channels to specific subplots so that channels line up with their physical locations
% the file will be some crazy thing like this:
% 'EEG210_22629-001,22629-003,22629-005,22629-007,22629-009,22629-011 wPLI_dbt'; 
% instead, we'll search for it.
dataFolder = dir(folder);
for iFile = 1:size(dataFolder,1)
    if contains(dataFolder(iFile).name,'specAnalysis') && contains(dataFolder(iFile).name,exptDate) 
        file = dataFolder(iFile).name;
    end
end
if ~exist('file','var')
    error(['Found ' dataFolder(1).folder ' but not the file we''re looking for!']);
end

load([folder file]); %careful! what if there's another file with a similar name?  as written, the code will just load the last one it found, but that's not certainly the correct one...




% load and plot - edit for specific recording type and channels
listOfSegments = fields(out.specAnalysis{1,1});
% grab the labels / values for the frequencies
freqLabels = out.specAnalysis{1,1}.(listOfSegments{1}).freq;
% For EEG, we want to compare anterior electrodes to posterior
%plottingArray = nan(nChans,nChans,size(listOfSegments,1));
nChans = size(out.specAnalysis{1,1}.(listOfSegments{1}).powspctrm,1);
for iSegment = 1:size(listOfSegments,1)
    thisSeg = listOfSegments{iSegment};
    for iChan = 1:nChans
        specdataLog(iChan).data(iSegment,:) = real(log2(out.specAnalysis{1,1}.(thisSeg).powspctrm(iChan,:)));
        % taking the log2 of these is fine for the spectrogram, but the
        % units will get nonsensical without that context.  If we want to
        % look at average spectral power, we need the not log data too.
        specdata(iChan).data(iSegment,:) = real(out.specAnalysis{1,1}.(thisSeg).powspctrm(iChan,:));
    end
end

% also exclude channels here
if ~isnan(chansToExclude)
    for iChan = 1:size(chansToExclude,1)
        specdata(chansToExclude(iChan)).data(:,:) = nan;
        specdataLog(chansToExclude(iChan)).data(:,:) = nan;
    end
end



for iChan = 1:nChans
    specdataLog(iChan).data = specdataLog(iChan).data';
    specdata(iChan).data = specdata(iChan).data';
end



windowTimes = out.segmentTimeOfDay{1,1};
[exptDate_dbForm] = houseConvertDateTo_dbForm(exptDate);
windowTimes = datetime(exptDate_dbForm,'TimeZone','local')+windowTimes;
[moveTimeDrugStruct] = getMoveTimeDrugbyAnimalDate(animalName,exptDate,false);
moveTimes = moveTimeDrugStruct.fullTimeArrayTOD;
moveArray = moveTimeDrugStruct.fullMoveStream;
TheseDrugs = moveTimeDrugStruct.drugTOD;

% t = 0 should be injection;  
% WARNING!  this assumes that the last injection is the one to ref as t=0
adjTimes = windowTimes-TheseDrugs(end).time;
adjMoveTimes = moveTimes-TheseDrugs(end).time;
% we will need to break apart the avgSpectra based on drug injection times,
% then hour lengths after 2nd injection, so grab these times here, too
for iDrugInj = 1:size(TheseDrugs,2)
    TheseDrugs(iDrugInj).adjTime = TheseDrugs(iDrugInj).time-TheseDrugs(end).time;
    injTimeList(iDrugInj) = TheseDrugs(iDrugInj).adjTime;
end
injTimeList = unique(injTimeList); % need to reset this and rerun it through to set up the correct hours
for iDrugInj = 1:size(injTimeList,2)
    avgSpectraBreakIndex(iDrugInj) = find(adjTimes>injTimeList(iDrugInj),1);
    movementBreakIndex(iDrugInj) = find(adjMoveTimes>injTimeList(iDrugInj),1);
end

% continue finding breakpoints
moreTime = true;
breakIndex = size(avgSpectraBreakIndex,2)+1;
nextTime = injTimeList(iDrugInj)+hours(1);
while moreTime
    avgSpectraBreakIndex(breakIndex) = find(adjTimes>nextTime,1);
    movementBreakIndex(breakIndex) = find(adjMoveTimes>nextTime,1);
    breakIndex = breakIndex+1;
    nextTime = nextTime+hours(1);
    if adjTimes(end) < nextTime
        moreTime = false;
    end
end


% combine front and rear for bandpower analysis
% warning!  hardcoded channels for now!!!  fix this via database!!!!
% I don;t like the way I wrote this, but if either of a front/rear pair is
% naned out, just make the final 'combined' data to good channel.  I don't
% know if anything needs to be done otherwise (like error / scaling thing)
if any(any(isnan(specdata(1).data))) || any(any(isnan(specdata(4).data)))
    if any(any(isnan(specdata(1).data))) 
        combSpecdata(1).data = specdata(4).data;
    else
        combSpecdata(1).data = specdata(1).data;
    end
else
    combSpecdata(1).data = (specdata(1).data+specdata(4).data)/2;
end
if any(any(isnan(specdata(2).data))) || any(any(isnan(specdata(3).data)))
    if any(any(isnan(specdata(2).data)))
        combSpecdata(2).data = specdata(3).data;
    else
        combSpecdata(2).data = specdata(2).data;
    end
else
    combSpecdata(2).data = (specdata(2).data+specdata(3).data)/2;
end


avgSpectraBreakIndex = [1 avgSpectraBreakIndex];
movementBreakIndex = [1 movementBreakIndex];

for iHour = 1:size(avgSpectraBreakIndex,2)-1
    iStart = avgSpectraBreakIndex(iHour);
    iStop = avgSpectraBreakIndex(iHour+1)-1;
    for iChan = 1:nChans % for average spectra
        dataSet(iHour).avgSpectra(:,iChan) = mean(specdata(iChan).data(:,iStart:iStop),2,'omitnan');
    end
    dataSet(iHour).movement = moveArray(movementBreakIndex(iHour):movementBreakIndex(iHour+1)-1);
    dataSet(iHour).movementTimes = adjMoveTimes(movementBreakIndex(iHour):movementBreakIndex(iHour+1)-1);
    dataSet(iHour).time = adjTimes(iStart:iStop);
    for iChan = 1:2 % bandpower only uses front and rear. this should be done better, but...
        % also break spectra into bands like the undergrad homework assignment:
        % will be much better to break this out into a function so we're
        % not repeating ourselves, but this will work for now.
        % Delta
        bounds(1) = find(freqLabels>=FreqBands.Limits.delta(1),1);
        bounds(2) = find(freqLabels>=FreqBands.Limits.delta(2),1);
        dataSet(iHour).delta(:,iChan) = mean(combSpecdata(iChan).data(bounds(1):bounds(2),iStart:iStop),1,'omitnan');
        dataSet(iHour).avgDelta(:,iChan) = mean(dataSet(iHour).delta(:,iChan),'omitnan');
        % Theta
        bounds(1) = find(freqLabels>=FreqBands.Limits.theta(1),1);
        bounds(2) = find(freqLabels>=FreqBands.Limits.theta(2),1);
        dataSet(iHour).theta(:,iChan) = mean(combSpecdata(iChan).data(bounds(1):bounds(2),iStart:iStop),1,'omitnan');
        dataSet(iHour).avgTheta(:,iChan) = mean(dataSet(iHour).theta(:,iChan),'omitnan');
        % Alpha
        bounds(1) = find(freqLabels>=FreqBands.Limits.alpha(1),1);
        bounds(2) = find(freqLabels>=FreqBands.Limits.alpha(2),1);
        dataSet(iHour).alpha(:,iChan) = mean(combSpecdata(iChan).data(bounds(1):bounds(2),iStart:iStop),1,'omitnan');
        dataSet(iHour).avgAlpha(:,iChan) = mean(dataSet(iHour).alpha(:,iChan),'omitnan');
        % Beta
        bounds(1) = find(freqLabels>=FreqBands.Limits.beta(1),1);
        bounds(2) = find(freqLabels>=FreqBands.Limits.beta(2),1);
        dataSet(iHour).beta(:,iChan) = mean(combSpecdata(iChan).data(bounds(1):bounds(2),iStart:iStop),1,'omitnan');
        dataSet(iHour).avgBeta(:,iChan) = mean(dataSet(iHour).beta(:,iChan),'omitnan');
        % Gamma
        bounds(1) = find(freqLabels>=FreqBands.Limits.gamma(1),1);
        bounds(2) = find(freqLabels>=FreqBands.Limits.highGamma(2),1);
        dataSet(iHour).gamma(:,iChan) = mean(combSpecdata(iChan).data(bounds(1):bounds(2),iStart:iStop),1,'omitnan');
        dataSet(iHour).avgGamma(:,iChan) = mean(dataSet(iHour).gamma(:,iChan),'omitnan');
    end
end


% this is really ugly hardcoding.  FIX THIS!
summaryData.pre.move = mean(dataSet(1).movement);
summaryData.post.move = mean(dataSet(4).movement);
summaryData.pre.avgDelta = dataSet(1).avgDelta;
summaryData.pre.avgTheta = dataSet(1).avgTheta;
summaryData.pre.avgAlpha = dataSet(1).avgAlpha;
summaryData.pre.avgBeta = dataSet(1).avgBeta;
summaryData.pre.avgGamma = dataSet(1).avgGamma;
summaryData.post.avgDelta = dataSet(4).avgDelta;
summaryData.post.avgTheta = dataSet(4).avgTheta;
summaryData.post.avgAlpha = dataSet(4).avgAlpha;
summaryData.post.avgBeta = dataSet(4).avgBeta;
summaryData.post.avgGamma = dataSet(4).avgGamma;
summaryData.TheseDrugs = TheseDrugs;



save([saveFolder animalName '_' exptDate '_bandpowerSet.mat'],"dataSet");


if skipTheActualPlotting
    return
end





% % normalize (Bryan is working on this)
% norm =  length(data) * bandTFR.bandwidth / (1+bandTFR.upsampleFx);
% PSD = sum(abs(bandTFR.blrep).^2)/norm;



%  ======= Plotting bandpower =============================================

if size(TheseDrugs,2) > 1
    titletext = [animalName ' Bandpower over time for ' exptDate ' ' TheseDrugs(1).what ' & ' TheseDrugs(2).what];
    savetext = [TheseDrugs(1).what '_' TheseDrugs(2).what];
else
    titletext = [animalName ' Bandpower over time for ' exptDate ' ' TheseDrugs(1).what];
    savetext = TheseDrugs(1).what;
end

bandPower = figure('Name',titletext); 
for iHour = 1:size(dataSet,2)
    subtightplot(6,1,1);
    title(titletext);
    plot(dataSet(iHour).time,dataSet(iHour).delta(:,1),"Color",'r');
    hold on
    plot(dataSet(iHour).time,dataSet(iHour).delta(:,2),"Color",'b');
    ylabel('delta power');

    subtightplot(6,1,2);
    plot(dataSet(iHour).time,dataSet(iHour).theta(:,1),"Color",'r');
    hold on
    plot(dataSet(iHour).time,dataSet(iHour).theta(:,2),"Color",'b');
    ylabel('theta power');

    subtightplot(6,1,3);
    plot(dataSet(iHour).time,dataSet(iHour).alpha(:,1),"Color",'r');
    hold on
    plot(dataSet(iHour).time,dataSet(iHour).alpha(:,2),"Color",'b');
    ylabel('alpha power');

    subtightplot(6,1,4);
    plot(dataSet(iHour).time,dataSet(iHour).beta(:,1),"Color",'r');
    hold on
    plot(dataSet(iHour).time,dataSet(iHour).beta(:,2),"Color",'b');
    ylabel('beta power')

    subtightplot(6,1,5);
    plot(dataSet(iHour).time,dataSet(iHour).gamma(:,1),"Color",'r');
    hold on
    plot(dataSet(iHour).time,dataSet(iHour).gamma(:,2),"Color",'b');
    ylabel('gamma power');

    subtightplot(6,1,6);
    plot(adjMoveTimes, moveArray);
    ylabel('Movement');
    ylim([0,max(moveArray)*1.2]);
end
subtightplot(6,1,5);
legend({'Front','Rear'});
for i = 1:6
    subtightplot(6,1,i);
    xlim([adjMoveTimes(1),adjMoveTimes(end)]);
end



if ~exist([saveFolder 'bandpower\'],"dir")
    mkdir([saveFolder 'bandpower\']);
end
saveas(bandPower,[saveFolder 'bandpower\' animalName '-' exptDate '-' savetext '.fig']);
saveas(bandPower,[saveFolder 'bandpower\' animalName '-' exptDate '-' savetext '.jpg']);



% ======= Plotting average spectral power =================================


if size(TheseDrugs,2) > 1
    titletext = [animalName ' average spectral power for ' exptDate ' ' TheseDrugs(1).what ' & ' TheseDrugs(2).what];
    savetext = [TheseDrugs(1).what '_' TheseDrugs(2).what];
else
    titletext = [animalName ' average spectral power for ' exptDate ' ' TheseDrugs(1).what];
    savetext = TheseDrugs(1).what;
end

getYMax = nan;
getYMin = nan;
for iHour = 1:size(dataSet,2)
    getYMax = max(max(max(dataSet(iHour).avgSpectra)),getYMax);
    getYMin = max(min(min(dataSet(iHour).avgSpectra)),getYMin);
end

avgspectra = figure('Name',titletext); 
for iChan = 1:nChans
    subplot(2,2,chanEEGRemap(iChan));
%     subtightplot(2,2,chanEEGRemap(iChan),[0.04,0.01]);
    for iHour = 1:size(dataSet,2)
        loglog(freqLabels,dataSet(iHour).avgSpectra(:,iChan)); 
        hold on
    end
    
    %ylabel('Power (mV^2)');  % this is wrong... stop showing the wrong thing...
    
    ylim([getYMin*1.1,getYMax*1.1]);
    title(['Ch' num2str(iChan) ' ' plotTitleLabels{iChan}],'Interpreter', 'none');
end


for iChan = 1:nChans
%     subtightplot(2,2,iChan,[0.04,0.01]);
    subplot(2,2,iChan);

    if iChan == 1
        set(gca,'xticklabel',{[]});
    end
    if iChan == 2
        set(gca,'xticklabel',{[]});
        set(gca,'yticklabel',{[]});
    end
    if iChan == 3
        xlabel('Freq');
        legend(legLabels,'Location','southwest','FontSize',5);
        ylabel('Power (mV^2)')
    end
    if iChan == 4
        set(gca,'yticklabel',{[]});
    end
end
sgtitle([animalName '-' exptDate '-' savetext],'Interpreter', 'none');

if ~exist([saveFolder 'avgspectra\'],"dir")
    mkdir([saveFolder 'avgspectra\']);
end
fileName = [saveFolder 'avgspectra\' animalName '-' exptDate '-' savetext];
saveas(avgspectra,[fileName '.fig']);
saveas(avgspectra,[fileName '.jpg']);


print('-painters',fileName,'-r300','-dpng');
if reportPlot
    try
        sendSlackFig([animalName '-' exptDate '-' savetext],[fileName '.png']);
    catch
        disp(['failed to upload ' fileName ' to Slack']);
    end
end





% ======= Plotting spectrogram and movement ===============================

if size(TheseDrugs,2) > 1
    titletext = [animalName ' spectrogram and movement for ' exptDate ' ' TheseDrugs(1).what ' & ' TheseDrugs(2).what];
    savetext = [TheseDrugs(1).what '_' TheseDrugs(2).what];
else
    titletext = [animalName ' spectrogram and movement for ' exptDate ' ' TheseDrugs(1).what];
    savetext = TheseDrugs(1).what;
end

spectrogramFig = figure('Name',titletext);
for iChan = 1:nChans
    subtightplot(nChans+1,1,iChan);
    colormap('jet')
    pcolor(adjTimes,log2(freqLabels),specdataLog(iChan).data)
    shading flat
    axis xy; %colorbar('east');
    if iChan == nChans; colorbar('east'); end
    ylim([log2(freqLabels(1)) log2(freqLabels(end))]);
    set(gca,'fontsize',10);
    set(gca,'ytick',log2([2 4 8 16 30 50]),'yticklabel',string([2 4 8 16 30 50]));
    ylabel('Hz');
    xlabel('time');
end
% Movement here (loaded previously)
subtightplot(nChans+1,1,nChans+1);
plot(adjMoveTimes, moveArray);
ylabel('Movement');
xlim([adjMoveTimes(1),adjMoveTimes(end)]);
ylim([0,max(moveArray)*1.2]);
% indicate where manipulations took place.
% loop through drug injections here
for iDrugInj = 1:size(TheseDrugs,2)
    thisDrugTime = TheseDrugs(iDrugInj).adjTime;
    thisDrugName = [TheseDrugs(iDrugInj).what ' ' num2str(TheseDrugs(iDrugInj).amount)];
    xline(thisDrugTime,'-',thisDrugName);
end
sgtitle([animalName '-' exptDate '-' savetext],'Interpreter', 'none');

if ~exist([saveFolder 'spectrogram\'],"dir")
    mkdir([saveFolder 'spectrogram\']);
end
saveas(spectrogramFig,[saveFolder 'spectrogram\' animalName '-' exptDate '-' savetext '.fig']);
saveas(spectrogramFig,[saveFolder 'spectrogram\' animalName '-' exptDate '-' savetext '.jpg']);
























% %%% ================= Movement from pipeline example ====================
% fileList = out.block;
% listToUse = strsplit(fileList,',');
% 
% % we also need metadata - change animal name
% metadataPath = ['M:\PassiveEphys\AnimalData\' animalName '\metadata.mat'];
% load(metadataPath);
% 
% %Pick out the times for the movement events
% theseTimes = metaData(contains(metaData.block,listToUse),:).blockTime;
% 
% conditionsList = strsplit(out.conditions,',');
% for i = 1:length(listToUse)
%     thisExptIndex = char(listToUse(i));
%     [magData,magDT] = HTRMagLoadData(thisExptIndex);
%     dataToPlot = smooth(abs(magData-mean(magData)),(1/magDT)*4,'sgolay',2);
%     tempText = strrep(thisExptIndex,'-','_');
%     loadedData.(['blk' tempText]) = dataToPlot;
%     
%     
%     segTime = out.analysisOptions(1,1).segTime;
%     splitTime = out.analysisOptions(1,1).splitTime;
%     fs = 1/magDT;
%     
%     conditions{i} = char(conditionsList(i));
%     blockTime.(['blk' tempText]) = theseTimes(i);
% end
% 
% [loadedData,segmentTimeData] = patientAnalysis.segmentData(loadedData,blockTime,conditions,1/fs,splitTime,segTime);
% 
% actionList = fields(loadedData);
% for i = 1:size(fields(loadedData),1)
%     %thisTime = metaData(contains(actionList(i),segmentTimeData)).blockTime;
%     time(i) = getfield(segmentTimeData,actionList{i});
%     meanMove(i) = mean(getfield(loadedData,actionList{i}));
% end
% 
% 
% % =======================Plot The Movement=====================
% subplot(2,1,2)
% plot(windowTimes, meanMove);
% title('Movement Across Time')
% %xline(line,'-','Psilocybin')

% ======================= previous way of plotting  =====================
% subtightplot(5,1,1);
% imagesc(Ch1);
% yticks(1:24);
% yticklabels(fliplr(freqLabels));
% ylabel('Chan1');
% 
% subtightplot(5,1,2);
% imagesc(Ch2);
% yticks(1:24);
% yticklabels(fliplr(freqLabels));
% ylabel('Chan2');
% 
% subtightplot(5,1,3);
% imagesc(Ch3);
% yticks(1:24);
% yticklabels(fliplr(freqLabels));
% ylabel('Chan3');
% 
% subtightplot(5,1,4);
% imagesc(Ch4);
% yticks(1:24);
% yticklabels(fliplr(freqLabels));
% ylabel('Chan4');