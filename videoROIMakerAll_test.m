function [finalMovementArray,timeGrid,pixROI] = videoROIMakerAll_test(fileName,pixROI)

% GIVEN: a file location
% DO: load video file; prompt user to draw ROI; read video 60s at a
% time & exclude pixels outside ROI; calculate 1st derivative across all pixels, average, and
% save the difference array and output pixROI for subsequent use

% example parameters:
% fileName = 'W:\Data\PassiveEphys\2019\19327-003\2019_19327-003_Cam1.avi';
% pixROI = [];

delims = strfind(fileName,filesep);
rawPath = fileName(1:delims(end));
saveDirRoot = '\\MEMORYBANKS\Data\PassiveEphys\'; % analyzed data should be put in 'memorybanks'
savePath = [saveDirRoot fileName(delims(end-2)+1:delims(end))];
saveFile = [savePath fileName(delims(end)+1:end-4) '- roiMovementArray.mat'];

try
    data = TDTbin2mat(rawPath,'TYPE',{'epocs'}); % Synapse version also stores timestamps from TDT file % only need epocs - this saves a ton of time.
    frameTimeStamps = data.epocs.Cam1.onset; % this makes assumptions about the structure.  will need to change if we change 'Cam1' e.g.
    synapseData = true;
catch
    warning('non-synapse data detected.');
    synapseData = false;
end

secToLoad = 60; %load a managable time span 

try % make sure file or non .avi video version exist
    vidObj = VideoReader(fileName);
catch
    error(['Found, but could not load ' fileName]);
end

% WIP: grab some general parameters about to video to aid preallocation steps
FR = vidObj.FrameRate;
%calculate actual frame rate??
nFrames = vidObj.Duration*FR; % !!!this will not be true for old videos!!!!!!!!

% draw ROI & use shape to create logical to exclude pixels as nans in subsequent steps
if isempty(pixROI)
    vidObj.CurrentTime = 1; %this line seems problematic??
    currentFrame = rgb2gray(readFrame(vidObj)); %read in frame at CurrentTime
    figure('name',['time = ' num2str(vidObj.CurrentTime)]);
    disp('please draw shape around bottom of cage at animal height');
    [thesePix] = roipoly(currentFrame); %draw polygon around mouse area    
    hold on
    imshow(thesePix,[]); %show selection
    pixROI = logical(thesePix(:,:)); %now use pix to exclude non-ROI pixels in each frame
end

dPix = [];
dPixSm = [];
timeGrid = [];

% vidObj.CurrentTime= 0; %WIP: reset current time. Is this acceptable?
timeIndex = 0; 

tic; 
while timeIndex < vidObj.Duration
    
    vidObj.CurrentTime = timeIndex;
    
    % check if the current interval ends before the video does. If not, set
    % the endTime equal to totalDuration
    if timeIndex+secToLoad < vidObj.Duration
        endTime = timeIndex+secToLoad;
    else
        endTime = vidObj.Duration;
        tempLum = [];
    end
    
    % read frames from this segment into memory as grayscale, exclude the pixels outside ROI
    iTemp = 1; % temp frame counter just for this 60second segment
    while vidObj.CurrentTime <= endTime && hasFrame(vidObj)
        tempFrame = rgb2gray(readFrame(vidObj));
        tempFrame(~pixROI) = nan; % exclude as nan 
        tempLum(:,:,iTemp) = tempFrame; % fill temp variable for diff
        tempTimes(iTemp) = vidObj.CurrentTime;
        iTemp = iTemp+1; % count up temp counter
    end
    timeIndex = endTime; % increment timeIndex up

    tempDPix = abs(diff(tempLum,1,3)); % nonsmoothed differences
    tempDPixSm = smooth3(tempDPix,'box',[11 11 round(FR/2)*2+1]); % smoothed differences
    
    % calculate mean difference per frame over all pixels this segment
    tempDPix = squeeze(nanmean(tempDPix,[1,2])); 
    tempDPixSm = squeeze(nanmean(tempDPixSm,[1,2]));
        
    % concatenate temp mean difference arrays with output array
    dPix = cat(1,dPix,tempDPix);
    dPixSm = cat(1,dPixSm,tempDPixSm); 
    timeGrid = cat(1,timeGrid,tempTimes);
    
    %TO-DO: Calculate standard deviation of pixels...?? Account for
    %luminance differences
    
    
end
toc

% Remove first and last second of data to exclude artifacts
disp('setting first and last second of data to nan');
dPix(1:FR) = nan;
dPixSm(1:FR) = nan;
dPix(nFrames-FR:nFrames) = nan;
dPixSm(nFrames-FR:nFrames) = nan; 

% rename movement array to something sensible
finalMovementArray = dPixSm;

%TO-DO: TIMESTAMPS
% in the Synapse version, we have two time arrays: one that was created by
% Synapse itself, and one encoded in the video.  We have both now.  Synapse
% frame time stamps start slightly after the beginning of recording, and
% will indicate so, so we need to align the two here. Everything (including
% ephys) is relative to start of recording, so that's all that matters when
% adjusting time.
disp('starting time adjustment');
tic
if synapseData
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
else
    %load in existing timestamp array???
%     load([fileName ]
end
toc


% save difference array and pixROI
% save(saveFile,'finalMovementArray','frameTimeStamps','pixROI');
%% testing above format with mmread instead of VideoReader. 4/9/2019

% example parameters:
% fileName = 'W:\Data\PassiveEphys\2019\19327-003\2019_19327-003_Cam1.avi'; %new
fileName = 'W:\Data\PassiveEphys\2017\17512-000\17512-000'; %old
pixROI = [];

delims = strfind(fileName,filesep);
rawPath = fileName(1:delims(end));
saveDirRoot = '\\MEMORYBANKS\Data\PassiveEphys\'; % analyzed data should be put in 'memorybanks'
savePath = [saveDirRoot fileName(delims(end-2)+1:delims(end))];
saveFile = [savePath fileName(delims(end)+1:end-4) '- roiMovementArray.mat'];

try
    data = TDTbin2mat(rawPath,'TYPE',{'epocs'}); % Synapse version also stores timestamps from TDT file % only need epocs - this saves a ton of time.
    frameTimeStamps = data.epocs.Cam1.onset; % this makes assumptions about the structure.  will need to change if we change 'Cam1' e.g.
    synapseData = true;
catch
    warning('non-synapse data detected.');
    synapseData = false;
end

% WIP: grab some general parameters about video
secToLoad = 60; %load a managable time span 
frameToShow = 1;
try % make sure file or non .avi video version exist
    firstFrame = mmread(fileName,frameToShow);
catch
    error(['Found, but could not load ' fileName]);
end

% draw ROI & use shape to create logical to exclude pixels as nans in subsequent steps
if isempty(pixROI)
    currentFrame = rgb2gray(firstFrame.frames.cdata); %convert firstFrame to grayscale
    figure('name',['time = ' num2str(firstFrame.times) 's']);
    disp('please draw shape around bottom of cage at animal height');
    [thesePix] = roipoly(currentFrame); %draw polygon around mouse area    
    hold on
    imshow(thesePix,[]); %show selection
    pixROI = logical(thesePix(:,:)); %now use pix to exclude non-ROI pixels in each frame
end

dPix = [];
dPixSm = [];
timeGrid = [];

timeIndex = 0; %start at time = 0

tic; 
while timeIndex < firstFrame.totalDuration

    if (timeIndex+secToLoad) < (firstFrame.totalDuration) %if there's all of secToLoad remaining
        testVid = mmread(fileName,[],[timeIndex,timeIndex+secToLoad]);
    else %if there's less than secToLoad remaining
        testVid = mmread(fileName,[],[timeIndex,firstFrame.totalDuration]);
    end
    
    timeIndex = timeIndex+secToLoad;
    
    if ~exist('actualFrameRate','var')
        actualFrameRate = length(testVid.times)/secToLoad;
    end
    
    nFrames = length(testVid.frames); 
    
    % store frame into the variable tempFrame as grayscale, exclude the
    % pixels outside ROI, add into tempLum for all frames
    for iFrame = 1:nFrames
        tempFrame(:,:) = rgb2gray(testVid.frames(iFrame).cdata); %read in frame as grayscale
        tempFrame(~pixROI) = nan; % exclude as nan 
        tempLum(:,:,iFrame) = tempFrame; % fill temp variable for diff
    end
    tempTimes = testVid.times;
    
    % compute 1st derivative over 3rd dimension (frames) to get frame by frame difference signal
    tempDPix = abs(diff(tempLum,1,3)); % nonsmoothed differences
    tempDPixSm = smooth3(tempDPix,'box',[11 11 round(actualFrameRate/2)*2+1]); % smoothing step (WIP why these dimensions?)
    
    % calculate mean difference per frame over all pixels this segment
    tempDPixSm = squeeze(nanmean(tempDPixSm,[1,2]));
    
    if ~isempty('dPixSm')
        dPixSm = cat(1,dPixSm,tempDPixSm);  % build the array by the time length we're stepping through.
        timeGrid = cat(2,timeGrid,tempTimes); %WIP is this correct?
        display([num2str(size(dPixSm,1)+1) ' frames completed.']); %dPixSm is nFrames-1 long
        toc;
    else
        dPixSm = dPixSm; % initialize the array
        timeGrid = tempTimes;
        display(['Starting with ' num2str(size(dPixSm,1)+1) ' frames']); %dPixSm is nFrames-1 long
        toc;
    end
    
    %TO-DO: Calculate standard deviation of pixels...?? Account for
    %luminance differences
end
toc

% Remove first and last second of data to exclude artifacts
disp('setting first and last second of data to nan');
dPix(1:actualFrameRate) = nan;
dPixSm(1:actualFrameRate) = nan;
dPix(nFrames-actualFrameRate:nFrames) = nan;
dPixSm(nFrames-actualFrameRate:nFrames) = nan; 

% rename movement array to something sensible
finalMovementArray = dPixSm;

if ~synapseData
    % load in LED frame time stamps
    load([fileName '-movementInfoAdjusted.mat'],'finalLEDTimes');
    a = finalLEDTimes;
    b = finalLEDTimes+actualFrameRate; %assumes 1sec light pulse
    c = union(a,b);
    finalMovementArray = nan;
end

%TO-DO: TIMESTAMPS
% in the Synapse version, we have two time arrays: one that was created by
% Synapse itself, and one encoded in the video.  We have both now.  Synapse
% frame time stamps start slightly after the beginning of recording, and
% will indicate so, so we need to align the two here. Everything (including
% ephys) is relative to start of recording, so that's all that matters when
% adjusting time.
disp('starting time adjustment');
tic
if synapseData
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
else
    %can we use existing timestamp array?
%     load([fileName ]
end
toc


%%
%plot results of above.
% figure();
% plot(dPix)
% hold on; plot(dPixSm);
% legend('abs(diff)','smooth3(abs(diff))');




%DUMPSTER:
% recreate video object one last time in case CurrentTime was screwed up from earlier
% vidObj = VideoReader(fileName);
% h = testVid.Height;
% w = testVid.Width;
% nFramesPerMin = FR*60;
% expectedOneMinuteSpan = FR*60;
%dMov - where frame x frame differences will be stored
%         tempLum = nan(h,w,expectedOneMinuteSpan);
    %check if structure is populated yet to avoid
%     if dMov.dLum(1,1,1) == -5000
%         dMov.dLum = tempDLum;
%         dMov.dLumSm = tempDLumSm;
%     else
%         dMov.dLum = cat(3,dMov.dLum,tempDLum); %store in structure & concatenate along frames dimension
%         dMov.dLumSm = cat(3,dMov.dLumSm,tempDLumSm);  %store in structure & concatenate along frames dimension
%     end
% dMov = struct('dLum',[],'dLumSm',[]);
% iFrame = [];
%         iFrame = iFrame+1; %count up frame counter
    %if iFrame exists, we want to continue filling in mov from where the
    %program left off. Otherwise, start from first frame
%     if isempty(iFrame)
%         iFrame = 1;
%     end
%recreate video object for real since NumberOfFrames is stupid
% vidObj = VideoReader(fileName);
% expectedOneMinuteSpan = FR*60;
% tempPreAlloc = nan(testVid.Height,testVid.Width,expectedOneMinuteSpan);
%mov - where each frame will be stored in an array... Do I even need this? TBD
% tic
% mov = struct('cdata', cell(1, nFrames),'dLum',cell(1, nFrames),'dLumSm',cell(1, nFrames));
% for k = 1:nFrames
%     mov(k).cdata = zeros(testVid.Height,testVid.Width,'uint8');
% end
% toc
%         mov(iFrame).cdata = tempFrame; %fill actual structure with movie
% r.dLum = []; %WIP
% r.dLumSm = []; %WIP
% mov(k).dLum = zeros(testVid.Height,testVid.Width,'uint8');
%     mov(k).dLumSm = zeros(testVid.Height,testVid.Width,'uint8');
%     framesThisSegment(1) = iFrame; %WIP: use this variable to track which frames are currently being loaded in...

%     framesThisSegment(2) = iFrame-1; %WIP: use this variable to track which frames are currently being loaded in...

% savePath = [saveDirRoot fileName(delims(end-2)+1:delims(end))];
% saveFile = [savePath fileName(delims(end)+1:end-4) '-framegrid.mat'];
  
    %WIP: subtract frames in this section
%     for i=framesThisSegment(1):(framesThisSegment(2)) %why doesn't -1 work?
%         try 
%             s(i+1).diff = s(i+1).cdata - s(i).cdata;
%         catch
%             warning(['frame ' num2str(i) 'subtraction is problematic?'])
%         end
%     end
    
    % timeGrid = testVid.times;
% actualFrameRate = length(testVid.times)/secToLoad;
% TODO !!!verify sync
% differences = zeros(testVid.Height,testVid.Width,nFrames-1);
%         mov(:,:,iFrame) = tempFrame;
% mov = zeros(testVid.Height,testVid.Width,nFrames); %preallocate mov, where we store the grayscale movie array
% movDiff = zeros(testVid.Height,testVid.Width,nFrames-1);
% [R,C] = size(thesePix);
%         mov(:,:,iFrame) = tempMov(pix);
%         for i = 1:R
%            for j =  1:C
%                if ~(thesePix(i,j))
% %                    mov(i,j,iFrame) = tempMov(i,j);
%                    s(iFrame).cdata(i,j) = tempMov(i,j);
%                else
%                    s(iFrame).cdata(i,j) = nan;
% %                    mov(i,j,iFrame) = nan;
%                end
%            end
%         end