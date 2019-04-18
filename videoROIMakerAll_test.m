function [finalMovementArray_adj,timeGrid,roiPix] = videoROIMakerAll_test(vidFileName,roiPix)

% GIVEN: a file location and (optional) existing 240x320 logical. 
% DO: load video file; prompt user to draw ROI; read video 60s at a
% time & exclude pixels outside ROI; calculate 1st derivative across all pixels, average, and
% save the difference array and output pixROI for subsequent use

% updated 4/18/2019

% calls: TDTbin2mat & loadTrialList (in TDTUtilities); mmread
% (Z:\DataBanks\mmread); roipoly & imfilter (Image Processing Toolbox)

% example parameters:
vidFileName = 'W:\Data\PassiveEphys\2018\18410-000\18410-000'; %EEG51  
% vidFileName = 'W:\Data\PassiveEphys\2019\19404-000\2019_19404-000_Cam1.avi'; %EEG74 
% vidFileName = 'W:\Data\PassiveEphys\2017\17512-000\17512-000'; %EEG29 
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
catch
    error(['Found, but could not load ' vidFileName]);
end

% 1c. draw ROI & use shape to create logical to exclude pixels as nans in subsequent steps
if isempty(roiPix)
    figure('name',['time = ' num2str(firstFrame.times) 'sec'],'Position',[520,398,461,700]);
    subtightplot(3,1,1);
    disp('step 1) draw a closed shape around bottom of cage');
    [roiPix] = roipoly(currentFrame); % background + mouse ROI selection
    disp('background ROI selected!');
    bkgd = currentFrame;
    bkgd(~roiPix) = nan;
    subtightplot(3,1,2);
    disp('step 2) draw a closed shape around ANIMAL');
    imshow(bkgd);
    mus = bkgd; % create mouse image variable before drawing ROI
    [musPix] = roipoly(bkgd); % mouse ROI selection
    disp('mouse ROI selected!');
    subtightplot(3,1,3);
    mus(~musPix) = nan; % exclude all non-mouse pixels
    bkgd(musPix) = nan; % exclude mouse pixels from background
    musArea = sum(musPix,'all'); % area of mouse (number of pixels)
    bkgdArea = sum(roiPix-musPix,'all'); % area of background (number of pixels)
    musLum = nanmean(mus,'all'); % mean luminance of mouse
    bkgdLum = nanmean(bkgd,'all'); % mean luminance of background (no mouse)
    imshow(bkgd);
else
    figure('name',['time = ' num2str(firstFrame.times) 'sec'],'Position',[261 119 319 854]);
    currentFrame(~roiPix) = nan;
    imshow(currentFrame)
    
end

dFrames = []; % the frame x frame differences will be stored here
timeGrid = []; % the timestamps of each frame will be stored here
timeIndex = 0; % if set to 0, I assume this will start at first frame
secToLoad = 60; %load a managable time span 

% 2. load secToLoad number of seconds of video at a time, exclude non-ROI
% pixels, smooth with 2D filter, concatenate & loop through entire video.


tic; % NOTE: Will take about (total # of frames)/100 seconds (e.g. 250 sec for a 25,000-frame video). 
while timeIndex < firstFrame.totalDuration
    
    % 2a. determine how much video to load, load video w/ mmread. 
    % (this was taken from Sean's code)
    if (timeIndex+secToLoad) < (firstFrame.totalDuration) % if there's all of secToLoad remaining
        testVid = mmread(vidFileName,[],[timeIndex,timeIndex+secToLoad]);
        timeIndex = timeIndex+secToLoad;
    else % if there's less than secToLoad remaining
        testVid = mmread(vidFileName,[],[timeIndex,firstFrame.totalDuration]);
        timeIndex = firstFrame.totalDuration;
    end %TO-DO: change the incrementation from using time to frame (more precise)
    toc

    nFrames = length(testVid.frames); % number of frames in this segment
    
    % resetting each of these seems to be important to avoid 60sec artifacts...
    sm_temp_dFrames = zeros(240,320,nFrames-1);
    frames = zeros(240,320,nFrames);
    
    % 2b. convert one frame to grayscale, exclude the pixels outside ROI,
    % store the temporary frame in 'frames', loop through remaining frames
    for iFrame = 1:nFrames
        tempFrame = rgb2gray(testVid.frames(iFrame).cdata); % read in frame as grayscale
        tempFrame(~roiPix) = 0; % set non-ROI pixels to zero!
        frames(:,:,iFrame) = tempFrame; % store in frames variable for this iteration
    end
    tempTimes = testVid.times; % WIP: do we trust these times?
    
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
        disp([num2str(size(dFrames,1)+1) ' frames completed.']); % FYI: dFrames is nFrames-1 long
        toc;
    else
        dFrames = sm_temp_dFrames_avg; % initialize the array
        timeGrid = tempTimes;  % WIP is this correct?
        disp(['Starting with ' num2str(size(dFrames,1)+1) ' frames']); % FYI: dFrames is nFrames-1 long
        toc;
    end
    
end
toc

% 3. smooth the difference array across time 
finalMovementArray = smooth(dFrames);

% 4. perform adjustment based on size and luminance of mouse/background
finalMovementArray_adj = finalMovementArray/((musArea/bkgdArea)*(bkgdLum-musLum)); 

%% TO-DO: EPHYS TIMESTAMPS & LED ADJUSTMENT
% in the Synapse version, we have two time arrays: one that was created by
% Synapse itself, and one encoded in the video.  We have both now.  Synapse
% frame time stamps start slightly after the beginning of recording, and
% will indicate so, so we need to align the two here. Everything (including
% ephys) is relative to start of recording, so that's all that matters when
% adjusting time.

if ~exist('actualFrameRate','var') %WIP is this an acceptable way to compute actual frame rate?
    elapsedTime = (timeGrid(end)-timeGrid(1));
    totalFrames = length(finalMovementArray)+1;
    actualFrameRate = totalFrames/elapsedTime; 
end

delims = strfind(vidFileName,filesep);
rawPath = vidFileName(1:delims(end));

% check if the video was recorded on synapse; if so, find tdt trial stamps;
% if not, load the finalLEDTimes (???)




% SEANS NOTES: 4/18/19, the following is not ideal.  Check for data storage
% characteristics with 'if'.  try/catch should be limited to specific
% procedures (and catch usually handles errors that arise from a specific
% procedure)
try
    data = TDTbin2mat(rawPath,'TYPE',{'epocs'}); % Synapse version stores timestamps in TDT file % only need epocs
    frameTimeStamps = data.epocs.Cam1.onset; % will need to change if we change 'Cam1' e.g.
    synapseData = true;
catch
    warning('non-synapse data detected.');
    synapseData = false;
    load([vidFileName '-movementInfo.mat'],'finalLEDTimes'); 
end



% find ephys trial times % TODO: What to do with these??
ephysFileName = [saveDirRoot vidFileName(delims(3):delims(5))];
tempEphysTrialTime = loadTrialList(ephysFileName);



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
    % use proper LED timestamps
    
    
    
    
    
    adjLEDTimes = [];
    for i = 1:length(finalLEDTimes)
        tempA = finalLEDTimes(i):round((finalLEDTimes(i)+1*actualFrameRate));
        adjLEDTimes = [adjLEDTimes tempA];
    end
    finalMovementArray_adj(adjLEDTimes) = nan;
    
    
    
    % we need to finalize this array: frameTimeStamps
    
    
end
toc
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

% timestamp adjustment
% if ~synapseData
%     
% end
% % finalMovementArray(isnan(finalMovementArray)) = [];


%     imshow(tempPix); %show selection
%     pixROI = logical(tempPix(:,:)); %now use pix to exclude non-ROI pixels in each frame

%===========SD===========================%
% counts = [];
%         if isempty(counts)
%             [tempCount,bins] = imhist(tempFrame);
%             counts = tempCount; %initialize the histogram counts
%         else
%             tempCount = imhist(tempFrame);
%             counts = sum([tempCount,counts],2);
%         end
% Calculate standard deviation of pixels... 
% y = counts(2:end); x = bins(2:end); % exclude zero from dist
% f = fit(x,y,'gauss1'); % single gaussian fit
% sigma = f.c1; % grab sigma from fit (c1)

% subplot(2,1,2); % histogram
% plot(f,x,y);
% ylim([0 15e6]);
% xlabel('grayscale value')
% ylabel('count');
% sigma = mygaussfit(x,y); % calculate standard deviation over the binned data
%=====================================%

 % 1st derivative over 3rd dimension (frames) to get frame by frame difference signal (nonsmoothed differences
%     temp_dFrames = abs(diff(frames,1,3));
%     % smoothing step
%     sm_temp_dFrames = smooth3(temp_dFrames,'box',[11 11 round(actualFrameRate/2)*2+1]);
%     
%     % calculate mean difference per frame over all pixels (dimensions 1&2) this segment
%     sm_temp_dFrames = squeeze(nanmean(sm_temp_dFrames,[1,2])); 
%     
%     if ~isempty(dFrames)
%         dFrames = cat(1,dFrames,sm_temp_dFrames);  % build the array by the time length we're stepping through.
%         timeGrid = cat(2,timeGrid,tempTimes); %WIP is this correct?
%         disp([num2str(size(dFrames,1)+1) ' frames completed.']); %dPixSm is nFrames-1 long
%         toc;
%     else
%         dFrames = sm_temp_dFrames; % initialize the array
%         timeGrid = tempTimes;
%         disp(['Starting with ' num2str(size(dFrames,1)+1) ' frames']); %dPixSm is nFrames-1 long
%         toc;
%     end


%     for iFrame = 1:nFrames
%         tempFrame(:,:) = rgb2gray(testVid.frames(iFrame).cdata); %read in frame as grayscale
% %         threshLevel = graythresh(tempFrame);
%         tempFrame(~pixROI) = nan; % exclude as nan 
%         %Otsu's method:
%         frames(:,:,iFrame) = im2bw(tempFrame, threshLevel);  % fill frames variable this segment
% %         frames(:,:,iFrame) = tempFrame;
% %         subplot(2,1,1);
% %         imshow(uint8(frames(:,:,iFrame)));
% %         subplot(2,1,2);
% %         imshow(frames_otsu(:,:,iFrame));
%     end

% plot(finalMovementArray);
% hold on;
% pd = fitdist(y,'Normal');
% sigma = pd.sigma;

% f = fit(x,y,'gauss');
% plot(f,x,y);

%     temp_dFrames_avg = squeeze(nanmean(temp_dFrames,[1,2])); 

%     sm_temp_dFrames = smooth3(temp_dFrames,'box',[11 11 round(actualFrameRate/2)*2+1]);


% disp('setting first and last second of data to nan');
% dPix(1:actualFrameRate) = nan;
% dFrames(1:actualFrameRate) = nan;
% dPix(nFrames-actualFrameRate:nFrames) = nan;
% dPixSm(nFrames-actualFrameRate:nFrames) = nan; 

%/sdThisSegment';     sdThisSegment = squeeze(nanstd(frames,[],'all')); %WIP does this go here??
% example parameters:
% fileName = 'W:\Data\PassiveEphys\2019\19327-003\2019_19327-003_Cam1.avi';
% pixROI = [];

% % WIP: grab some general parameters about to video to aid preallocation steps
% FR = vidObj.FrameRate;
% %calculate actual frame rate??
% nFrames = vidObj.Duration*FR; % !!!this will not be true for old videos!!!!!!!!
% 
% % draw ROI & use shape to create logical to exclude pixels as nans in subsequent steps
% if isempty(pixROI)
%     vidObj.CurrentTime = 1; %this line seems problematic??
%     currentFrame = rgb2gray(readFrame(vidObj)); %read in frame at CurrentTime
%     figure('name',['time = ' num2str(vidObj.CurrentTime)]);
%     disp('please draw shape around bottom of cage at animal height');
%     [thesePix] = roipoly(currentFrame); %draw polygon around mouse area    
%     hold on
%     imshow(thesePix,[]); %show selection
%     pixROI = logical(thesePix(:,:)); %now use pix to exclude non-ROI pixels in each frame
% end
% 
% dPix = [];
% dPixSm = [];
% timeGrid = [];
% 
% % vidObj.CurrentTime= 0; %WIP: reset current time. Is this acceptable?
% timeIndex = 0; 
% 
% tic; 
% while timeIndex < vidObj.Duration
%     
%     vidObj.CurrentTime = timeIndex;
%     
%     % check if the current interval ends before the video does. If not, set
%     % the endTime equal to totalDuration
%     if timeIndex+secToLoad < vidObj.Duration
%         endTime = timeIndex+secToLoad;
%     else
%         endTime = vidObj.Duration;
%         tempLum = [];
%     end
%     
%     % read frames from this segment into memory as grayscale, exclude the pixels outside ROI
%     iTemp = 1; % temp frame counter just for this 60second segment
%     while vidObj.CurrentTime <= endTime && hasFrame(vidObj)
%         tempFrame = rgb2gray(readFrame(vidObj));
%         tempFrame(~pixROI) = nan; % exclude as nan 
%         tempLum(:,:,iTemp) = tempFrame; % fill temp variable for diff
%         tempTimes(iTemp) = vidObj.CurrentTime;
%         iTemp = iTemp+1; % count up temp counter
%     end
%     timeIndex = endTime; % increment timeIndex up
% 
%     tempDPix = abs(diff(tempLum,1,3)); % nonsmoothed differences
%     tempDPixSm = smooth3(tempDPix,'box',[11 11 round(FR/2)*2+1]); % smoothed differences
%     
%     % calculate mean difference per frame over all pixels this segment
%     tempDPix = squeeze(nanmean(tempDPix,[1,2])); 
%     tempDPixSm = squeeze(nanmean(tempDPixSm,[1,2]));
%         
%     % concatenate temp mean difference arrays with output array
%     dPix = cat(1,dPix,tempDPix);
%     dPixSm = cat(1,dPixSm,tempDPixSm); 
%     timeGrid = cat(1,timeGrid,tempTimes);
%     
%     %TO-DO: Calculate standard deviation of pixels...?? Account for
%     %luminance differences
%     
%     
% end
% toc
% 
% % Remove first and last second of data to exclude artifacts
% disp('setting first and last second of data to nan');
% dPix(1:FR) = nan;
% dPixSm(1:FR) = nan;
% dPix(nFrames-FR:nFrames) = nan;
% dPixSm(nFrames-FR:nFrames) = nan; 
% 
% % rename movement array to something sensible
% finalMovementArray = dPixSm;

%TO-DO: TIMESTAMPS
% in the Synapse version, we have two time arrays: one that was created by
% Synapse itself, and one encoded in the video.  We have both now.  Synapse
% frame time stamps start slightly after the beginning of recording, and
% will indicate so, so we need to align the two here. Everything (including
% ephys) is relative to start of recording, so that's all that matters when
% adjusting time.

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