function [finalMovementArrayNew,timeGridNew,finalLEDTimes] = videoROIBrainwareLED(vidFileName,finalMovementArrayNew,timeGridNew)


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
    load([rawPath vidFileName(delims(end)+1:end) '-movementInfo.mat'],'finalLEDTimes','finalMovementArray','timeGrid');
catch
    warning('movementInfo file not found in W');
end
if ~exist('finalLEDTimes','var')
    try
        load(['\\memorybanks' rawPath(delims(1):delims(end)) vidFileName(delims(end)+1:end) '-movementInfo.mat'],'finalLEDTimes','finalMovementArray','timeGrid');
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


% 2.5 compare loaded variables and passed parameters
% 'finalMovementArray','timeGrid' finalMovementArrayNew,timeGridNew
if length(finalMovementArray)~=length(finalMovementArrayNew)
    error('finalMovementArrayNew not equal in length to finalMovementArray (old)');
end

if ~isequal(timeGrid,timeGridNew)
    error('timeGridNew not equal to timeGrid (old)');
end

clear timeGrid finalMovementArray % delete loaded timeGrid and finalMovementArray.


% 3. determine ephys trial start times
tempEphysTrialTime = tempEphysTrialTime(:) - tempEphysTrialTime(1); % relative to beginning of ephys start time
tempLEDTrialTime = timeGridNew(finalLEDTimes)';
if length(tempEphysTrialTime) ~= length(tempLEDTrialTime)
   tempEphysTrialTime = tempEphysTrialTime(1:length(tempLEDTrialTime)); %Occurs when end of video is cut off
end


% 4. match to LED time array
% find the diff, then outliers, and decide if we should
% correct
tempEphysLEDDiff = tempEphysTrialTime-tempLEDTrialTime;
% we want to reassign tempLEDTrialTime because we fixed any
% calculated times to a real, nearest frame
for iTimes = 1:length(tempLEDTrialTime)
    tempNewFrameTimes = timeGridNew;
    tempLEDTrialTime = timeGridNew(finalLEDTimes)';
    tempEphysLEDDiff = tempEphysTrialTime-tempLEDTrialTime;
    % correct jitter (lack of frame precision) and drift (unexplained video desynchronization) 
    % if we need to adjust the LED start time more than a full
    % ephys frame time stamp
    % first find if there are any frames between Ephys start
    % time and Video determined start time, then delete them.
%                 framesGreater = find(tempNewFrameTimes > tempLEDTrialTime(iTimes));
%                 framesLess = find(tempNewFrameTimes < tempLEDTrialTime(iTimes)+tempEphysLEDDiff(iTimes));
%                 if iTimes == 1
%                     framesLess = 1;
%                 end
%                 framesToKill = framesGreater(1):framesLess(end);
    timeStampsToKill = tempNewFrameTimes(tempNewFrameTimes > tempEphysTrialTime(iTimes));
    timeStampsToKill = timeStampsToKill(timeStampsToKill < tempLEDTrialTime(iTimes)); %only remove frames that occur after ephys trial start and before LED trial start
    framesToKill = zeros(1,length(timeStampsToKill));
    for iFrame = 1:length(timeStampsToKill)                   
        framesToKill(iFrame) = find(tempNewFrameTimes == timeStampsToKill(iFrame));
    end
    if ~isempty(framesToKill)
        %eliminate frames in the way of adjustment
        tempNewFrameTimes(framesToKill) = [];
        %also change movement array, timestamps, and LED timestamps from
        %Expt structure
        timeGridNew(framesToKill) = [];%timeGrid(framesToKill) = [];
        finalMovementArrayNew(framesToKill) = []; %finalMovementArray(framesToKill) = []; 
        finalLEDTimes(iTimes:end) = finalLEDTimes(iTimes:end)-length(framesToKill);
    end

    %NOW we can match the LED to ephys directly (and make
    %whatever small adjustments we need to)
    timeAdj = timeGridNew(finalLEDTimes(iTimes)) - tempEphysTrialTime(iTimes); %timeGrid(finalLEDTimes(iTimes)) - tempEphysTrialTime(iTimes);
    thisTrialIndex = finalLEDTimes(iTimes);
    %nextTrialIndex = Experiment(iList).LEDTimesAdj(iTimes+1);
    timeGridNew(thisTrialIndex:end) = timeGridNew(finalLEDTimes(iTimes):end)-timeAdj; %timeGrid(thisTrialIndex:end) = timeGrid(finalLEDTimes(iTimes):end)-timeAdj;
    %Experiment(iList).frameTimeStampsAdj(Experiment(iList).LEDTimesAdj(iTimes):end)
end





% finalMovementArray = smoothedMovementArrayAdj;
% frameTimeStampsAdj = frameTimeStampsAdj;
