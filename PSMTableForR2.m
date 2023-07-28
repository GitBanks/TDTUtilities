function PSMTableForR2(animalName,exptDate)
% !! REDOING THIS !
% instead of recalculating everything which DOES NOT match what we've done,
% I'm just using what we've done in plotSpectraEEG - simply loading that
% output into PSM / matching format


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
% animalName = 'EEG200';
% exptDate = '22614';

% MIGHT WANT TO MAKE THIS A PARAMETER!!!


% TODO! make this a flexible parameter or global path check from a set type
% input maybe

try
%     loadFileFolder = 'M:\PassiveEphys\AnimalData\Fluvoxamine-LPS\';
    loadFileFolder = 'M:\PassiveEphys\AnimalData\DOI\';
    loadFile = [loadFileFolder animalName '_' exptDate '_bandpowerSet.mat'];
    load(loadFile,"dataSet");
    chanOfInterest = [1,2];
    specificHours = [1,4];
catch
    try
        loadFileFolder = 'M:\PassiveEphys\AnimalData\combined\';
        loadFile = [loadFileFolder animalName '_' exptDate '_bandpowerSet.mat'];
        load(loadFile,"dataSet");
        chanOfInterest = [1,2];
        specificHours = [1,4];
    catch
        try
            loadFileFolder = 'M:\Zarmeen\Data\spectra\';
            loadFile = [loadFileFolder animalName '_' exptDate '_bandpowerSet.mat'];
            load(loadFile,"dataSet");
            % we want to load R PFC for now.  We will find the channels
            % with this 
            [electrodeLocation,map,~] = getElectrodeLocationFromAnimalName(animalName);
            % next, remember that the channels are saved in order 1:16 for
            % 'map' list, then in that order pulled from electrodeLocation
            channelList = electrodeLocation(map);
            chanOfInterest = find(contains(channelList,'R mPFC') | (contains(channelList,' R ') & contains(channelList,'PFC')))';
            specificHours = [1,2];
        catch
            error(['File not found' loadFile]);
        end
    end
end


treatments = getTreatmentInfo(animalName,exptDate);
thisDrug = treatments.pars{1};

theseExptIndices = getExperimentsByAnimalAndDate(animalName,exptDate);


totalSegs = 0;
for i = 1:size(specificHours,2)
    totalSegs = totalSegs+size(dataSet(specificHours(i)).time,1);
end

%2) Preallocate empty table
varTypes = {'string','string','string','string','double', 'double','duration','double','double','double','double','double','double','double','double','double','double','double','double','double'};
varNames = {'animalName', 'date','drug', 'index','isPeak','win','winTime','meanMovement','AvgTotalPowA','deltaA','thetaA','alphaA','betaA','gammaA','AvgTotalPowP','deltaP','thetaP','alphaP','betaP','gammaP'};
sz = [totalSegs,length(varNames)];
PSMTable = table('Size',sz,'VariableTypes',varTypes,'VariableNames',varNames);

%3) Start pulling in data


incrementSeg = 1;
for i = 1:size(specificHours,2)
    exptIndex = theseExptIndices{specificHours(i)};
    exptIndex = exptIndex(7:9);
    [loadedData,segmentTimeData] = getSegmentMovementUsingPipeline(animalName,exptDate,exptIndex);
    actionList = fields(loadedData);
    for iField = 1:size(fields(loadedData),1)
        %thisTime = metaData(contains(actionList(i),segmentTimeData)).blockTime;
        time(iField) = getfield(segmentTimeData,actionList{iField});
        meanMove(iField) = mean(getfield(loadedData,actionList{iField}));
    end
    


  % TODO!:  if we want a specific time window, we'll want to more
        % tightly define dataSet(specificHours(i)).time and use that window
        % of segments to define this loop
        % so we're going to want iSegment to be a predefined array of that
        % window

    for iSegment = 1:size(dataSet(specificHours(i)).time,1)
        


        %thisSeg = listOfSegments{iSegment};
        
        chanN = chanOfInterest(1);
        % first eleement here is anterior
        PSMTable.AvgTotalPowA(incrementSeg) = dataSet(specificHours(i)).delta(iSegment,chanN);
        PSMTable.deltaA(incrementSeg) = dataSet(specificHours(i)).delta(iSegment,chanN);
        PSMTable.thetaA(incrementSeg) = dataSet(specificHours(i)).theta(iSegment,chanN);
        PSMTable.alphaA(incrementSeg) = dataSet(specificHours(i)).alpha(iSegment,chanN);
        PSMTable.betaA(incrementSeg) = dataSet(specificHours(i)).beta(iSegment,chanN);
        PSMTable.gammaA(incrementSeg) = dataSet(specificHours(i)).gamma(iSegment,chanN);
        %PSMTable.highGamma(incrementSeg) = mean(mean(out.specAnalysis{1,1}.(thisSeg).powspctrm(iChans,highGamma),1));

        % 2nd element here is the posterior (updated: for just some mice)
        chanN = chanOfInterest(2);
        PSMTable.AvgTotalPowP(incrementSeg) = dataSet(specificHours(i)).delta(iSegment,chanN);
        PSMTable.deltaP(incrementSeg) = dataSet(specificHours(i)).delta(iSegment,chanN);
        PSMTable.thetaP(incrementSeg) = dataSet(specificHours(i)).theta(iSegment,chanN);
        PSMTable.alphaP(incrementSeg) = dataSet(specificHours(i)).alpha(iSegment,chanN);
        PSMTable.betaP(incrementSeg) = dataSet(specificHours(i)).beta(iSegment,chanN);
        PSMTable.gammaP(incrementSeg) = dataSet(specificHours(i)).gamma(iSegment,chanN);

        PSMTable.winTime(incrementSeg) = dataSet(specificHours(i)).time(iSegment);
        PSMTable.meanMovement(incrementSeg) = meanMove(iSegment);
        if i == 1
            PSMTable.isPeak(incrementSeg) = 0;
        else
            PSMTable.isPeak(incrementSeg) = 1;
        end
        PSMTable.animalName(incrementSeg) = animalName;
        PSMTable.index(incrementSeg) = exptIndex;
        PSMTable.date(incrementSeg) = exptDate;
        PSMTable.drug(incrementSeg) = thisDrug;
        PSMTable.win(incrementSeg) = incrementSeg;
        incrementSeg = incrementSeg+1;
    end
    clear meanMove
end

% CSV Saving
outPath = [getPathGlobal('animalSaves') animalName '\'];

saveFileName = ['PSM_' animalName '_' exptDate '.csv'];

tableOutPath = fullfile(outPath, saveFileName);
writetable(PSMTable,tableOutPath);






