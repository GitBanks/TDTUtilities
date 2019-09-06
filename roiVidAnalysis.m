function [roiPix,fullROI] = roiVidAnalysis(vidFileName,date,index,loadRoiPix,fullROI)
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



% Synapse version also stores timestamps from TDT file
try
    delims = strfind(vidFileName,filesep);
    rawPath = vidFileName(1:delims(end));
    data = TDTbin2mat(rawPath,'TYPE',{'epocs'}); % only need epocs - this saves a ton of time.
    frameTimeStamps = data.epocs.Cam1.onset; % this makes assumptions about the structure.  will need to change if we change 'Cam1' e.g.
    synapseData = true;
catch
    warning('non-synapse data detected.');
    synapseData = false;
end

% make sure file or non .avi video version exist (copied from Sean's code)
if exist(vidFileName) ~= 2 
    vidFileName = vidFileName(1:end-4);
    if exist(vidFileName) ~= 2
        error(['Cannot find the file ' vidFileName]);
    end
end

frameToShow = 1; 
frameSet = false; %this will be false until user confirms that frame is OK
qq = figure('name',['frame = ' num2str(frameToShow)]);
try 
    while ~frameSet
        firstFrame = mmread(vidFileName,frameToShow);
        currentFrame = rgb2gray(firstFrame.frames.cdata); %convert firstFrame to grayscale

        imshow(currentFrame);
        prompt = 'True/False: is this frame appropriate? e.g. mouse wholly on filter paper, not standing';
        temp = inputdlg(prompt); %my initial attempt at having the user evaluate if the mouse is in frame or not.
        frameSet = str2double(temp{:});
        frameToShow = frameToShow+1000;
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
if loadRoiPix
    load(['\\MEMORYBANKS\Data\PassiveEphys\2019\' date '-' index '\' date '-' index '-movement.mat'],'roiPix');
end


if ~exist('roiPix','var') || isempty(roiPix)
    if exist('fullROI','var') && ~isempty(fullROI)
        [roiPix,~,musArea,bkgdArea,musLum,bkgdLum,fullROI,mouseROI] = drawMouseROI(firstFrame,currentFrame,fullROI);
    else
        [roiPix,~,musArea,bkgdArea,musLum,bkgdLum,fullROI,mouseROI] = drawMouseROI(firstFrame,currentFrame);
    end
    disp(num2str([musArea,bkgdArea,musLum,bkgdLum],'%.1f    ')); 
    disp((musArea/bkgdArea)*(bkgdLum-musLum));

else
    figure('name',['time = ' num2str(firstFrame.times) 'sec'],'Position',[261 119 319 854]);
    currentFrame(~roiPix) = nan;
    imshow(currentFrame);
end






% read whole video into wholeVid structure
tic
disp('reading video using mmread');
wholeVid = mmread(vidFileName);
toc

%preallocate arrays
tic
disp('preallocating arrays');
nFrames = length(wholeVid.frames);
frames = zeros(h,w,nFrames,'uint8');
times = zeros(1,nFrames);
toc

%convert each frame to grayscale and set pixels outside ROI to zero. 
tic
disp('converting frames to grayscale & excluding pixels outside ROI');
for iFrame = 1:nFrames
    frames(:,:,iFrame) = rgb2gray(wholeVid.frames(iFrame).cdata); % store in frames variable for this iteration
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
%sm_temp_dFrames = nan(h,w,nFrames-1);
sm_temp_dFrames_avg = nan(nFrames-1,1);
parfor i = 1:size(temp_dFrames,3)
    sm_temp = imfilter(temp_dFrames(:,:,i), ones(11)/11^2); % 2D smoothing filter - are we satisfied with this?
    sm_temp(~roiPix) = nan; % exclude nans
    %sm_temp_dFrames_avg(i) = nanmean(sm_temp(roiPix));
    sm_temp_dFrames_avg(i) = nanmean(sm_temp,'all');
end
toc

% smooth the difference array across time and subtract minimum value to
% correct floor differences
tic
% finalMovementArray = smooth(sm_temp_dFrames_avg);
finalMovementArray = smooth(sm_temp_dFrames_avg-min(sm_temp_dFrames_avg));
toc

% perform adjustment based on size and luminance of mouse/background 
finalMovementArray = finalMovementArray/((musArea/bkgdArea)*(bkgdLum-musLum)); 

% calculate average frame rate & divid movement signal by that
avg_FR = size(frames,3)/max(times);
finalMovementArray = finalMovementArray*avg_FR; %multiply by average frame rate

%eliminate first 3 frames
%finalMovementArray(1:3) = nan;

% timesBak = times
% 
% finalMovementArray(find(frameTimeStamps(1) > times)) = [];
% times(find(frameTimeStamps(1) > times)) = [];
% if length(frameTimeStamps) > length(times)
% 
% end
% if length(frameTimeStamps) < length(times)
% 
% end


% 5. sean's LED trial alignment fix and shit
figure
if ~synapseData
    [finalMovementArray_fixed,timeGrid_fixed,~] = videoROIBrainwareLED(vidFileName,finalMovementArray,times);
    plot(timeGrid_fixed(1:end-1),finalMovementArray_fixed);
else
    plot(times(1:end-1),finalMovementArray);
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
end
title(vidFileName);


% if the video ran longer than the ephys
times = times';
if length(finalMovementArray) > length(times)
    for i = 1:(length(finalMovementArray) - length(times))
        times = [times times(end)+mean(diff(times(end-10:end)))];
    end
end
times = times';
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

frameTimeStampsAdj = times;


finalMovementArrayNoScale = finalMovementArray * ((musArea/bkgdArea)*(bkgdLum-musLum));

save(['\\MEMORYBANKS\Data\PassiveEphys\2019\' date '-' index '\' date '-' index '-movement.mat'],'finalMovementArray','frameTimeStampsAdj','roiPix','fullROI','mouseROI','finalMovementArrayNoScale');

end

function [roiPix,musPix,musArea,bkgdArea,musLum,bkgdLum,fullROI,mouseROI] = drawMouseROI(firstFrame,currentFrame,fullROI)
%it's in the title. Use with final product of videoROI analysis
figure('name',['time = ' num2str(firstFrame.times) 'sec'],'Position',[520,100,461,700]);
subtightplot(3,1,1);
disp('step 1) draw a closed shape around bottom of cage');
%[roiPix] = roipoly(currentFrame); % background + mouse ROI selection
h = imshow(currentFrame);
if ~exist('fullROI','var')
    [fullROI] = drawassisted(h);
else
    disp('using existing ROI')
    
    %fullROI.Image = h;
    %fullROI.Parent = gca;
    %fullROI.Selected = true;
    
    [newfullROI] = drawassisted(h,'Position',fullROI.Position,'Waypoints',fullROI.Waypoints);
    customWait(newfullROI);
    
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
subtightplot(3,1,2);
disp('step 2) draw a closed shape around ANIMAL');
h2 = imshow(bkgd);
mus = bkgd; % create mouse image variable before drawing ROI
%[musPix] = roipoly(bkgd); % mouse ROI selection

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