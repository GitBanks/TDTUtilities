function plotSpectraEEG(animalName,exptDate)
% test params
% animalName = 'EEG210';
% exptDate = '22629';

% nChans = 4;
% NOTE: a better way to do this would be to pull channel labels since they
% may vary by animal
%legendLabels = {'Anterior R vs Posterior R','Anterior R vs Posterior L','Anterior L vs Posterior R','Anterior L vs Posterior L'};

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

plotText = ''; % this will go into the plot title.  Get this from the database.

load([folder file]);

% load and plot - edit for specific recording type and channels
listOfSegments = fields(out.specAnalysis{1,1});




% For EEG, we want to compare anterior electrodes to posterior
%plottingArray = nan(nChans,nChans,size(listOfSegments,1));
for iSegment = 1:size(listOfSegments,1)
    thisSeg = listOfSegments{iSegment};
    Ch1(iSegment,:) = log2(out.specAnalysis{1,1}.(thisSeg).powspctrm(1,:));
    Ch2(iSegment,:) = log2(out.specAnalysis{1,1}.(thisSeg).powspctrm(2,:));
    Ch3(iSegment,:) = log2(out.specAnalysis{1,1}.(thisSeg).powspctrm(3,:));
    Ch4(iSegment,:) = log2(out.specAnalysis{1,1}.(thisSeg).powspctrm(4,:));
end
freqLabels = out.specAnalysis{1,1}.(thisSeg).freq;
Ch1 = Ch1';
Ch2 = Ch2';
Ch3 = Ch3';
Ch4 = Ch4';

windowTimes = out.segmentTimeOfDay{1,1};
[exptDate_dbForm] = houseConvertDateTo_dbForm(exptDate);
windowTimes = datetime(exptDate_dbForm)+windowTimes;

[S] = getMoveTimeDrugbyAnimalDate(animalName,exptDate);
moveTimes = S.fullTimeArrayTOD;
moveArray = S.fullMoveStream;
TheseDrugs = S.drugTOD;


figure()





% Matt's suggestion


subtightplot(5,1,1);
colormap('jet')
pcolor(windowTimes,log2(freqLabels),Ch1)
shading flat
axis xy;colorbar('eastoutside');
ylim([log2(freqLabels(1)) log2(freqLabels(end))]);
set(gca,'fontsize',10);
set(gca,'ytick',log2([2 4 8 16 30 50]),'yticklabel',string([2 4 8 16 30 50]));
ylabel('Hz');
xlabel('time')
%caxis([-15 10]);

subtightplot(5,1,2);
colormap('jet')
pcolor(windowTimes,log2(freqLabels),Ch2)
shading flat
axis xy;colorbar('eastoutside');
ylim([log2(freqLabels(1)) log2(freqLabels(end))]);
set(gca,'fontsize',10);
set(gca,'ytick',log2([2 4 8 16 30 50]),'yticklabel',string([2 4 8 16 30 50]));
ylabel('Hz');
xlabel('time')
%caxis([-15 10]);

subtightplot(5,1,3);
colormap('jet')
pcolor(windowTimes,log2(freqLabels),Ch3)
shading flat
axis xy;colorbar('eastoutside');
ylim([log2(freqLabels(1)) log2(freqLabels(end))]);
set(gca,'fontsize',10);
set(gca,'ytick',log2([2 4 8 16 30 50]),'yticklabel',string([2 4 8 16 30 50]));
ylabel('Hz');
xlabel('time')
%caxis([-15 10]);

subtightplot(5,1,4);
colormap('jet')
pcolor(windowTimes,log2(freqLabels),Ch4)
shading flat
axis xy;colorbar('eastoutside');
ylim([log2(freqLabels(1)) log2(freqLabels(end))]);
set(gca,'fontsize',10);
set(gca,'ytick',log2([2 4 8 16 30 50]),'yticklabel',string([2 4 8 16 30 50]));
ylabel('Hz');
xlabel('time')
%caxis([-15 10]);

% Movement here (loaded previously)
subtightplot(5,1,5);
plot(moveTimes, moveArray);
ylabel('Movement');
xlim([moveTimes(1),moveTimes(end)]);
ylim([0,max(moveArray)*1.2]);
% indicate where manipulations took place.
% loop through drug injections here
for iDrugInj = 1:size(TheseDrugs,2)
    thisDrugTime = TheseDrugs(iDrugInj).time;
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