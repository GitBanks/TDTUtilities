function videoMovementScoreByGridSynapse(animal,exptDate)
% this step involves loading multiple videos and ensuring there is
% consistency across them.  This should only be run after every index for
% the day is finished
% function to establish area animal occupies from the video frame grid
% given: animal name and date
% do: 
% 1. find correct movement files; 
% 2. establish correct space to calculate movement across; 
% 3. calculate movement; 
% 4. update animal information table
% I'm not 100% happy with how it loads the same file more than once, but
% the advantage is that these sections are modular - we can rescan the
% movement spaces used in one operation, and recalculate movement
% magnitudes in another.  Advantageous if we want to plug this into the old
% system (with a few minor tweaks likely), bring it to a new system, run
% these operations from another setting / program, or change just that
% function.
% Calls:
% [heatMapMoveIsolated] = movementIsolator(fileName)
% [threshEst] = behaviorThresholdEstimation(experimentInfo);
% [tempBehavParams] = fillTempBehavParams(experimentInfo)
% [listOfAnimalExpts] = getExperimentsByAnimal(animal,'Spon')
% test params
% animal = 'DREADD07';
% exptDate = '18907';

% animal = 'EEG57';
% exptDate = '18n14';

% animal = 'EEG37';
% exptDate = '17615';

% animal = 'EEGRoboMouse';
% exptDate = '19310';



% a few hard-coded variables that should be parameters or from settings file
masterFileName = 'W:\Data\PassiveEphys\EEG animal data\MouseBehavParams.mat';
rootDir = 'M:\PassiveEphys\2019\'; % !!TODO!! % get 2018 path a little smarter than you're doing right now.
%ZS 19107
% find correct movement files
display(['Loading ' exptDate ' from database.']);
listOfAnimalExpts = getExperimentsByAnimal(animal,'Spon');
listIndex = 1;
for iDays = 1:size(listOfAnimalExpts,1)
    if isempty(listOfAnimalExpts{iDays,1})
        error('This step is only set to run on spontaneous stuff for now.')
    end
    if ~isempty(strfind(listOfAnimalExpts{iDays,1}(1:5),exptDate))
        operationList{listIndex} = listOfAnimalExpts{iDays,1};
        framesFile = dir([rootDir operationList{listIndex} '\*framegrid.mat*']);
        if isempty(framesFile)
            error('No framegrid found.  Check that path is OK, and framegrid has been run.');
        end
        fileNameList{listIndex} = [rootDir operationList{listIndex} '\' framesFile.name];
        listIndex = listIndex+1;
    end
end
% establish correct space to calculate movement across all indices for day
display('Isolating movement areas');
subPlotSpaces = [ceil(sqrt(length(operationList))) floor(sqrt(length(operationList)))];
thisFig = figure('position',[50 50 1000 1000]);
for iList = 1:length(operationList)
    subtightplot(subPlotSpaces(1),subPlotSpaces(2),iList);
    [heatMapMoveIsolated(:,:,iList)] = movementIsolator(fileNameList{iList});
    drawnow
    set(gca,'XTick',[],'YTick',[]);
end
pause(1);
heatMapMoveFinal = mean(heatMapMoveIsolated,3)>mean(mean(mean(heatMapMoveIsolated,3)));
figure(thisFig);
for iList = 1:length(operationList)
    subtightplot(subPlotSpaces(1),subPlotSpaces(2),iList);
    [heatMapMoveIsolated(:,:,iList)] = movementIsolator(fileNameList{iList},heatMapMoveFinal);
    drawnow
end
% save heatMapMoveFinal and figure here?  is there a need?

% calculate movement;
display('Calculating movement');
experimentInfo = struct();
for iList = 1:length(operationList)
    load(fileNameList{iList},'frameGrid','frameTimeStamps');
    expectedOneSecondSpan = sum(frameTimeStamps(frameTimeStamps < 2) > 1);
    tempCatAllGrids = [];
    nSquares = sum(sum(heatMapMoveFinal));
%     maxRead = min([length(experimentInfo(iList).frames) length(experimentInfo(iList).frameTimeStamps)]);
    experimentInfo(iList).frames = zeros(1,length(frameGrid));
    % == frame value calculation ==
    framesTemp = zeros(1,length(frameGrid));
    for iGrid = 1:size(heatMapMoveFinal,1)
        for jGrid = 1:size(heatMapMoveFinal,2)
            if heatMapMoveFinal(iGrid,jGrid) == true
                tempCatAllGrids = [tempCatAllGrids squeeze(squeeze(frameGrid(iGrid,jGrid,:)))'];
                framesTemp = framesTemp+squeeze(frameGrid(iGrid,jGrid,:))';
            end
        end
    end
    framesTemp = framesTemp/nSquares;
%     for iSubt = 1:length(framesTemp)-1
%         
%         %framesTemp(iSubt) = abs(framesTemp(iSubt+1)-framesTemp(iSubt));
%     end
    %framesTemp = 
    experimentInfo(iList).framesRaw = abs(diff(framesTemp));
    
    experimentInfo(iList).framesRaw(1:expectedOneSecondSpan) = 0;
    experimentInfo(iList).framesRaw(end-expectedOneSecondSpan:end) = 0;
    
    % smoothing we've been using
    % 'raiseTheRoof' is a smoothing that only pushes values higher (to
    % account for instability when animal moves around)
    %experimentInfo(iList).framesRaw = smooth(raiseTheRoof(experimentInfo(iList).framesRaw,expectedOneSecondSpan*4),expectedOneSecondSpan*4,'sgolay');
    
    a = smooth(experimentInfo(iList).framesRaw,expectedOneSecondSpan,'sgolay');
    
    experimentInfo(iList).framesRaw = smooth(experimentInfo(iList).framesRaw,expectedOneSecondSpan);
    % convol
    
    
    experimentInfo(iList).framesRaw(find(experimentInfo(iList).framesRaw<0)) = 0;
    %set beginning and end .5 seconds to zero 
    %halfS = floor(expectedOneSecondSpan/2);
   
    
    % == normalized frame value calculation ==
    maxVal = prctile(tempCatAllGrids,99);
    minVal = prctile(tempCatAllGrids,1);
    frameGrid = (frameGrid-minVal)/maxVal;
    % we do this here AFTER prctile has been calculated, etc.
    if size(frameTimeStamps,2) > size(frameGrid,3)
        adjVal = abs(size(frameTimeStamps,2)-size(frameGrid,3));
        frameGrid = cat(3,zeros(10,10,adjVal),frameGrid);
        experimentInfo(iList).frames = [zeros(1,adjVal) experimentInfo(iList).frames];
    end
    for iGrid = 1:size(heatMapMoveFinal,1)
        for jGrid = 1:size(heatMapMoveFinal,2)
            if heatMapMoveFinal(iGrid,jGrid) == true
                experimentInfo(iList).frames = experimentInfo(iList).frames+squeeze(frameGrid(iGrid,jGrid,:))';
            end
        end
    end
    experimentInfo(iList).frames = experimentInfo(iList).frames/nSquares;
    experimentInfo(iList).index = operationList{iList};
    experimentInfo(iList).frames = abs(diff(experimentInfo(iList).frames));
    experimentInfo(iList).frameTimeStamps = frameTimeStamps;
    finalMovementArray = experimentInfo(iList).framesRaw;
    % finalMovementArray = experimentInfo(iList).frames;
    % finalLEDTimes = Experiment(iList).LEDTimesAdj;
    frameTimeStampsAdj = experimentInfo(iList).frameTimeStamps;
    filePathName = [rootDir operationList{iList} '\' operationList{iList} '-movementInfoAdjusted.mat'];
    display(['Saving: ' filePathName]);
    save(filePathName,'finalMovementArray','frameTimeStampsAdj');
    clear finalMovementArray frameTimeStampsAdj frameGrid frameTimeStamps
end
close all
% Update existing behavior structure file.  
% Note: We could include this step above, but I'm making an effort to 
% 'modularize' each step, to possibly make updates and implementation 
% across programs easier.
tempBehavParams = fillTempBehavParams(experimentInfo);
close all
display('Loading existing behavior save file (may take a minute)');
%check to see if master behavParams file exists
if exist(masterFileName,'file') == 2
    load(masterFileName); % will load behavParams
    stupidChars = strfind(animal,'-'); % a few animals were named with chars that matlab can't use in structure field names
    if  stupidChars > 0
        animal = [animal(1:stupidChars-1) animal(stupidChars+1:end)];
    end
    behavParams.(animal).(['date' exptDate]) = tempBehavParams.(['date' exptDate]);
    save(masterFileName,'behavParams');
else
    error('Master save file not found!');
end






