function plotSpectraEEG(animalName,exptDate)
% test params
% animalName = 'EEG210';
% exptDate = '22629';

legLabels = {'Ch1','Ch2','Ch3','Ch4','Ch5','Ch6'};

folder = ['M:\PassiveEphys\AnimalData\initial\' animalName '\'];



% the file will be some crazy thing like this:
% 'EEG210_22629-001,22629-003,22629-005,22629-007,22629-009,22629-011 wPLI_dbt'; 
% instead, we'll search for it.
dataFolder = dir(folder);
for iFile = 1:size(dataFolder,1)
    if contains(dataFolder(iFile).name,'specAnalysis') && contains(dataFolder(iFile).name,exptDate) 
        file = dataFolder(iFile).name;
    end
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
        specdata(iChan).data(iSegment,:) = log2(out.specAnalysis{1,1}.(thisSeg).powspctrm(iChan,:));
    end
end
for iChan = 1:nChans
    specdata(iChan).data = specdata(iChan).data';
end

windowTimes = out.segmentTimeOfDay{1,1};
[exptDate_dbForm] = houseConvertDateTo_dbForm(exptDate);
windowTimes = datetime(exptDate_dbForm,'TimeZone','local')+windowTimes;

[S] = getMoveTimeDrugbyAnimalDate(animalName,exptDate);
moveTimes = S.fullTimeArrayTOD;
moveArray = S.fullMoveStream;
TheseDrugs = S.drugTOD;

% t = 0 should be injection;  
% WARNING!  this assumes that the last injection is the one to ref as t=0
adjTimes = windowTimes-TheseDrugs(end).time;
adjMoveTimes = moveTimes-TheseDrugs(end).time;
for iDrugInj = 1:size(TheseDrugs,2)
    TheseDrugs(iDrugInj).adjTime = TheseDrugs(iDrugInj).time-TheseDrugs(end).time;
end


% find average spectra here
for iChan = 1:nChans
    avgSpectra(:,iChan) = mean(specdata(iChan).data,2);
end

if size(TheseDrugs,2) > 1
    titletext = [animalName ' average spectral power for ' exptDate ' ' TheseDrugs(1).what ' & ' TheseDrugs(2).what];
else
    titletext = [animalName ' average spectral power for ' exptDate ' ' TheseDrugs(1).what];
end

figure(); 
loglog(freqLabels,avgSpectra); 
legend(legLabels); 
title(titletext,'Interpreter', 'none'); 
ylabel('Power (mV^2)'); 
xlabel('Freq');






% plotting now
figure();

for iChan = 1:nChans
    subtightplot(nChans+1,1,iChan);
    colormap('jet')
    pcolor(adjTimes,log2(freqLabels),specdata(iChan).data)
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