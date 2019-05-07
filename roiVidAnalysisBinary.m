function [roiPix,fullROI] = roiVidAnalysisBinary(vidFileName,date,index,loadRoiPix,fullROI,skipMouse,useOldROI)
% GIVEN: a file location and (optional) existing 240x320 logical. 
% DO: load video file; prompt user to draw ROI; read video 60s at a
% time & exclude pixels outside ROI; calculate 1st derivative across all pixels, average, and
% save the difference array and output pixROI for subsequent use

% updated 4/28/2019

% calls: loadTrialList (in TDTUtilities); mmread
% (Z:\DataBanks\mmread); roipoly & imfilter (Image Processing Toolbox)

addpath('Z:\DataBanks\mmread');

% example parameters:
% vidFileName = 'W:\Data\PassiveEphys\2018\18410-000\18410-000'; %EEG51  %108905
% vidFileName = 'W:\Data\PassiveEphys\2019\19404-000\2019_19404-000_Cam1.avi'; %EEG74 %36152
% vidFileName = 'W:\Data\PassiveEphys\2017\17512-000\17512-000'; %EEG29 
% vidFileName = 'W:\Data\PassiveEphys\2019\19310-001\2019_19310-001_Cam1.avi'; %EEGRoboMouse %603
% vidFileName = 'W:\Data\PassiveEphys\2019\19425-000\2019_19425-000_Cam1.avi'; %EEG76
% roiPix = [];

if nargin<7
    useOldROI = false;
end


% make sure file or non .avi video version exist (copied from Sean's code)
if exist(vidFileName) ~= 2 
    vidFileName = vidFileName(1:end-4);
    if exist(vidFileName) ~= 2
        error(['Cannot find the file ' vidFileName]);
    end
end

frameToShow = 1; 
frameSet = false; %this will be false until 
% try to load a single frame of the video
try 
    qq = figure('name',['frame = ' num2str(frameToShow)]);
    while ~frameSet
        firstFrame = mmread(vidFileName,frameToShow);
        currentFrame = rgb2gray(firstFrame.frames.cdata); %convert firstFrame to grayscale
        
        if useOldROI
            break;
        end
        
        imshow(currentFrame);
        prompt = 'True/False: is this frame appropriate? e.g. mouse wholly on filter paper, not standing';
        temp = inputdlg(prompt); %my initial attempt at having the user evaluate if the mouse is in frame or not.
        frameSet = str2double(temp{:});
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
if nargin<4
    loadRoiPix = false;
end
if nargin<6
    skipMouse = false;
end

if loadRoiPix
    load(['M:\PassiveEphys\2019\' date '-' index '\' date '-' index '-movement.mat'],'roiPix');
end


if ~exist('roiPix','var') || isempty(roiPix)
    if exist('fullROI','var') && ~isempty(fullROI)
        [roiPix,~,musArea,bkgdArea,musLum,bkgdLum,fullROI,mouseROI] = drawMouseROI(firstFrame,currentFrame,fullROI,skipMouse,useOldROI);
    else
        [roiPix,~,musArea,bkgdArea,musLum,bkgdLum,fullROI,mouseROI] = drawMouseROI(firstFrame,currentFrame,[],true);
    end
else
    figure('name',['time = ' num2str(firstFrame.times) 'sec'],'Position',[261 119 319 854]);
    currentFrame(~roiPix) = nan;
    imshow(currentFrame);
end





tic
% read whole video into wholeVid structure
disp('reading video using mmread');
wholeVid = mmread(vidFileName);


%preallocate arrays

disp('preallocating arrays');
nFrames = length(wholeVid.frames);
frames = zeros(h,w,nFrames,'uint8');


%convert each frame to grayscale and set pixels outside ROI to zero. 

disp('converting frames to grayscale & excluding pixels outside ROI');
for iFrame = 1:nFrames
    frames(:,:,iFrame) = rgb2gray(wholeVid.frames(iFrame).cdata); % store in frames variable for this iteration
   
end
times = wholeVid.times;




% Is this synapse data or old data?
[synapseData,frameTimeStamps] = isSynapseData(vidFileName);

if ~synapseData
    [framesToKeep,times,~] = videoROIBrainwareLED(vidFileName,times);
    
    % KILL FRAMES
    %times = times(framesToKeep);
    %frames = frames(:,:,framesToKeep);
    
else
    [framesToKeep,times] = synapseFrameTimeAdjust(times,frameTimeStamps);
end


figure()
ninetyfifth = prctile(frames(:,:,framesToKeep),95,3);
imshow(ninetyfifth);

figure()
ptoneth = prctile(frames(:,:,framesToKeep),0.01,3);
imshow(ptoneth);


%figure()
%imshow(ninetyfifth-ptoneth);

% Binarize
scale = double(ninetyfifth-ptoneth);
scale(scale<50) = 0;



%% DEBUG
% figure()
% tic
% for i = 1:size(frames,3)
% 
%    subframe = double(frames(:,:,i)-ptoneth);
% 
%    scaleframe = true(size(subframe));
%    scaleframe(subframe>scale*.3) = 0;
% 
%    imshow(scaleframe);
%    pause(.01);
% end

% figure()
% tic
% for i = 1:size(frames,3)
%    imagesc(squeeze(frames(:,:,i)));
%    title(i);
%    pause(.01);
% end
% toc
%%


%figure()
tic
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

% compute 1st derivative across frames dimension (3)


disp('calculating diff(frames)');
temp_dFrames = abs(diff(frames,1,3));


temp_dFrames = temp_dFrames(:,:,framesToKeep(1:end-1));

times = times(framesToKeep(1:end-1));

%% Debug
% figure()
% for i=1:(size(frames,3)-1)
%    imshow(squeeze(temp_dFrames(:,:,i))*255);
%    pause(.01);
% end

%%
% 2D smoothing (this takes >100 seconds

disp('2D smoothing')
%sm_temp_dFrames = nan(h,w,nFrames-1);
sm_temp_dFrames_avg = nan(size(temp_dFrames,3),1);
parfor i = 1:size(temp_dFrames,3)
    sm_temp = imfilter(temp_dFrames(:,:,i), ones(7)/7^2); % 2D smoothing filter - are we satisfied with this?
    
    %imshow(sm_temp*255);
    %pause(.01);
    
    sm_temp(~roiPix) = nan; % exclude nans
    %sm_temp_dFrames_avg(i) = nanmean(sm_temp(roiPix));
    sm_temp_dFrames_avg(i) = nanmean(sm_temp,'all');
    

end


% figure()
% for i=1:(size(frames,3)-1)
%    imshow(squeeze(temp_dFrames(:,:,i))*255);
%    pause(.01);
% end


% smooth the difference array across time and subtract minimum value to
% correct floor differences
avg_FR = size(frames,3)/max(times);
% finalMovementArray = smooth(sm_temp_dFrames_avg);
finalMovementArray = smooth(sm_temp_dFrames_avg-min(sm_temp_dFrames_avg),2*floor(avg_FR)+1);

% perform adjustment based on size and luminance of mouse/background 
%finalMovementArray = finalMovementArray/((musArea/bkgdArea)*(bkgdLum-musLum)); 

% calculate average frame rate & divid movement signal by that
%avg_FR = size(frames,3)/max(times);
%finalMovementArray = finalMovementArray*avg_FR; %multiply by average frame rate

toc;

frameTimeStampsAdj = times;


if ~exist(['M:\PassiveEphys\2019\' date '-' index],'dir')
   mkdir(['M:\PassiveEphys\2019\' date '-' index]);
end

save(['M:\PassiveEphys\2019\' date '-' index '\' date '-' index '-movementBinary.mat'],'finalMovementArray','frameTimeStampsAdj','roiPix','fullROI','mouseROI','avg_FR');

end

function [roiPix,musPix,musArea,bkgdArea,musLum,bkgdLum,fullROI,mouseROI] = drawMouseROI(firstFrame,currentFrame,fullROI,skipMouse,useOldROI)
%it's in the title. Use with final product of videoROI analysis
figure('name',['time = ' num2str(firstFrame.times) 'sec'],'Position',[520,100,461,700]);
subtightplot(3,1,1);
disp('step 1) draw a closed shape around bottom of cage');
%[roiPix] = roipoly(currentFrame); % background + mouse ROI selection

if nargin<5
    useOldROI = false;
end


h = imshow(currentFrame);
if ~exist('fullROI','var') || isempty(fullROI)
    [fullROI] = drawassisted(h);
else
    disp('using existing ROI')
    
    %fullROI.Image = h;
    %fullROI.Parent = gca;
    %fullROI.Selected = true;
    
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


if nargin<4
    skipMouse = false;
end

roiPix = createMask(fullROI);
disp('background ROI selected!');
bkgd = currentFrame;
bkgd(~roiPix) = nan;
subtightplot(3,1,2);
disp('step 2) draw a closed shape around ANIMAL');
h2 = imshow(bkgd);
mus = bkgd; % create mouse image variable before drawing ROI
%[musPix] = roipoly(bkgd); % mouse ROI selection
if skipMouse
    musPix=[];
    musArea=1;
    bkgdArea=1;
    musLum=0;
    bkgdLum=1;
    mouseROI=[];
else
    [mouseROI] = drawassisted(h2);
    
    musPix = createMask(mouseROI);
    disp('mouse ROI selected!');
    subtightplot(3,1,3);
    mus(~musPix) = nan; % exclude all non-mouse pixels
    bkgd(musPix) = nan; % exclude mouse pixels from background
    musArea = sum(musPix,'all'); % area of mouse (number of pixels)
    bkgdArea = sum(roiPix-musPix,'all'); % area of background (number of pixels)
    musLum = nanmean(mus,'all'); % mean luminance of mouse
    bkgdLum = nanmean(bkgd,'all'); % mean luminance of background (no mouse)
end
imshow(bkgd);

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