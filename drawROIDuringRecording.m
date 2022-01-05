% function to draw the video ROI during recording 
% (run from synapseFrontEnd_dual or synapseFrontEnd)

% - will need to locate/load video file, display frame from video, allow user to draw ROI,
%   then save the ROI output in the file where the video analysis output is stored name... 
% - after the first index, will need to load existing ROI, then require user to adapt drawing as neeeded. 

% roiVidAnalysisBinary(vidFileName,date,index,fullROI,useOldROI)
% addpath('Z:\DataBanks\mmread'); % this hopefully will have been added

vidFileName = [getPathGlobal('W') 'PassiveEphys\20' date(1:2) '\' date '-' index '\20' date(1:2) '_' date '-' index '_Cam*.avi'];
 
useOldROI = false; % won't use previously drawn ROI

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
    currentTime = firstFrame.times;
catch
    error(['Found, but could not load ' vidFileName]);
end

if ~exist('fullROI','var') || isempty(fullROI)
    fullROI = [];
    useOldROI = 0;
end

[roiPix,fullROI] = drawMouseROI(currentFrame,currentTime,fullROI,useOldROI);