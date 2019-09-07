function [roiPix,fullROI] = roiVidAnalysisBinary(vidFileName,date,index,fullROI,useOldROI)
% GIVEN: a file location and (optional) existing 240x320 logical. 
% DO: load video file; prompt user to draw ROI; read entire video & exclude pixels outside ROI; calculate 1st derivative across all pixels, average, and
% save the difference array and output pixROI for subsequent use

% updated 6/20/2019

% calls: loadTrialList (in TDTUtilities); mmread
% (Z:\DataBanks\mmread); roipoly & imfilter (Image Processing Toolbox)

addpath('Z:\DataBanks\mmread');

% example parameters:
% vidFileName = 'W:\Data\PassiveEphys\2018\18410-000\18410-000'; %EEG51  %108905
% vidFileName = 'W:\Data\PassiveEphys\2019\19404-000\2019_19404-000_Cam1.avi'; %EEG74 %36152

if nargin<5
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
        opts.Interpreter = 'tex'; % Use the TeX interpreter to format the question
        opts.Default = 'Yes'; % default answer is yes... 
        quest = 'Is this frame appropriate? e.g. mouse wholly on filter paper';
        answer = questdlg(quest,'INPUT REQUIRED','Yes','No',opts);
        if strcmp(answer,'Yes'); frameSet = true; else frameSet = false; end
        frameToShow = frameToShow+100;
        clf
    end
catch
    error(['Found, but could not load ' vidFileName]);
end

close(qq);
h = firstFrame.height;
w = firstFrame.width;

if ~exist('roiPix','var')
    if exist('fullROI','var') && ~isempty(fullROI)
        [roiPix,fullROI] = drawMouseROI(firstFrame,currentFrame,fullROI,useOldROI);
    else
        [roiPix,fullROI] = drawMouseROI(firstFrame,currentFrame,[],useOldROI);
    end
else
    figure('name',['time = ' num2str(firstFrame.times) 'sec']);%,'Position',[261 119 319 854]);
    currentFrame(~roiPix) = nan;
    imshow(currentFrame);
end
vidFileName
tic
disp('reading video using mmread');
wholeVid = mmread(vidFileName);

disp('preallocating arrays');
nFrames = length(wholeVid.frames);
frames = zeros(h,w,nFrames,'uint8');

disp('converting frames to grayscale & excluding pixels outside ROI');
for iFrame = 1:nFrames
    frames(:,:,iFrame) = rgb2gray(wholeVid.frames(iFrame).cdata); % store in frames variable for this iteration
end
times = wholeVid.times; % important! this is going to become the new time array

% determine if this is Synapse data or old data
[synapseData,frameTimeStamps] = isSynapseData(vidFileName);

if ~synapseData
    [framesToKeep,times,~] = videoROIBrainwareLED(vidFileName,times);    
else
    [framesToKeep,times] = synapseFrameTimeAdjust(times,frameTimeStamps);
end

% manual removal of frames, mostly due to cage being open during these
% periods...

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
end

% display Bryan's magic
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


%%%%%%%%%% frame length downsampling! added 6/12/2019 %%%%%%%%
avg_FR = size(frames,3)/(times(end) - times(1));

if avg_FR > 12 % if framerate is above the normal limits, downsample the video signal!
    
    warning('avg_FR too high');
    frames = frames(:,:,1:4:end-3);
    times = times(1:4:end-3);
    
    %recalculate avg_FR 
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
% 2D smoothing 

disp('2D smoothing')
sm_temp_dFrames_avg = nan(size(temp_dFrames,3),1);
parfor i = 1:size(temp_dFrames,3)
    sm_temp = imfilter(temp_dFrames(:,:,i), ones(7)/7^2); % 2D smoothing filter - are we satisfied with this?
    %imshow(sm_temp*255);
    %pause(.01);
    
    sm_temp(~roiPix) = nan; % exclude nans
    sm_temp_dFrames_avg(i) = nanmean(sm_temp,'all');
end

% figure()
% for i=1:(size(frames,3)-1)
%    imshow(squeeze(temp_dFrames(:,:,i))*255);
%    pause(.01);
% end

% smooth the difference array across time and subtract minimum value to
% correct floor differences
finalMovementArray = smooth(sm_temp_dFrames_avg-min(sm_temp_dFrames_avg),2*floor(avg_FR)+1);

toc;

frameTimeStampsAdj = times;


if ~exist(['M:\PassiveEphys\20' date(1:2) '\' date '-' index],'dir')
   mkdir(['M:\PassiveEphys\20' date(1:2) '\' date '-' index]);
end

save(['M:\PassiveEphys\20' date(1:2) '\' date '-' index '\' date '-' index '-movementBinary.mat'],'finalMovementArray','frameTimeStampsAdj','roiPix','fullROI','avg_FR');

end

function [roiPix,fullROI] = drawMouseROI(firstFrame,currentFrame,fullROI,useOldROI)
%it's in the title. Use with final product of videoROI analysis
figure('name',['time = ' num2str(firstFrame.times) 'sec']);%,'Position',[520,100,461,700]);
disp('INPUT REQUIRED: draw a closed shape around bottom of cage');

if nargin<4
    useOldROI = false;
end

h = imshow(currentFrame);
if ~exist('fullROI','var') || isempty(fullROI)
    [fullROI] = drawassisted(h);
else
    disp('using existing ROI')
    
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