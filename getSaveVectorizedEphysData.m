function saveArraySpecAnalysis(animalName,exptDate)
% we want to convert the specAnalysis output to a time array
% format, for much easier readability, and flexibility.  We'll save this in
% the animal's folder.  This will make it easier to select time windows for
% PSM and other plotting.

% test params
% animalName = 'EEG200';
% exptDate = '22614';

% WIP we don't think we'll need 'set' data, but we *may* if we want to
% exclude channels (e.g.).  If that's the case we should include the animals 'set'
% string so it's loaded with getPathGlobal
% saveFolder = getPathGlobal([setName '-savePath']); 

% === Set a few parameters to start
% We'll assume we only care about predefined bands (we've been using these
% for years).  Let's continue to use the bands defined here: FreqBands
bandNames = FreqBands.Names(1:5);
bandRanges = zeros(2,5); % these will be set when we find the corresponding element in the specAnalysis loaded data

% === Find and load the animals specAnalysis output.
folder = [getPathGlobal('pipelineSaves') animalName '\'];
% the file will be some crazy thing like this:
% 'EEG210_22629-001,22629-003,22629-005,22629-007,22629-009,22629-011 wPLI_dbt'; 
% instead, we'll search for it.
dataFolder = dir(folder);
for iFile = 1:size(dataFolder,1)
    if contains(dataFolder(iFile).name,'specAnalysis') && contains(dataFolder(iFile).name,exptDate) 
        file = dataFolder(iFile).name;
    end
end
if ~exist('file','var')
    error(['Found ' dataFolder(1).folder ' but not the file we''re looking for!']);
end
load([folder file]);
% if we run this for ZZ data, we'll need to add this: [out] = removeNonKeywordFromSpecAnalysis(out,searchWord)
if contains(animalName,'ZZ')
    [out] = removeNonKeywordFromSpecAnalysis(out);
end

% === load all valid fields
listOfSegments = fields(out.specAnalysis{1,1});

% === grab the labels / values for the frequencies
freqLabels = out.specAnalysis{1,1}.(listOfSegments{1}).freq;
for iBand = 1:size(bandNames,2)
    thisFreq = bandNames{iBand};
    bandRanges(1,iBand) = find(freqLabels>=FreqBands.Limits.(thisFreq)(1),1);
    bandRanges(2,iBand) = find(freqLabels>=FreqBands.Limits.(thisFreq)(2),1);
end
bandRanges(2,5) = find(freqLabels>=FreqBands.Limits.highGamma(2),1); % we've been using highGamma as the gamma bound

% === get the band ranges of interest for each segment and channel.
nChans = size(out.specAnalysis{1,1}.(listOfSegments{1}).powspctrm,1);
for iSegment = 1:size(listOfSegments,1)
    thisSeg = listOfSegments{iSegment};
    for iChan = 1:nChans
        for iBand = 1:size(bandNames,2)
            bandStart = bandRanges(1,iBand);
            bandEnd = bandRanges(2,iBand);
            specdata(iChan).data(iSegment,iBand) = mean(out.specAnalysis{1,1}.(thisSeg).powspctrm(iChan,bandStart:bandEnd));
        end
    end
end

% === get the window times, relative to the last injection (and we're
% assuming that's t=0 )
windowTimes = out.segmentTimeOfDay{1,1};
[exptDate_dbForm] = houseConvertDateTo_dbForm(exptDate);
windowTimes = datetime(exptDate_dbForm,'TimeZone','local')+windowTimes;
[moveTimeDrugStruct] = getMoveTimeDrugbyAnimalDate(animalName,exptDate,false);
TheseDrugs = moveTimeDrugStruct.drugTOD;
adjTimes = windowTimes-TheseDrugs(end).time;

% === get movement values 
% we did get movement data from getMoveTimeDrugbyAnimalDate, but let's
% use the pipeline segmenting to define these windows, to better match the
% relevant segments
theseExptIndices = getExperimentsByAnimalAndDate(animalName,exptDate);   % need to change for ZZ???
masterIndex = 1;
for iIndex = 1:size(theseExptIndices,1)
    exptIndex = theseExptIndices{iIndex};
    exptIndex = exptIndex(7:9);
    [loadedData,segmentTimeData] = getSegmentMovementUsingPipeline(animalName,exptDate,exptIndex);
    actionList = fields(loadedData);
    for iField = 1:size(fields(loadedData),1)
        %thisTime = metaData(contains(actionList(i),segmentTimeData)).blockTime;
        moveTimes(masterIndex) = getfield(segmentTimeData,actionList{iField}); % hopefully don;t need these, but compare it to other segmented data
        meanMove(masterIndex) = mean(getfield(loadedData,actionList{iField}));
        masterIndex = masterIndex+1;
    end
end
adjMoveTimes = moveTimes-TheseDrugs(end).time;
% adjTimes and adjMoveTimes should agree (since they used the same
% analysis).
if length(adjTimes)-length(adjMoveTimes) ~= 0
    error('something went wrong with the segmenting - there''s a difference between specanalysis and movement segments' )
end

% === now create the array we've been waiting for
varTypes = {'duration','double','double','double','double','double','double','double','double','double','double','double'};
varNames = {'time','meanMovement','deltaA','thetaA','alphaA','betaA','gammaA','deltaP','thetaP','alphaP','betaP','gammaP'};
sz = [length(adjTimes),length(varNames)];
happyTable = table('Size',sz,'VariableTypes',varTypes,'VariableNames',varNames);
happyTable.time = adjTimes;
happyTable.meanMovement = meanMove';
happyTable.deltaA = specdata(1).data(:,1);    % compare to specdata(4).data(:,1) ???
happyTable.thetaA = specdata(1).data(:,2);  
happyTable.alphaA = specdata(1).data(:,3);  
happyTable.betaA = specdata(1).data(:,4);  
happyTable.gammaA = specdata(1).data(:,5);  
happyTable.deltaP = specdata(2).data(:,1);      % compare to specdata(3).data(:,1) ???
happyTable.thetaP = specdata(2).data(:,2);
happyTable.alphaP = specdata(2).data(:,3);
happyTable.betaP = specdata(2).data(:,4);
happyTable.gammaP = specdata(2).data(:,5);

% === save now










