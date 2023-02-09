function [loadedData,segmentTimeData] = getSegmentMovementUsingPipeline(animalName,exptDate,exptIndex)

% given: and animal name and date/index
% return: segmented movement data using the pipeline

% depends on metadata thing to have been run

% animalName = 'EEG200';
% exptDate = '22614';
% exptIndex = '001';
% analysisType = 'specAnalysis';

% Movement 
metadataPath = [getPathGlobal('animalSaves') animalName '\metadata.mat'];
% workingFolder = [getPathGlobal('pipelineSaves') animalName '\'];

% need to figure this out - if we want to specify the 'option set' or the
% analysis type
% if ~exist('analysisType','var')
%     analysisType = 'specAnalysis'; % add this as a parameter?
% end

% checkFolder = dir(workingFolder);
% for ii=1:size(checkFolder,1)
%     % make sure it contains today's date and analysis type
%     if contains(checkFolder(ii).name,exptDate) && contains(checkFolder(ii).name,analysisType) 
%         workingFileName = checkFolder(ii).name;
%     end
% end
% TODO: Zarmeen requested adding multiple days to a PSM file.  We can do
% that by making workingFileName a list and stepping through it (then
% concatenating the outputs) *OR* by running this on each animal, then
% combining the .csv files as desired.
% now fix up the metadata path loaded below (Thanks Daleep!);
try 
    %load([workingFolder workingFileName]);
    load(metadataPath);
catch
    error(['This function depends on ecog metadata to have been compiled - check this folder: ' metadataPath]);
end

% listOfSegments = fields(out.specAnalysis{1,1});

% narrow down which expts we want to load
thisBlock = [exptDate '-' exptIndex];
selectedTable = metaData(contains(metaData.block,thisBlock),:);

% listToUse = strsplit(fileList,',');

%Pick out the times for the movement events
theseTimes = selectedTable.blockTime;

% conditionsList = strsplit(out.conditions,',');

[magData,magDT] = HTRMagLoadData(thisBlock);
dataToPlot = smooth(abs(magData-mean(magData)),(1/magDT)*4,'sgolay',2);
tempText = strrep(thisBlock,'-','_');
loadedData.(['blk' tempText]) = dataToPlot;

%     segTime = out.analysisOptions(1,1).segTime;
%     splitTime = out.analysisOptions(1,1).splitTime;
% load these in from analysisOptions - but also avoid loading in the whole
% spec analysis output....
segTime = 4;
splitTime = 60;
fs = 1/magDT;

conditions{:} = char(selectedTable.conditions);
blockTime.(['blk' tempText]) = theseTimes;

disp('Starting segmenting with pipeline');
[loadedData,segmentTimeData] = patientAnalysis.segmentData(loadedData,blockTime,conditions,1/fs,splitTime,segTime);
disp('Finished segmenting.')

