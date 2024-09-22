% Master notes for 2024 LPS paper
% Date related notes in descending order / recent on top
% =========================================================================
% =========================================================================


% =========================================================================
% =========================================================================
% 9/25/24 
% will refresh list from 9/13/24.
% 1. [SOLVED] verify the median
% 2. show spectra before and after movement (results 1) ;  
% 3. cytokine box plots clean up axes
% 4. cytokine / delta scatter - normalize to saline (treat data the same way) also fit line - linear regression on sal/sal and sal/lps data single regression for all those; 
% 5. show one whole movement day; the actual "movement events for one whole
% day
% 6. Verify Box plots 

% ===================
% 2. show spectra before and after movement.  Code working, need help sortingand cleaning up plots.
setName = 'poster2023';
load(getPathGlobal([setName '-matTableBandpower']));
for iTable = 1:size(workingTable,1)
    animalName = workingTable.Animal{iTable};
    exptDate = workingTable.Date{iTable};
    showPlot = true;
    exclude = workingTable.ChansToExclude(iTable);
    plotArray = plotSpectralDensityGaussFitAnimalDate(animalName,exptDate,showPlot,exclude,true);
    drawnow
end

% ===================
% 3. cytokine box plots clean up axes
% 

% ===================
% 4. (plot) cytokine scatter - normalize to saline (treat data the same 
% way) also fit line - linear regression on sal/sal and sal/lps data single
% regression for all those; 
% ==== example of how to set up cytokine plotting on the new table.
clear all
load('C:\Users\Matt Banks\Desktop\paper data sets\poster2023BandpowerData4.mat',"newWorkingTable")
groups = unique(newWorkingTable.groupID);
groups = groups(~isnan(groups));
groups = groups(groups>0)';
indexHere = 1;
for iGroup = groups %just step through the ones we found
    orderedGroupName{indexHere} = newWorkingTable(newWorkingTable.groupID==groups(indexHere),:).groupText(1,1);
    indexHere = indexHere+1;
end
figure
% ==== IL6 ====
subplot(1,3,1);
for i = 1:size(groups,2)
    subgroup = newWorkingTable(newWorkingTable.groupID==groups(i),:);
    scatter(subgroup.IL6.*subgroup.scaleFactor,subgroup.delta,"filled");
    hold on;
end
xlim([0,300]);
title('IL6');
% ==== TNF alpha ====
subplot(1,3,2);
for i = 1:size(groups,2)
    subgroup = newWorkingTable(newWorkingTable.groupID==groups(i),:);
    scatter(subgroup.TNF.*subgroup.scaleFactor,subgroup.delta,"filled");
    hold on;
end
xlim([0,10]);
title('TNF alpha');
% ==== IL10 ====
subplot(1,3,3);
for i = 1:size(groups,2)
    subgroup = newWorkingTable(newWorkingTable.groupID==groups(i),:);
    scatter(subgroup.IL10.*subgroup.scaleFactor,subgroup.delta,"filled");
    hold on;
end
xlim([0,10]);
title('IL10');

%TODO confirm pg/ml
for iPlot = 1:3
    subplot(1,3,iPlot);
    ylabel('delta change');
    xlabel('cytokine level 4 hours post');
    if iPlot == 1
        legend(orderedGroupName,'Interpreter','none');
    end
    ylim([0.25,3]);
end

% ===================
% 5. show one whole movement day
% when getFitGaussMixByAnimalDate() is run, it saves a file to getPathGlobal('animalSaves')
% it saves segment times and average movement This means we can load the 
animalName = 'EEG367';
exptDate = '23906';
outPath = [getPathGlobal('animalSaves') animalName '\'];
saveFileName = ['MoveFit_' animalName '_' exptDate '.csv'];
tableOutPath = fullfile(outPath, saveFileName);
thisTable = readtable(tableOutPath);
plot(thisTable.winTime,thisTable.meanMovement);

% ===================
% 6. Verify Box plots 
setName = 'poster2023';
load(getPathGlobal([setName '-matTableBandpower']));
for iTable = 1:size(workingTable,1)
    animalName = workingTable.Animal{iTable};
    exptDate = workingTable.Date{iTable};
    animalOut = getBandPrePostRatioFromFit(animalName,exptDate);
    workingTable.gFitDelta(iTable) = animalOut.delta;
    workingTable.gFitTheta(iTable) = animalOut.theta;
    workingTable.gFitGamma(iTable) = animalOut.gamma;
    workingTable.gFitAplha(iTable) = animalOut.alpha;
    workingTable.gFitBeta(iTable) = animalOut.beta;
end
plotBandPowerGaussFitSummaries(workingTable);




% =========================================================================
% =========================================================================
% 9/17/24 no updates. I had a medical procedure and could not make time


% =========================================================================
% =========================================================================
% 9/13/24 Notes & tasks due
% 1. verify the median is displayed (otherwise why is it not 1); 
% 2. show spectra before and after movement (results 1) ;  
% 3. cytokine box plots clean up axes
% 4. cytokine / delta scatter - normalize to saline (treat data the same way) also fit line - linear regression on sal/sal and sal/lps data single regression for all those; 
% 5. show one whole movement day; the actual "movement events for one whole
% day
% 6. Verify Box plots 

% biggest feat accomplished was getting computer, remote, and code working
% and refamiliarized - only started real plot progress last night at 4PM
% i.e., the day before the meeting with no time to spare

% ===================
% 1. verify the median is displayed (otherwise why is it not 1); 
% answer comes from the function:  On each box, the central mark indicates 
% the median, and the bottom and top edges of the box indicate the 25th and 
% 75th percentiles, respectively. 

% ===================
% 2. show spectra before and after movement (results 1).  Code working,
% need help sorting.
% [code moved to more recent dates]

% ===================
% 3. cytokine box plots clean up axes
% notes on scatterplot here C_24617-plotsAboveAreDone-workingOnCytokineScatter

% ===================
% 4. (plot) cytokine scatter - normalize to saline (treat data the same 
% way) also fit line - linear regression on sal/sal and sal/lps data single
% regression for all those; 
% ==== example of how to set up cytokine plotting on the new table.
% [code moved to more recent dates]

% ===================
% 6. Verify Box plots 
% latest box plots and movement box plots here: 
% C_24528-organizing_plots_for_the_paper_3.m
% [code moved to more recent dates]
