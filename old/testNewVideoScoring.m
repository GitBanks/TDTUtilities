%1. find correct video names
%2. draw shape where cage/animal was
%3. isolate those pixels in all frames of video
%4. compute frame x frame differences 
%5. smooth/clean difference array
%6. save into output structure and move onto next video

%notes: converted to grayscale (how much meaningful info is lost?)

%questions:
%what are best practices for optimizing code? When to convert to double?
%Matrix computation for frame x frame differences instead of individual?

fileName = [getPathGlobal('W') 'PassiveEphys\2019\19310-002\2019_19310-002_Cam1.avi'];
%  fileName = 'W' ':\Data\PassiveEphys\2019\19313-001\2019_19313-001_Cam1.avi';

%2. draw shape around where mouse movement can be expected
S = loadVidDrawShape(fileName);

%pre-allocate variables
Y = nan(length(S.mov)-1,1);
Y2 = nan(length(S.mov)-1,1);
Z = nan(length(S.mov)-1,1);
W = nan(length(S.mov)-1,1);
%3. calculate frame x frame differences
disp('calculating frame x frame differences');
tic
iFrame = 1;
while iFrame < length(S.mov)
    X2 = S.mov(iFrame+1).cdata(logical(S.thesePix));
    X1 = S.mov(iFrame).cdata(logical(S.thesePix));
    Y(iFrame) = mean(abs(X2-X1));
    Y2(iFrame) = mean((X2-X1).^2);
    Z(iFrame) = abs(mean(X2)-mean(X1));
    W(iFrame) = std(double(X2-X1));
    iFrame = iFrame+1;
end
toc
%%
figure
h(1) = subplot(2,1,1);
plot(Z/mean(Z));
hold on
plot(Y/mean(Y));
hold on
plot(Y2/mean(Y2));
hold on
plot(W/mean(W));
legend('Z abs(m2-m1)','Y mean(abs(X2-X1))','Y2 mean((X2-X1)^2)','W std(X2-X1)')
title('no smoothing (divided by mean)')
% ylim([0,12])


h(2) = subplot(2,1,2);
plot(smooth(Z/mean(Z)));
hold on
plot(smooth(Y/mean(Y)));
hold on
plot(smooth(Y2/mean(Y2)));
hold on
plot(smooth(W/mean(W)));
title('default smooth (divided by mean)')
xlabel('nFrames');
ylabel('mean luminance change');
legend('Z abs(mean(X2)-mean(X1))','Y mean(abs(X2-X1))','Y2 mean((X2-X1)^2)','W std(X2-X1)')


%%
figure
h(1) = subplot(2,1,1);
plot(Y2);
hold on
plot(Z2);
legend('Y','Z')
title('no filter')
ylim([0,12])
h(2) = subplot(2,1,2);
plot(smooth(Y2));
hold on
plot(smooth(Z2));
title('smooth')
xlabel('nFrames');
ylabel('mean luminance change');
ylim([0,12])
legend('Y (mean(abs(X2-X1)))','Z (abs(mean(X2)-mean(X1)))')


%%

figure('name','hist comparison')
subplot(5,1,1)
hist(log(Z))
title('Z')

subplot(5,1,2)
hist(log(Y))
title('Y')

subplot(5,1,3)
hist(log(Y2))
title('Y2')

subplot(5,1,4)
hist(log(W))
title('W')

load('M:\PassiveEphys\2019\19310-002\19310-002-movementInfoAdjusted','finalMovementArray');
subplot(5,1,5)
hist(log(finalMovementArray))
title('sean')



%% testing suggestions from Bryan 3/20/2019

%1. can you plot the difference image while the flesh mouse moves? For example, 
% there are shrinkage filters that would help remove single pixel values, 
% or a median average in a small window might work for the samed
localDir = 'roboMouse_001';

% fileNombre = 'W' ':\Data\PassiveEphys\2019\19310-002\2019_19310-002_Cam1.avi';
fileNombre = [getPathGlobal('W') 'PassiveEphys\2019\19310-001\2019_193130-001_Cam1.avi'];

%load video using VideoReader, have user draw shape around area to analyze
S = loadVidDrawShape(fileNombre);

%pre-allocate variables
Y3 = nan(240,320,length(S.mov)-1); %note: for an hour of video this will be close to 2gb...
disp('calculating frame x frame differences');
tic
iFrame = 1;
zeroPixels = ~logical(S.thesePix(:,:));
while iFrame < length(S.mov)
    %load in given frame
    X1 = double(S.mov(iFrame).cdata);
    X1(zeroPixels) = 0;
    
    %load in next frame
    X2 = double(S.mov(iFrame+1).cdata);
    X2(zeroPixels) = 0;
    
    %subtract frames
    Y3(:,:,iFrame) = (X2-X1);
    
    %iterate to next frame
    iFrame = iFrame+1;
end
toc
disp('frame differences calculated and stored in Y3');

%smooth data...
disp('starting convolution (smoothing)');
tic
Y3 = convn(Y3,ones(11,11,11)/11^3,'same');
toc
disp('convolution finished');

%set the directory where frame x frame images and videos will be saved
workingDir = '';
dirToUse = fullfile(workingDir,localDir);
if ~exist(dirToUse,'dir')
    mkdir(dirToUse);
    disp([dirTouse ' created']);
end


%write image files individually before generating video of frame x frame differences
disp(['writing image files to ' dirToUse]);
tic
for ii = 1:1800 %size(Y3,3)
    filename = [sprintf('%04d',ii) '.jpg'];
    fullname = fullfile(dirToUse,filename);
    % Write out to a JPEG file (img1.jpg, img2.jpg, etc.)
    imwrite(uint8(floor((squeeze(Y3(:,:,ii))*20+255)/2)),fullname)  %<----bryan's magic calculation  
end
toc
disp(['images now stored in' workingDir]);

%loop through images created in previous steps to create video!
imageNames = dir(fullfile(dirToUse,'*.jpg'));
imageNames = {imageNames.name}';

outputVideo = VideoWriter(fullfile(workingDir,'Subtraction_19310_v0'));
outputVideo.FrameRate = S.v.FrameRate;
open(outputVideo)
disp('creating video file');
for ii = 1:length(imageNames)
   img = imread(fullfile(dirToUse,imageNames{ii}));
   writeVideo(outputVideo,img)
end

close(outputVideo)

subVid = VideoReader(fullfile(workingDir,'Subtraction_19310_v0.avi'));

ii = 1;
while hasFrame(subVid)
   mov(ii) = im2frame(readFrame(subVid));
   ii = ii+1;
end
disp('uhhh video file created');

%     Y2(:,:,iFrame) = conv2(Y3(:,:,iFrame),K,'same');
%     Y(:,:,iFrame) = abs(Y2(:,:,iFrame));
%%

figure()
hold on;
Y = squeeze(mean(mean(abs(Y3),1),2));
plot(Y);
plot(smooth(Y,40));













