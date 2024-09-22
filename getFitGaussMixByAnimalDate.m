function [gaussFitTable] = getFitGaussMixByAnimalDate(animalName,exptDate)

% function 
% given: animal name and date
% DO:
% 1. load in movement data
% 2. segment movement data
% 3. run fitGaussMix
% 4. apply arrayOut to dataToFit

% test params
% animalName = 'EEG367';
% exptDate = '23906';

if contains(animalName, 'ZZ') 
    findExptType = 'Spon';
else
    findExptType = '';
end
theseExptIndices = getExperimentsByAnimalAndDate(animalName,exptDate,findExptType);

totalSegs = 100;
varTypes = {'string','string','string','duration','double','string','double'};
varNames = {'animalName','date','index','winTime','meanMovement','drug','acceptedGaussFit'};
sz = [totalSegs,length(varNames)];
gaussFitTable = table('Size',sz,'VariableTypes',varTypes,'VariableNames',varNames);

treatments = getTreatmentInfo(animalName,exptDate);
thisDrug = treatments.pars{1};


% [exptDate_dbForm] = houseConvertDateTo_dbForm(exptDate);
% +windowTimes;

doOnce = 1;
grandIter = 1;
for i = 1:size(theseExptIndices,1)
    exptIndex = theseExptIndices{i};
    exptIndex = exptIndex(7:9);
    [loadedData,segmentTimeData] = getSegmentMovementUsingPipeline(animalName,exptDate,exptIndex);
    actionList = fields(loadedData);
    if doOnce
        firstWindowTime = getfield(segmentTimeData,actionList{1});
%         firstWindowTime = datetime(firstWindowTime,'TimeZone','local')
        firstWindowTime = datetime(firstWindowTime,'TimeZone','local');
        doOnce = 0;
    end
    
    for iField = 1:size(fields(loadedData),1)
        %thisTime = metaData(contains(actionList(i),segmentTimeData)).blockTime;
        gaussFitTable.winTime(grandIter) = getfield(segmentTimeData,actionList{iField})-firstWindowTime;
        gaussFitTable.meanMovement(grandIter) = mean(getfield(loadedData,actionList{iField}));
        gaussFitTable.animalName(grandIter)=animalName;
        gaussFitTable.date(grandIter)=exptDate;
        gaussFitTable.index(grandIter)=exptIndex;
        gaussFitTable.drug(grandIter)=thisDrug;
        grandIter = grandIter+1;
    end
end

plotOption = true;
[gaussFitTable.acceptedGaussFit,pInclude,gaussParams] = fitGaussMix(gaussFitTable.meanMovement,plotOption);

% CSV Saving
outPath = [getPathGlobal('animalSaves') animalName '\'];
saveFileName = ['MoveFit_' animalName '_' exptDate '.csv'];
tableOutPath = fullfile(outPath, saveFileName);
writetable(gaussFitTable,tableOutPath);



% we include all indices, is that ideal or not?  won;t the fits be
% different?
















