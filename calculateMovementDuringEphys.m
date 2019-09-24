function [meanMovementPerWindow,gMouseEphys_out,gBatchParams] = calculateMovementDuringEphys(animalName,thisDate,thisExpt,gMouseEphys_out,gBatchParams)

% given an animal name, date, and experiment, calculate average movement during associated 
% ephys trials and add to ephys structure

% example inputs
% animalName = 'EEG22';
% thisDate = 'date17131';
% thisExpt = 'expt001';

if ~exist('gMouseEphys_out','var') || ~exist('gBatchParams','var')
    outFileName = 'mouseEphys_out_noParse.mat';
    computerSpecPath = '\\144.92.218.131\Data\Data\PassiveEphys\EEG animal data\';
    load([computerSpecPath outFileName],'mouseEphys_out','batchParams');
    gMouseEphys_out = mouseEphys_out;
    gBatchParams = batchParams;
end

% Load behav data, divide into segments w/ overlap, calculate mean of each segment
fileNameStub = ['PassiveEphys\20' thisDate(5:6) '\' thisDate(5:end) '-' thisExpt(5:end)...
    '\' thisDate(5:end) '-' thisExpt(5:end) '-movementBinary.mat']; %WARNING: EDITED ON 5/6/2019

% try
%     load(['W:\Data\' fileNameStub],'finalMovementArray','frameTimeStampsAdj');
% catch
try
    load(['\\MEMORYBANKS\Data\' fileNameStub],'finalMovementArray','frameTimeStampsAdj'); %WARNING: EDITED ON 5/2/2019
catch
    error(['Can not find ' fileNameStub])
end
% end
fileInfo = dir(['\\MEMORYBANKS\Data\' fileNameStub]);
% time = fileInfo.date;
try
    windowLength = gBatchParams.(animalName).windowLength;
    windowOverlap = gBatchParams.(animalName).windowOverlap;
catch
    warning('window duration and overlap not set');
    windowLength = 20;
    windowOverlap = 0.25;
end

indexLength = frameTimeStampsAdj(end);  
for iWindow = 1:indexLength
    if ((iWindow-1)*windowLength)*(1-windowOverlap) + windowLength < indexLength
        windowTimeLims(iWindow,1) = ((iWindow-1)*windowLength)*(1-windowOverlap);
        windowTimeLims(iWindow,2) = ((iWindow-1)*windowLength)*(1-windowOverlap) + windowLength;
    end
end

for iWindow = 1:size(windowTimeLims,1)
    timeStampsInWindow = frameTimeStampsAdj(frameTimeStampsAdj <= windowTimeLims(iWindow,2));
    timeStampsInWindow = timeStampsInWindow(timeStampsInWindow >= windowTimeLims(iWindow,1));
    if ~isempty(timeStampsInWindow)
        for iFrame = 1:length(timeStampsInWindow)
            framesToUse(iFrame) = find(frameTimeStampsAdj == timeStampsInWindow(iFrame));
        end
         %added 4/8/2019 ZS in case video ran too long and framesToUse has frames outside finalMovementArray... 
        try
            meanMovementPerWindow(iWindow,1) = mean(finalMovementArray(framesToUse));
        catch
            warning('framesToUse has elements outside of finalMovementArray');
            framesToUse = framesToUse(framesToUse <= finalMovementArray);
            meanMovementPerWindow(iWindow,1) = mean(finalMovementArray(framesToUse));
        end
    else
        meanMovementPerWindow(iWindow,1) = NaN;
    end
    clear timeStampsInWindow framesToUse
end 

% check if this is wPLI data and exclude trials that were excluded in the
% ephys structure
fieldnombres = fieldnames(gMouseEphys_out.(animalName).(thisDate).(thisExpt));
if sum(contains(fieldnombres,'delta')) > 1 %assume wpli structure has band names listed
    disp('WPLI data detected')
    theseTrials = ~isnan(gMouseEphys_out.(animalName).(thisDate).(thisExpt).delta.connVal(:,1));%!!!!! CHECK THIS PLEASE 6/16/2019
    excludeTrials = find(theseTrials==0);
    if ~isempty(excludeTrials)
        meanMovementPerWindow(excludeTrials) = nan;
        gMouseEphys_out.(animalName).(thisDate).(thisExpt).activity = meanMovementPerWindow;
        disp('discarded trials!');
    else
        disp('No trials to exclude based on ephys. Checking length of array'); 
        % WIP/DEBUG
        % exclude trials at the end... uhhh
        oldNWindows = length(gMouseEphys_out.(animalName).(thisDate).(thisExpt).delta.activity);
        currentNWindows = length(meanMovementPerWindow);
        if oldNWindows < currentNWindows
            disp('Detected too many movement windows. Removing elements from end of current array');
            meanMovementPerWindow(oldNWindows+1:currentNWindows) = nan; % is it better to have nan or delete these trials?
            gMouseEphys_out.(animalName).(thisDate).(thisExpt).activity = meanMovementPerWindow;
        elseif oldNWindows > currentNWindows
            warning('Detected fewer windows than previously saved. Using current array');

            %plot to check!
%             figure; h(1) = subplot(1,2,1); plot(gMouseEphys_out.(animalName).(thisDate).(thisExpt).delta.activity); 
%             h(2) = subplot(1,2,2); plot(meanMovementPerWindow);
%             sgtitle([animalname ' ' thisDate ' ' thisExpt]);
%             linkaxes(h,'x');
            
            gMouseEphys_out.(animalName).(thisDate).(thisExpt).activity = meanMovementPerWindow;
        else
            excludeMovementTrials = isnan(gMouseEphys_out.(animalName).(thisDate).(thisExpt).delta.activity);
            if any(excludeMovementTrials==1) %if there are any trials to exclude
                warning('found movement trials to exclude within old movement structure but not ephys...');
                meanMovementPerWindow(excludeMovementTrials) = nan;
                gMouseEphys_out.(animalName).(thisDate).(thisExpt).activity = meanMovementPerWindow;
            else %if there are NO trials to exclude
                gMouseEphys_out.(animalName).(thisDate).(thisExpt).activity = meanMovementPerWindow;
                disp('Detected no trials to exclude');
            end
        end

    end
else % if not wPLI data, use the following lines to exclude trials
    try
        theseTrials = gMouseEphys_out.(animalName).(thisDate).(thisExpt).trialsKept;
        % exclude the corresponding trials from the mean movement structure
        gMouseEphys_out.(animalName).(thisDate).(thisExpt).activity = ...
                meanMovementPerWindow(theseTrials);
        disp('discarded trials excluded!');
        % grab the trials that were kept
    catch
        warning('theseTrials no existe');
%         gMouseEphys_out.(animalName).(thisDate).(thisExpt).activity = ...
%                 meanMovementPerWindow;
    end
end


