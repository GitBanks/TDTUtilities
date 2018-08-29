function [] = synapseFrontEnd(animalName)
%testinputs
%animalName = 'EEG16'

%1. pull the last few recent animals to select from
%2. display a limited set of experiments to try and allow toggle
%   a. test? or leave that for brainware?
%   b. LPS
%   c. saline
%   d. ketamine
%   e. Iso
%3. present button to get next experiment ready - when clicked it:
%   a. creates notebook entry (locking in an index)
%   b. sets up randomized trials for Synapse
%   c. gets Synapse ready to record
%   d. monitors Synapse for when it's done recording - when done, it
%   imports the last index and gets the next one ready!


% TODO !!! : add a check to see if we can connect to recording computer path
% (sometimes network logs us out) !!!! otherwise we can't guarantee
% importing will work consistantly
% example path: \\144.92.237.187\c\Data\2018\

S.enableMultiThread = 1; % for testing or using without parfor, set to 0
S.recordingComputer = '144.92.237.187';
S.recordingComputerSubfolder = '\c\Data\';
% TODO: add a check or scan for latest recording folder (low priority)

S.dbConn = dbConnect();
% TODO make this part of interface - gui?
S.animalName = animalName;
% dbConn = dbConnect();
% latestAnimal = 270%DOTO how to find?
% ephysResult = fetch(dbConn,['select animalName from animals where animalID='  num2str(latestAnimal)]);   
% TODO make this part of interface - gui? store predefined sets here?
% S.experimentDrugManipulation = 'LPS';
% presets?  make part of gui?
S.nHoursPre = 1; % refers to number of hours pre time zero manipulation
S.nHoursPost = 4;
S.forceStimPresentation = false; % this will force 
S.nExptsRecordedToday = 0;
S.listOfExperimentsRunToday = {};



%starting pool here!  we need to be sure to shut it down
if S.enableMultiThread 
    parpool(2);
end
% Start Synapse 
updateDynamicDisplayBox('Starting Synapse');
S = synapseConnectionProcess(S); % connect to recording computer

S.fh = figure('units','pixels',...
    'position',[100 100 1400 700],...
    'menubar','none',...
    'numbertitle','off',...
    'name','Experiment Day Setup',...
    'resize','off');
S.Preselects = {'Saline','LPS','ISO','Ketamine','CNO'}; % just add manipulations as needed (?)
%!!!!!!TODO!!!!! make this selectable?
uicontrol('style','text',...
    'units','pix',...
    'position',[10 650 120 30],...
    'string',S.animalName); 
S.pp = uicontrol('style','pop',...
    'unit','pix',...
    'position',[135 650 120 30],...
    'string',S.Preselects); 
S.pb = uicontrol('style','push',...
    'units','pix',...
    'posit',[270 650 120 30],...
    'string', 'Setup this expt',...
    'fontsize',10,...
    'callback',{@setupExpt,S});
setupFigure(S); % draw a number of list boxes and display fixed text
S = listOfAllExperiments(S);
% everything done
uiwait;
% cleanup
if S.enableMultiThread; delete(gcp); end
synapseDisconnect(S.syn);





  

function [S] = pushbuttonStartNextIndex(varargin)
S = varargin{3};
if isempty(S.ExperimentsRemaining.exptDescriptionText)
    % We may want to do an import step here (if we've run the whole day and
    % clicking imports the last one.
    return;   %stop user from otherwise running nothing.
end
userListSelection = get(S.ls,'Value'); % Get the user's choice.
S.nExptsRecordedToday = S.nExptsRecordedToday+1;
S.listOfExperimentsRunToday{S.nExptsRecordedToday} = S.ExperimentsRemaining.exptDescriptionText{userListSelection};
S.tempnTrials = S.ExperimentsRemaining.nTrialsIndexArray(userListSelection);
S.tempnStims = S.ExperimentsRemaining.nStimsIndexArray(userListSelection);
% these next few steps will remove the user selected expt from list
S.ExperimentsRemaining.exptDescriptionText(userListSelection) = [];
S.ExperimentsRemaining.nTrialsIndexArray(userListSelection) = [];
S.ExperimentsRemaining.nStimsIndexArray(userListSelection) = [];
S = refreshExptRemainingToBeRun(S);
updateDynamicDisplayBox('Creating new notebook entry');
S = createNewNotebookEntry(S); % create notebook entry
pause(.5);

% %!!!TODO!!!%%%%%%%%%%%%%!!!!!!!!!!!!!!!!!!!!!!!!!!!! ? shut off other buttons?


updateDynamicDisplayBox('loading in parameter set');
S = parameterCreationProcess(S); % create a parameter set and load it in
% !!!!!!!!!!!!!!!!!!! alternatively, start recording immediately in
% parameterCreationProcess or here (syanapse needs to be running to set
% parameters)



% Here we use parallel computing to run a command to setup (and wait for)
% next expt while it analyzes the last one.  Need to set up a few
% parameters instead of passing the 'S' object that we update.
[date,~] = fixDateIndexToFiveForSynapse(S.exptDate,S.exptIndex);
if ~isempty(S.exptIndexLast')
    [~,indexLast] = fixDateIndexToFiveForSynapse(S.exptDate,S.exptIndexLast);
else
    indexLast = '-1'; %this could hand synapseImportingPathway a -1 val
    % if we haven't run anything previously today which will tell it to
    % skip analysis
end
synapseObj = S.syn;
recordingComputer = S.recordingComputer;
subfolder = S.recordingComputerSubfolder;

if S.enableMultiThread
    parfor i = 1:2
        if i == 1
            synapseRecordingPathway(synapseObj);
        else
            synapseImportingPathway(date,indexLast,recordingComputer,subfolder);
        end
    end
else
    
    synapseRecordingPathway(synapseObj);
    synapseImportingPathway(date,indexLast,recordingComputer,subfolder);
end


updateDynamicDisplayBox('finished recording!','black');
% === path to start synapse, collect data, wait for that to finish complete
% here
pause(1);
updateDynamicDisplayBox('','black');
pause(1);
updateDynamicDisplayBox('Refreshing lists');
% refresh all lists and the pushbutton.
S = refreshExptRemainingToBeRun(S);
S = refreshIndicesCompletedToday(S);
S = listOfAllExperiments(S);
updateDynamicDisplayBox('','black');

%%%%!!!!!!!!!!!!!!!!!!!!!!!!!!!! ? reenable other buttons once we're done?

% % % TESTING
% % S.recordingComputer = '144.92.237.187';
% % S.syn = SynapseAPI(S.recordingComputer);
% % S.syn.setMode(0); %need to set mode to idle to modify parameters.
% % S.syn.getModeStr()
% for i=1:40  %blinky.  maybe do this while Synapse is running?
% updateDynamicDisplayBox(S.listOfExperimentsRunToday{S.nExptsRecordedToday},'red');
% pause(.1);
% updateDynamicDisplayBox(S.listOfExperimentsRunToday{S.nExptsRecordedToday},'black');
% pause(.1);
% end




function synapseRecordingPathway(varargin)
% S = varargin{1};
synapseObj = varargin{1};
% date = varargin{2};
% index = varargin{3};
% === path to start synapse, collect data, wait for that to finish
%[date,index] = fixDateIndexToFiveForSynapse(S.exptDate,S.exptIndex);
% synapseObj.setCurrentBlock([date '-' index]);
% waitingForUserToStartRecording = true; % recent change: program auto-starts so should already be '3'
% while waitingForUserToStartRecording
%     updateDynamicDisplayBox('waiting for user to record');
%     pause(1);
%     if synapseObj.getMode() == 3
%         waitingForUserToStartRecording = false;
%     end
% end
waitingForUserToFinishRecording = true;
while waitingForUserToFinishRecording
    updateDynamicDisplayBox('waiting for recording to complete');
    pause(1);
    if synapseObj.getMode() == 0
        waitingForUserToFinishRecording = false;
    end
end
synapseObj.setMode(0);




function synapseImportingPathway(varargin)
% test block:
% [date,index] = fixDateIndexToFiveForSynapse(S.exptDate,S.exptIndex);
% date = '18821'
% index = '001'
% synapseImportingPathway(date,indexLast,recordingComputer,subfolder);
% recordingComputer = '144.92.237.187';
% subfolder = '\c\Data\';

% may want to add try/catch so if a single day doesn't analyze we don't shit ourselves
date = varargin{1};
index = varargin{2}; %this is set to the previous index (see call)
recordingComputer = varargin{3};
subfolder = varargin{4};

if ~isempty(strfind(index,'-1')); return; end; % don't run on first index - if nothing has been run today yet.
dirStrRecSource = ['\\' recordingComputer subfolder '20' date(1:2) '\' date '-' index '\'];
% WARNING! the following shouldn't be hard coded as they are.  Pass as parameters
% to synapseImportingPathway
dirStrRawData = ['W:\Data\PassiveEphys\' '20' date(1:2) '\' date '-' index '\'];
dirStrAnalysis = ['M:\PassiveEphys\' '20' date(1:2) '\' date '-' index '\'];
% %% STEP 1 MOVE RECORDED DATA TO RAW %%
moveDataRecToRaw(dirStrRecSource,dirStrRawData);
% %% STEP 2 IMPORT 
dirCheck = dir([dirStrAnalysis '*data*']); % check to see if ephys info is imported
if isempty(dirCheck)
    display('Handing info to existing importData function.  This will take a few minutes.');
    importDataSynapse(date,index) % !!! still testing!!! be careful!!!
    
    
    %importDataSynapse(date,index);
    %!!!!!!!!!!!!!TODO!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    %!!!!!!!!!!!!!!importData('PassiveEphys',S.exptDate,S.exptIndexLast);
    
    
else
    display('Data already imported.');
end
% %% COPY MOVIES %% this should be redundant since we now copy all files above,
% but it's little cost to just double check movie file location, so I'll
% leave this for now.
vidFileName = [];
videoFileTypesToLookFor = {'.avi','.'};
videoFound = false;
for iSearch = 1:length(videoFileTypesToLookFor)
    dirCheck = dir([dirStrRawData '*' videoFileTypesToLookFor{iSearch}]);  % TODO: should we also look for AVI files?
    for iDir = 1:length(dirCheck)
        if dirCheck(iDir).isdir == false && dirCheck(iDir).bytes > 1000
            display('found a movie already on server');
            videoFound = true;
            vidFileName = [dirStrRawData dirCheck(iDir).name];
        end
    end
end
if videoFound == false;
    display('Since we didn''t find a movie on server, let''s copy it now.');
    for iSearch = 1:length(videoFileTypesToLookFor)
        dirCheck = dir([dirStrRecSource '*' videoFileTypesToLookFor{iSearch}]);
        for iDir = 1:length(dirCheck)
            if dirCheck(iDir).isdir == false && dirCheck(iDir).bytes > 1000
                display('Copying now');
                source = [dirStrRecSource dirCheck(iDir).name];
                vidFileName = [dirStrRawData dirCheck(iDir).name];
                if ~exist(dirStrRawData,'dir')
                    mkdir(dirStrRawData);
                end
                copyfile(source,vidFileName);
                videoFound = true;
            end
        end
    end
end

% %% GRIDIFICATION %%
repeatedAttempts = 1;
maxAttempts = 4;
if videoFound == false % no video?  can't run
    display(['No video found in ' dirStrRawData '!']);
elseif isempty(dir([vidFileName '-framegrid.mat']))
    % if grid isn't done, or user wants to rerun it anyway create the frame 
    % grid!  this takes a while.
    while repeatedAttempts < maxAttempts
        try
            display('attempting to run mmread on video...')
            videoFrameGridMake(vidFileName);
            repeatedAttempts = maxAttempts;
        catch
            display(['mmread is slightly unstable.  Let''s try ' num2str(maxAttempts-repeatedAttempts) ' more times.' ])
            repeatedAttempts = repeatedAttempts+1;
        end
    end
end




% get animal name and ID info
% dbConn = dbConnect();
% exptID = getIDfromDateIndex(S.exptDate,exptIndex);
% if ~strcmpi(exptType,'Behavioral')
%     ephysResult = fetch(dbConn,['select detailID from detail_ephys where exptid='  num2str(exptID)]);
%     animalID = fetch(dbConn,['select animalID from masterexpt where exptid='  num2str(exptID)]);
%     %animalName = fetch(dbConn,['select animalName from animals where animalID='  num2str(animalID{1})]);
%     if(isempty(ephysResult))
%          ephysErr = MException('EphysData:NonExsistent', ...
%          ['No data found in detail_ephys table for experiment number - ' num2str(exptID) ' Check the e-notebook.']);
%          throw(ephysErr);
%     end
% end
















function [S] = parameterCreationProcess(varargin)
S = varargin{1};
sequenceUpdated = false;
countX = 1;
while ~sequenceUpdated
    csvAssembler(S.exptDate,S.exptIndex,S.tempnStims,S.tempnTrials); %setup trial file (writes to folder)
    % update and send parameters to Synapse
    % need to set tank name here if we're going to just start recording!
    [date,index] = fixDateIndexToFiveForSynapse(S.exptDate,S.exptIndex);
    S.syn.setCurrentBlock([date '-' index]);
    S.syn.setMode(3); %changing this so recording just starts! make sure we're happy with this! !!!!!!!!!TODO!!!!!!!!!
    pause(4);
    seqList = S.syn.getParameterValues('ParSeq1','SequenceFileList');
    result = 0;
    if iscell(seqList)
        for iList = 1:length(seqList)
            [exptDate,exptIndex] = fixDateIndexToFiveForSynapse(S.exptDate,S.exptIndex);
            if ~isempty(strfind([exptDate '-' exptIndex],seqList{iList}))
                result = S.syn.setParameterValue('ParSeq1','SequenceFileIndex',iList-1); %index starts at 0
            end
        end
    end
    if result == 0;
        updateDynamicDisplayBox(['We are not able to update sequence ' num2str(countX)]);
        S.pb = uicontrol('style','push',...
        'units','pix',...
        'posit',[270 650 120 30],...
        'string', 'retry!',...
        'fontsize',10,...
        'callback',{@parameterRecreate,S});
        pause(1);
    end
    if result == 1
        sequenceUpdated = true;
    end
    countX = countX+4;
end
function [S] = parameterRecreate(varargin)
S = varargin{3};
csvAssembler(S.exptDate,S.exptIndex,S.tempnStims,S.tempnTrials); %setup trial file (writes to folder)

function [S] = synapseConnectionProcess(varargin)
S = varargin{1};
connected = false;
while ~connected
    try
        S = synapseConnect(S);
    catch
        updateDynamicDisplayBox('Connection error! Check network and Synapse software!');
        %display('Connection error! Check network and Synapse software!');
        S.pb = uicontrol('style','push',...
        'units','pix',...
        'posit',[270 650 120 30],...
        'string', 'connect!',...
        'fontsize',10,...
        'callback',{@synapseReconnect,S});
    end
    try
        if ~isempty(strfind({'Idle', 'Standby', 'Preview', 'Record'},S.syn.getModeStr()))
            %need to test connectivity
            S.syn.setMode(2); %need to switch between states to get it to respond...
            if S.syn.setMode(0);
                connected = true;
            end
        end
    catch
        updateDynamicDisplayBox('Check network and Synapse software');
        pause(1);
    end
end
function [S] = synapseConnect(varargin)
S = varargin{1};
S.syn = SynapseAPI(S.recordingComputer);
function [S] = synapseReconnect(varargin)
S = varargin{3};
S.syn = SynapseAPI(S.recordingComputer);
function synapseDisconnect(varargin)
synapseObj = varargin{1};
synapseObj.delete();

function [S] = createNewNotebookEntry(varargin)
% create notebook entry
S = varargin{1};
lastEntryID = fetch(S.dbConn,'SELECT MAX(exptID) FROM masterexpt');
hardware = 'TDT'; %this is a TDT specific program.
grandExpt = 'PassiveEphys'; %this is another assumption
animalID = fetch(S.dbConn,['SELECT animalID FROM animals WHERE animalName=''' S.animalName '''']);
exptDate = fetch(S.dbConn,['SELECT exptDate FROM masterexpt WHERE exptID=' num2str(lastEntryID{1})]);
exptIndex = fetch(S.dbConn,['SELECT exptIndex FROM masterexpt WHERE exptID=' num2str(lastEntryID{1})]);
experimenterID = fetch(S.dbConn,['SELECT experimenterID FROM masterexpt WHERE exptID= ''' num2str(lastEntryID{1}) '''']);
% check date, make sure if date is different index is reset
if isequal(houseTodayDateIn_dbForm,exptDate{1})
    S.exptIndexLast = exptIndex{1};
    S.exptDate = exptDate{1};
    S.exptIndex = exptIndex{1}+1;
else
    S.exptDate = houseTodayDateIn_dbForm;
    S.exptIndex = 0;
    S.exptIndexLast = [];
end
thisID = lastEntryID{1}+1;
% == Add the main information
addNotebookEntry = ['INSERT INTO masterexpt (exptIndex, hardware, grandExpt,'...
    'exptDate, animalID, experimenterID) VALUES (' num2str(S.exptIndex) ','''...
    hardware ''',''' grandExpt ''',''' S.exptDate ''',' num2str(animalID{:})...
    ',' num2str(experimenterID{:}) ')'];
% Add a check to be sure we did it correctly??
% == Add the details
SQLdetail_ephys = fetch(S.dbConn,['SELECT * FROM detail_ephys WHERE exptID= ''' num2str(lastEntryID{1}) '''']);
exptID = num2str(thisID);
if ~isempty(SQLdetail_ephys)
    filter_lowcut = num2str(SQLdetail_ephys{3});
    filter_highcut = num2str(SQLdetail_ephys{4});
    amp_gain = num2str(SQLdetail_ephys{5});
    sample_freq = num2str(SQLdetail_ephys{6});
    chamber = num2str(SQLdetail_ephys{7});
    headstage = num2str(SQLdetail_ephys{8});
    preamp = num2str(SQLdetail_ephys{10});
    spkrCenter = num2str(SQLdetail_ephys{13});
    recordingBox = num2str(SQLdetail_ephys{14});
else  %defaults... not sure if this is correct
    filter_lowcut = '0.2';
    filter_highcut = '8545'; % default
    amp_gain = '10000'; % this is a guess!!!
    sample_freq = '24414'; % default
    chamber = 'Bottom';
    headstage = 'ZC16';
    preamp = 'PZ5';
    spkrCenter = 'blank';
    recordingBox = 'blank';
end
addDetailEphys = ['INSERT INTO detail_ephys (exptID,filter_lowcut,filter'...
    '_highcut,amp_gain,sample_freq,chamber,headstage,preamp,spkrCenter,'...
    'recordingBox) VALUES (' exptID ',' filter_lowcut ...
    ',' filter_highcut ',' amp_gain ','...
    sample_freq ',''' chamber ''','''...
    headstage ''',''' preamp ''','''...
    spkrCenter ''',''' recordingBox ''')'];
addDescription = ['UPDATE masterexpt SET notebookDesc= ''' ...
    S.listOfExperimentsRunToday{S.nExptsRecordedToday} ''' WHERE exptID= '''...
    num2str(thisID) ''''];
display(['Description will be: ' S.listOfExperimentsRunToday{S.nExptsRecordedToday} ' Be sure you are happy with that']);
%! we're editing the notebook here!!! be careful when changing syntax!
exec(S.dbConn,addNotebookEntry);
exec(S.dbConn,addDetailEphys);
exec(S.dbConn,addDescription);

function updateDynamicDisplayBox(textI,colorI)
%handy way to update diplay text
if ~exist('colorI','var')
    colorI = 'black';
end
uicontrol('style','text',...
    'units','pix',...
    'position',[320 570 300 40],...
    'ForegroundColor',colorI,...
    'string', textI,...
    'fontsize',10);

function [S] = listOfAllExperiments(varargin)
[S] = varargin{1}; % !can't call this as a callback!
%find list of experiments already run
S.existingList = flip(getExperimentsByAnimal(S.animalName)); %flip to show latest
S.existingListHand = uicontrol('style','list',...
    'units','pix',...
    'position',[630 10 320 610],...
    'string', [S.existingList{:,2}],...
    'fontsize',10);

function [S] = refreshIndicesCompletedToday(varargin)
[S] = varargin{1}; % !can't call this as a callback!
% refresh today's finished experiments
S.listFromToday = uicontrol('style','list',...
    'units','pix',...
    'position',[320 10 300 540],...
    'string', S.listOfExperimentsRunToday,...
    'fontsize',10);


function [S] = setupExpt(varargin)
% not in 'setup' because it could get called again (planned drop down menu)
% if the user wants to reset the day.
[S] = varargin{3};
S.experimentDrugManipulation = get(S.pp,'Value'); % Get the user's choice.
disp(['Setting up ' S.Preselects{S.experimentDrugManipulation} ' experiment.']);
%synapseExptSetup sets up all the indices
S.Experiment = synapseExptSetup(S.animalName,S.Preselects{S.experimentDrugManipulation},S.nHoursPre,S.nHoursPost,S.forceStimPresentation);
S.ExperimentsRemaining = S.Experiment;
setupExptToBeRun(S);

function [S] = setupExptToBeRun(varargin)
%setupExptToBeRun sets up experiment for the day based on selection from
%list, then button press
[S] = varargin{1}; % !can't call this as a callback!
S.ls = uicontrol('style','list',...
    'units','pix',...
    'position',[10 10 300 610],...
    'string', S.Experiment.exptDescriptionText,...
    'fontsize',10);
S.pb_index = uicontrol('style','push',...
    'units','pix',...
    'posit',[270 650 120 30],... % we want to overwrite last button (to avoid repeating/changing a list) was% 'posit',[405 650 120 30],
    'string', 'Setup next index',...
    'fontsize',10,...
    'callback',{@pushbuttonStartNextIndex,S});

function [S] = refreshExptRemainingToBeRun(varargin)
%refreshExptRemainingToBeRun is separate, getting smaller as we step
%through the workflow
[S] = varargin{1}; 
S.ls = uicontrol('style','list',...
    'units','pix',...
    'position',[10 10 300 610],...
    'string', S.ExperimentsRemaining.exptDescriptionText,...
    'fontsize',10);
S.pb_index = uicontrol('style','push',...
    'units','pix',...
    'posit',[270 650 120 30],... % we want to overwrite last button (to avoid repeating/changing a list) was% 'posit',[405 650 120 30],
    'string', 'Setup next index',...
    'fontsize',10,...
    'callback',{@pushbuttonStartNextIndex,S});

% % % SETUP % % %
function [S] = setupFigure(varargin)
% just a bunch of figure setup that should exist for the entire program
S = varargin{1};
%'position',[xPos yPos width height]
uicontrol('style','text',...
    'units','pix',...
    'position',[320 600 300 40],...
    'fontweight','bold',...
    'string','Status');
uicontrol('style','text',...
    'units','pix',...
    'position',[630 600 320 40],...
    'fontweight','bold',...
    'string','Finished Indices');
uicontrol('style','text',...
    'units','pix',...
    'position',[10 600 300 40],...
    'fontweight','bold',...
    'string','Experiments remaining to run today');
uicontrol('style','text',...
    'units','pix',...
    'position',[320 530 300 40],...
    'fontweight','bold',...
    'string','Experiments already run'); 
S.existingListHand = uicontrol('style','list',...
    'units','pix',...
    'position',[630 10 320 610],...
    'string', '',...
    'fontsize',10);
S.ls = uicontrol('style','list',...
    'units','pix',...
    'position',[10 10 300 610],...
    'string', '',...
    'fontsize',10);
S.listFromToday = uicontrol('style','list',...
    'units','pix',...
    'position',[320 10 300 540],...
    'string', '',...
    'fontsize',10);
