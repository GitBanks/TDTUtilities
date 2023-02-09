function PSMTableForR(animalName,thisDate,analysisType)
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


% input examples:
% animalName = 'ZZ14';
% thisDate = '22120';
% analysisType = 'specAnalysis';

% input examples:
% animalName = 'EEG187';
% thisDate = '22331';
% analysisType = 'specAnalysis';



% need to figure this out - if we want to specify the 'option set' or the
% analysis type
if ~exist('analysisType','var')
    analysisType = 'specAnalysis'; % add this as a parameter?
end


% instead of naming the file:
% file = 'ZZ14_22120-000,22120-003,22120-004,22120-005,22120-006 specAnalysis-ZZMouseOptionsSpec';
% look in this folder:
workingFolder = [getPathGlobal('pipelineSaves') animalName '\'];
checkFolder = dir(workingFolder);
for ii=1:size(checkFolder,1)
    % make sure it contains today's date and analysis type
    if contains(checkFolder(ii).name,thisDate) && contains(checkFolder(ii).name,analysisType) 
        workingFileName = checkFolder(ii).name;
    end
end
% TODO: Zarmeen requested adding multiple days to a PSM file.  We can do
% that by making workingFileName a list and stepping through it (then
% concatenating the outputs) *OR* by running this on each animal, then
% combining the .csv files as desired.
% now fix up the metadata path loaded below (Thanks Daleep!);
metadataPath = [getPathGlobal('animalSaves') animalName '\metadata.mat'];






treatments = getTreatmentInfo(animalName,thisDate);
DOB = getBirthDate(animalName);
% to get animal age for this table, just subtract DOB from thisDate (after
% formatting)
%formatDateFive(thisDate)
%[newDate,~] = fixDateIndexToFiveForSynapse(thisDate,'000');

thisDrug = treatments.pars{1};
load([workingFolder workingFileName]);
listOfSegments = fields(out.specAnalysis{1,1});

%2) Preallocate empty table
varTypes = {'string','string','string','string','double', 'double','double', 'double', 'double','double', 'double','double','double', 'double','double'};
varNames = {'animalName', 'date','drug', 'index', 'isPeak', 'win', 'winTime','meanMovement', 'AvgTotalPow', 'delta', 'theta', 'alpha', 'beta','gamma','highGamma' };
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

load(metadataPath);

%Pick out the times for the movement events
theseTimes = metaData(contains(metaData.block,listToUse),:).blockTime;

conditionsList = strsplit(out.conditions,',');
for i = 1:length(listToUse)
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

disp('Starting segmenting with pipeline - hold tight, it takes a while...');
[loadedData,segmentTimeData] = patientAnalysis.segmentData(loadedData,blockTime,conditions,1/fs,splitTime,segTime);
disp('Finished segmenting.')

actionList = fields(loadedData);
for i = 1:size(fields(loadedData),1)
    %thisTime = metaData(contains(actionList(i),segmentTimeData)).blockTime;
    time(i) = getfield(segmentTimeData,actionList{i});
    meanMove(i) = mean(getfield(loadedData,actionList{i}));
end

PSMTable.meanMovement = meanMove';

% Other info
segTimes ={out.segmentTimes{1,1}};
oldSegTimes = cellfun(@(x) x - segTimes{1,1}(1), segTimes, 'un', 0);
newSegTimes = duration(0,0,oldSegTimes{1,1}, 'Format','hh:mm:ss');

PSMTable.winTime = newSegTimes;
preInj = contains(listOfSegments,'PostInj');
PSMTable.isPeak = preInj;
PSMTable.animalName(:,1) = animalName;
PSMTable.index(:,1) = out.block;
PSMTable.date (:,1)= thisDate;
PSMTable.drug (:,1)= thisDrug;

% CSV Saving

outPath = [getPathGlobal('animalSaves') animalName '\'];
saveFileName = ['PSM_' animalName '_' thisDate '_' thisDrug '.csv'];
tableOutPath = fullfile(outPath, saveFileName);
writetable(PSMTable,tableOutPath);
