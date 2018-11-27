function videoFrameGridMakerSynapse(fileName)
% GIVEN: a file location
% DO: load video file; reduce each frame to a grid; save grid file to
% location
% example parameter:
% fileName = 'W:\Data\PassiveEphys\2018\18907-001\2018_18907-001_Cam1.avi';
% change in Synapse version: analyzed data should be put in 'memorybanks'
% or appropriate derived or analysis path.

saveDirRoot = '\\MEMORYBANKS\Data\PassiveEphys\';
delims = strfind(fileName,filesep);
rawPath = fileName(1:delims(end));
savePath = [saveDirRoot fileName(delims(end-2)+1:delims(end))];
saveFile = [savePath fileName(delims(end)+1:end-4) '-framegrid.mat'];
% Synapse version also stores timestamps from TDT file
data = TDTbin2mat(rawPath,'TYPE',{'epocs'}); % only need epocs - this saves a ton of time.
frameTimeStamps = data.epocs.Cam1.onset; % this makes assumptions about the structure.  will need to change if we change 'Cam1' e.g.
% the rest of the program, below, is just the old version.
% TODO % We may not need all of the following since we have the real frame
% timestamps already
secToLoad = 60; %load a managable time span - on Helios, 1 min of video takes 13 seconds to load,
% make sure file or non .avi video version exist
if exist(fileName) ~= 2
    fileName = fileName(1:end-4);
    if exist(fileName) ~= 2
        error(['Cannot find the file ' fileName]);
    end
end
try 
    firstFrame = mmread(fileName,1);
catch
    error(['Found, but could not load ' fileName]);
end
try
% === Loading the whole video and run a vectorization reduction ===
timeIndex = 0;
tic;
while timeIndex < firstFrame.totalDuration
    % create a 10*10 frame grid, so we can see what's happening in a
    % more refined way. % QUESTION: do we want more / less
    % resolution?  Add this as a parameter?

    if (timeIndex+secToLoad) < (firstFrame.totalDuration) %if there's all of secToLoad remaining
        testVid = mmread(fileName,[],[timeIndex,timeIndex+secToLoad]);
    else %if there's less than secToLoad remaining
        testVid = mmread(fileName,[],[timeIndex,firstFrame.totalDuration]);
    end

    tempGrid = zeros(10,10,int32(length(testVid.times)));
    timeIndex = timeIndex+secToLoad;
    %add some rounding in case video isn't div by 10 (is that possible?)
    stepA = testVid.height/size(tempGrid,1);
    stepB = testVid.width/size(tempGrid,2);
    % TODO !!!verify sync
    nFrames = length(testVid.frames); 
    for iFrame = 1:nFrames
        for iGrid = 1:stepA:testVid.height
            for jGrid = 1:stepB:testVid.width
                tempGrid(ceil(iGrid/stepA),ceil(jGrid/stepB),iFrame) = sum(sum(sum(testVid.frames(iFrame).cdata(iGrid:iGrid+stepA-1,jGrid:jGrid+stepB-1,:))));
            end
        end
    end
    if exist('frameGrid','var')
        frameGrid = cat(3,frameGrid,tempGrid); % build the array by the time length we're stepping through.
        timeGrid = cat(2,timeGrid,testVid.times);
        display([num2str(size(frameGrid,3)) ' frames completed.']);
        toc;
    else
        frameGrid = tempGrid; % initialize the array
        timeGrid = testVid.times;
        display(['Starting with ' num2str(size(frameGrid,3)) ' frames']);
        actualFrameRate = length(testVid.times)/secToLoad;
        toc;
    end
end
% in the Synapse version, we have two time arrays: one that was created by
% Synapse itself, and one encoded in the video.  We have both now.  Synapse
% frame time stamps start slightly after the beginning of recording, and
% will indicate so, so we need to align the two here. Everything (including
% ephys) is relative to start of recording, so that's all that matters when
% adjusting time.
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
if (length(timeGrid) - length(newFrameTimeStamps)) - length(find(frameTimeStamps(end) < timeGrid)) < 2
    for iFill = 1:length(find(frameTimeStamps(end) < timeGrid))
        endFill(iFill) = frameTimeStamps(end)+mean(diff(frameTimeStamps))*iFill;
    end
    if exist('endfill','var')
        newFrameTimeStamps = [newFrameTimeStamps endFill];
    end
    if length(timeGrid) ~= length(newFrameTimeStamps) %if we're off by one, figure out which end to stick the last frame
        if newFrameTimeStamps(1)-timeGrid(1)>newFrameTimeStamps(end)-timeGrid(end)
            newFrameTimeStamps = [0.001 newFrameTimeStamps]; % if more time exists at beginning of time stamps
        else
            newFrameTimeStamps = [newFrameTimeStamps newFrameTimeStamps(end)+mean(diff(frameTimeStamps))];
        end
    end
else
    warning('something is wrong with video alignment!');    
end
frameTimeStamps = newFrameTimeStamps';
timeGrid = frameTimeStamps; % not sure which one is used when, get rid of one once we know...
% some possible integrity checks (if we need them): actualFrameRate should
% equal mean(diff(frameTimeStamps)); if frameTimeStamps isn't totally equal
% in length to timeGrid ask TDT, or maybe if it's off by one it's OK? 100ms
% of error OK?
save(saveFile,'frameGrid','timeGrid','firstFrame','actualFrameRate','frameTimeStamps'); % seriously, get rid of either timeGrid or frameTimeStamps
catch
    display('Fatal error while running main grid loop.  Likely culprit is mmread. File not saved! Try rerunning.')
end


