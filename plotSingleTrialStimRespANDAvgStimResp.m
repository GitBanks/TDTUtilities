%This script needs:
%1) A table of all your experiments - Zarmeen is using the
%getStimRespMaxPeaksTable script to generate single trial data and then using a comprehensive 
%table with single trial data 
%2) You need to have run both get evoked response data for the average
%peaks and also the get single trial stim response script

%This script will give you:
%1) Plots of the single trial data and the averaged data from the stim responses
clear all

%Load in the CSV with the single trial data
dataTable = readtable('M:\Zarmeen\Data\SR Model Fits\SRTableComplete2');
iROI = 1


for iExpt = 1:size(dataTable,1)
date = char(dataTable.Index(iExpt))
exptDate = date(1:5);
exptIndex = date(7:9);
animal = dataTable.Animal(iExpt);
animal = char(animal);
outPath1 = ['M:\PassiveEphys\20' exptDate(1:2) '\' exptDate '-' exptIndex '\'];
singleTrialData = load([outPath1 exptDate '-' exptIndex '_singleTrialPeakDataFilt'],'singleTrialPeakDataFilt','plotTimeArray','allTraces');
avgTrialData = load([outPath1 exptDate '-' exptIndex '_peakData'],'peakData','plotTimeArray','avgTraces');

    if contains(dataTable.Animal{iExpt},'ZZ06')
        manualPeakEntry = [2];
    end 
    if contains(dataTable.Animal{iExpt},'ZZ09')
        manualPeakEntry = [1];
    end
    if contains(dataTable.Animal{iExpt},'ZZ10')
        manualPeakEntry = [2];
    end
    if contains(dataTable.Animal{iExpt},'ZZ14')
        manualPeakEntry = [1];
    end
    if contains(dataTable.Animal{iExpt},'ZZ15')
        manualPeakEntry = [1];
    end
    if contains(dataTable.Animal{iExpt},'ZZ16')
        manualPeakEntry = [1];
    end
    if contains(dataTable.Animal{iExpt},'ZZ19')
        manualPeakEntry = [1];
    end
    if contains(dataTable.Animal{iExpt},'ZZ20')
        manualPeakEntry = [1];
    end
    if contains(dataTable.Animal{iExpt},'ZZ21')
        manualPeakEntry = [1];
    end
    if contains(dataTable.Animal{iExpt},'ZZ22')
        manualPeakEntry = [1];
    end
    
%here we pick the peak
avgPkResponses = (avgTrialData.peakData.pkVals(iROI).data(manualPeakEntry,:));

%% Plotting here
FigName = ['SingleTrial and Avg Stim Resp plot - ' animal '_' exptDate '_' exptIndex];


thisFigure = figure('Name',FigName);
subplot(2,2,1)
plot(singleTrialData.singleTrialPeakDataFilt.stimArrayNumeric, singleTrialData.singleTrialPeakDataFilt.pkVals.data,'-o');
XL = get(gca, 'YLim');
hold on
plot(avgTrialData.peakData.stimArrayNumeric, avgPkResponses,'-o', 'MarkerSize',10 , 'LineWidth', 2, 'Color', [0 0 0]);
hold off
ax = gca;
title('Single Trial Responses and Averaged Responses');
ax.XLabel.String = 'Stim intensity (\muA)';
ax.YLabel.String = 'Pk resp (V)';

tPreStim = 0.05; %sec
tPostStim = 0.2; %sec

[~,indexOut,isTank] = getIsTank(exptDate,exptIndex);
[stimSet,dTRec,stimArray,stimTimes] = getSynapseStimSetData(exptDate,indexOut,tPreStim,tPostStim,isTank);
preStimIndex = floor(tPreStim/dTRec);
postStimIndex = ceil(tPostStim/dTRec);
nStims = length(stimSet);
nTrials = size(stimSet(1).data,2);


if contains(exptDate,'22705')
    for i = 1:size(stimSet,2)
        stimSet(i).data(1:2,:,:) = stimSet(i).data(5:6,:,:);  
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


baseWin = [-5,-0.5]*1.e-3; %sec;
baseWinIndex = floor(baseWin/dTRec)
plotTimeArray = dTRec*(-preStimIndex:postStimIndex)

%% Visualize raw data
subplot(2,2,2) 
for iStim = 1:nStims
   for iTrial = 1:nTrials
       hold on
    plot(plotTimeArray,squeeze(stimSet(iStim).sub(1,iTrial,:)))
   end
end
ax = gca;
    ax.XLim = [-tPreStim,tPostStim];
    ax.YLim = [-50.0e-05, 50.0e-05]
    ax = gca;
title('Raw Data');

    
%% Visualize normalized data
for iROI = 1 %:nROIs
    for iStim = 1:nStims
         for iTrial = 1:nTrials
     tempMn = stimSet(iStim).sub(iROI,iTrial,:);
     baseVal = mean(tempMn(preStimIndex + baseWinIndex(1):preStimIndex + baseWinIndex(2)));
     data(iStim).sub(1,iTrial,:) = tempMn  - baseVal;
         end
    end
end


subplot(2,2,3)
for iStim = 1:nStims
   for iTrial = 1:nTrials
       hold on
    plot(plotTimeArray,squeeze(data(iStim).sub(1,iTrial,:)))
   end
end
ax = gca;
ax = gca;
title('Normalized Data');
ax.XLim = [-tPreStim,tPostStim];
ax.YLim = [-50.0e-05, 50.0e-05]

%%visualize smoothed data
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

subplot(2,2,4) 
for iStim = 1:length(stimSet)
     for iTrials = 1:nTrials
         hold on
         plot(plotTimeArray,squeeze(data(iStim).sub(1,iTrials,:)));
     end
end
    ax = gca;
    ax.XLim = [-tPreStim,tPostStim];
    ax.YLim = [-50.0e-05, 50.0e-05] %[1.05*plotMin(iROI),1.05*plotMax(iROI)];
    ax.XLabel.String = 'time(sec)';
    ax = gca;
    title('Filtered Data');
    if iROI == 1
        ax.YLabel.String = 'avg dataSub (V)';
    end
 
 


fileString = [exptDate '-' exptIndex];
outPath = [getPathGlobal('M') 'PassiveEphys\20' exptDate(1:2) '\' fileString '\']
outPath2 = 'M:\Zarmeen\Data\Stimulus Response Curves\'
saveas(thisFigure,[outPath2 FigName '.png'])
saveas(thisFigure,[outPath FigName '.fig'])

end

dataList = unique(dataTable.DateIndex)
for i = 1:size(dataList)
    fileName = [outPath FigName]; 
    try
        desc = [FigName];
        sendSlackFig(desc,[outpath1 fileName{i} '.png']);
    catch
        disp(['failed to upload ' fileName ' to Slack']);
    end
end
   