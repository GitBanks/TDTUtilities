% We want to make an excel readable table with the following:
% 1) animalName = patientID
% 2) age 
% 3) date/index (block)
% 4) drug
% 5) mvmt values
% 6) baseline or treatment
% 7) Windows
% 8) LZc score - Spec analysis (delta, alpha, and theta specifically) - WPLI
% !!When finished work to make this a function!!

%function makePPM(animalName,thisDate)

%1) Load in the analysis out from whatever analysis you want to run PPM with eg
%spec Analysis:
animalName = 'ZZ14';
thisDate = '22120';


folder = ['M:\PassiveEphys\AnimalData\initial\' animalName '\'];
file = 'ZZ14_22120-000,22120-003,22120-004,22120-005,22120-006 specAnalysis';
treatments = getTreatmentInfo(animalName,thisDate);
DOB = getBirthDate(animalName);
% to get animal age for this table, just subtract DOB from thisDate (after
% formatting)
formatDateFive(thisDate)
[newDate,~] = fixDateIndexToFiveForSynapse(thisDate,'000');

thisDrug = treatments.pars{1};
load([folder file]);
listOfSegments = fields(out.specAnalysis{1,1});

%2) Preallocate empty table
varTypes = {'string','string','string','string','double', 'double', 'double', 'double','double', 'double','double','double', 'double','double'};
varNames = {'animalName', 'date','drug', 'index', 'isPeak', 'win', 'meanMovement', 'AvgTotalPow', 'delta', 'theta', 'alpha', 'beta','gamma','highGamma' };
sz = [length(listOfSegments),length(varNames)];
PSMTable = table('Size',sz,'VariableTypes',varTypes,'VariableNames',varNames);

%3) Start pulling in data
%The frequency band allocation is done based on our previously defined
%frequency bands found in freqBands
iChans = 1:2;
delta = 1:4;
theta = 4:8;
alpha = 8:11;
beta = 11:15;
gamma = 15:19;
highGamma = 19:24;
for iSegment = 1:size(listOfSegments,1)
thisSeg = listOfSegments{iSegment};
PSMTable.AvgTotalPow(iSegment) = mean(mean(out.specAnalysis{1,1}.(thisSeg).powspctrm(iChans,:),1));
PSMTable.delta(iSegment) = mean(mean(out.specAnalysis{1,1}.(thisSeg).powspctrm(iChans,delta),1));
PSMTable.theta(iSegment) = mean(mean(out.specAnalysis{1,1}.(thisSeg).powspctrm(iChans,theta),1));
PSMTable.alpha(iSegment) = mean(mean(out.specAnalysis{1,1}.(thisSeg).powspctrm(iChans,alpha),1));
PSMTable.beta(iSegment) = mean(mean(out.specAnalysis{1,1}.(thisSeg).powspctrm(iChans,beta),1));
PSMTable.gamma(iSegment) = mean(mean(out.specAnalysis{1,1}.(thisSeg).powspctrm(iChans,gamma),1));
PSMTable.highGamma(iSegment) = mean(mean(out.specAnalysis{1,1}.(thisSeg).powspctrm(iChans,highGamma),1));
PSMTable.win(iSegment) = iSegment;
end

% Movement 
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

PSMTable.meanMovement = meanMove'

%% Other info
preInj = contains(listOfSegments,'PostInj');
PSMTable.isPeak = preInj;
PSMTable.animalName(:,1) = animalName;
PSMTable.index(:,1) = out.block;
PSMTable.date (:,1)= thisDate;
PSMTable.drug (:,1)= thisDrug;

%% CSV Saving

fileName = strcat(animalName,'',thisDate,'',thisDrug,'','.csv')
outPath = ['M:\mouseLFP\MatlabCSV'];
tableOutPath = fullfile(outPath, fileName)
writetable(PSMTable,tableOutPath)





