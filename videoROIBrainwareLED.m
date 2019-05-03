function [keepFrames,times,finalLEDTimes] = videoROIBrainwareLED(vidFileName,times)


% procedure for aligning existing LED pulse information with corresponding
% ephys trial start time information, and adjusting any other arrays
% associated with that timeline.  This is only applicable to previously
% recorded Brainware data
% 1. load existing LED pulse information
% 2. load ephys
% 3. determine ephys trial start times
% 4. match to LED time array, make adjustments as needed (since ephys is
% the 'truth')

% ex: vidFileName = 'W:\Data\PassiveEphys\2018\18410-000\18410-000'; %EEG51

% setup 
delims = strfind(vidFileName,filesep);
rawPath = vidFileName(1:delims(end));

% 1. load existing LED pulse information
try
    load([rawPath vidFileName(delims(end)+1:end) '-movementInfo.mat'],'finalLEDTimes','timeGrid');
catch
    warning('movementInfo file not found in W');
end
if ~exist('finalLEDTimes','var')
    try
        load(['\\memorybanks' rawPath(delims(1):delims(end)) vidFileName(delims(end)+1:end) '-movementInfo.mat'],'finalLEDTimes','timeGrid');
    catch
        error('movementInfo file not found in memorybanks');
    end
end
if ~exist('finalLEDTimes','var')
    error('movementInfo file not found');
end

% 2. load ephys
ephysDirName = ['\\memorybanks' rawPath(delims(1):delims(end))];
tempEphysTrialTime = loadTrialList(ephysDirName);


if ~isequal(timeGrid,times)
    error('timeGridNew not equal to timeGrid (old)');
end

clear timeGrid % delete loaded timeGrid and finalMovementArray.

finalLEDFrames = finalLEDTimes;

% 3. determine ephys trial start times
tempEphysTrialTime = tempEphysTrialTime(:) - tempEphysTrialTime(1); % relative to beginning of ephys start time
tempLEDTrialTime = times(finalLEDFrames)';
if length(tempEphysTrialTime) ~= length(tempLEDTrialTime)
   tempEphysTrialTime = tempEphysTrialTime(1:length(tempLEDTrialTime)); %Occurs when end of video is cut off
end



newTimes = times - times(finalLEDFrames(1));

for iLED = 2:length(finalLEDFrames)
    % Adjust timeGridnew
    start = finalLEDFrames(iLED-1);
    stop = finalLEDFrames(iLED);
    startTime = tempEphysTrialTime(iLED-1);
    stopTime = tempEphysTrialTime(iLED);
    
    startVidTime = tempLEDTrialTime(iLED-1);
    stopVidTime = tempLEDTrialTime(iLED);
    
    scaleFactor = (stopTime-startTime)/(stopVidTime-startVidTime);
    
    newTimes(start:stop) = (times(start:stop)-times(start))*scaleFactor + newTimes(start);
end


keepFrames = true(size(times));
for iLED = 1:length(finalLEDFrames)
    % Exclude frames near LED times
    ledFrame = finalLEDFrames(iLED);
    
    keepFrames((ledFrame-2):ledFrame) = false;
    discardInterval = find(newTimes>(newTimes(ledFrame)+.7),1,'first');
    keepFrames(ledFrame:discardInterval) = false;
end
