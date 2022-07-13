function plotWPLIEEG(animalName,exptDate,bandOfInterest)

% animalName = 'EEG210';
% exptDate = '22629';
if ~exist('bandOfInterest','var')
    bandOfInterest = 'delta';
end


nChans = 4;
% NOTE: a better way to do this would be to pull channel labels since they
% may vary by animal
legendLabels = {'Anterior R vs Posterior R','Anterior R vs Posterior L','Anterior L vs Posterior R','Anterior L vs Posterior L'};

folder = ['M:\PassiveEphys\AnimalData\initial\' animalName '\'];

% the file will be some crazy thing like this:
% 'EEG210_22629-001,22629-003,22629-005,22629-007,22629-009,22629-011 wPLI_dbt'; 
% instead, we'll search for it.
dataFolder = dir(folder);
for iFile = 1:size(dataFolder,1)
    if contains(dataFolder(iFile).name,'wPLI_dbt') && contains(dataFolder(iFile).name,exptDate) 
        file = dataFolder(iFile).name;
    end
end

plotText = ''; % this will go into the plot title.  Get this from the database.

load([folder file]);

% load and plot - edit for specific recording type and channels
listOfSegments = fields(out.wPLI_dbt{1,1});

% For EEG, we want to compare anterior electrodes to posterior
%plottingArray = nan(nChans,nChans,size(listOfSegments,1));
for iSegment = 1:size(listOfSegments,1)
    thisSeg = listOfSegments{iSegment};
    %plottingArray(:,:,iSegment) = out.wPLI_dbt{1,1}.(thisSeg).wPLI_debias.(bandOfInterest);
    ChannelPairDisplay(1,iSegment) = out.wPLI_dbt{1,1}.(thisSeg).wPLI_debias.(bandOfInterest)(1,2);
    ChannelPairDisplay(2,iSegment) = out.wPLI_dbt{1,1}.(thisSeg).wPLI_debias.(bandOfInterest)(1,3);
    ChannelPairDisplay(3,iSegment) = out.wPLI_dbt{1,1}.(thisSeg).wPLI_debias.(bandOfInterest)(4,2);
    ChannelPairDisplay(4,iSegment) = out.wPLI_dbt{1,1}.(thisSeg).wPLI_debias.(bandOfInterest)(4,3);
end

windowTimes = out.segmentTimeOfDay{1,1};

[exptDate_dbForm] = houseConvertDateTo_dbForm(exptDate);
windowTimes = datetime(exptDate_dbForm)+windowTimes;

[S] = getMoveTimeDrugbyAnimalDate(animalName,exptDate);
moveTimes = S.fullTimeArrayTOD;
moveArray = S.fullMoveStream;
TheseDrugs = S.drugTOD;

figure();

subplot(2,1,1)
plot(windowTimes,ChannelPairDisplay);
title([animalName ' WPLI ' bandOfInterest ' Band Connectivity' plotText]);
legend(legendLabels);
xlim([windowTimes(1),windowTimes(end)]);

subplot(2,1,2)
plot(moveTimes, moveArray);
title([animalName ' Movement Across Time'])
xlim([moveTimes(1),moveTimes(end)]);
ylim([0,max(moveArray)*1.2]);

%loop through drug injections here
for iDrugInj = 1:size(TheseDrugs,2)
    thisDrugTime = TheseDrugs(iDrugInj).time;
    thisDrugName = [TheseDrugs(iDrugInj).what ' ' num2str(TheseDrugs(iDrugInj).amount)];
%     subplot(2,1,1);
%     xline(thisDrugTime,'-',thisDrugName);  % TODO Fix this datetime misalignment
    subplot(2,1,2);
    xline(thisDrugTime,'-',thisDrugName);
end








% %%% ==================== Movement =========================
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

