%% =============================  WPLI ===========================
% Load saved data
% final save location will be something like M:\PassiveEphys\AnimalData\initial\ZZ14\
% Full load command will be something like:
folder = 'M:\PassiveEphys\AnimalData\initial\ZZ14\';
file = 'ZZ14_22120-000,22120-003,22120-004,22120-005,22120-006 wPLI_dbt-ZZMouseOptionsNoSubSegLength20';
load([folder file]);

% load and plot - edit for specific recording type and channels
listOfSegments = fields(out.wPLI_dbt{1,1});
bandOfInterest = 'alpha';
nChans = 6;

% ================= Plot for ipsi mPFC x contra mPFC =================
%Create a list of channel pairs we want to look through then have it look
%through the pairs ipsi mPFCxcontra mPFC - PULL IN WHERE I AM LABELING THE
%CHANNELS AND PULL FROM THAT - out.ECoGchannels{1,1}.oldROI
%strcmp([out.ECoGchannels{1,1}.oldROI],'LFP L mPFC')
%create an empty array

plottingArray = nan(nChans,nChans,size(listOfSegments,1));
for iSegment = 1:size(listOfSegments,1)
    thisSeg = listOfSegments{iSegment};
    %plottingArray(:,:,iSegment) = out.wPLI_dbt{1,1}.(thisSeg).wPLI_debias.(bandOfInterest);
    ChannelPairDisplay(1,iSegment) = out.wPLI_dbt{1,1}.(thisSeg).wPLI_debias.(bandOfInterest)(1,3);
    ChannelPairDisplay(2,iSegment) = out.wPLI_dbt{1,1}.(thisSeg).wPLI_debias.(bandOfInterest)(1,4);
    ChannelPairDisplay(3,iSegment) = out.wPLI_dbt{1,1}.(thisSeg).wPLI_debias.(bandOfInterest)(2,3);
    ChannelPairDisplay(4,iSegment) = out.wPLI_dbt{1,1}.(thisSeg).wPLI_debias.(bandOfInterest)(2,4);
end

for iSegment = 1:size(listOfSegments,1)
    thisSeg = listOfSegments{iSegment};
    %plottingArray(:,:,iSegment) = out.wPLI_dbt{1,1}.(thisSeg).wPLI_debias.(bandOfInterest);
    ChannelPairDisplay2(1,iSegment) = out.wPLI_dbt{1,1}.(thisSeg).wPLI_debias.(bandOfInterest)(3,5);
    ChannelPairDisplay2(2,iSegment) = out.wPLI_dbt{1,1}.(thisSeg).wPLI_debias.(bandOfInterest)(3,6);
    ChannelPairDisplay2(3,iSegment) = out.wPLI_dbt{1,1}.(thisSeg).wPLI_debias.(bandOfInterest)(4,5);
    ChannelPairDisplay2(4,iSegment) = out.wPLI_dbt{1,1}.(thisSeg).wPLI_debias.(bandOfInterest)(4,6);
end
windowTimes = out.segmentTimeOfDay{1,1};

windowGaps = diff(windowTimes);
largeWindowGapLocations = find(windowGaps>median(windowGaps));

tempWindowTimes = windowTimes;
for ii = 1:size(largeWindowGapLocations,1)
    gapTimeLength = windowGaps(largeWindowGapLocations(ii));
    gapIndex = largeWindowGapLocations(ii); % this will be the last element befor the discontinuity
    tempWindowTimes(gapIndex+1:end) = tempWindowTimes(gapIndex+1:end) - gapTimeLength;
end

tempWindowTimes = tempWindowTimes(:) - tempWindowTimes(1);

line = tempWindowTimes(largeWindowGapLocations(1));

figure();
subplot(3,1,1)
plot(tempWindowTimes,ChannelPairDisplay);
title('WPLI Alpha Band Connectivity with Psilocbyin Ipsi mPFC x contra mPFC');
xline(line,'-','Psilocybin')

subplot(3,1,2)
plot(tempWindowTimes,ChannelPairDisplay2);
title('WPLI Alpha Band Connectivity with Psilocbyin Contra mPFC x Contra vCA1')
xline(line,'-','Psilocybin')

%%% ==================== Movement =========================
fileList = out.block;
listToUse = strsplit(fileList,',');

% we also need metadata - change animal name
metadataPath = 'M:\PassiveEphys\AnimalData\ZZ14\metadata.mat';
load(metadataPath);

%Pick out the times for the movement events
theseTimes = metaData(contains(metaData.block,listToUse),:).blockTime;

conditionsList = strsplit(out.conditions,',');
for i = 1:length(listToUse);
    thisExptIndex = char(listToUse(i));
    [magData,magDT] = HTRMagLoadData(thisExptIndex);
    dataToPlot = smooth(abs(magData-mean(magData)),(1/magDT)*4,'sgolay',2);
    tempText = strrep(thisExptIndex,'-','_');
    loadedData.(['blk' tempText]) = dataToPlot;
    
    
    segTime = out.analysisOptions(1,1).segTime;
    splitTime = out.analysisOptions(1,1).splitTime;
    fs = 1/magDT;
    
    conditions{i} = char(conditionsList(i));
    blockTime.(['blk' tempText]) = theseTimes(i);
end

[loadedData,segmentTimeData] = patientAnalysis.segmentData(loadedData,blockTime,conditions,1/fs,splitTime,segTime);

actionList = fields(loadedData);
for i = 1:size(fields(loadedData),1)
    %thisTime = metaData(contains(actionList(i),segmentTimeData)).blockTime;
    time(i) = getfield(segmentTimeData,actionList{i});
    meanMove(i) = mean(getfield(loadedData,actionList{i}));
end


% =======================Plot The Movement=====================
subplot(3,1,3)
plot(tempWindowTimes, meanMove);
title('Movement Across Time')
xline(line,'-','Psilocybin')

