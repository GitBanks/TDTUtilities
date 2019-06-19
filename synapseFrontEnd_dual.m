function [] = synapseFrontEnd_dual
% FOR DUAL RECORDING DUMMY!

% test inputs
% animalName = 'EEG85'

% This GUI will allow user to select an experiment type for two animals
% for which the program will create all expected indices
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
% 2019, Banks Lab, Sean Grady & Ziyad Sultan.

% WIP: check code for % TODO % or % !!! TODO !!! % for different levels of
% urgency to make the program better

% TODO % add 'config' file that allows parameters, file locations, and general lab changes to be centrally located.

% ! TODO ! %  add a check to see if we can connect to recording computer path (sometimes network logs us out!) otherwise we can't guarantee importing will work consistantly
% example path: \\144.92.237.187\c\Data\2018\
S.enableMultiThread = 1; % for testing or using without parfor, set to 0
S.recordingComputer = '144.92.237.183'; %'\\ANESBL2'; %
S.recordingComputerSubfolder = '\Data\PassiveEphys\';%'\c\Data\';
S.dbConn = dbConnect();

[S.livingAnimals,S.livingAnimalsID] = getLivingAnimals; % get list of living animals for user to select

% TODO % add nHoursPre to the GUI as a toggle or parameter
S.nHoursPre = 2; %1 % refers to number of hours pre time zero manipulation. We will set this to '2' if making two injections.
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
    'position',[100 100 900 700],...
    'menubar','none',...
    'numbertitle','off',...
    'name','Experiment Day Setup',...
    'resize','off');  
% Left chamber
S.aa(1) = uicontrol('style','pop',...
    'unit','pix',...
    'position',[50 600 120 20],...
    'string',S.livingAnimals); 
uicontrol('style','text',...
    'units','pix',...
    'position',[45 620 130 20],...
    'fontweight','bold',...
    'string','Left Chamber (Cam2)');

% Right chamber
S.aa(2) = uicontrol('style','pop',...
    'unit','pix',...
    'position',[275 600 120 20],...
    'string',S.livingAnimals);
uicontrol('style','text',...
    'units','pix',...
    'position',[270 620 130 20],...
    'fontweight','bold',...
    'string','Right Chamber (Cam1)');

updateDynamicDisplayBox('Starting Synapse');
S = synapseConnectionProcess(S); % Start Synapse, connect to recording computer            
S.Preselects = {'Saline','LPS','ISO','Ketamine','CNO','Minocycline','a5 Inverse Agonist','Piroxicam'}; 

% LEFT
S.pp(1) = uicontrol('style','pop',...
    'unit','pix',...
    'position',[50 570 120 20],...
    'string',S.Preselects); 
% RIGHT
S.pp(2) = uicontrol('style','pop',...
    'unit','pix',...
    'position',[275 570 120 20],...
    'string',S.Preselects); 

S.pb = uicontrol('style','push',...
    'units','pix',...
    'posit',[49 540 150 20],...
    'string', 'Setup both experiments',...
    'fontsize',10,...
    'callback',{@setupExpt,S});
% !TODO! %
% 9/10/18: Issue discovered when trying to run 'synapseImportingPathway' at
% the end, after this point.  The structure 'S' looks like it's updated
% between setupExptToBeRun and refreshExptRemainingToBeRun through repeated
% calls to pushbuttonStartNextIndex, but that (updated) S never outputs
% here.

setupFigure(S); % draw a number of list boxes and display fixed text

uiwait(S.fh);  % everything set up now. wait for button pushes or exit.
% END OF PROGRAM %
if S.enableMultiThread; delete(gcp); end % important to turn off multithreading; if crashed, will need to manually stop this!
synapseDisconnect(S.syn); % disconnect from synapse


% ! TODO ! %!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! We may want to run fileMaint (when finished as a function)
% before exiting to be sure we've copied, imported, and analyzed everything
% for the day.  We could then use this point to run analyses that use the
% whole day. . . . and upload plots to Slack?!? . . . or add this day to a
% dynamic summary plot (with statistical power calculations!).


function [S] = pushbuttonStartNextIndex(varargin)
S = varargin{3};
if isempty(S.ExperimentsRemaining(1).exptDescriptionText) %does it matter if I hardcode here?
    % the following three lines should be part of a seperate sequence
    % (they're already found in createNotebookEntry), but for now, we'll
    % set these up to run the last import before exiting.
    lastEntryID = fetchAdjust(S.dbConn,'SELECT MAX(exptID) FROM masterexpt');
    exptDate = fetchAdjust(S.dbConn,['SELECT exptDate FROM masterexpt WHERE exptID=' num2str(lastEntryID{1})]);
    exptIndex = fetchAdjust(S.dbConn,['SELECT exptIndex FROM masterexpt WHERE exptID=' num2str(lastEntryID{1})]);
    synapseImportingPathway(exptDate,exptIndex,S.recordingComputer,S.recordingComputerSubfolder,S);
    uiresume(S.fh);
    return;   %stop user from running nothing.
end
userListSelection(1) = get(S.ls_left,'Value'); % Get the user's choice for the left cage.
userListSelection(2) = get(S.ls_right,'Value'); % Get the user's choice for the right cage.
S.nExptsRecordedToday = S.nExptsRecordedToday+1;

for iList = 1:length(userListSelection)
    S.listOfExperimentsRunToday{iList,S.nExptsRecordedToday} = S.ExperimentsRemaining(iList).exptDescriptionText{userListSelection(iList)};
    S.tempnTrials(iList) = S.ExperimentsRemaining(iList).nTrialsIndexArray(userListSelection(iList));
    S.tempnStims(iList) = S.ExperimentsRemaining(iList).nStimsIndexArray(userListSelection(iList));
    S.ExperimentsRemaining(iList).exptDescriptionText(userListSelection(iList)) = []; % remove the user selected expt from list
    S.ExperimentsRemaining(iList).nTrialsIndexArray(userListSelection(iList)) = []; % remove the user selected expt parameters from list
    S.ExperimentsRemaining(iList).nStimsIndexArray(userListSelection(iList)) = []; % remove the user selected expt parameters from list
end

S = refreshExptRemainingToBeRun(S);
updateDynamicDisplayBox('Creating new notebook entry');
S = createNewNotebookEntry(S); % create notebook entry
pause(.5);
% !!!TODO!!! % shut off other buttons?

disp(['notebook ' S.exptDate{1} ', index ' num2str([S.exptIndex{:}]) ' made, and ' sprintf('%s,',S.exptIndexLast{:}) ' will be analyzed']);

updateDynamicDisplayBox('loading in parameter set');
S = parameterCreationProcess(S); % create a parameter set and load it in. This starts recording and playing sequence automatically.
% Here we use parallel computing to run a command to setup (and wait for)
% next expt while it analyzes the last one.


% [date{1,1},~] = fixDateIndexToFiveForSynapse(S.exptDate,S.exptIndex);
if ~isempty(S.exptIndexLast')
    [date,indexLast{1}] = fixDateIndexToFiveForSynapse(S.exptDate{1},S.exptIndexLast{1});
    [~,indexLast{2}] = fixDateIndexToFiveForSynapse(S.exptDate{1},S.exptIndexLast{2});
else
    indexLast = '-1'; %this will hand synapseImportingPathway a -1 val
    % if we haven't run anything previously today which will tell it to
    % skip analysis
end

if ~isempty(strfind(S.animalName{1},'LFP'))
    sponTime = 610;
elseif ~isempty(strfind(S.animalName{1},'EEG'))
    sponTime = 3610;
else
    disp('I hope you didn''t plan to run any spontaneous recordings...')
    sponTime = 610;
end

if S.enableMultiThread % this will make program unavailable until *both* 1 and 2 are finished completely.
    parfor i = 1:2
        if i == 1
            synapseRecordingPathway(S.syn,S.tempnStims(1),S.tempnTrials(1),sponTime); %#ok<*PFBNS>
            disp(['Recording ' date ' ' num2str(S.exptIndex{:,1}) ' finished']);
        else
            blockLocation = [date '-' indexLast{1}];
            synapseImportingPathway(date,indexLast{1},S.recordingComputer,S.recordingComputerSubfolder,blockLocation);
            disp(['Importing ' date ' index ' indexLast{1} ' finished']);
            synapseImportingPathway(date,indexLast{2},S.recordingComputer,S.recordingComputerSubfolder,blockLocation);
            disp(['Importing ' date ' index ' indexLast{2} ' finished']);
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
dateX = varargin{1};
index = varargin{2}; %this is set to the previous index (see call)
recordingComputer = varargin{3}; %'ANESBL2'; hotfix 4/23/2019 ZS
subfolder = varargin{4};
blockLocation = varargin{5}; %added 6/18
if ~isempty(strfind(index,'-1')); return; end; % don't run on first index - if nothing has been run today yet.
dirStrRecSource = ['\\' recordingComputer subfolder '20' dateX(1:2) '\' dateX '-' index '\'];
% TODO %  the following shouldn't be hard coded as they are.  Pass as parameters to synapseImportingPathway
dirStrRawData = ['W:\Data\PassiveEphys\' '20' dateX(1:2) '\' dateX '-' index '\'];
% dirStrAnalysis = ['M:\PassiveEphys\' '20' date(1:2) '\' date '-' index '\'];
dirStrAnalysis = ['\\MEMORYBANKS\Data\PassiveEphys\' '20' dateX(1:2) '\' dateX '-' index '\'];
% MOVE RECORDED DATA TO RAW %
try
    moveDataRecToRaw(dirStrRecSource,dirStrRawData); % move recorded files to raw data server
catch
    warning('moveDataRecToRaw failed to run.');
end
% IMPORT DATA % 
dirCheck = dir([dirStrAnalysis '*data*']); % check to see if ephys info is imported
if isempty(dirCheck)
    display('Handing info to existing importData function.  This will take a few minutes.');
    importDataSynapse_dual(dateX,index,blockLocation);  %WARNING: blockLocation is assigned to the date-index associated with the "left" cage data stream. 
else
    display('Data already imported.');
end
% % MOVIES: grid, prep % 


function [S] = parameterCreationProcess(varargin) 
S = varargin{1};
sequenceUpdated = false;
countX = 1;
while ~sequenceUpdated
    
    csvAssembler(S.exptDate{1},S.exptIndex{1},S.tempnStims(1),S.tempnTrials(1)); %setup trial file (writes to folder)
    
    [date,index] = fixDateIndexToFiveForSynapse(S.exptDate{1},S.exptIndex{1}); % need to set tank name here if we're going to just start recording!
%     S.blockLocation = [date '-' index];
    pause(1);
    S.syn.setCurrentBlock([date '-' index]); % update and send parameters to Synapse
    S.syn.setMode(3); % recording set to auto start (3 is rec).
    pause(2); % reduced this from 4 8/30/18
    
    if ~isempty(strfind(S.animalName{1},'EEG')) % Assumes both animals are EEG!!!!!!!!!!!!!!!!!!!!!!
        result = 1;
    else
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
        updateDynamicDisplayBox('Starting sequence!'); 
        S.syn.setParameterValue('ParSeq1','Reset',0); % do we need to check to see if it's spon rec?  this may reset recording
        sequenceUpdated = true;
    end
    countX = countX+1;
    
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
for iList = 1:length(S.listOfExperimentsRunToday)
    exptDescTemp{iList} = S.listOfExperimentsRunToday{iList,S.nExptsRecordedToday};
    [S.exptDate{iList},S.exptIndex(iList),S.exptIndexLast{iList}] = createNewNotebookEntryTDT(exptDescTemp{iList},S.animalName{iList});
end

function updateDynamicDisplayBox(textI,colorI)
%handy way to update diplay text
if ~exist('colorI','var')
    colorI = 'black';
end
uicontrol('style','text',...
    'units','pix',...
    'position',[50 100 150 50],...
    'ForegroundColor',colorI,...
    'string', textI,...
    'fontsize',10);

function [S] = listOfAllExperiments(varargin)
[S] = varargin{1}; % !can't call this as a callback!
%find list of experiments already run
S.existingList = [];
for ii = 1:length(S.animalName)
    tempList = getExperimentsByAnimal(S.animalName{ii});
    
    for jj = 1:size(tempList,1)
        tempList{jj,2} = {[S.animalName{ii} ': ' char(tempList{jj,2})]};
    end
    S.existingList = vertcat(S.existingList,tempList);
    clear tempList
end

S.existingList = flip(S.existingList);  %flip to show latest
S.existingListHand = uicontrol('style','list',...
    'units','pix',...
    'position',[500 10 320 610],...
    'string', [S.existingList{:,2}],...
    'fontsize',10);

function [S] = refreshIndicesCompletedToday(varargin)
[S] = varargin{1}; % !can't call this as a callback!
% refresh today's finished experiments
S.listFromToday = uicontrol('style','list',...
    'units','pix',...
    'position',[275 205 320 200],...205 120 20
    'string', S.listOfExperimentsRunToday,...
    'fontsize',10);


function [S] = setupExpt(varargin)
% not in 'setup' because it could get called again (planned drop down menu)
% if the user wants to reset the day.
[S] = varargin{3};
for iAnimal = 1:length(S.pp)
    S.experimentDrugManipulation(iAnimal) = get(S.pp(iAnimal),'Value'); % Get the user's choice.
    S.experimentDrugName{iAnimal} = S.Preselects{S.experimentDrugManipulation(iAnimal)};
    disp(['Setting up ' S.experimentDrugName{iAnimal} ' experiment.']);
    
    S.animalNumber(iAnimal) = get(S.aa(iAnimal),'Value'); % Get the user's choice.
    S.animalName{iAnimal} = S.aa(iAnimal).String{S.animalNumber(iAnimal)};
    disp(['Setting up '  S.animalName{iAnimal} ' experiment.']);
    
    %synapseExptSetup sets up all the indices
    S.Experiment(iAnimal) = synapseExptSetup(S.animalName{iAnimal},S.experimentDrugName{iAnimal},S.nHoursPre,S.nHoursPost); 
    S.ExperimentsRemaining(iAnimal) = S.Experiment(iAnimal);
end
S = listOfAllExperiments(S);
setupExptToBeRun(S);

function [S] = setupExptToBeRun(varargin)
%setupExptToBeRun sets up experiment for the day based on selection from
%list, then button press
[S] = varargin{1}; % !can't call this as a callback!
S.ls_left = uicontrol('style','list',...
    'units','pix',...
    'position',[50 235 200 300],...
    'string', S.Experiment(1).exptDescriptionText,...
    'fontsize',10);

S.ls_right = uicontrol('style','list',...
    'units','pix',...
    'position',[275 235 200 300],...
    'string', S.Experiment(2).exptDescriptionText,...
    'fontsize',10);
%NOTE: make sure to disable setupThisExpt!!!!!!

S.pb_index = uicontrol('style','push',...
    'units','pix',...
    'posit',[49 205 120 20],... % we want to overwrite last button (to avoid repeating/changing a list) was% 'posit',[405 650 120 30],
    'string', 'Setup next index',...
    'fontsize',10,...
    'callback',{@pushbuttonStartNextIndex,S});

function [S] = refreshExptRemainingToBeRun(varargin)
%refreshExptRemainingToBeRun is separate, getting smaller as we step
%through the workflow
[S] = varargin{1}; 
S.ls_left = uicontrol('style','list',...
    'units','pix',...
    'position',[50 235 200 300],...
    'string', S.ExperimentsRemaining(1).exptDescriptionText,...
    'fontsize',10);
S.ls_right = uicontrol('style','list',...
    'units','pix',...
    'position',[275 235 200 300],...
    'string', S.ExperimentsRemaining(2).exptDescriptionText,...
    'fontsize',10);
S.pb_index = uicontrol('style','push',...
    'units','pix',...
    'posit',[49 205 120 20],... % we want to overwrite last button (to avoid repeating/changing a list) was% 'posit',[405 650 120 30],
    'string', 'Setup next index',...
    'fontsize',10,...
    'callback',{@pushbuttonStartNextIndex,S});

% % % SETUP % % %
function [S] = setupFigure(varargin)
% just a bunch of figure setup that should exist for the entire program
S = varargin{1};
%'position',[xPos yPos width height]
% uicontrol('style','text',...
%     'units','pix',...
%     'position',[320 600 300 40],...
%     'fontweight','bold',...
%     'string','Status');
uicontrol('style','text',...
    'units','pix',...
    'position',[500 600 320 40],...
    'fontweight','bold',...
    'string','Finished Indices - all time');
% uicontrol('style','text',...
%     'units','pix',...
%     'position',[10 600 300 40],...
%     'fontweight','bold',...
%     'string','Experiments remaining to run today');
% uicontrol('style','text',...
%     'units','pix',...
%     'position',[320 530 300 40],...
%     'fontweight','bold',...
%     'string','Completed experiments across animals'); 
S.existingListHand = uicontrol('style','list',...
    'units','pix',...
    'position',[500 10 320 325],... 
    'string', '',...
    'fontsize',10);
% S.ls = uicontrol('style','list',...
%     'units','pix',...
%     'position',[10 10 300 610],...
%     'string', '',...
%     'fontsize',10);
% S.listFromToday = uicontrol('style','list',...
%     'units','pix',...
%     'position',[320 10 300 540],...
%     'string', '',...
%     'fontsize',10);
