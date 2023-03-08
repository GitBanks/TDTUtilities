function fileMaint(animal)
% A utility to run that replicates the import data pathway in synapseFrontEnd
% NOTE: this will just run through all applicable analyses.  If notebook
% description information is incorrect (stim/resp listed when there is none) 
% it will very likely fail.

% === test parameters
% animal = 'ZZ10';
% animal = 'ZZ09';

% === override and analysis toggle parameters - change rarely
forceReimport = 0; % change this to 1 if you've messed up the noise thresholding in some way - remember to change it back!
runMagnetDataSaving = 1;

% === establish a clean list of all experiments we're interested in
listOfAnimalExpts = getExperimentsByAnimal(animal);
descOfAnimalExpts = listOfAnimalExpts(:,2);
listOfAnimalExpts = listOfAnimalExpts(:,1);

% === before full automation, we can use this to set drug or eStim parameters 
% in the DB
manuallySetGlobalParamUI(animal); 

% === verify the electrode information has been entered correctly.  This is a
% local function within FileMaint, below
[electrodeLocation] = checkElectrode(listOfAnimalExpts{1}(1:5),listOfAnimalExpts{1}(7:9),animal);

% === Set paths
path.dirStrAnalysisROOT = [mousePaths.M 'PassiveEphys\']; % 'M' drive
%dirStrRecSourceAROOT = '\\144.92.237.187\Data\PassiveEphys\'; %Nessus
%path.dirStrRecSourceAROOT = '\\144.92.237.183\Data\PassiveEphys\'; %Gilgamesh
path.dirStrRecSourceAROOT = ['\\' getPathGlobal('REC') '\Data\PassiveEphys\']; % fake Gilgamesh (21708, it's broken today)
path.dirStrRecSourceBROOT = ['\\' getPathGlobal('REC') '\Data\PassiveEphys\']; % only point to the only REC computer we use, for now (2/28/23)
%path.dirStrRecSourceBROOT = '\\144.92.237.187\Data\PassiveEphys\'; %Nessus we dont use this computer
path.dirStrRawDataROOT = [mousePaths.W 'PassiveEphys\']; %'W' drive
path.dirStrServer = '\\144.92.237.180\Users\'; %Helmholz

% === check network connections
% we often have network connection issues.  Handle that verification here,
% so later errors aren't confusing.  checkConnection is a local function.
checkConnection(path.dirStrAnalysisROOT);
checkConnection(path.dirStrRecSourceAROOT);
checkConnection(path.dirStrRecSourceBROOT); % we used to use a try/catch for if one computer isn't hooked up, but it will just stall out in any case...  either add some reasonable timeout checks, or just accept the error it will throw here.  
checkConnection(path.dirStrRawDataROOT);
checkConnection(path.dirStrServer);

% === create a list of what needs to be done
% the idea of this table is that if tasks are 'done', the logical should
% evaluate 'true'.  The exception is video files - sometimes there's no video
sz = [length(listOfAnimalExpts) 8];
varTypes = {'string','string','logical','logical','string','logical','logical','logical'};
varNames = {'DateIndex','Description','Imported','Magnets','videoDone','RECAEmpty','RECBEmpty','needStimResp'};
exptTable = table('Size',sz,'VariableTypes',varTypes,'VariableNames',varNames);
for iList = 1:length(listOfAnimalExpts)
    exptTable.Description(iList) = descOfAnimalExpts{iList}{1};
    date = listOfAnimalExpts{iList}(1:5);
    index = listOfAnimalExpts{iList}(7:9);
    [dirStrAnalysis,dirStrRawData,dirStrRecSourceA,dirStrRecSourceB] = getPaths(path,date,index);
    exptTable.DateIndex(iList) = [date '-' index];
    % === are the raw data moved yet?
    if isempty(dir(dirStrRecSourceA))
        exptTable.RECAEmpty(iList) = true;
    end
    if isempty(dir(dirStrRecSourceB))
        exptTable.RECBEmpty(iList) = true;
    end
    % === are data imported?
    if ~isempty(dir([dirStrAnalysis '*data*'])) || forceReimport
        exptTable.Imported(iList) = true;
    else
        exptTable.Imported(iList) = false;
    end
    % === do we need to run a stim response curve?
    if contains(exptTable.Description(iList),'stim/resp') && isempty(dir([dirStrAnalysis '*_peakData*']))
        exptTable.needStimResp(iList) = true;
    else
        exptTable.needStimResp(iList) = false;
    end
    % === are magnet data imported? 
    [exptTable] = magnetFileScan(dirStrAnalysis,exptTable,iList); % local function below
    % === is video analyzed (if it exists)?
    [exptTable] = videoFileScan(dirStrRawData,dirStrAnalysis,exptTable,iList); % local function below
end   

% === MOVE TDT TANK FILE TO W DRIVE
operatingList = exptTable.DateIndex(exptTable.RECAEmpty == false);
for iList = 1:length(operatingList)
    date = operatingList{iList}(1:5);
    index = operatingList{iList}(7:9);
    [~,dirStrRawData,dirStrRecSourceA,~] = getPaths(path,date,index);
    disp(['Found REC data to MOVE to W for ' date '-' index ]);
    try
        moveDataRecToRaw(dirStrRecSourceA,dirStrRawData);
    catch
        disp('moveDataRecToRaw failed.');
    end
end
operatingList = exptTable.DateIndex(exptTable.RECBEmpty == false);
for iList = 1:length(operatingList)    
    date = operatingList{iList}(1:5);
    index = operatingList{iList}(7:9);
    [~,dirStrRawData,~,dirStrRecSourceB] = getPaths(path,date,index);
    disp(['Found REC data to MOVE to W for ' date '-' index ]);
    try
        moveDataRecToRaw(dirStrRecSourceB,dirStrRawData);
    catch
        disp('moveDataRecToRaw failed.');
    end
end

% === CONVERT FROM TDT TANK FILE TO MATLAB FORMAT, SAVE TO MEMORY BANKS
operatingList = exptTable.DateIndex(exptTable.Imported == false);
for iList = 1:length(operatingList)    
    date = operatingList{iList}(1:5);
    index = operatingList{iList}(7:9);
    [tankDate,tankIndex] = getIsTank(date,index);
    disp(['Found Raw data to IMPORT from W to mat format on M at ' date '-' index ]);
    importDataSynapse_dual(date,index,[tankDate '-' tankIndex]);
end


% === CHECK FOR MAGNET DATA, SAVE TO MEMORY BANKS
operatingList = exptTable.DateIndex(exptTable.Magnets == false);
for iList = 1:length(operatingList)
    date = operatingList{iList}(1:5);
    index = operatingList{iList}(7:9);
    [tankDate,tankIndex] = getIsTank(date,index);
    [dirStrAnalysis,dirStrRawData,~,~] = getPaths(path,date,index);
    tankPath = [path.dirStrRawDataROOT '20' date(1:2) '\' tankDate '-' tankIndex '\'];
    saveMagnetDataFiles(dirStrRawData,tankPath,dirStrAnalysis);
end
% since we may have moved and analyzed a few things we can re-establish our list
for iList = 1:length(listOfAnimalExpts)
    [dirStrAnalysis,~,~,~] = getPaths(path,date,index);
    [exptTable] = magnetFileScan(dirStrAnalysis,exptTable,iList);
end

% === RUN THE MAGNET EVENT VERIFIER, SAVE TO MEMORY BANKS\
if runMagnetDataSaving
operatingList = exptTable.DateIndex(exptTable.Magnets == true);
for iList = 1:length(operatingList)
    date = operatingList{iList}(1:5);
    index = operatingList{iList}(7:9);
    plotEnable = false;
    disp(['running HTR event verifier on ' date '-' index])
    [~] = HTRMagDetectionHandler([date '-' index],plotEnable);
end
end

% === CHECK IF WE NEED TO RUN A STIM RESP CURVE AND DO SO
operatingList = exptTable.DateIndex(exptTable.needStimResp == true);
for iList = 1:length(operatingList)    
    date = operatingList{iList}(1:5);
    index = operatingList{iList}(7:9);
    evokedStimResp_userInput(date,index);
end

% === SAVE AN UPDATED SUMMARY FILE FOR THIS ANIMAL
summaryLocation = ['M:\PassiveEphys\AnimalData\' animal '\' ];
if ~exist(summaryLocation,'dir')
    mkdir(summaryLocation);
end
save([summaryLocation animal '-exptSummary'],'exptTable');


% % TO DO LIST
% 1. if this is working for all data types and animals, we can get rid of the following: 
%    fileMaint_Mag(exptDate,Animal1,Animal2)
%    fileMaint_dual(animal,hasTankIndices)
%    maybe saveMagnetDataFiles(exptDate,Animal1,Animal2);
% 2. incorporate WHOLE DAY ANALYSIS below?
% 3. incorporate MOVEMENT ANALYSIS below?
% 4. incorporate spontaneous analysis from Ziyad below?

% TODO 7/7/21 ZS SG
% incorporate spontaneous analyses
    % Approach #1
        % (both of the following functions are in TDTUtilities)
        % add mouseEphys_specAnalysis to compute band power & power spectra (AND Lempel-Ziv analysis) 
        % add mouseEphys_wPLIAnalysis to compute connectivity data
    % Approach #2
        % finish rewrite of mouseEphys_spontAnalyses (in TDTUtilities),
        % i.e. a version without field trip functions/streamlined code in
        % the style of the runAnalysis in the ECoG repo

% === RUN ANY WHOLE DAY ANALYSIS IF IT NEEDS TO BE RUN
% work in progress. we need a way to confirm indecies are appropriately grouped
% 'Baseline / stim' 'Post LTP / stim' 'Post LTD / stim'
% plotPlasticityAmplitudePeaks(exptDate,exptIndices)

% === RUN MOVEMENT ANALYSIS
% since we may have moved and analyzed a few things we can re-establish our list
% for iList = 1:length(listOfAnimalExpts)
%     [dirStrAnalysis,dirStrRawData,~,~] = getPaths(path,date,index);
%     [exptTable] = videoFileScan(dirStrRawData,dirStrAnalysis,exptTable,iList);
% end
% try
%     runBatchROIAnalysis(animal) % ADDED 5/13/2019
% catch
%     warning('failed to run movement analysis');
% end

end


% === BEGIN LOCAL FUNCTIONS

function [dirStrAnalysis,dirStrRawData,dirStrRecSourceA,dirStrRecSourceB] = getPaths(path,date,index)
    dirStrAnalysis = [path.dirStrAnalysisROOT '20' date(1:2) '\' date '-' index '\'];
    dirStrRawData = [path.dirStrRawDataROOT '20' date(1:2) '\' date '-' index '\'];
    dirStrRecSourceA = [path.dirStrRecSourceAROOT '20' date(1:2) '\' date '-' index '\']; 
    dirStrRecSourceB = [path.dirStrRecSourceBROOT '20' date(1:2) '\' date '-' index '\']; 
end

function [exptTable] = magnetFileScan(dirStrAnalysis,exptTable,iList)
    if ~isempty(dir([dirStrAnalysis '*_magnetData*']))
        exptTable.Magnets(iList) = true;
    else
        exptTable.Magnets(iList) = false;
    end
    if ~isempty(dir([dirStrAnalysis '*skipMagnet*']))
        exptTable.Magnets(iList) = false;
    end
end

function [exptTable] = videoFileScan(dirStrRawData,dirStrAnalysis,exptTable,iList)
    if isempty(dir([dirStrRawData '*_Cam*']))
        exptTable.videoDone(iList) = 'none';
    else
        if ~isempty(dir([dirStrAnalysis '*-movementBinary*' '.mat'])) 
            exptTable.videoDone(iList) = 'true';
        else
            exptTable.videoDone(iList) = 'false';
        end
    end
end

function [electrodeLocation] = checkElectrode(date,index,animal)
% check to see if probe has been entered, if not, copy existing template
electrodeLocation = [];
try
    [electrodeLocation,~] = getElectrodeLocationFromDateIndex(date,index);
catch
    disp('Probe information not found.  Using template.');
    disp('WARNING!!! if probe configuration has changed, stop now and correct in database!!!');
    if strcmp(animal(1:3),'EEG')
        setElectrodeLocationFromAnimal('EEG52',animal);
    elseif strcmp(animal(1:3),'LFP')
        setElectrodeLocationFromAnimal('LFP16',animal);
    elseif strcmp(animal(1:3),'DRE')
        setElectrodeLocationFromAnimal('DREADD07',animal);
    elseif strcmp(animal(1:2),'ZZ')
        error('please enter probe configuration for this animal'); % ZZ animals tend to be unique
    elseif strcmp(animal(1:3),'Mag') || strcmp(animal(1:3),'mag')
        setElectrodeLocationFromAnimal('Mag003',animal);
    else
        error('Animal type not recognized.')
    end
    [electrodeLocation,~] = getElectrodeLocationFromDateIndex(date,index);
end

end









% old filemaint steps. likely will not use these, but handy references

%     % %% MUA CHECK %% might want to fix up 'artifact rejection' option - some need it, some don't
%     if ~isempty(strfind(descOfAnimalExpts{iList}{:},'Stim'))
%         disp('Running MUA analysis')
%         dirCheck = dir([dirStrAnalysis '*TrshldMUA_Stim*']);
%         if isempty(dirCheck)
%             analyzeMUAthresholdArtifactRejection('PassiveEphys',date,index,index,0,1,0,1,0,-.5,1.5,-.001,3,2,1,false);
% %             analyzeMUAthresholdArtifactRejection(exptType,exptDate,exptIndex,threshIndex,rejectAcrossChannels,...
% %     filterMUA,subtrCommRef,detection,interpolation,tPltStart,tPltStop,PSTHPlotMin,...
% %     PSTHPlotMax,threshFac,batchBoolean,isArduino)
%         else
%             disp([date '-' index ' analyze MUA already done.']);
%         end
%     end

% % STEP 4: RUN SPEC ANALYSIS
% try
%     disp('starting spec analysis') ; 
%     tic
%     forceReRun = 0; %will run all dates found for this animal
%     [gBatchParams, gMouseEphys_out] = mouseEphys_specAnalysis(animal,forceReRun);
%     toc
% catch
%     warning('failed to run spec analysis'); 
% end

% % spectra
% try
%     plotFieldTripSpectra({animal},1,gMouseEphys_out,gBatchParams); %spectra will save if second param = 1
% catch
% end

% % grady plots
% try
%     plotTimeDActivityAndBP(animal,'delta',1);
% catch
% end

% % STEP 5: RUN WPLI ANALYSIS
% % calculate phase lag for a single day (is this preferable?) and save
% disp('starting wpli analysis');
% tic
% [gBatchParams, gMouseEphys_conn] =  mouseEphys_wPLIAnalysis(animal,forceReRun);
% saveBatchParamsAndEphysConn(gBatchParams,gMouseEphys_conn);
% toc

% plotType = 'timeseries';
% fileName = ['M:\PassiveEphys\AnimalData\' animal '\' plotType];
% print('-painters',fileName,'-r300','-dpng');
% try
%     desc = [animal ];
%     sendSlackFig(desc,[fileName '.png']);
% catch
%     disp('failed to plot time series');
% end
