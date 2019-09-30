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

%animal = 'EEG55';

listOfAnimalExpts = getExperimentsByAnimal(animal);

forceReimport = 0;
forceRegrid = 0;
forceReimportTrials = 0;

% before full automation, we can use this to set drug parameters in the DB
% so that below we can run
manuallySetGlobalParamUI(animal); 

descOfAnimalExpts = listOfAnimalExpts(:,2);
listOfAnimalExpts = listOfAnimalExpts(:,1);

% check to see if probe has been entered, and if not prompt user for that
% info
try
    [electrodeLocation] = getElectrodeLocationFromDateIndex(listOfAnimalExpts{1}(1:5),listOfAnimalExpts{1}(7:9));
catch
    disp('Probe information not found.  Using template.');
    disp('WARNING!!! if probe configuration has changed, stop now and correct in database!!!');
    if strcmp(animal(1:3),'EEG')
        setElectrodeLocationFromAnimal('EEG52',animal);
    elseif strcmp(animal(1:3),'LFP')
        setElectrodeLocationFromAnimal('LFP16',animal);
    elseif strcmp(animal(1:3),'DRE')
        setElectrodeLocationFromAnimal('DREADD07',animal);
    else
        error('Animal type not recognized.')
    end
end

if ~exist(['W:\Data\PassiveEphys\EEG animal data\' animal '\'],'dir')
    mkdir(['W:\Data\PassiveEphys\EEG animal data\' animal '\']);
    disp(['making dir: W:\Data\PassiveEphys\EEG animal data\' animal '\']);
end

for iList = 1:length(listOfAnimalExpts)
    date = listOfAnimalExpts{iList}(1:5);
    index = listOfAnimalExpts{iList}(7:9);
    dirStrAnalysis = ['\\MEMORYBANKS\Data\PassiveEphys\' '20' date(1:2) '\' date '-' index '\'];
    dirStrRecSource = ['\\144.92.237.183\Data\PassiveEphys\' '20' date(1:2) '\' date '-' index '\']; 
    dirStrRawData = ['W:\Data\PassiveEphys\' '20' date(1:2) '\' date '-' index '\'];
    disp(['$$$ Processing ' date '-' index ' $$$']);
    % %% STEP 1 MOVE 
    try
        moveDataRecToRaw(dirStrRecSource,dirStrRawData);
    catch
        disp('moveDataRecToRaw didn''t run.');
    end
    % %% STEP 2 IMPORT 
    dirCheck = dir([dirStrAnalysis '*data*']); % check to see if ephys info is imported
    if isempty(dirCheck) || forceReimport
        disp('Handing info to existing importData function.  This will take a few minutes.');
        try
            importDataSynapse(date,index);
        catch
            disp([date '-' index ' not imported!!']);
        end
    elseif forceReimportTrials
        disp('Data already imported, but updating trialinfo');
        updateStimInfoSynapse(date,index);
    end
    % %% STEP 3 (sadly) move to W (sadly because analyzed data are going to 'raw data' storage zone)
    if ~exist(['W:\Data\PassiveEphys\EEG animal data\' animal '\' date '-' index '\'],'dir')
        mkdir(['W:\Data\PassiveEphys\EEG animal data\' animal '\'  date '-' index '\']);
        disp(['making dir: W:\Data\PassiveEphys\EEG animal data\' animal '\'  date '-' index '\']);
    end
    currentDir = dir(dirStrAnalysis);
    for iDir = 1:length(currentDir) %could add a check to see if files exist to save time (if they do)

        if strfind(currentDir(iDir).name,'EEGdata') >0
            fileString = [dirStrAnalysis currentDir(iDir).name];
            load(fileString);
            DSephysData = ephysData;
            DSdT = dT;
            save(['W:\Data\PassiveEphys\EEG animal data\' animal '\' date '-' index '\DS-' currentDir(iDir).name],'DSephysData','DSdT');
            clear ephysData
            clear DSephysData
        end
        if strfind(currentDir(iDir).name,'trial') >0
            %if 
            display(['Copying ' currentDir(iDir).name]);
            copyfile([dirStrAnalysis currentDir(iDir).name],['W:\Data\PassiveEphys\EEG animal data\' animal '\' date '-' index '\' currentDir(iDir).name])
            %else
                
            %end
        end
    end
end

runBatchROIAnalysis(animal) %ADDED 5/13/2019 as first step to implementing new analysis!

% Ephys analysis and plotting 
%============================================================%
% To-do: add a check here to see if analysis/plotting is finished! 

addpath('Z:\fieldtrip-20170405\');
disp('starting spec analysis') ; tic
runICA = 0; %
forceReRun = 0; %will run all dates found for this animal
[gBatchParams, gMouseEphys_out] = mouseDelirium_specAnalysis_Synapse(animal,runICA,forceReRun);
saveBatchParamsAndEphysOut(gBatchParams,gMouseEphys_out); toc

% spectra
plotFieldTripSpectra({animal},1,gMouseEphys_out,gBatchParams); %spectra will save if second param = 1

% grady plots
plotTimeDActivityAndBP(animal,'delta',1);

% make slope plots
% plotPeakVsBaselineLinearFit(animal);

% update power and slope tables
% TODO: generate master power and slope tables and add functionality to
% just add entries

% calculate phase lag for a single day (is this preferable?) and save
disp('starting wpli analysis'); 
addpath('Z:\DataBanks\Kovach Toolbox Rev 751\trunk\DBT');
addpath('C:\Users\Matt Banks\Documents\Code\mouse-delirium\wpli');
tic
[gBatchParams, gMouseEphys_conn] =  mouseDelirium_WPLI_dbt_Synapse(animal,runICA,forceReRun);
saveBatchParamsAndEphysConn(gBatchParams,gMouseEphys_conn); 
toc
% update WPLI table

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






