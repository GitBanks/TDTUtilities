%This is to get the single trial peak data for in vivo LFP experiments and to plot single
%trial peaks

% .subMean will be (ROI x samples)
% .sub will be (ROI x trials x samples)
% 1. we can replace anything that says stimSet.subMean(iROI,:) with stimSet.sub(iROI,1,:)
% 2. wherever I am looping through the iROI i will have to loop through the
% trials
% 3. Smooth the curve wherever the data is plotted out
close all
clear all
exptTable = readtable('M:\Zarmeen\Data\SR Model Fits\SRTableComplete.csv');
for iExpt = 1:size(exptTable,1)
      
relevantROIs = {'mPFC', 'LFP R PFC'}; % labels in database can be any of these
% Window for analysis and plotting, relative to stim time
tPreStim = 0.05; %sec
tPostStim = 0.2; %sec
% Start searching for peaks and troughs of responses after this time
artifactDur = 2.e-3; %sec;
% Average over this window to get estimate of peak value
avgWinTime = 1.e-3; %sec; 
% Time window re stim time to calculate baseline value that is subtracted from peak values
baseWin = [-5,-0.5]*1.e-3; %sec; 
%hardcoded location - not ideal, but this works for now
%date = char(exptTable.Index{iExpt});

exptDate = '21624';
exptIndex = '006';
% exptDate = date(1:5);
% exptIndex = date(7:9);
fileString = [exptDate '-' exptIndex];
outPath = [getPathGlobal('M') 'PassiveEphys\20' exptDate(1:2) '\' fileString '\'];

animal = getAnimalByDateIndex(exptDate,exptIndex);
outPath2 = [getPathGlobal('M') 'PassiveEphys\AnimalData\' animal '\'];
if ~exist(outPath2,'dir')
    mkdir(outPath2);
end


%% load data
% will repeat this for the dual recordings to load in the parallel set

[~,indexOut,isTank] = getIsTank(exptDate,exptIndex);
[stimSet,dTRec,stimArray,stimTimes] = getSynapseStimSetData(exptDate,indexOut,tPreStim,tPostStim,isTank);
if contains(exptDate,'22705')
    for i = 1:size(stimSet,2)
        stimSet(i).data(1:2,:,:) = stimSet(i).data(5:6,:,:); % or whatever chan - 5:6?  
        %yes
        % and also 
        stimSet(i).sub(1,:,:) = stimSet(i).sub(3,:,:);
        stimSet(i).dataMean(1:2,:) = stimSet(i).dataMean(5:6,:);
        stimSet(i).subMean(1,:) = stimSet(i).subMean(3,:);
    end
end


if contains(exptDate,'22706')
    for i = 1:size(stimSet,2)
        stimSet(i).data(1:2,:,:) = stimSet(i).data(5:6,:,:); % or whatever chan - 5:6?  
        %yes
        % and also 
        stimSet(i).sub(1,:,:) = stimSet(i).sub(3,:,:);
        stimSet(i).dataMean(1:2,:) = stimSet(i).dataMean(5:6,:);
        stimSet(i).subMean(1,:) = stimSet(i).subMean(3,:);
    end
end

%% commands to process some of these parameters
if ~exist(outPath,'dir')
    mkdir(outPath);
end
animalName = getAnimalByDateIndex(exptDate,exptIndex);
    
[electrodeLocs,map,~] = getElectrodeLocationFromDateIndex(exptDate,exptIndex);

electrodeLocs = electrodeLocs(map);
%%%%NOTE: The following assumes that channels are arranged in pairs and
%%%%that the channels are ordered in Synapse as they are in eNotebook
%You NEED to have a CSV made!
ROILabels = electrodeLocs(contains(electrodeLocs,relevantROIs,'IgnoreCase',true));
ROILabels = unique(ROILabels,'stable');
nStims = length(stimSet);
nTrials = size(stimSet(1).data,2);
nROIs = 1; %size(stimSet(1).sub,1); %number of regions with recording electrodes
preStimIndex = floor(tPreStim/dTRec);
postStimIndex = ceil(tPostStim/dTRec);


%% Ugly kludge alert!
% Need to account for delay between stim times as saved by Synapse and stim
% times as they appear in data. Do this by averaging across stimuli and
% finding first peak after t=0 (i.e. after what Synapse thinks is the stim
% time).
pkThresh = 5.e-6;
tempData = zeros(size(stimSet(1).sub));
for iStim = 1:nStims
    tempData = tempData+stimSet(iStim).sub/nStims;
end
% figure()
saveIndex = zeros(1,nROIs);
for iROI = 1 
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

%% Compute means and find min/max for plotting
startSearchIndex = actualStimIndex+ceil(artifactDur/dTRec); %Start search for plot min and max after artifact
stimSet(iStim).dataMean = squeeze(mean(stimSet(iStim).data,2));
stimSet(iStim).subMean = squeeze(mean(stimSet(iStim).sub,2));
for iROI = 1 %:nROIs
    plotMax(iROI) = -1.e10;
    plotMin(iROI) = 1.e10;
    for iStim = 1:nStims
        plotMax(iROI) = max([plotMax(iROI),prctile(stimSet(iStim).subMean(iROI,startSearchIndex:end),99)]);
        plotMin(iROI) = min([plotMin(iROI),prctile(stimSet(iStim).subMean(iROI,startSearchIndex:end),1)]);
    end
end
%%
% try loading previously saved data
if isfile([outPath2 animal '_peakDataOverTime.mat'])
    load([outPath2 animal '_peakDataOverTime'],'peakDataOverTime');
    structureList = fields(peakDataOverTime);
    p = struct;
    for iROI = 1 %:nROIs
        tPkList = [];
        yPkList = [];
        for iii = 1:length(structureList)
            tPkList = vertcat(tPkList,peakDataOverTime.(structureList{iii}).peakData.pkSearchData(iROI).tPk);
            yPkList = vertcat(yPkList,peakDataOverTime.(structureList{iii}).peakData.pkSearchData(iROI).yPk);
        end
        p(iROI).tPkList = tPkList;
        p(iROI).yPkList = yPkList;
    end
end
%% Subtract baseline from post stimulus period to zero out any abberrations 
baseWinIndex = floor(baseWin/dTRec)
plotTimeArray = dTRec*(-preStimIndex:postStimIndex)

figure() %Visualize raw data
for iStim = 1:nStims
   for iTrial = 1:nTrials
       hold on
    plot(plotTimeArray,squeeze(stimSet(iStim).sub(1,iTrial,:)))
   end
end

for iROI = 1 %:nROIs
    for iStim = 1:nStims
         for iTrial = 1:nTrials
     tempMn = stimSet(iStim).sub(iROI,iTrial,:);
     baseVal = mean(tempMn(preStimIndex + baseWinIndex(1):preStimIndex + baseWinIndex(2)));
     data(iStim).sub(1,iTrial,:) = tempMn  - baseVal;
         end
    end
end


figure() %Visualize normalized data
for iStim = 1:nStims
   for iTrial = 1:nTrials
       hold on
    plot(plotTimeArray,squeeze(data(iStim).sub(1,iTrial,:)))
   end
end

   
%% Apply filter to data
%gausswin() will give you a gaussian window, by default it's 2.5 SD wide. 
%Sampling frequency (fs) in Hz, times 20/2000 is 20 milliseconds wide so, 10 ms on either side;

f = gausswin((1/dTRec)*(20/10000)); 

%makes sure the filter sums to 1
f = f/sum(f);
for iStim = 1:length(stimSet)
    for iTrial = 1:nTrials
       tempData = data(iStim).sub(1,iTrial,:);
       tempData = squeeze(filter(f,1,tempData))';
       data(iStim).sub(1,iTrial,:) = tempData;
    end
end
 

%% Plot traces
ampLabel = [];

for iStim = 1:nStims
    if iscell(stimArray)
        [token,remain] = strtok(stimArray{iStim},'-');
        ampLabel{iStim} = [token '\mu' 'A'];
    else 
        ampLabel{iStim} = [num2str(stimArray(iStim)) '\mu' 'A'];
    end
end
plotTimeArray = dTRec*(-preStimIndex:postStimIndex);
FigName = ['Stim-Resp plot - ' animalName '_' exptDate '_' exptIndex];
thisFigure = figure('Name',FigName);
for iROI = 1 %:nROIs
    % Plot avg traces
    subPlt(iROI) = subplot(1,nROIs,iROI);
    hold on
    for iStim = 1:length(stimSet)
        for iTrials = 1:nTrials
            %plot(plotTimeArray,squeeze((stimSet(iStim).sub(iROI,iTrials,:))));
            plot(plotTimeArray,squeeze(data(iStim).sub(1,iTrials,:)));
        end
    end
%     if exist('tPkList','var') %Comment this in or out if you want to see where previous peaks were selected
%         plot(p(iROI).tPkList,p(iROI).yPkList,'*b','MarkerSize',8); 
%     end
    ax = gca;
    ax.XLim = [-tPreStim,tPostStim];
    ax.YLim = [-20.0e-05, 20.0e-05] %[1.05*plotMin(iROI),1.05*plotMax(iROI)];
    ax.XLabel.String = 'time(sec)';
    if iROI == 1
        ax.YLabel.String = 'avg dataSub (V)';
    end
 
    if iROI == nROIs
        legend(ampLabel,'FontSize',6,'Location','NorthEast');
        legend('boxoff');
    end
end


%% Have user click on peaks in each subplot to inform peak search windows
msgFig = msgbox({'Click once in each subplot to indicate approximate location of peaks.';...
    'Proceed from left to right. Hit enter to end for each ROI.'});
uiwait(msgFig);
figure(thisFigure);
opts.Default = 'Yes'; % Can just hit enter to proceed
opts.Interpreter = 'Tex'; % Apparently it is necessary to set this option
if exist('pkSearchData','var')
    clear pkSearchData;
end
for iROI = 1 %:nROIs
    subplot(subPlt(iROI));
    proceed = 0;
    while ~proceed
        [temp_tPk,temp_yPk] = ginput; % Get click input
        hand = plot(temp_tPk,temp_yPk,'+r','MarkerSize',12);
        answer = questdlg(['Accept pk(s) for ' ROILabels{iROI} ' ?'], ...
        [ROILabels{iROI} 'peak estimate'], ...
        'Yes','No',opts);
        % Handle response
        switch answer
            case 'Yes'
                pkSearchData(iROI).tPk = temp_tPk;
                pkSearchData(iROI).pkSign = sign(temp_yPk);
                pkSearchData(iROI).yPk = temp_yPk;
                proceed = 1;
            case 'No'
                delete(hand); % Removes erroneous peak marker
                proceed = 0;
        end
    end
end
close(thisFigure);
%% Estimate peak responses by averaging around the peaks and troughs
avgWinIndex = floor(avgWinTime/dTRec);
baseWinIndex = floor(baseWin/dTRec);
pkVals = struct();


for iROI = 1 %:nROIs
    pkVals(iROI).data = zeros(nStims, nTrials);
    for iPk = 1:length(pkSearchData(iROI).tPk)
        for iStim = 1:nStims
            for iTrial = 1:nTrials
                %Start and stop indices of time window re stim time to search for peak minimum resp
                this_tPk = pkSearchData(iROI).tPk(iPk);
                pkSearchIndices = ceil([this_tPk - this_tPk/2,this_tPk + this_tPk/2]/dTRec);
                tempIndA = actualStimIndex+pkSearchIndices;
                tempIndA(2) = min(tempIndA(2),length(stimSet(iStim).sub(iROI,iTrial,:)));  
                pkSign = pkSearchData(iROI).pkSign(iPk);
                tempMn = stimSet(iStim).sub(iROI,iTrial,:);
                if pkSign>0
                    [~, pkIndex] = max(tempMn(tempIndA(1):tempIndA(2)));
                else
                    [~, pkIndex] = min(tempMn(tempIndA(1):tempIndA(2)));
                end
               baseVal = mean(tempMn(preStimIndex + baseWinIndex(1):preStimIndex + baseWinIndex(2))); % this is the baseline pre stim 
                tempIndB(1) = actualStimIndex+pkSearchIndices(1)+pkIndex-avgWinIndex;
                tempIndB(2) = actualStimIndex+pkSearchIndices(1)+pkIndex+avgWinIndex;
                pkVals(iROI).data(iStim,iTrial) = mean(tempMn(tempIndB(1):tempIndB(2))) - baseVal;
                pkVals(iROI).peakTimeCalc(iStim, iTrial) = (pkIndex+tempIndA(1))*dTRec-tPreStim;
                pkVals(iROI).baseVal(iStim, iTrial) = baseVal;
            end
        end
    end
end


%% 
% set up a few more labels and configurations for the plot

ampLabel = [];
for iStim = 1:nStims
    if iscell(stimArray)
        %TODO use '-' as a delimiter to get each sides correct amplitude -
        %use 'remain'
        [token,remain] = strtok(stimArray{iStim},'-');
        
        ampLabel{iStim} = [token '\mu' 'A'];
        stimArrayNumeric(iStim) = str2num(token);
    else 
        ampLabel{iStim} = [num2str(stimArray(iStim)) '\mu' 'A'];
        stimArrayNumeric(iStim) = stimArray(iStim);
    end
end
plotTimeArray = dTRec*(-preStimIndex:postStimIndex);


%%
for iStim = 1:length(stimSet)
    allTraces(iStim).stimSet = stimSet(iStim).sub;
    allTraces(iStim).stimArrayNumeric = stimArrayNumeric(iStim);
    allTraces(iStim).ampLabel = ampLabel{iStim};

end
% here is where all the SAVING happens this will create indivudal files
% Time of peak re stim time
% Response magnitude (pk, inner product)
% Time of stim relative to start of file
singleTrialPeakDataFilt = struct;
singleTrialPeakDataFilt.pkSearchData = pkSearchData; % user selected Time of peak re stim time
singleTrialPeakDataFilt.ROILabels = ROILabels; %corresponding labels
singleTrialPeakDataFilt.stimArrayNumeric = stimArrayNumeric;
singleTrialPeakDataFilt.pkVals = pkVals; % Response magnitude 
singleTrialPeakDataFilt.stimTimes = stimTimes; % Time of stim relative to start of file
singleTrialPeakDataFilt.plotMin = plotMin;
singleTrialPeakDataFilt.plotMax = plotMax;
singleTrialPeakDataFilt.plotTimeArray = plotTimeArray; 
singleTrialPeakDataFilt.allTraces = allTraces;
singleTrialPeakDataFilt.stimSet = stimSet;

    
outPath2 = ['M:\PassiveEphys\AnimalData\' animalName '\']
save([outPath fileString '_singleTrialPeakDataFilt'],'singleTrialPeakDataFilt','plotTimeArray','allTraces');
% saveas(figure1,[outPath2 'raw' exptDateIndex '.fig'])
% saveas(figure2,[outPath2 'normalized' exptDateIndex  '.fig'])
% saveas(thisFigure,[outPath2 'smoothed' exptDateIndex '.fig'])
%  
    

end

sendToSlack = false;
plotCalculatedPeaks = false;
plotSingleTrialStimRespByDateIndex(exptDate,exptIndex,sendToSlack,plotCalculatedPeaks)