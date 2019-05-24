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
try
    load(['W:\Data\' fileNameStub],'finalMovementArray','frameTimeStampsAdj');
catch
    try
        load(['\\MEMORYBANKS\Data\' fileNameStub],'finalMovementArray','frameTimeStampsAdj'); %WARNING: EDITED ON 5/2/2019
    catch
        error(['Can not find ' fileNameStub])
    end
end

windowLength = gBatchParams.(animalName).windowLength;
windowOverlap = gBatchParams.(animalName).windowOverlap;

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
        try %added 4/8/2019 ZS in case video ran too long and framesToUse has frames outside finalMovementArray... 
            meanMovementPerWindow(iWindow,1) = mean(finalMovementArray(framesToUse));
        catch
            disp('my dumbass try-catch was triggered');
            framesToUse = framesToUse(framesToUse <= finalMovementArray);
            meanMovementPerWindow(iWindow,1) = mean(finalMovementArray(framesToUse));
        end
    else
        meanMovementPerWindow(iWindow,1) = NaN;
    end
    clear timeStampsInWindow framesToUse
end 

% grab the trials that were kept
try 
    theseTrials = gMouseEphys_out.(animalName).(thisDate).(thisExpt).trialsKept;
    % exclude the corresponding trials from the mean movement structure
    gMouseEphys_out.(animalName).(thisDate).(thisExpt).activity = ...
            meanMovementPerWindow(theseTrials);
    disp('discarded trials excluded!');
catch
    warning('theseTrials no existe')
end
