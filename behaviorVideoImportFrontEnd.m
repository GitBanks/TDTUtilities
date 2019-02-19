function behaviorVideoImportFrontEnd()

S.nMice = 2;
S.fileSys.rawData = '\\144.92.218.131\Data\Data\PassiveEphys\';
S.fileSys.analyzedData = '\\MEMORYBANKS\Data\PassiveEphys\';
% will need to manually move video files to a temp folder, and point to
% that folder here:
S.vFileName{1} = 'C:\Users\Grady\Desktop\MinocyclineExpt-190218-120819\Saline-190218-120819\MinocyclineExpt-190218-120819_Saline-190218-120819_Cam1.avi';
S.vFileName{2} = 'C:\Users\Grady\Desktop\MinocyclineExpt-190218-120819\Saline-190218-131554\MinocyclineExpt-190218-120819_Saline-190218-131554_Cam1.avi';
S.vFileName{3} = 'C:\Users\Grady\Desktop\MinocyclineExpt-190218-120819\Saline-190218-131819\MinocyclineExpt-190218-120819_Saline-190218-131819_Cam1.avi';
S.vFileName{4} = 'C:\Users\Grady\Desktop\MinocyclineExpt-190218-120819\Saline-190218-132049\MinocyclineExpt-190218-120819_Saline-190218-132049_Cam1.avi';
S.vFileName{5} = 'C:\Users\Grady\Desktop\MinocyclineExpt-190218-120819\Saline-190218-132316\MinocyclineExpt-190218-120819_Saline-190218-132316_Cam1.avi';







S.workingFileIndex = 0;
S.fh = figure('units','pixels',...
    'position',[100 100 1400 700],...
    'menubar','none',...
    'numbertitle','off',...
    'name','mouse locations',...
    'resize','off');
S.dbConn = dbConnect();
[S.livingAnimals,S.livingAnimalsID] = getLivingAnimals;
S.livingAnimals = S.livingAnimals.animalName;
S.zoneNames = num2cell(1:S.nMice);
S.finalList = cell(S.nMice,1);
S.ppAnimalnames = uicontrol('style','pop',...
    'unit','pix',...
    'position',[135 650 120 30],...
    'string',S.livingAnimals);
S.ppZoneNames = uicontrol('style','pop',...
    'unit','pix',...
    'position',[285 650 120 30],...
    'string',S.zoneNames); 
S = refreshButtons(S);
uiwait;

function [S] = refreshButtons(varargin)
S = varargin{1};
S.pbMatch = uicontrol('style','push',...
    'unit','pix',...
    'position',[435 650 120 30],...
    'string', 'mouse/zone pair',...
    'fontsize',10,...
    'callback',{@matchZonesAnimals,S});
S.pbMatch = uicontrol('style','push',...
    'unit','pix',...
    'position',[585 650 120 30],...
    'string', 'assign mice2expt',...
    'fontsize',10,...
    'callback',{@assignmentFnx,S});
S.pbLoad = uicontrol('style','push',...
    'unit','pix',...
    'position',[735 650 120 30],...
    'string', 'load next video',...
    'fontsize',10,...
    'callback',{@loadNextVideo,S});

function [S] = loadNextVideo(varargin)
S = varargin{3};
if S.workingFileIndex > length(S.vFileName)
    disp('Assignment complete.')
    uiresume;
end
if isfield(S,'video')
    S = rmfield(S,'video');
end
S.workingFileIndex = S.workingFileIndex+1;
v = VideoReader(S.vFileName{S.workingFileIndex});

iFrames = 1;
disp('Loading video.  This may take a while for larger videos.');
while hasFrame(v)
    S.video.frames(iFrames).cdata = readFrame(v);
    %newVid(iFrames,:,:,:) = readFrame(v);
    iFrames=iFrames+1;
end
disp('Video loading complete.');
set(gca,'XTickLabel',[],'YTickLabel',[],'XTick',[],'YTick',[]);
imagesc(S.video.frames(2));
drawnow;
if isfield(S,'mouseLoc')
    disp('We found existing mouse zones, please be sure they line up, otherwise restart this progam');
    for iZone = 1:S.nMice
        rectangle('Position',S.mouseLoc(iZone).coords,'EdgeColor','r','LineStyle','--');
        text(S.mouseLoc(iZone).displayCoords(1),S.mouseLoc(iZone).displayCoords(2),num2str(iZone),'Color','red','FontSize',14);
        text(S.mouseLoc(iZone).displayCoords(1)-30,S.mouseLoc(iZone).displayCoords(2)-20,S.finalList{iZone,1},'Color','red','FontSize',10);
    end
else
    for iZone = 1:S.nMice
        S.mouseLoc(iZone).coords = round(getrect); % getrect output [xmin ymin width height]
        display(['Assigned zone ' num2str(iZone)]);
        S.mouseLoc(iZone).displayCoords = round([S.mouseLoc(iZone).coords(1)+0.5*S.mouseLoc(iZone).coords(3),S.mouseLoc(iZone).coords(2)+0.5*S.mouseLoc(iZone).coords(4)]);
        text(S.mouseLoc(iZone).displayCoords(1),S.mouseLoc(iZone).displayCoords(2),num2str(iZone),'Color','red','FontSize',14);
        %draw box where selections was
        rectangle('Position',S.mouseLoc(iZone).coords,'EdgeColor','r','LineStyle','--');
    end
end
S = refreshButtons(S);


function [S] = matchZonesAnimals(varargin)
S = varargin{3};
tempZone = get(S.ppZoneNames,'Value');
tempAnimal = get(S.ppAnimalnames,'Value');
text(S.mouseLoc(tempZone).displayCoords(1)-30,S.mouseLoc(tempZone).displayCoords(2)-20,S.livingAnimals{tempAnimal,1},'Color','red','FontSize',10);
S.finalList{tempZone,1} = S.livingAnimals{tempAnimal,1};
S = refreshButtons(S);
% S.livingAnimals
% S.zoneNames


function [S] = assignmentFnx(varargin)
S = varargin{3};
doOnce = 1;

tempNameStart = find(S.vFileName{S.workingFileIndex}=='\');
tempSourceData = S.vFileName{S.workingFileIndex}(1:tempNameStart(end));
%tempFileName = S.vFileName{iList}(tempNameStart(end)+1:end);
disp('Getting timestamps');
data = TDTbin2mat(tempSourceData,'TYPE',{'epocs'}); 
frameTimeStamps = data.epocs.Cam1.onset; 
actualFrameRate = frameTimeStamps(end)/length(frameTimeStamps);

for iList = 1:length(S.finalList) % loop through each animal
    exptDescTemp = ['Behavior of multiple animals, hour ' num2str(S.workingFileIndex) ' zone ' num2str(iList)];
    animalName = S.finalList{iList};
    % assign animal to index in the notebook, create entry
    [exptDate,exptIndex,~] = createNewNotebookEntryTDT(exptDescTemp,animalName);
    % move video array subset to appropriate index
    tempW = S.mouseLoc(iList).coords(1):S.mouseLoc(iList).coords(1)+S.mouseLoc(iList).coords(3);
    tempH = S.mouseLoc(iList).coords(2):S.mouseLoc(iList).coords(2)+S.mouseLoc(iList).coords(4);
    for iFrames = 1:length(S.video.frames)
        tempMovie.frames(iFrames).cdata = S.video.frames(iFrames).cdata(tempH,tempW,:);
    end
    [date,index] = fixDateIndexToFiveForSynapse(exptDate,exptIndex);
    mkdir([S.fileSys.rawData exptDate(1:4) '\' date '-' index '\']);

    if doOnce % move whole video to raw data, first zone dir only
        % get timestamps.% only need epocs - this saves a ton of time.
        % this makes assumptions about the structure.  will need to change if we change 'Cam1' e.g.
        copyfile(S.vFileName{iList},[S.fileSys.rawData exptDate(1:4) '\' date '-' index '\' S.vFileName{iList}(tempNameStart(end)+1:end)]);
        doOnce = 0;
        
    end
    % then move split video to raw data indexed by animal
    % rawFileName = [S.fileSys.rawData exptDate(1:4) '\' date '-' index '\split-' animalName];
    % videoFrameGridMakerSynapse(fileName) % This standalone process was
    % too specialized for the task, so gridMaker, below, was written
    [frameGrid] = gridMaker(tempMovie);
    firstFrame = tempMovie.frames(2).cdata;
    clear tempMovie
    timeGrid = frameTimeStamps; % not sure which one is used when, get rid of one once we know...
    % some possible integrity checks (if we need them): actualFrameRate should
    % equal mean(diff(frameTimeStamps)); if frameTimeStamps isn't totally equal
    % in length to timeGrid ask TDT, or maybe if it's off by one it's OK? 100ms
    % of error OK?   
    analyzedDirName = [S.fileSys.analyzedData exptDate(1:4) '\' date '-' index '\'];
    mkdir(analyzedDirName);
    save([analyzedDirName 'split-' animalName '-zone-' num2str(iList)],'frameGrid','timeGrid','firstFrame','actualFrameRate','frameTimeStamps'); 
    
    
    % set up next video split (allow predrawn boxes on new vid to verify view
    % hasn't drifted in space)
    % TODO also handle notebook+expt setup
    % TODO VERIFY GRID SOFTWARE WILL SPIT OUT APPROPRIATE VALUES ASAP
    clear tempMovie tempW tempH frameGrid
    disp(['Done with animal.  Created: split-' animalName '-zone-' num2str(iList)]);
end
disp('Done with this video.');


function [movieGrid] = gridMaker(tempMovie)

nFrames = length(tempMovie.frames); 
movieGrid = zeros(10,10,int32(nFrames));
%add some rounding in case video isn't div by 10 (is that possible?)
heightX = size(tempMovie.frames(1).cdata,2);
widthX = size(tempMovie.frames(1).cdata,1);
stepA = floor(heightX/size(movieGrid,2));
stepB = floor(widthX/size(movieGrid,1));

for iFrame = 1:nFrames
    %display(['frame ' num2str(iFrame)])
    for iGrid = 1:stepA:heightX-stepA
        for jGrid = 1:stepB:widthX-stepB
            movieGrid(ceil(iGrid/stepA),ceil(jGrid/stepB),iFrame) = sum(sum(sum(tempMovie.frames(iFrame).cdata(jGrid:jGrid+stepB-1,iGrid:iGrid+stepA-1,:))));
        end
    end
end



% 
% for i=1:10
%     for j=1:10
%         stepTwoGrid(i,j,:) = smooth(raiseTheRoof(frameGrid(i,j,:),40),40,'sgolay');
%         %smoothedGrid(i,j,:) = smooth(smoothedGrid(i,j,:));
%     end
% end
% 
% for iFrame = 1:length(stepTwoGrid)-1
%     newGrid(:,:,iFrame) = abs(stepTwoGrid(:,:,iFrame+1)-stepTwoGrid(:,:,iFrame));
% end
% % figure();
% for i=1:10
%     for j=1:10
%         smoothedGrid(i,j,:) = smooth(raiseTheRoof(newGrid(i,j,:),40),40,'sgolay');
%         %smoothedGrid(i,j,:) = smooth(smoothedGrid(i,j,:));
% %         plot(squeeze(squeeze(smoothedGrid(i,j,:))));
% %         hold on;
%     end
% end
% finalMovement = squeeze(sum(squeeze(sum(smoothedGrid,2)),1));
% figure();
% plot(finalMovement);
% figure();
% for j = 1:length(smoothedGrid)
%     imagesc(smoothedGrid(:,:,j));
%     drawnow;
%     pause(1/10)
% end
% 



