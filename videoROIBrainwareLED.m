function [keepFrames,newTimes,finalLEDTimes] = videoROIBrainwareLED(vidFileName,times)


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
    load([rawPath vidFileName(delims(end)+1:end) '-movementInfo.mat'],'finalLEDTimes','timeGrid','nMissingTrials','frameGridLEDElement');
catch
    warning('movementInfo file not found in W');
end
if ~exist('finalLEDTimes','var')
    try
        load(['\\memorybanks' rawPath(delims(1):delims(end)) vidFileName(delims(end)+1:end) '-movementInfo.mat'],'finalLEDTimes','timeGrid','nMissingTrials','frameGridLEDElement');
    catch
        error('movementInfo file not found in memorybanks');
    end
end
if ~exist('finalLEDTimes','var')
    error('movementInfo file not found');
end

% 2. load ephys trial info
ephysDirName = ['\\memorybanks' rawPath(delims(1):delims(end))];
tempEphysTrialTime = loadTrialList(ephysDirName);

ephysStartTime = tempEphysTrialTime(1);


if exist('nMissingTrials','var')
    ephysFirstLEDTime = tempEphysTrialTime(nMissingTrials+1);
    finalLEDTimes(1:nMissingTrials) = [];    % remove padded trials from video trial array
    finalLEDTimes = finalLEDTimes - find(frameGridLEDElement>0,1); % subtract missing number of elements from the formerly padded array
    tempEphysTrialTime(1:nMissingTrials) = [];  % remove padded trials from ephys trial array
else
    ephysFirstLEDTime = tempEphysTrialTime(1);
end
        
clear timeGrid % delete timeGrid (we don't need it)

finalLEDFrames = finalLEDTimes; % rename, since finalLEDTimes isn't actually a time array, but contains the timeGrid elements with associated LED pulses

% 3. determine ephys trial start times relative to start
tempEphysTrialTime = tempEphysTrialTime(:) - ephysStartTime; % relative to beginning of ephys trials


tempLEDTrialTime = times(finalLEDFrames)'; 
if length(tempEphysTrialTime) ~= length(tempLEDTrialTime)
   tempEphysTrialTime = tempEphysTrialTime(1:length(tempLEDTrialTime)); % occurs when end of video is cut off
   warning('length(tempEphysTrialTime) ~= length(tempLEDTrialTime)');
end

newTimes = times - times(finalLEDFrames(1)) + (ephysFirstLEDTime-ephysStartTime); % times is now relative to the first LED pulse and cast as a different variable

for iLED = 2:length(finalLEDFrames)
    
    start = finalLEDFrames(iLED-1); % interval start element
    stop = finalLEDFrames(iLED); % interval end element
    
    startTime = tempEphysTrialTime(iLED-1); % ephys trial start time
    stopTime = tempEphysTrialTime(iLED); % ephys trial end time
    
    startVidTime = tempLEDTrialTime(iLED-1); % video trial start time
    stopVidTime = tempLEDTrialTime(iLED); % video trial end time
    
    %compare ephys trial time (assumed to be accurate) 
    %to video trial time (assumed to be complete BS) and calculate a scale factor to adjust 
    scaleFactor = (stopTime-startTime)/(stopVidTime-startVidTime); 
    
    newTimes(start:stop) = (times(start:stop)-times(start))*scaleFactor + newTimes(start); % Bryan magic
end

% Exclude frames near LED times, just to be cautious
keepFrames = true(size(times));
for iLED = 1:length(finalLEDFrames)
    ledFrame = finalLEDFrames(iLED);
    if ledFrame-2 < 1 %if the LED occurs too close to the start, we can't subtract two frames before...
        keepFrames(1:ledFrame) = false; %ADDED 5/31/2019
    else
        keepFrames((ledFrame-2):ledFrame) = false;
    end
    discardInterval = find(newTimes>(newTimes(ledFrame)+.7),1,'first');
    keepFrames(ledFrame:discardInterval) = false;
end


figure()
plot(newTimes)
hold on;
scatter(finalLEDFrames,tempEphysTrialTime)
