function [] = synapseFrontEnd(animalName)
% test inputs
% animalName = 'EEG16'

% This GUI, when given an animal name, will allow user to select an 
% experiment type for which the program will create all expected indices
% with related 'stim' and 'spontaneous' settings for Synapse.  This
% interface will control Synapse: each press of 'start next index' will run
% and stop the whole next recording period (usually 10-20 mins) while
% *also* importing the last most recently recorded period.  User simply
% needs to click button between periods, and be sure data collection looks
% appropriate (experimental manipulations, animal behavior, signal quality,
% data file and program management).
% Keep in mind this contains numerous helper / sub functions that need to
% be considered when making modifications, but this will allow
% compartmentalization and scaling as new processes are available and
% analyses desired.
% 2018, Banks Lab, Sean Grady.

% WIP: check code for % TODO % or % !!! TODO !!! % for different levels of
% urgency to make the program better

% WARNING! this is no longer suitable for regular EEG (1 hour) recordings
% until we add 'spontaneous' wait time as a parameter

% TODO % add 'config' file that allows parameters, file locations, and general lab changes to be centrally located.

% ! TODO ! %  add a check to see if we can connect to recording computer path (sometimes network logs us out!) otherwise we can't guarantee importing will work consistantly
% example path: \\144.92.237.187\c\Data\2018\
S.enableMultiThread = 1; % for testing or using without parfor, set to 0
S.recordingComputer = '144.92.237.187';
S.recordingComputerSubfolder = '\c\Data\';
S.dbConn = dbConnect();
% TODO % animalName is presently a parameter, but a menu selection might be better?  or auto-populate with recent (living) animal? 
S.animalName = animalName;
% TODO % we may want to add nHoursPre to the GUI as a toggle or parameter
S.nHoursPre = 1; % refers to number of hours pre time zero manipulation. We will set this to '2' if making two injections.
S.nHoursPost = 4; % we've been doing 4, but consider adding it as a toggle in addition to nHoursPre

% !! TODO !! % create parameter here to check for when inj is, and auto-next index stuff? urgent because this will allow us to streamline data collection

% TODO % set all the following as toggles in GUI
S.forceStimPresentation = false; % this will force synapseExptSetup to create stimulus periods even if it's an EEG animal
S.nExptsRecordedToday = 0; % initialization, but we could also use this to set a different number if, e.g., the program was restarted and we needed to resume at middle of day
S.listOfExperimentsRunToday = {}; % similar to nExptsRecordedToday. initialized here, but could be used to resume.

if S.enableMultiThread % starting pool here!  we need to be sure to shut it down at end of program
    parpool(2);
end
S.fh = figure('units','pixels',...
    'position',[100 100 1400 700],...
    'menubar','none',...
    'numbertitle','off',...
    'name','Experiment Day Setup',...
    'resize','off');  
updateDynamicDisplayBox('Starting Synapse');
S = synapseConnectionProcess(S); % Start Synapse, connect to recording computer            
S.Preselects = {'Saline','LPS','ISO','Ketamine','CNO','Minocycline'};  %added Minocycline 2/12/2019 ZS % just add manipulations as needed for now.  if there's a funky setup, we need to edit synapseExptSetup to handle it (see how iso is handled)
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
% !TODO! %
% 9/10/18: Issue discovered when trying to run 'synapseImportingPathway' at
% the end, after this point.  The structure 'S' looks like it's updated
% between setupExptToBeRun and refreshExptRemainingToBeRun through repeated
% calls to pushbuttonStartNextIndex, but that (updated) S never outputs
% here.

setupFigure(S); % draw a number of list boxes and display fixed text
S = listOfAllExperiments(S); 
uiwait(S.fh);  % everything set up now. wait for button pushes or exit.
% END OF PROGRAM %
if S.enableMultiThread; delete(gcp); end % important to turn off multithreading; if crashed, will need to manually stop this!
synapseDisconnect(S.syn); % disconnect from synapse


% videoMovementScoreByGridSynapse(animalName,formatDateFive)
% if ~isempty(S.exptIndexLast') % this will import the last expt recorded before exiting.
%     [date,indexLast] = fixDateIndexToFiveForSynapse(S.exptDate,S.exptIndexLast);
%     synapseImportingPathway(date,indexLast,S.recordingComputer,S.recordingComputerSubfolder);
% end
% ! TODO ! %!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! We may want to run fileMaint (when finished as a function)
% before exiting to be sure we've copied, imported, and analyzed everything
% for the day.  We could then use this point to run analyses that use the
% whole day. . . . and upload plots to Slack?!? . . . or add this day to a
% dynamic summary plot (with statistical power calculations!).


function [S] = pushbuttonStartNextIndex(varargin)
S = varargin{3};
if isempty(S.ExperimentsRemaining.exptDescriptionText)
    % the following three lines should be part of a seperate sequence
    % (they're already found in createNotebookEntry), but for now, we'll
    % set these up to run the last import before exiting.
    lastEntryID = fetchAdjust(S.dbConn,'SELECT MAX(exptID) FROM masterexpt');
    exptDate = fetchAdjust(S.dbConn,['SELECT exptDate FROM masterexpt WHERE exptID=' num2str(lastEntryID{1})]);
    exptIndex = fetchAdjust(S.dbConn,['SELECT exptIndex FROM masterexpt WHERE exptID=' num2str(lastEntryID{1})]);
    synapseImportingPathway(exptDate,exptIndex,S.recordingComputer,S.recordingComputerSubfolder);
    uiresume(S.fh);
    return;   %stop user from running nothing.
end
userListSelection = get(S.ls,'Value'); % Get the user's choice.
S.nExptsRecordedToday = S.nExptsRecordedToday+1;
S.listOfExperimentsRunToday{S.nExptsRecordedToday} = S.ExperimentsRemaining.exptDescriptionText{userListSelection};
S.tempnTrials = S.ExperimentsRemaining.nTrialsIndexArray(userListSelection);
S.tempnStims = S.ExperimentsRemaining.nStimsIndexArray(userListSelection);
S.ExperimentsRemaining.exptDescriptionText(userListSelection) = []; % remove the user selected expt from list
S.ExperimentsRemaining.nTrialsIndexArray(userListSelection) = []; % remove the user selected expt parameters from list
S.ExperimentsRemaining.nStimsIndexArray(userListSelection) = []; % remove the user selected expt parameters from list
S = refreshExptRemainingToBeRun(S);
updateDynamicDisplayBox('Creating new notebook entry');
S = createNewNotebookEntry(S); % create notebook entry
pause(.5);
% !!!TODO!!! % shut off other buttons?
updateDynamicDisplayBox('loading in parameter set');
S = parameterCreationProcess(S); % create a parameter set and load it in. This starts recording and playing sequence automatically.
% Here we use parallel computing to run a command to setup (and wait for)
% next expt while it analyzes the last one.
[date,~] = fixDateIndexToFiveForSynapse(S.exptDate,S.exptIndex);
if ~isempty(S.exptIndexLast')
    [~,indexLast] = fixDateIndexToFiveForSynapse(S.exptDate,S.exptIndexLast);
else
    indexLast = '-1'; %this will hand synapseImportingPathway a -1 val
    % if we haven't run anything previously today which will tell it to
    % skip analysis
end

if ~isempty(strfind(S.animalName,'LFP'))
    sponTime = 610;
elseif ~isempty(strfind(S.animalName,'EEG'))
    sponTime = 3610;
else
    disp('I hope you didn''t plan to run any spontaneous recordings...')
    sponTime = 610;
end


if S.enableMultiThread % this will make program unavailable until *both* 1 and 2 are finished completely.
    parfor i = 1:2
        if i == 1
            synapseRecordingPathway(S.syn,S.tempnStims,S.tempnTrials,sponTime); %#ok<*PFBNS>
            disp(['Recording ' date ' ' S.exptIndex ' finished']);
        else
            synapseImportingPathway(date,indexLast,S.recordingComputer,S.recordingComputerSubfolder);
            disp(['Importing ' date ' ' indexLast{1} ' finished']);
        end
    end
else
    % will take too long to analyze in sequence if we're not running parallel threads
    synapseRecordingPathway(S.syn,S.tempnStims,S.tempnTrials,sponTime);
    %synapseImportingPathway(date,indexLast,recordingComputer,subfolder); 
end
updateDynamicDisplayBox('finished recording!','black');
pause(1);
updateDynamicDisplayBox('','black');
pause(1);
updateDynamicDisplayBox('Refreshing lists');
% refresh all lists and the pushbutton.
S = refreshExptRemainingToBeRun(S);
S = refreshIndicesCompletedToday(S);
S = listOfAllExperiments(S);
updateDynamicDisplayBox('','black');


function synapseRecordingPathway(varargin)
synapseObj = varargin{1};
tempnStims = varargin{2};
tempnTrials = varargin{3};
sponTime = varargin{4};
% synapseObj = S.syn
% tempnStims = S.tempnStims
% tempnTrials = S.tempnTrials
% sponTime = sponTime
waitingForUserToFinishRecording = true;
updateDynamicDisplayBox('waiting for recording to complete');
% spontaneous mode
% TODO % may want to allow time adjustments
if tempnStims == -1 % represents 'spontaneous' mode
    tic
    while waitingForUserToFinishRecording
        elapsedTime = toc;
        %pause(sponTime); % this will wait 10 minutes before proceeding (for spon mode)
        % !!TODO!! % make this a parameter, setting, or something other than a
        % hard-coded number!!
        if (elapsedTime > sponTime) || (synapseObj.getMode ~= 3)
            waitingForUserToFinishRecording = false;
            synapseObj.setMode(0);
        end
        pause(1);
    end
end
% evoked / stimulation mode
while waitingForUserToFinishRecording
    progress = synapseObj.getParameterValue('ParSeq1','Progress'); % this will return which trial the sequence is in.
    % at the end of the trials, it will return 0
    pause(2); % scan the server every 2 seconds.  pause here (instead of end) so that at least 2 seconds of recording goes by after sequence finishes
    if progress == 0
        synapseObj.setMode(0);
        waitingForUserToFinishRecording = false;
    end
end


function synapseImportingPathway(varargin)
% test block:
% [date,index] = fixDateIndexToFiveForSynapse(S.exptDate,S.exptIndex);
% date = '18821'
% index = '001'
% synapseImportingPathway(date,indexLast,recordingComputer,subfolder);
% recordingComputer = '144.92.237.187';
% subfolder = '\c\Data\';

% TODO % add error handling so if a single day doesn't analyze we don't shit ourselves
date = varargin{1};
index = varargin{2}; %this is set to the previous index (see call)
recordingComputer = varargin{3};
subfolder = varargin{4};
if ~isempty(strfind(index,'-1')); return; end; % don't run on first index - if nothing has been run today yet.
dirStrRecSource = ['\\' recordingComputer subfolder '20' date(1:2) '\' date '-' index '\'];
% TODO %  the following shouldn't be hard coded as they are.  Pass as parameters to synapseImportingPathway
dirStrRawData = ['W:\Data\PassiveEphys\' '20' date(1:2) '\' date '-' index '\'];
dirStrAnalysis = ['M:\PassiveEphys\' '20' date(1:2) '\' date '-' index '\'];
% MOVE RECORDED DATA TO RAW %
moveDataRecToRaw(dirStrRecSource,dirStrRawData); % move recorded files to raw data server
% IMPORT DATA % 
dirCheck = dir([dirStrAnalysis '*data*']); % check to see if ephys info is imported
if isempty(dirCheck)
    display('Handing info to existing importData function.  This will take a few minutes.');
    importDataSynapse(date,index)
else
    display('Data already imported.');
end
% MOVIES: grid, prep % 
vidFile = dir([dirStrRawData '*.avi']); % simplified version for Synapse
if isempty(vidFile)
    error('video file not found!  This program expects video!')
end
vidFilePath = [dirStrRawData vidFile.name];
repeatedAttempts = 1;
maxAttempts = 4;
if isempty(dir([dirStrAnalysis '*-framegrid.mat']))
    while repeatedAttempts < maxAttempts
        try
            display('attempting to run mmread on video...')
            videoFrameGridMakerSynapse(vidFilePath);
            repeatedAttempts = maxAttempts;
        catch
            display(['mmread is slightly unstable.  Let''s try ' num2str(maxAttempts-repeatedAttempts) ' more times.' ])
            repeatedAttempts = repeatedAttempts+1;
        end
    end
end


function [S] = parameterCreationProcess(varargin) 
S = varargin{1};
sequenceUpdated = false;
countX = 1;
while ~sequenceUpdated
    csvAssembler(S.exptDate,S.exptIndex,S.tempnStims,S.tempnTrials); %setup trial file (writes to folder)
    [date,index] = fixDateIndexToFiveForSynapse(S.exptDate,S.exptIndex); % need to set tank name here if we're going to just start recording!
    pause(1);
    S.syn.setCurrentBlock([date '-' index]); % update and send parameters to Synapse
    S.syn.setMode(3); % recording set to auto start (3 is rec).
    pause(2); % reduced this from 4 8/30/18
    seqList = S.syn.getParameterValues('ParSeq1','SequenceFileList');
    result = 0;
    if iscell(seqList) % do we need to check this?
        for iList = 1:length(seqList)
            [exptDate,exptIndex] = fixDateIndexToFiveForSynapse(S.exptDate,S.exptIndex);
            if ~isempty(strfind([exptDate '-' exptIndex],seqList{iList}))
                result = S.syn.setParameterValue('ParSeq1','SequenceFileIndex',iList-1); %index starts at 0
                
            end
        end
    end
    if result == 0
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
        pause(1);
        updateDynamicDisplayBox(['Starting sequence!']); 
        S.syn.setParameterValue('ParSeq1','Reset',0); % do we need to check to see if it's spon rec?  this may reset recording
        
        sequenceUpdated = true;
    end
    countX = countX+2;
end
% auto start seq here? !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!


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
        S.pb = uicontrol('style','push',...
        'units','pix',...
        'posit',[270 650 120 30],...
        'string', 'connect!',...
        'fontsize',10,...
        'callback',{@synapseReconnect,S});
    end
    try
        if ~isempty(strfind({'Idle', 'Standby', 'Preview', 'Record'},S.syn.getModeStr()))
            S.syn.setMode(2); % switch between states to test connectivity
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
% S.recordingComputer = '144.92.237.187';
S.syn = SynapseAPI(S.recordingComputer);
function [S] = synapseReconnect(varargin)
S = varargin{3};
S.syn = SynapseAPI(S.recordingComputer);
function synapseDisconnect(varargin)
synapseObj = varargin{1};
synapseObj.delete();

function [S] = createNewNotebookEntry(varargin)
S = varargin{1};
exptDescTemp = S.listOfExperimentsRunToday{S.nExptsRecordedToday};



[S.exptDate,S.exptIndex,S.exptIndexLast] = createNewNotebookEntryTDT(exptDescTemp,S.animalName);

% lastEntryID = fetch(S.dbConn,'SELECT MAX(exptID) FROM masterexpt');
% hardware = 'TDT'; %this is always a TDT specific program.
% grandExpt = 'PassiveEphys'; %this is another assumption
% animalID = fetch(S.dbConn,['SELECT animalID FROM animals WHERE animalName=''' S.animalName '''']);
% exptDate = fetch(S.dbConn,['SELECT exptDate FROM masterexpt WHERE exptID=' num2str(lastEntryID{1})]);
% exptIndex = fetch(S.dbConn,['SELECT exptIndex FROM masterexpt WHERE exptID=' num2str(lastEntryID{1})]);
% experimenterID = fetch(S.dbConn,['SELECT experimenterID FROM masterexpt WHERE exptID= ''' num2str(lastEntryID{1}) '''']);
% % check date, make sure if date is different index is reset
% if isequal(houseTodayDateIn_dbForm,exptDate{1})
%     S.exptIndexLast = exptIndex{1};
%     S.exptDate = exptDate{1};
%     S.exptIndex = exptIndex{1}+1;
% else
%     S.exptDate = houseTodayDateIn_dbForm;
%     S.exptIndex = 0;
%     S.exptIndexLast = [];
% end
% thisID = lastEntryID{1}+1;
% % == Add the main information
% addNotebookEntry = ['INSERT INTO masterexpt (exptIndex, hardware, grandExpt,'...
%     'exptDate, animalID, experimenterID) VALUES (' num2str(S.exptIndex) ','''...
%     hardware ''',''' grandExpt ''',''' S.exptDate ''',' num2str(animalID{:})...
%     ',' num2str(experimenterID{:}) ')'];
% % == Add the details
% SQLdetail_ephys = fetch(S.dbConn,['SELECT * FROM detail_ephys WHERE exptID= ''' num2str(lastEntryID{1}) '''']);
% exptID = num2str(thisID);
% if ~isempty(SQLdetail_ephys)
%     filter_lowcut = num2str(SQLdetail_ephys{3});
%     filter_highcut = num2str(SQLdetail_ephys{4});
%     amp_gain = num2str(SQLdetail_ephys{5});
%     sample_freq = num2str(SQLdetail_ephys{6});
%     chamber = num2str(SQLdetail_ephys{7});
%     headstage = num2str(SQLdetail_ephys{8});
%     preamp = num2str(SQLdetail_ephys{10});
%     spkrCenter = num2str(SQLdetail_ephys{13});
%     recordingBox = num2str(SQLdetail_ephys{14});
% else  %defaults... not sure if this is correct
%     filter_lowcut = '0.2';
%     filter_highcut = '8545'; % default
%     amp_gain = '1'; % according to TDT, Synapse output is saved at 'unity' gain
%     sample_freq = '24414'; % default
%     chamber = 'Bottom';
%     headstage = 'ZC16';
%     preamp = 'PZ5';
%     spkrCenter = 'blank';
%     recordingBox = 'blank';
% end
% addDetailEphys = ['INSERT INTO detail_ephys (exptID,filter_lowcut,filter'...
%     '_highcut,amp_gain,sample_freq,chamber,headstage,preamp,spkrCenter,'...
%     'recordingBox) VALUES (' exptID ',' filter_lowcut ...
%     ',' filter_highcut ',' amp_gain ','...
%     sample_freq ',''' chamber ''','''...
%     headstage ''',''' preamp ''','''...
%     spkrCenter ''',''' recordingBox ''')'];
% addDescription = ['UPDATE masterexpt SET notebookDesc= ''' ...
%     exptDescTemp ''' WHERE exptID= '''...
%     num2str(thisID) ''''];
% display(['Description will be: ' exptDescTemp ' Be sure you are happy with that']);
% %! we're editing the notebook here!!! be careful when changing syntax!
% exec(S.dbConn,addNotebookEntry);
% exec(S.dbConn,addDetailEphys);
% exec(S.dbConn,addDescription);

function updateDynamicDisplayBox(textI,colorI)
%handy way to update diplay text
if ~exist('colorI','var')
    colorI = 'black';
end
uicontrol('style','text',...
    'units','pix',...
    'position',[320 570 300 50],...
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
