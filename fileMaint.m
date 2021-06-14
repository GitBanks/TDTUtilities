function fileMaint(animal)
% A utility  to run that replicates the import data pathway in
% synapseFrontEnd
% 1. move files
% 2. import data
% 3. move downsampled to W (renamed EEG channels) sorry, this is expected in an analysis.  I'll change once I get to that one...
% 4. Turn movie into a grid file
% 5. This is also set to run the video analysis program at end of day
% (needs all finished video files)
% notes
% absolutely do not run on anything except synapse data!!!!
% WARNING this is only operating upon EEGdata files for now!!!
% WARNING a few locations are hardcoded!

% %test parameter
%animal = 'ZZ06';

%override parameters - used rarely
forceReimport = 0;
forceReimportTrials = 0;

% establish a clean list of all experiments we're interested in
listOfAnimalExpts = getExperimentsByAnimal(animal);
descOfAnimalExpts = listOfAnimalExpts(:,2);
listOfAnimalExpts = listOfAnimalExpts(:,1);

% before full automation, we can use this to set drug or eStim parameters 
% in the DB
manuallySetGlobalParamUI(animal); 

% verify the electrode information has been entered correctly.  This is a
% local function within FileMaint, below
[electrodeLocation] = checkElectrode(listOfAnimalExpts{1}(1:5),listOfAnimalExpts{1}(7:9),animal);

% establish a few parameters to keep the main loop clean.
% We should improve root locations - REC could be different.  We could also
% check for connections here so that later attempts to connect don't fail
dirStrAnalysisROOT = [mousePaths.M 'PassiveEphys\']; % 'M' drive
%dirStrRecSourceAROOT = '\\144.92.237.187\Data\PassiveEphys\'; %Nessus
dirStrRecSourceAROOT = '\\144.92.237.183\Data\PassiveEphys\'; %Gilgamesh
dirStrRecSourceBROOT = '\\144.92.237.187\Data\PassiveEphys\'; %Nessus
dirStrRawDataROOT = [mousePaths.W 'PassiveEphys\']; %'W' drive
dirStrServer = '\\144.92.237.186\Users\'; %Helmholz
%dirStrServer = '\\HELMHOLTZ\'; %Helmholz another way
% dirStrServer = '\\Server1\data\';

% we often have network connection issues.  Handle that verification here,
% so later errors aren't confusing.  checkConnection is a local function.
checkConnection(dirStrAnalysisROOT);
checkConnection(dirStrRecSourceAROOT);
try
    checkConnection(dirStrRecSourceBROOT);
catch
    disp('Can''t find alt REC computer.  Reverting to primary REC.');
    dirStrRecSourceBROOT = dirStrRecSourceAROOT;
end
checkConnection(dirStrRawDataROOT);
checkConnection(dirStrServer);


% check all recorded files first?
sz = [length(listOfAnimalExpts) 7];
varTypes = {'string','string','logical','logical','string','logical','logical'};
% the idea of this table is that if tasks are 'done', the logical should
% evaluate 'true'.  The exception is video files - sometimes there's no
% video
varNames = {'DateIndex','Description','RECmoved','Imported','videoDone','RECAEmpty','RECBEmpty'};
exptTable = table('Size',sz,'VariableTypes',varTypes,'VariableNames',varNames);
for iList = 1:length(listOfAnimalExpts)
    exptTable.Description(iList) = descOfAnimalExpts{iList}{1};
    date = listOfAnimalExpts{iList}(1:5);
    index = listOfAnimalExpts{iList}(7:9);
    exptTable.DateIndex(iList) = [date '-' index];
    dirStrAnalysis = [dirStrAnalysisROOT '20' date(1:2) '\' date '-' index '\'];
    dirStrRecSourceA = [dirStrRecSourceAROOT '20' date(1:2) '\' date '-' index '\']; 
    dirStrRecSourceB = [dirStrRecSourceBROOT '20' date(1:2) '\' date '-' index '\']; 
    dirStrRawData = [dirStrRawDataROOT '20' date(1:2) '\' date '-' index '\'];
    if isempty(dir(dirStrRecSourceA))
        exptTable.RECAEmpty(iList) = true;
    end
    if isempty(dir(dirStrRecSourceB))
        exptTable.RECBEmpty(iList) = true;
    end
    % are files moved?
    if exptTable.RECAEmpty(iList) == true && exptTable.RECBEmpty(iList) == true && ~isempty(dir([dirStrRawData '*.tbk']))
        exptTable.RECmoved(iList) = true;
    else
        exptTable.RECmoved(iList) = false;
    end
    % are data imported?
    if ~isempty(dir([dirStrAnalysis '*data*']))
        exptTable.Imported(iList) = true;
    else
        exptTable.Imported(iList) = false;
    end
    % is video analyzed (if it exists)?
    [exptTable] = videoFileScan(dirStrRawData,dirStrAnalysis,exptTable,iList);
    
end   

% STEP 1 MOVE TDT TANK FILE TO W DRIVE
operatingList = exptTable.DateIndex(exptTable.RECAEmpty == false);
for iList = 1:length(operatingList)
    date = operatingList{iList}(1:5);
    index = operatingList{iList}(7:9);
    dirStrRecSource = [dirStrRecSourceAROOT '20' date(1:2) '\' date '-' index '\']; 
    dirStrRawData = [dirStrRawDataROOT '20' date(1:2) '\' date '-' index '\'];
    disp(['Found REC data to MOVE to W for ' date '-' index ]);
    try
        moveDataRecToRaw(dirStrRecSource,dirStrRawData);
    catch
        disp('moveDataRecToRaw didn''t run.');
    end
end

operatingList = exptTable.DateIndex(exptTable.RECBEmpty == false);
for iList = 1:length(operatingList)    
    date = operatingList{iList}(1:5);
    index = operatingList{iList}(7:9);
    dirStrRecSource = [dirStrRecSourceBROOT '20' date(1:2) '\' date '-' index '\']; 
    dirStrRawData = [dirStrRawDataROOT '20' date(1:2) '\' date '-' index '\'];
    disp(['Found REC data to MOVE to W for ' date '-' index ]);
    try
        moveDataRecToRaw(dirStrRecSource,dirStrRawData);
    catch
        disp('moveDataRecToRaw didn''t run.');
    end
end

% STEP 2 CONVERT FROM TDT TANK FILE TO MATLAB FORMAT, SAVE TO MEMORYBANKS
operatingList = exptTable.DateIndex(exptTable.Imported == false);
for iList = 1:length(operatingList)    
    date = operatingList{iList}(1:5);
    index = operatingList{iList}(7:9);
    [tankDate,tankIndex] = getIsTank(date,index);
    dirStrAnalysis = [dirStrAnalysisROOT '20' date(1:2) '\' date '-' index '\'];
    disp(['Found Raw data to IMPORT from W to mat format on M at ' date '-' index ]);
    importDataSynapse_dual(date,index,[tankDate '-' tankIndex]);
%     importDataSynapse(date,index); % may want to add a way to force it to re-import
end

for iList = 1:length(listOfAnimalExpts)
    %quick rescan for video files if we've moved some during import
    [exptTable] = videoFileScan(dirStrRawData,dirStrAnalysis,exptTable,iList);
end



% % !!!!!!!!!!! need to process this!  (needs a rewrite)
% saveMagnetDataFiles(exptDate,Animal1,Animal2);



% % STEP 3: RUN MOVEMENT ANALYSIS
% try
%     runBatchROIAnalysis(animal) % ADDED 5/13/2019
% catch
%     warning('failed to run movement analysis');
% end


% if this is working for all data types and animals, we can get rid of the following: 
% fileMaint_Mag(exptDate,Animal1,Animal2)
% fileMaint_dual(animal,hasTankIndices)
% maybe saveMagnetDataFiles(exptDate,Animal1,Animal2);

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
        %setElectrodeLocationFromAnimal('DREADD07',animal);
        error('please enter probe configuration for this animal');
    elseif strcmp(animal(1:3),'Mag')
        setElectrodeLocationFromAnimal('Mag003',animal);
    else
        error('Animal type not recognized.')
    end
end


end




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


% 
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



