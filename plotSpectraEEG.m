function mattsData = plotSpectraEEG(animalName,exptDate,chansToExclude)
% test params
% animalName = 'EEG200';
% exptDate = '22614';
% chansToExclude = NaN;
% chansToExclude = 4;

% save some specific data for Matt
mattsData = struct;


%legLabels = {'Ch1','Ch2','Ch3','Ch4','Ch5','Ch6'};
legLabels = {'Pre inj 1','Pre inj 2','Post inj 1','Post inj 2','Post inj 3','Post inj 4'};
plotTitleLabels = {'R Anterior','R Posterior','L Posterior','L Anterior'};
% no, do better.  load this from database!
% we're also going to run into trouble if this isn't the EEG.  What we need
% to do is reference the mapping files we make for each animal, then base
% which subplots to make on that...

folder = ['M:\PassiveEphys\AnimalData\initial\' animalName '\']; % data from the pipeline 
saveFolder = 'M:\PassiveEphys\AnimalData\Fluvoxamine-LPS\';
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
        specdataLog(iChan).data(iSegment,:) = log2(out.specAnalysis{1,1}.(thisSeg).powspctrm(iChan,:));
        % taking the log2 of these is fine for the spectrogram, but the
        % units will get nonsensical without that context.  If we want to
        % look at average spectral power, we need the not log data too.
        specdata(iChan).data(iSegment,:) = out.specAnalysis{1,1}.(thisSeg).powspctrm(iChan,:);
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

[moveTimeDrugStruct] = getMoveTimeDrugbyAnimalDate(animalName,exptDate);
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
    avgSpectraBreakIndex(iDrugInj) = find(adjTimes>TheseDrugs(iDrugInj).adjTime,1);
    movementBreakIndex(iDrugInj) = find(adjMoveTimes>TheseDrugs(iDrugInj).adjTime,1);
end

% continue finding breakpoints
moreTime = true;
breakIndex = size(avgSpectraBreakIndex,2)+1;
nextTime = TheseDrugs(iDrugInj).adjTime+hours(1);
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
        hourSt(iHour).avgSpectra(:,iChan) = mean(specdata(iChan).data(:,iStart:iStop),2,'omitnan');
    end
    hourSt(iHour).movement = moveArray(movementBreakIndex(iHour):movementBreakIndex(iHour+1)-1);
    hourSt(iHour).movementTimes = adjMoveTimes(movementBreakIndex(iHour):movementBreakIndex(iHour+1)-1);
    hourSt(iHour).time = adjTimes(iStart:iStop);
    for iChan = 1:2 % bandpower only uses front and rear. this should be done better, but...
        % also break spectra into bands like the undergrad homework assignment:
        % will be much better to break this out into a function so we're
        % not repeating ourselves, but this will work for now.
        % Delta
        bounds(1) = find(freqLabels>=FreqBands.Limits.delta(1),1);
        bounds(2) = find(freqLabels>=FreqBands.Limits.delta(2),1);
        hourSt(iHour).delta(:,iChan) = mean(combSpecdata(iChan).data(bounds(1):bounds(2),iStart:iStop),1);
        hourSt(iHour).avgDelta(:,iChan) = mean(hourSt(iHour).delta(:,iChan));
        % Theta
        bounds(1) = find(freqLabels>=FreqBands.Limits.theta(1),1);
        bounds(2) = find(freqLabels>=FreqBands.Limits.theta(2),1);
        hourSt(iHour).theta(:,iChan) = mean(combSpecdata(iChan).data(bounds(1):bounds(2),iStart:iStop),1);
        hourSt(iHour).avgTheta(:,iChan) = mean(hourSt(iHour).theta(:,iChan));
        % Alpha
        bounds(1) = find(freqLabels>=FreqBands.Limits.alpha(1),1);
        bounds(2) = find(freqLabels>=FreqBands.Limits.alpha(2),1);
        hourSt(iHour).alpha(:,iChan) = mean(combSpecdata(iChan).data(bounds(1):bounds(2),iStart:iStop),1);
        hourSt(iHour).avgAlpha(:,iChan) = mean(hourSt(iHour).alpha(:,iChan));
        % Beta
        bounds(1) = find(freqLabels>=FreqBands.Limits.beta(1),1);
        bounds(2) = find(freqLabels>=FreqBands.Limits.beta(2),1);
        hourSt(iHour).beta(:,iChan) = mean(combSpecdata(iChan).data(bounds(1):bounds(2),iStart:iStop),1);
        hourSt(iHour).avgBeta(:,iChan) = mean(hourSt(iHour).beta(:,iChan));
        % Gamma
        bounds(1) = find(freqLabels>=FreqBands.Limits.gamma(1),1);
        bounds(2) = find(freqLabels>=FreqBands.Limits.highGamma(2),1);
        hourSt(iHour).gamma(:,iChan) = mean(combSpecdata(iChan).data(bounds(1):bounds(2),iStart:iStop),1);
        hourSt(iHour).avgGamma(:,iChan) = mean(hourSt(iHour).gamma(:,iChan));
    end
end



mattsData.pre.move = mean(hourSt(1).movement);
mattsData.post.move = mean(hourSt(4).movement);
mattsData.pre.avgDelta = hourSt(1).avgDelta;
mattsData.pre.avgTheta = hourSt(1).avgTheta;
mattsData.pre.avgAlpha = hourSt(1).avgAlpha;
mattsData.pre.avgBeta = hourSt(1).avgBeta;
mattsData.pre.avgGamma = hourSt(1).avgGamma;
mattsData.post.avgDelta = hourSt(4).avgDelta;
mattsData.post.avgTheta = hourSt(4).avgTheta;
mattsData.post.avgAlpha = hourSt(4).avgAlpha;
mattsData.post.avgBeta = hourSt(4).avgBeta;
mattsData.post.avgGamma = hourSt(4).avgGamma;
mattsData.TheseDrugs = TheseDrugs;


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
for iHour = 1:size(hourSt,2)
    subtightplot(6,1,1);
    title(titletext);
    plot(hourSt(iHour).time,hourSt(iHour).delta(:,1),"Color",'r');
    hold on
    plot(hourSt(iHour).time,hourSt(iHour).delta(:,2),"Color",'b');
    ylabel('delta power');

    subtightplot(6,1,2);
    plot(hourSt(iHour).time,hourSt(iHour).theta(:,1),"Color",'r');
    hold on
    plot(hourSt(iHour).time,hourSt(iHour).theta(:,2),"Color",'b');
    ylabel('theta power');

    subtightplot(6,1,3);
    plot(hourSt(iHour).time,hourSt(iHour).alpha(:,1),"Color",'r');
    hold on
    plot(hourSt(iHour).time,hourSt(iHour).alpha(:,2),"Color",'b');
    ylabel('alpha power');

    subtightplot(6,1,4);
    plot(hourSt(iHour).time,hourSt(iHour).beta(:,1),"Color",'r');
    hold on
    plot(hourSt(iHour).time,hourSt(iHour).beta(:,2),"Color",'b');
    ylabel('beta power')

    subtightplot(6,1,5);
    plot(hourSt(iHour).time,hourSt(iHour).gamma(:,1),"Color",'r');
    hold on
    plot(hourSt(iHour).time,hourSt(iHour).gamma(:,2),"Color",'b');
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
for iHour = 1:size(hourSt,2)
    getYMax = max(max(max(hourSt(iHour).avgSpectra)),getYMax);
    getYMin = max(min(min(hourSt(iHour).avgSpectra)),getYMin);
end

avgspectra = figure('Name',titletext); 
for iChan = 1:nChans
    subplot(2,2,chanEEGRemap(iChan));
%     subtightplot(2,2,chanEEGRemap(iChan),[0.04,0.01]);
    for iHour = 1:size(hourSt,2)
        loglog(freqLabels,hourSt(iHour).avgSpectra(:,iChan)); 
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

saveas(avgspectra,[saveFolder 'avgspectra\' animalName '-' exptDate '-' savetext '.fig']);
saveas(avgspectra,[saveFolder 'avgspectra\' animalName '-' exptDate '-' savetext '.jpg']);






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