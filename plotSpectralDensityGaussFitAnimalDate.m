function plotArray = plotSpectralDensityGaussFitAnimalDate(animalName,exptDate,showPlot,chansToExclude,showOriginalPlot,windowPre,windowPost)
% we need to pass excluded channels through to fetchSpectraFromPipelineByAnimalDate
if ~exist("chansToExclude","var")
    chansToExclude = nan;
end
if ~exist("showOriginalPlot","var") % JUST ADDED. IN CASE SOME CODE BROKE
    showOriginalPlot = false;
end
if ~exist("showPlot","var")
    showPlot = true;
end
% establish this, or preset?
if ~exist("windowPre","var") || ~exist("windowPost","var")
    windowPre = [duration(0,00,00),duration(1,00,00)];
    windowPost = [duration(2,30,00),duration(3,30,00)];
end
disp(['Processing ' animalName ' on ' exptDate '.']);
useFullSpectra = true;
% ==== load the segmented spectra
[~,specTableOut] = fetchSpectraFromPipelineByAnimalDate(animalName,exptDate,useFullSpectra,chansToExclude);
treatments = getTreatmentInfo(animalName,exptDate);
extraText = [treatments.pars{1,end}(1:3) '_' num2str(fix(treatments.vals(1,end))) '_' treatments.pars{2,end}(1:3) '_' num2str(treatments.vals(2,end))];
segTimes = specTableOut.segTime - specTableOut.segTime(1);
fullSpectra = specTableOut.spectra;
% ==== load the movement info from the gaussian fit program
moveDataPath = [getPathGlobal('animalSaves') animalName '\'];
moveDataFileName = ['MoveFit_' animalName '_' exptDate '.csv'];
tableOutPath = fullfile(moveDataPath, moveDataFileName);
moveTable = readtable(tableOutPath);
% find the index for pre and post
moveTable.ctrl = moveTable.winTime>windowPre(1) & moveTable.winTime<windowPre(2);
moveTable.postInj = moveTable.winTime>windowPost(1) & moveTable.winTime<windowPost(2);
% then use the "accepted" windows for each window and output the
% post/pre ratio
logicalCtrl = moveTable.ctrl & moveTable.acceptedGaussFit;
logicalpostInj = moveTable.postInj & moveTable.acceptedGaussFit;
plotArray(1,:) = mean(fullSpectra(logicalCtrl,:),1,"omitnan");
plotArray(2,:) = mean(fullSpectra(logicalpostInj,:),1,"omitnan");
if showPlot
    freqLabels = specTableOut.freqLabels;
    titletext = [animalName ' ' exptDate ' ' extraText ' movement accepted'];
    avgspectra = figure('Name',titletext); 
    loglog(freqLabels,plotArray(1,:)); 
    hold on
    loglog(freqLabels,plotArray(2,:)); 
    xlabel('Freq');
    ylabel('Power (mV^2)');
    legend({'ctrl','peak drug effect'});
    saveas(avgspectra,['C:\Users\Matt Banks\Desktop\spectraFigs\' titletext ]);
end

if showOriginalPlot
    plotArray(1,:) = mean(fullSpectra(moveTable.ctrl,:),1,"omitnan");
    plotArray(2,:) = mean(fullSpectra(moveTable.postInj,:),1,"omitnan");
    freqLabels = specTableOut.freqLabels;
    titletext = [animalName ' ' exptDate ' ' extraText ' original'];
    avgspectra = figure('Name',titletext); 
    loglog(freqLabels,plotArray(1,:)); 
    hold on
    loglog(freqLabels,plotArray(2,:)); 
    xlabel('Freq');
    ylabel('Power (mV^2)');
    legend({'ctrl','peak drug effect'});
    saveas(avgspectra,['C:\Users\Matt Banks\Desktop\spectraFigs\' titletext ]);
end


