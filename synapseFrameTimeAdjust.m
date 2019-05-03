function [times] = synapseFrameTimeAdjust(times,frameTimeStamps)

%timestamp adjustment for ephys trials... (imported from Sean)
    startNotFilledIn = true;
    startFillIndex = 1;
    while startNotFilledIn
        beginning(startFillIndex) = frameTimeStamps(1)-(mean(diff(frameTimeStamps))*startFillIndex);
        if (beginning(startFillIndex)-(mean(diff(frameTimeStamps)))) < 0
            startNotFilledIn = false;
        end
        startFillIndex = startFillIndex+1;
    end
    newFrameTimeStamps = [flip(beginning) frameTimeStamps'];
    if (length(times) - length(newFrameTimeStamps)) - length(find(frameTimeStamps(end) < times)) < 2
        for iFill = 1:length(find(frameTimeStamps(end) < times))
            endFill(iFill) = frameTimeStamps(end)+mean(diff(frameTimeStamps))*iFill;
        end
        if exist('endfill','var')
            newFrameTimeStamps = [newFrameTimeStamps endFill];
        end
        if length(times) ~= length(newFrameTimeStamps) %if we're off by one, figure out which end to stick the last frame
            if newFrameTimeStamps(1)-times(1)>newFrameTimeStamps(end)-times(end)
                newFrameTimeStamps = [0.001 newFrameTimeStamps]; % if more time exists at beginning of time stamps
            else
                newFrameTimeStamps = [newFrameTimeStamps newFrameTimeStamps(end)+mean(diff(frameTimeStamps))];
            end
        end
    else
        warning('something is wrong with video alignment!');    
    end
    frameTimeStamps = newFrameTimeStamps';
    times = frameTimeStamps; % not sure which one is used when, get rid of one once we know...
    % some possible integrity checks (if we need them): actualFrameRate should
    % equal mean(diff(frameTimeStamps)); if frameTimeStamps isn't totally equal
    % in length to timeGrid ask TDT, or maybe if it's off by one it's OK? 100ms
    % of error OK?