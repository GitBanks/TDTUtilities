function [finalMovementArray_adj,timeGrid,roiPix] = videoROIMakerAll_test(vidFileName,roiPix)

% GIVEN: a file location and (optional) existing 240x320 logical. 
% DO: load video file; prompt user to draw ROI; read video 60s at a
% time & exclude pixels outside ROI; calculate 1st derivative across all pixels, average, and
% save the difference array and output pixROI for subsequent use

% updated 4/18/2019

% calls: TDTbin2mat & loadTrialList (in TDTUtilities); mmread (Z:\DataBanks\mmread); roipoly & imfilter (Image Processing Toolbox)

% example parameters:
% vidFileName = 'W:\Data\PassiveEphys\2018\18410-000\18410-000'; %EEG51  
% vidFileName = 'W:\Data\PassiveEphys\2019\19404-000\2019_19404-000_Cam1.avi'; %EEG74 
vidFileName = 'W:\Data\PassiveEphys\2017\17512-000\17512-000'; %EEG29 
% vidFileName = 'W:\Data\PassiveEphys\2016\16o27-001\16o27-001'; %EEG18
% vidFileName = 'W:\Data\PassiveEphys\2019\19310-001\2019_19310-001_Cam1.avi'; %EEGRoboMouse
roiPix = [];

% 1a. make sure file or non .avi video version exist (copied from Sean's code)
if exist(vidFileName) ~= 2 
    vidFileName = vidFileName(1:end-4);
    if exist(vidFileName) ~= 2
        error(['Cannot find the file ' vidFileName]);
    end
end

frameToShow = 1;
% 1b. try to load a single frame of the video
try 
    firstFrame = mmread(vidFileName,frameToShow);
    currentFrame = rgb2gray(firstFrame.frames.cdata); %convert firstFrame to grayscale
    h = firstFrame.height;
    w = firstFrame.width;
catch
    error(['Found, but could not load ' vidFileName]);
end

% 1c. draw ROI & use shape to create logical to exclude pixels as nans in subsequent steps
if isempty(roiPix)
    [roiPix,~,musArea,bkgdArea,musLum,bkgdLum] = drawMouseROI(firstFrame,currentFrame);
else
    figure('name',['time = ' num2str(firstFrame.times) 'sec'],'Position',[261 119 319 854]);
    currentFrame(~roiPix) = nan;
    imshow(currentFrame);
end
dFrames = []; % the frame x frame differences will be stored here
timeGrid = []; % the timestamps of each frame will be stored here

startFrame = 1; %Start at 1
frameStep = 400; %Config to set the number of frames to analyze at a time; something comfortably held in memory.
complete = false;
tic;
while ~complete
    
    getFrames = startFrame:(startFrame+frameStep);
    thisSeg = mmread(vidFileName, getFrames);
    nFrames = size(thisSeg.frames,2); % number of frames in this segment (could be less than frameStep)

    % resetting each of these seems to be important to avoid 60sec artifacts...
    sm_temp_dFrames = zeros(h,w,nFrames-1);
    frames = zeros(h,w,nFrames);
    
    % 2b. convert one frame to grayscale, exclude the pixels outside ROI,
    % store the temporary frame in 'frames', loop through remaining frames
    for iFrame = 1:nFrames
        tempFrame = rgb2gray(thisSeg.frames(iFrame).cdata); % read in frame as grayscale
        tempFrame(~roiPix) = 0; % set non-ROI pixels to zero!
        frames(:,:,iFrame) = tempFrame; % store in frames variable for this iteration
    end
    tempTimes = thisSeg.times; % WIP: do we trust these times?
    
     % 2c. compute 1st derivative across frames (frame by frame differences)
    temp_dFrames = abs(diff(frames,1,3));
    
    % 2d. 2D smoothing 
    for i = 1:size(temp_dFrames,3)
        sm_temp = imfilter(temp_dFrames(:,:,i), ones(11)/11^2); % 2D smoothing filter - are we satisfied with this?
        sm_temp(~roiPix) = nan; % exclude nans
        sm_temp_dFrames(:,:,i) = sm_temp;
    end

    % 2e. calculate mean difference per frame over all pixels (dimensions 1&2) this segment
    sm_temp_dFrames_avg = squeeze(nanmean(sm_temp_dFrames,[1,2])); 
    
    % 2f. concatenate differences and time array into output variables
    if ~isempty(dFrames)
        dFrames = cat(1,dFrames,sm_temp_dFrames_avg);  % build the array by the time length we're stepping through.
        timeGrid = cat(2,timeGrid,tempTimes);  % WIP is this correct?
        disp([num2str(size(dFrames,1)+1) ' frames completed.']);
        toc;
    else
        dFrames = sm_temp_dFrames_avg; % initialize the array
        timeGrid = tempTimes;  % WIP is this correct?
        disp(['Starting with ' num2str(size(dFrames,1)+1) ' frames']);
        toc;
    end
    if nFrames < frameStep 
        frameStep = nFrames;
        startFrame = startFrame + frameStep;
        complete = true;
    end
    startFrame = startFrame + frameStep;
    
end
toc

% 3. smooth the difference array across time 
finalMovementArray = smooth(dFrames);

% 4. perform adjustment based on size and luminance of mouse/background
finalMovementArray_adj = finalMovementArray/((musArea/bkgdArea)*(bkgdLum-musLum)); 
timeGridNew = timeGrid; clear timeGrid
finalMovementArrayNew = finalMovementArray_adj;

%% TO-DO: EPHYS TIMESTAMPS & LED ADJUSTMENT
% 5. sean's LED trial alignment fix and shit
videoROIBrainwareLED(vidFileName,finalMovementArrayNew,timeGridNew)
%% PLOTTING
figure('Name',vidFileName);
plot(finalMovementArray_adj); 
title(vidFileName((delims(4)+1):(delims(5)-1))); % label with date & index
ylim([0 2.5]);
xlabel('frames');

outPath = 'C:\Users\Ziyad Sultan\Desktop\temp\';
outFigName = [outPath vidFileName((delims(4)+1):(delims(5)-1)) '_adj'];
savefig(gcf,outFigName);
disp([outFigName ' saved']);

outFileName = [outPath vidFileName((delims(4)+1):(delims(5)-1)) '_finalMovementArray_adj'];
save(outFileName,'finalMovementArray_adj');

%% TO-DO: SAVING
saveDirRoot = '\\MEMORYBANKS\Data\PassiveEphys\'; % analyzed data should be put in 'memorybanks'
savePath = [saveDirRoot vidFileName(delims(end-2)+1:delims(end))];
saveFile = [savePath vidFileName(delims(end)+1:end-4) '- roiMovementArray.mat'];
%% DUMPSTER:
