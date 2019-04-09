function movementCalculator_test(animal,exptDate)

% DESCRIPTION: 
% expanding on previous efforts in testNewVideoScoring from 3/20/2019 to
% test new video algorithm. Now I want to clean up that script, then apply
% it to batches of experiments. 

% TO-DO: 
% 1) timestamps???
% 2) add check if index follows an injection - if so, have user re-draw movement area due to possible movement of the cage. 
% 3) LED computation

% Note: check rest of code for possible to-dos. 

% EXAMPLE INPUTS: 
% animal = 'EEGRoboMouse'; %set animal to analyze 
% exptDate = '19310'; %set date to analyze

listOfExpts = getExperimentsByAnimal(animal,'Spon'); %grab relevant experiments & construct file name array

rootDir = ['W:\Data\PassiveEphys\20' exptDate(1:2) '\']; %root directory to load videos. Should only be W for all animals
[fileNameList,exptDesc] = findVideoFiles(listOfExpts,exptDate,rootDir); %grab list of video file names
fileStruct = struct;
disp('starting movement calculation.');

for iFile = 1:length(fileNameList) %loop through files to draw shape around cage, then analyze movement in that cage
    
    fileNombre = fileNameList{iFile}; %set file name
    description = exptDesc{iFile}; %find name of file
    
    if contains(description,'Pre') || iFile == 1
        disp('redraw area to analyze');
        redraw = true;
        thesePix = [];
    elseif contains(description,'Post') && contains(exptDesc{iFile-1},'Pre')
        disp('note: this recording came after an injection. ROI should be redrawn');
        redraw = true;
        thesePix = [];
    else 
        redraw = false;
        thesePix = thesePix;
    end
    
    %load video, convert to array 'mov', draw ROI, use thesePix to only pix within ROI
    %NOTE: pixels outside of ROI are already excluded in mov, as well as 1st & last seconds of video
    disp('loading video in. Be prepared to draw shape!'); 
    tic
    [mov,thesePix,h,w,FR,nFrames] = loadVidDrawShape(fileNombre,redraw,thesePix); 
    toc
    stdMov = nanstd(mov(:,:,nFrames:1000),0,'all'); %hotfix -only the first ~1000 frames... come on
    
    dFrames = nan(h,w,nFrames-1); %pre-allocate the frame x frame subtraction array
    
    disp('calculating frame x frame differences');
    tic
    for iFrame = 1:length(mov)-1
        dFrames(:,:,iFrame) = mov(:,:,iFrame)-mov(:,:,iFrame+1); % COMPUTE FRAME X FRAME GRAYSCALE DIFFERENCES
    end
    toc
    disp('frame differences calculated and stored in dFrames');

    %smooth frame x frame differences
    disp('starting convolution (smoothing)');
    tic
    fileStruct(iFile).finalMovementArray = smooth3(dFrames,'box',[11 11 round(FR/2)*2+1]); %is it correct to create the convolution with framerate?
    toc
    disp('convolution finished');
    fileStruct(iFile).stdMov = stdMov; %standard deviation of grayscale values in each frame for all frames of video

end
%% plot differences
figure();
for iFile = 1:length(fileNameList)
    h(iFile) = subplot(length(fileNameList),1,iFile);
    temp = fileStruct(iFile).finalMovementArray;
    movt = squeeze(nanmean(nanmean(abs(temp),1),2));
    stdev = fileStruct(iFile).stdMov;
    movtPct = movt/stdev;
    plot(movtPct);
end
linkaxes(h(:),'xy');
ylabel('smooth3(dFrame)/std(mov(:))');
%% saving shit
% outPath = ['M:\PassiveEphys\20' exptDate(1:2) '\' exptDate '\']; %TODO: determine where best to save this!
%% graveyard
% fileStruct(iFile).finalMovementArray2 = convn(dFrames,ones(11,11,FR)/FR^3,'same'); 
% listIndex = 1; %set iterant (?) to 1, only increases when a video file is successfully found
% disp('finding video files');
% tic
% for iExpt = 1:size(listOfExpts,1)
%     if isempty(listOfExpts{iExpt,1})
%         error('This step is only set to run on spon experiments for now.')
%     end
%     if ~isempty(strfind(listOfExpts{iExpt,1}(1:5),exptDate))
%         operationList{listIndex} = listOfExpts{iExpt,1};
%         vidFile = dir([rootDir operationList{listIndex} '\*.avi*']);
%         try %the following section *should* be good for Synapse.
%             if isempty(vidFile)
%                 error(['No video found for' operationList{listIndex}  '. Check that path is OK.']);
%             else
%                 fileNameList{listIndex} = [rootDir operationList{listIndex} '\' vidFile.name];
%                 exptDesc{listIndex} = listOfExpts{iExpt,2};
%                 listIndex = listIndex+1;
%             end
%         catch %for old system WIP TODO: find how old system data were named.
%             vidFile = dir([rootDir operationList{listIndex} '\operationList{listIndex}*.']);
%             if isempty(vidFile)
%                 warning(['No video found for ' operationList{listIndex}  '. Check that path is OK.']);
%             else
%                 fileNameList{listIndex} = [rootDir operationList{listIndex} '\' vidFile.name];
%                 exptDesc{listIndex} = listOfExpts{iExpt,2};
%                 listIndex = listIndex+1;
%             end
%         end
%     end
% end
% toc