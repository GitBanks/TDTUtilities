function [roiPix,fullROI] = roiVidAnalysisBinary(vidFileName,date,index,fullROI,useOldROI)
% GIVEN:
% * a video file (.avi) location, date, and index
% * optional:
%   -- fullROI (a 1x1 AssistedFreehand object used to create a logical mask)
%   -- useOldROI a true/false statement

% DO:
% 1) prompt user to draw ROI around cage (used later)
% 2) read entire video & convert to grayscale
% 3) adjust time arrays (can't trust 'em as is)
% 4) calculate the 1th and 95th percentile luminance values across video, subtract the 1th from the 95th to binarize... ???
% 5) calculate 1st derivative across all pixels to generate a difference matrix 
% 6) use 2D smoothing filter, exclude nonROI pixels, and average difference values across pixels
% 7) smooth across ~2sec, subtract minimum difference values
% 8) save the difference array + relevant variables, output pixROI for subsequent use in M drive

% CALLS:
% mmread (Z:\DataBanks\mmread)
% roipoly & imfilter (Image Processing Toolbox)
% ... and the rest _should_ be found here: https://github.com/GitBanks/TDTUtilities

% OUTPUT:
% * roiPix, a 2D logical matrix with same dimensions as video, derived from fullROI
% * fullROI (see above)

% EXAMPLE:
% vidFileName = 'W:\Data\PassiveEphys\2019\19404-000\2019_19404-000_Cam1.avi';
% date = '19404';
% index = '000';

% Banks Lab, 2019 (Ziyad Sultan, Bryan Krause, and Sean Grady)
%%=======================================================================%%
addpath('Z:\DataBanks\mmread');

if nargin<5
    useOldROI = false; % won't use previously drawn ROI
end

% make sure the video file exists
if exist(vidFileName,'file') ~= 2
    vidFileName = vidFileName(1:end-4);
    if exist(vidFileName,'file') ~= 2
        error(['Cannot find the file ' vidFileName]);
    end
end
disp(vidFileName);

try
    % try to load a single frame of the video
    frameToShow = 1;
    disp('reading in first frame');
    firstFrame = mmread(vidFileName,frameToShow);
    currentFrame = rgb2gray(firstFrame.frames.cdata); %convert firstFrame to grayscale
    h = firstFrame.height;
    w = firstFrame.width;
    currentTime = firstFrame.times;
catch
    error(['Found, but could not load ' vidFileName]);
end

if ~exist('fullROI','var') || isempty(fullROI)
    fullROI = [];
    useOldROI = 0;
end

% 1. prompt user to draw ROI around cage (used later)
[roiPix,fullROI] = drawMouseROI(currentFrame,currentTime,fullROI,useOldROI);

tic
% 2a. read WHOLE video into memory -> may crash if the video is >1hr and/or larger than 240x320 pixels
disp('reading video using mmread');
wholeVid = mmread(vidFileName);

disp('preallocating arrays');
nFrames = length(wholeVid.frames);
frames = zeros(h,w,nFrames,'uint8');

% 2b. convert video to grayscale
disp('converting frames to grayscale');
for iFrame = 1:nFrames
    frames(:,:,iFrame) = rgb2gray(wholeVid.frames(iFrame).cdata); % store in frames variable for this iteration
end
times = wholeVid.times; % important! this is going to become the new time array

% determine if this is Synapse data or old data
[synapseData,frameTimeStamps] = isSynapseData(vidFileName);

% 3) perform relevant time adjustment based on whether data is Synapse/not
if ~synapseData
    [framesToKeep,times,~] = videoROIBrainwareLED(vidFileName,times);
else
    [framesToKeep,times] = synapseFrameTimeAdjust(times,frameTimeStamps);
end

% manual removal of frames mostly due to cage being open during these times
if strcmp(date,'19717')
    if strcmp(index,'002')
        framesToKeep(8111:8335) = 0;
    elseif strcmp(index,'003')
        framesToKeep(8111:8326) = 0;
    elseif strcmp(index,'004')
        framesToKeep([388:746,5825:6070]) = 0;
    elseif strcmp(index,'005')
        framesToKeep([374:741,5816:6061]) = 0;
    elseif strcmp(index,'006')
        framesToKeep(28904:29095) = 0;
    elseif strcmp(index,'007')
        framesToKeep(28904:29089) = 0;
    elseif strcmp(index,'008')
        framesToKeep(2060:2240) = 0;
    elseif strcmp(index,'009')
        framesToKeep(2060:2252) = 0;
    end
elseif strcmp(date,'19830') && (strcmp(index,'006') || strcmp(index,'007'))
    framesToKeep(1:129) = 0;
elseif strcmp(date,'19918') && (strcmp(index,'000') || strcmp(index,'001'))
    if strcmp(index,'000')
        framesToKeep(17923:18081) = 0;
    elseif strcmp(index,'001')
        framesToKeep(17923:18100) = 0;
    end
end

% 4. calculate & display 1th and 95th percentile luminance values (Bryan's magic)
figure()
ninetyfifth = prctile(frames(:,:,framesToKeep),95,3);
imshow(ninetyfifth);
title('95th percentile luminance across video');

figure()
ptoneth = prctile(frames(:,:,framesToKeep),0.01,3);
imshow(ptoneth);
title('1th percentile luminance across video');

%figure()
%imshow(ninetyfifth-ptoneth);

% Binarize
scale = double(ninetyfifth-ptoneth);
scale(scale<50) = 0;
%%
%figure()

tic
% 4. (continued) subtract 1th percentile luminance from each frame, binarize (mouse/no mouse)
parfor i = 1:size(frames,3)
    %scaleframe = 1-double(frames(:,:,i)-ptoneth)./scale;
    subframe = double(frames(:,:,i)-ptoneth);
    %scaleframe = 1-subframe./scale;
    scaleframe = true(size(subframe));
    scaleframe(subframe>scale*.3) = 0;
    frames(:,:,i) = scaleframe;
    %imshow(scaleframe);
    %pause(.01);
end

% calculate average frame rate (fps) based on number of frames and time elapsed in sec
avg_FR = size(frames,3)/(times(end) - times(1));

% if framerate is above the normal limits (6-10fps), downsample the video signal!
if avg_FR > 12
    
    warning('avg_FR too high');
    frames = frames(:,:,1:4:end-3);
    times = times(1:4:end-3);
    
    % recalculate avg_FR
    avg_FR = size(frames,3)/(times(end) - times(1));
    
    for ii = 1:floor(size(framesToKeep,2)/4)
        shortFramesToKeep(ii) = all(framesToKeep((ii*4-3):ii*4));
    end
    
    framesToKeep = shortFramesToKeep;
    
    disp('calculating diff(frames)');
    temp_dFrames = abs(diff(frames,1,3));
    temp_dFrames = temp_dFrames(:,:,framesToKeep(1:end-1));
    
    times = times(framesToKeep(1:end-1));
    
else
    % compute 1st derivative across frames dimension (3)
    disp('calculating diff(frames)');
    temp_dFrames = abs(diff(frames,1,3));
    temp_dFrames = temp_dFrames(:,:,framesToKeep(1:end-1));
    
    times = times(framesToKeep(1:end-1));
end

%% Debug
% figure()
% for i=1:(size(frames,3)-1)
%    imshow(squeeze(temp_dFrames(:,:,i))*255);
%    pause(.01);
% end
%%
% 5. use 2D filter on the difference matrix, exclude pixels outside ROI, and average across pixels
disp('2D smoothing')
smooth_dFrames_avg = nan(size(temp_dFrames,3),1); % should be nFrames x 1 array
parfor i = 1:size(temp_dFrames,3)
    sm_temp = imfilter(temp_dFrames(:,:,i), ones(7)/7^2); % 2D smoothing filter
    %     imshow(sm_temp*255);
    %     pause(.01);
    
    sm_temp(~roiPix) = nan; % exclude pixels outside ROI as nans
    smooth_dFrames_avg(i) = nanmean(sm_temp,'all');
end

% figure()
% for i=1:(size(frames,3)-1)
%    imshow(squeeze(temp_dFrames(:,:,i))*255);
%    pause(.01);
% end

% smooth the difference array across time and subtract minimum value to correct floor differences
finalMovementArray = smooth(smooth_dFrames_avg-min(smooth_dFrames_avg),2*floor(avg_FR)+1);

toc;

% cast times to a new array
frameTimeStampsAdj = times;

% make directory if does not exist
if ~exist(['M:\PassiveEphys\20' date(1:2) '\' date '-' index],'dir')
    mkdir(['M:\PassiveEphys\20' date(1:2) '\' date '-' index]);
end

% save to M drive under appropriate date-index
save(['M:\PassiveEphys\20' date(1:2) '\' date '-' index '\' date '-' index '-movementBinary.mat'],'finalMovementArray','frameTimeStampsAdj','roiPix','fullROI','avg_FR');

end

function [roiPix,fullROI] = drawMouseROI(currentFrame,currentTime,fullROI,useOldROI)
% it's in the title. Use with final product of videoROI analysis
figure('name',['time = ' num2str(currentTime) 'sec']);%,'Position',[520,100,461,700]);
disp('INPUT REQUIRED: draw a closed shape around cage');

if nargin<4
    useOldROI = false;
end

h = imshow(currentFrame);
title('Draw a closed shape around cage');
if ~exist('fullROI','var') || isempty(fullROI)
    [fullROI] = drawassisted(h);
else
    disp('using existing ROI')
    title('using existing ROI');
    
    [newfullROI] = drawassisted(h,'Position',fullROI.Position,'Waypoints',fullROI.Waypoints);
    if ~useOldROI
        customWait(newfullROI);
    end
    
    if ~exist('newfullROI','var')
        [fullROI] = drawassisted(h);
        
    else
        fullROI = newfullROI;
    end
end

roiPix = createMask(fullROI);
disp('background ROI selected!');
bkgd = currentFrame;
bkgd(~roiPix) = nan;

figure
imshow(bkgd);
title('areas in black to be excluded from analysis');

end


function pos = customWait(hROI)

% Listen for mouse clicks on the ROI
l = addlistener(hROI,'ROIClicked',@clickCallback);

% Block program execution
uiwait;

% Remove listener
delete(l);

% Return the current position
pos = hROI.Position;

end


function clickCallback(~,evt)

if strcmp(evt.SelectionType,'double')
    uiresume;
end

end