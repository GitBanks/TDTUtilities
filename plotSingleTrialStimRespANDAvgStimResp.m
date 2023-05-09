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
dataTable = readtable('C:\Users\Grady\Documents\Zarmeen Data\SingleTrialPeakMax\singleTrialDataCombined');
iROI = 1

%Set the path for where we want the pngs saved- we will also save the plots
%in individual animal files in M drive
outPath1 = 'C:\Users\Grady\Documents\Zarmeen Data\SingleTrialANDAvgPlots\'



for iExpt = 1:size(dataTable,1)
date = char(dataTable{iExpt});
exptDate = date(1:5);
exptIndex = date(7:9);
animal = dataTable.Animal(iExpt);
animal = char(animal)
outPath2 = ['M:\PassiveEphys\20' exptDate(1:2) '\' exptDate '-' exptIndex '\'];
singleTrialData = load([outPath2 exptDate '-' exptIndex '_singleTrialPeakData'],'singleTrialPeakData','plotTimeArray','allTraces');
avgTrialData = load([outPath2 exptDate '-' exptIndex '_peakData'],'peakData','plotTimeArray','avgTraces');

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
    
avgPkResponses = (avgTrialData.peakData.pkVals(iROI).data(manualPeakEntry,:));

%Plotting here
FigName = ['SingleTrial and Avg Stim Resp plot - ' animal '_' exptDate '_' exptIndex];

thisFigure = figure('Name',FigName);
plot(singleTrialData.singleTrialPeakData.stimArrayNumeric, singleTrialData.singleTrialPeakData.pkVals.data,'-o');
XL = get(gca, 'YLim');
hold on
plot(avgTrial.peakData.stimArrayNumeric, avgPkResponses,'-o', 'MarkerSize',10 , 'LineWidth', 2, 'Color', [0 0 0]);
hold off
ax = gca;
title('Single Trial Responses and Averaged Responses');
ax.XLabel.String = 'Stim intensity (\muA)';
ax.YLabel.String = 'Pk resp (V)';



saveas(thisFigure,[outPath1 FigName '.png'])
saveas(thisFigure,[outPath2 FigName])

fileName = [outPath1 FigName];

%This will send the plots to datachecks

end

dataList = unique(dataTable.DateIndex)
for i = 1:size(dataList)
    fPath = 'C:\Users\Grady\Documents\Zarmeen Data\SingleTrialANDAvgPlots\'
    
    try
        desc = [FigName];
        sendSlackFig(desc,[fPath fileName{i} '.png']);
    catch
        disp(['failed to upload ' fileName ' to Slack']);
    end
end
   