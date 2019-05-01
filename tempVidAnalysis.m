function tempVidAnalysis(vidFileName)
% GIVEN: a file location and (optional) existing 240x320 logical. 
% DO: load video file; prompt user to draw ROI; read video 60s at a
% time & exclude pixels outside ROI; calculate 1st derivative across all pixels, average, and
% save the difference array and output pixROI for subsequent use

% updated 4/28/2019

% calls: TDTbin2mat & loadTrialList (in TDTUtilities); mmread
% (Z:\DataBanks\mmread); roipoly & imfilter (Image Processing Toolbox)

% example parameters:
% vidFileName = 'W:\Data\PassiveEphys\2018\18410-000\18410-000'; %EEG51  %108905
% vidFileName = 'W:\Data\PassiveEphys\2019\19404-000\2019_19404-000_Cam1.avi'; %EEG74 %36152
% vidFileName = 'W:\Data\PassiveEphys\2017\17512-000\17512-000'; %EEG29 
% vidFileName = 'W:\Data\PassiveEphys\2019\19310-001\2019_19310-001_Cam1.avi'; %EEGRoboMouse %603
vidFileName = 'W:\Data\PassiveEphys\2019\19425-000\2019_19425-000_Cam1.avi'; %EEG76
roiPix = [];

% make sure file or non .avi video version exist (copied from Sean's code)
if exist(vidFileName) ~= 2 
    vidFileName = vidFileName(1:end-4);
    if exist(vidFileName) ~= 2
        error(['Cannot find the file ' vidFileName]);
    end
end

frameToShow = 1; 
frameSet = false;
% try to load a single frame of the video
try 
    while ~frameSet
        firstFrame = mmread(vidFileName,frameToShow);
        currentFrame = rgb2gray(firstFrame.frames.cdata); %convert firstFrame to grayscale
        qq = figure('name',['frame = ' num2str(frameToShow)]);
        imshow(currentFrame);
        prompt = 'True/False: is this frame appropriate? e.g. mouse wholly on filter paper';
        temp = inputdlg(prompt);
        frameSet = str2double(temp{:});
%         frameSet = str2num(answer{:});
        frameToShow = frameToShow+100;
        clf
    end
catch
    error(['Found, but could not load ' vidFileName]);
end

close(qq);
h = firstFrame.height;
w = firstFrame.width;

% draw ROI & use shape to create logical to exclude pixels as nans in subsequent steps
if isempty(roiPix)
    [roiPix,~,musArea,bkgdArea,musLum,bkgdLum] = drawMouseROI(firstFrame,currentFrame);
else
    figure('name',['time = ' num2str(firstFrame.times) 'sec'],'Position',[261 119 319 854]);
    currentFrame(~roiPix) = nan;
    imshow(currentFrame);
end

tic

% read whole video into wholeVid structure
tic
disp('reading video using mmread');
wholeVid = mmread(vidFileName);
toc

%preallocate arrays
tic
disp('preallocating arrays');
nFrames = length(wholeVid.frames);
frames = zeros(h,w,nFrames);
times = zeros(1,nFrames);
toc

%convert each frame to grayscale and set pixels outside ROI to zero. 
tic
disp('converting frames to grayscale & excluding pixels outside ROI');
for iFrame = 1:nFrames
    tempFrame = rgb2gray(wholeVid.frames(iFrame).cdata); % read in frame as grayscale
    tempFrame(~roiPix) = 0; % set non-ROI pixels to zero!
    frames(:,:,iFrame) = tempFrame; % store in frames variable for this iteration
    times(:,iFrame) = wholeVid.times(iFrame);
end
toc 

% compute 1st derivative across frames dimension (3)
tic
disp('calculating diff(frames)');
temp_dFrames = abs(diff(frames,1,3));
toc

% 2D smoothing (this takes >100 seconds
tic
disp('2D smoothing')
sm_temp = nan(h,w,nFrames-1);
for i = 1:size(temp_dFrames,3)
    sm_temp = imfilter(temp_dFrames(:,:,i), ones(11)/11^2); % 2D smoothing filter - are we satisfied with this?
    sm_temp(~roiPix) = nan; % exclude nans
    sm_temp_dFrames(:,:,i) = sm_temp;
end
toc

% average difference signal
tic
sm_temp_dFrames_avg = squeeze(nanmean(sm_temp_dFrames,[1,2])); 
toc

% smooth the difference array across time and subtract minimum value to
% correct floor differences
tic
% finalMovementArray = smooth(sm_temp_dFrames_avg);
finalMovementArray = smooth(sm_temp_dFrames_avg-min(sm_temp_dFrames_avg));
toc

% perform adjustment based on size and luminance of mouse/background 
finalMovementArray_adj = finalMovementArray/((musArea/bkgdArea)*(bkgdLum-musLum)); 

% calculate average frame rate & divid movement signal by that
avg_FR = size(frames,3)/max(times);
finalMovementArray_adj = finalMovementArray_adj/avg_FR; %divide by average frame rate

% 5. sean's LED trial alignment fix and shit
figure
if ~synapseData
    [finalMovementArray_fixed,timeGrid_fixed,~] = videoROIBrainwareLED(vidFileName,finalMovementArray_adj,times);
    plot(timeGrid_fixed(1:end-1),finalMovementArray_fixed);
else
    plot(times(1:end-1),finalMovementArray_adj);
end
title(vidFileName);
% finalMovementArray = smooth(sm_temp_dFrames_avg);
% finalMovementArray_adj = finalMovementArray/((musArea/bkgdArea)*(bkgdLum-musLum));
% times = times(1:end-1)/3600;
% figure
% plot(times(1:end-1),finalMovementArray_adj);
% ylabel('smooth(dFrames)');
% title(vidFileName)
% 
% subplot(2,1,2);
% plot(times,finalMovtArrayMinusFloor_adj);
% % plot(times,experimentalArrayAdj);
% % ylabel('smooth((dFrames-min(dFrames))/dT)');

toc;


