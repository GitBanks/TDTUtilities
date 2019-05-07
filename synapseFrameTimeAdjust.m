function [framesToKeep,times] = synapseFrameTimeAdjust(times,frameTimeStamps)

% Assume the first frame is the one most similar to the first one recorded
% in synapse, to account for extra times in the video at the *beginning*
[~,firstFrame] = min(abs(times-frameTimeStamps(1)));

% missingFrames accounts for extra times in the video at the *end*
missingFrames = max([0 (length(times)-firstFrame+1) - length(frameTimeStamps)]);

% Adjust the timestamps we will ultimately keep
times(firstFrame:(end-missingFrames)) = frameTimeStamps(1:(length(times)-firstFrame+1-missingFrames));

% framesToKeep is true except for missing frames at the beginning and end
framesToKeep = true(size(times));
framesToKeep(1:(firstFrame-1)) = false;
if missingFrames>0
    framesToKeep((end-missingFrames+1):end)=false;
end

end