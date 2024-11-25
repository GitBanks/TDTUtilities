% Master notes for 2024 LPS paper
% =========================================================================
% KEEP THIS BLOCK AT TOP, LOG WORK IN NEXT BLOCK(s), RECENT FIRST.
% other scripts we're using for these plots:
CODE_24416_rerunningDataCleaning_FULL; % All the steps for reanalysis
C_24010_FOUND_fluvoxamineELISAPlots_MattsVersion; % box plot version of the cytokine plots alone
DeltaCytokinePlotForPaperNormalized; % as named, the delta/cytokine scatter plot we've been perfecting
% process related notes:
% 1. how are the cytokine data used?
% We ran two plates. The plate reader output we use is Calc_Conc_Mean. 
% Cytokines from the same plate are then multiplied by a scaling factor
% based on the total protein measure.  We then divided values from each 
% plate by the mean of the common control treatment (saline) ran on the 
% same plate.
% =========================================================================


% 11/25/24
% Dear diary... I've made improvements since last entry but did not
% detail them here.  Check git.

% 10/29/24
% pipeline reran (took almost 3 days because no parallel processing
% another day sorting out secondary plots - gauss fit into new table wasn't
% completely streamlined.  
% CODE_24416_rerunningDataCleaning_FULL 
% explains it all now.

% Delta_cytokinePlotForPaperNormalized
% last step: I realize I manually merged the cytokine table and the
% bandpower table, so need to redo that, too






% 10/18/24
% posted spectra for others, but still need to review.  track down how
% normalization was handled first.

% =========================================================================
% 10/11/24
% redo step 1. delta/cytokine
% 1,2,5,6 divide by 1
% 3,4,7,8, divide by 3
% plot these linear horizontal scale and log to compare
%
% also redo extra normalization for 2 - track down how that normalization
% was handled. 
%
% post avg specta
% 4a. track down 60Hz on that 3rd column;
% 4b. review all spectra; 

% =========================================================================
% 10/10/24
% review of all tasks:
% 1a. delta/cytokine scatter: run the regression on the log of the values;  
% 1b. delta/cytokine scatter: normalize to saline (treat data the same way)
% 2. find the code for cytokine box plots (then, I assume, just plot?)
% 3. run DMT+BD through new pipeline; 
% 4a. track down 60Hz on that 3rd column;
% 4b. review all spectra; 
% 5. [SENT] stats - anova 10dmt/lps, doi/lps, flvx/lps, sal/sal, sal/lps, maybe other dmt/lps. - anova vs nonparametric test. ;
% 6. review figures in sequence and clean up all axes / legends / labels
% 7. review anova vs nonparametric test

% 1a. delta/cytokine scatter: run the regression on the log of the values;  
% 1b. delta/cytokine scatter: normalize to saline (treat data the same way)
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
    x = log(subgroup.IL6.*subgroup.scaleFactor+1);
    y = subgroup.delta;
    scatter(x,y,"filled");
    hold on
%     if i==1 
%         coeffs = polyfit(x, y, 2);  % Fit a quadratic model
%         y_pred = polyval(coeffs, x);
%         [~,orderedLine]=sort(x);
%         plot(x(orderedLine),y_pred(orderedLine));
%     end
    % linear regression - we could program a search for saline / saline, or
    % just shortcut to 1 because we know that's the group ID.
    if i==1 
        b1=x\y;
        yCalc1 = b1*x;
        hold on
        [~,orderedLine]=sort(x);
        plot(x(orderedLine),yCalc1(orderedLine));
    end
    hold on;
end
xlim([0,300]);
title('IL6');
% ==== TNF alpha ====
subplot(1,3,2);
for i = 1:size(groups,2)
    subgroup = newWorkingTable(newWorkingTable.groupID==groups(i),:);
    x = log(subgroup.TNF.*subgroup.scaleFactor+1);
    y = subgroup.delta;
    scatter(x,y,"filled");
    if i==1
        b1=x\y;
        yCalc1 = b1*x;
        hold on
        [~,orderedLine]=sort(x);
        plot(x(orderedLine),yCalc1(orderedLine));
    end
    hold on;
end
xlim([0,10]);
title('TNF alpha');
% ==== IL10 ====
subplot(1,3,3);
for i = 1:size(groups,2)
    subgroup = newWorkingTable(newWorkingTable.groupID==groups(i),:);
    x = log(subgroup.IL10.*subgroup.scaleFactor+1);
    y = subgroup.delta;
    scatter(x,y,"filled");
    if i==1
        removeThese = isnan(x);
        x(removeThese)=[];
        y(removeThese)=[];
        b1=x\y;
        yCalc1 = b1*x;
        hold on
        [~,orderedLine]=sort(x);
        plot(x(orderedLine),yCalc1(orderedLine));
    end
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
    set(gca, 'XScale', 'log');
end

% 2. find the code for cytokine box plots
% C_24010-FOUND-fluvoxamineELISAPlots - Matts version

% 3. run DMT+BD through new pipeline; 
% using the following script:
% CODE_24416_rerunningDataCleaning_FULL
% added Sigma1 processing

% 4a. track down 60Hz on that 3rd column;
% 4b. review all spectra; 
% Need to step through M:\PassiveEphys\AnimalData\poster2023\avgspectra\
% Need to step through M:\PassiveEphys\AnimalData\Sigma1DMT\avgspectra\



% =========================================================================
% =========================================================================
% 9/29/24
% less than 24 hours before next meeting... as usual... and now the baby
% cries for me, brb...
% **** priorities for this week: ****
% 1:  produce 10 .fig files - show spectra before and after movement (results 1) ;  
% 2: run bd1063 with delta box plot analysis; 
% 3: run the regression on the log of the values;  

% note, we need to use this code, but on a specific subset:
% Sal LPS EEG313 23621
% Sal Sal EEG335 23720 
% DOI LPS EEG343 23809
% DMT LPS EEG237 23206 
% FLVX LPS EEG214 22727 
animalList={
'EEG313' 
'EEG335' 
'EEG343' 
'EEG237' 
'EEG214' };
dateList={
'23621'
'23720'
'23809'
'23206'
'22727'};
for iTable = 1:size(animalList,1)
    animalName = animalList{iTable};
    exptDate = dateList{iTable};
    showPlot = true;
    exclude = workingTable.ChansToExclude(iTable);
    plotArray = plotSpectralDensityGaussFitAnimalDate(animalName,exptDate,showPlot,exclude,true);
    drawnow
end

% for BD1063 set - need to run it through new steps of pipeline
animalDateTable = getAnimalDayTableByTreatment('BD1063');
% now try this updated set
setName = 'Sigma1';
workingTable = readtable(getPathGlobal([setName '-xlsTableGroupInfo']));
% load(getPathGlobal([setName '-matTableBandpower']));
for iTable = 1:size(workingTable,1)
    animalName = workingTable.animalName{iTable};
    exptDate = num2str(workingTable.Dates(iTable));
    [gaussFitTable] = getFitGaussMixByAnimalDate(animalName,exptDate); 
end
plotBandPowerSummaries(setName)

for iTable = 1:size(workingTable,1)
    animalName = workingTable.animalName{iTable};
    exptDate = num2str(workingTable.Dates(iTable));
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
% two days before meeting.  Still need to:
% part 3. find the code for cytokine box plots
% part 4. confirm linear regression?
% part 4. add normalization to saline option
% clean up all axes / legends / labels 
% ******* run bd1063 with delta box plot analysis

% 9/25/24 
% will refresh list from 9/13/24.
% 1. [SOLVED] verify the median
% 2. ****** show spectra before and after movement (results 1) ;  ** produce 10 .fig files 
% 3. cytokine box plots clean up axes
% 4. cytokine / delta scatter - normalize to saline (treat data the same way) also fit line - linear regression on sal/sal and sal/lps data single regression for all those; 
% 4  ****** - do the regression on the log of the values 
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
    x = subgroup.IL6.*subgroup.scaleFactor;
    y = subgroup.delta;
    scatter(x,y,"filled");
    % linear regression - we could program a search for saline / saline, or
    % just shortcut to 1 because we know that's the group ID.
    if i==1 
        b1=x\y;
        yCalc1 = b1*x;
        hold on
        [~,orderedLine]=sort(x);
        plot(x(orderedLine),yCalc1(orderedLine));
    end
    hold on;
end
xlim([0,300]);
title('IL6');
% ==== TNF alpha ====
subplot(1,3,2);
for i = 1:size(groups,2)
    subgroup = newWorkingTable(newWorkingTable.groupID==groups(i),:);
    x = subgroup.TNF.*subgroup.scaleFactor;
    y = subgroup.delta;
    scatter(x,y,"filled");
    if i==1
        b1=x\y;
        yCalc1 = b1*x;
        hold on
        [~,orderedLine]=sort(x);
        plot(x(orderedLine),yCalc1(orderedLine));
    end
    hold on;
end
xlim([0,10]);
title('TNF alpha');
% ==== IL10 ====
subplot(1,3,3);
for i = 1:size(groups,2)
    subgroup = newWorkingTable(newWorkingTable.groupID==groups(i),:);
    x = subgroup.IL10.*subgroup.scaleFactor;
    y = subgroup.delta;
    scatter(x,y,"filled");
    if i==1
        removeThese = isnan(x);
        x(removeThese)=[];
        y(removeThese)=[];
        b1=x\y;
        yCalc1 = b1*x;
        hold on
        [~,orderedLine]=sort(x);
        plot(x(orderedLine),yCalc1(orderedLine));
    end
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
    set(gca, 'XScale', 'log');
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
