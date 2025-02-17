% 2/13/25
% meeting
% 1. Figure 1: add other dose of DMT in power spectra; - raw traces and power spectra   
% ***2. reconsider the order of figures (so these might be different order);   
% 3. Figure 2 LPS show movement for the time course of the expt - use the mice in fig 1; 
% *** 4. Figure 2 show just the groups we're using;   
% 5. Figure 2 gaussian fit demo;   
% *** 6. Figure 3 updated, just the groups we care about;   
% 7. show the power spectra after the movement adjustment;   
% 8. make sure the methods detail the gaussian fit analysis;   
% * 9. Figure 4: combine plates 1& 2;   
% * 10. Figure 4: leftmost panel should be IL6;   
% *** 11. Figure 5: scatterplot latest version;   

% % this bit needs to be run if we haven't saved the new fits to the saved
% % table
% setName = 'poster2023';
% load(getPathGlobal([setName '-matTableBandpower']));
% for iTable = 1:size(workingTable,1)
%     animalName = workingTable.Animal{iTable};
%     exptDate = workingTable.Date{iTable};
%     animalOut = getBandPrePostRatioFromFit(animalName,exptDate);
%     workingTable.gFitDelta(iTable) = animalOut.delta;
%     workingTable.gFitTheta(iTable) = animalOut.theta;
%     workingTable.gFitGamma(iTable) = animalOut.gamma;
%     workingTable.gFitAplha(iTable) = animalOut.alpha;
%     workingTable.gFitBeta(iTable) = animalOut.beta;
% end

% recently, we've narrowed down the groups we want:
% Sal Sal, Sal LPS, FLVX LPS, DMT2.5 LPS, DMT10 LPS, DOI LPS  
% group 1: saline saline
% group 2: saline LPS
% group 3: flvx saline * get rid of this one
% group 4: FLVX LPS, 
% group 5: DMT saline * get rid of this one
% group 6: DMT2.5 LPS, 
% group 7: DMT10 LPS, 
% group 8: DOI saline  * get rid of this one
% group 9: DOI LPS 
% group 10: DOI ketanserin saline   * get rid of this one
% group 11: DOI ketanserin LPS   * get rid of this one
setName = 'poster2023';
load(getPathGlobal([setName '-matTableBandpower']));
newTable = workingTable;
newTable(newTable.group==3,:) = [];
newTable(newTable.group==5,:) = [];
newTable(newTable.group==8,:) = [];
newTable(newTable.group==10,:) = [];
newTable(newTable.group==11,:) = [];

% ===================
% 4. Figure 2 show just the groups we're using;   
setName = 'poster2023b';
plotBandPowerSummaries(setName)

% ===================
% 5. Figure 2 gaussian fit demo;
% 8. make sure the methods detail the gaussian fit analysis;
animalName = 'EEG367';
exptDate = '23906';
[gaussFitTable] = getFitGaussMixByAnimalDate(animalName,exptDate);
% plotOption = true;
% [gaussFitTable.acceptedGaussFit,pInclude,gaussParams] = fitGaussMix(gaussFitTable.meanMovement,plotOption);


% ===================
% 6. Verify Box plots 
plotBandPowerGaussFitSummaries(newTable);

% ===================
% 11. Figure 5: scatterplot latest version;   
DeltaCytokinePlotForPaperNormalized


% ===================
% 7. show the power spectra before and after the movement adjustment;   
% 7. this part shows after movement adj, so also grab the before
setName = 'poster2023';
workingTable = readtable(getPathGlobal([setName '-xlsTableGroupInfo']));
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
    exclude = workingTable.chansToExclude(iTable);
    plotArray = plotSpectralDensityGaussFitAnimalDate(animalName,exptDate,showPlot,exclude,true);
    drawnow
end
% ===================
% 3. Figure 2 LPS show movement for the time course of the expt - use the mice in fig 1; **movement plot  
% 3. show one whole movement day
% when getFitGaussMixByAnimalDate() is run, it saves a file to getPathGlobal('animalSaves')
% it saves segment times and average movement 
for iTable = 1:size(animalList,1)
    animalName = animalList{iTable};
    exptDate = dateList{iTable};
%     animalName = 'EEG367';
%     exptDate = '23906';
    outPath = [getPathGlobal('animalSaves') animalName '\'];
    saveFileName = ['MoveFit_' animalName '_' exptDate '.csv'];
    tableOutPath = fullfile(outPath, saveFileName);
    thisTable = readtable(tableOutPath);
    plot(thisTable.winTime,thisTable.meanMovement);
end



% ===================
% #9, 10
% * 9. Figure 4: combine plates 1& 2;   
% * 10. Figure 4: leftmost panel should be IL6;   
% C_24010_FOUND_fluvoxamineELISAPlots_MattsVersion doesn't seem to be the
% latest...
C_24010_FOUND_fluvoxamineELISAPlots_MattsVersion % OK, after some 
% examination, it's very close, but still missing a few changes... I'll
% just run with this one.


