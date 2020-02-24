function fileMaint_dual(animal,hasTankIndices)
% A utility  to run that replicates the import data pathway in
% synapseFrontEnd
% 1. add drug information to e-notebook
% 2. add probe information to e-notebook
% 3. move files from tank location on recording computer to W:\Data\PassiveEphys\Year
% 4. process & import data from W:\Data\PassiveEphys\Year\ to M:\Data\PassiveEphys\Year
% 5. move processed data from M:\Data\PassiveEphys\Year back to W:\Data\PassiveEphys\EEG animal data\animal (sorry)
% 6. run roi-based movement analysis
% 7. run spectral analysis & plot results
% 8. run weighted phase lag index analysis & plot results

% animal is animal ID as a string (e.g. 'EEG130');
% hasTankIndices is a boolean (i.e. 1 or 0) which is necessarily true if the animal was
% on cam1/EEG1/cage 1 on synapse (and thus associated with the tank files)
% or false if the animal was on cam2/EEG2/cage 2 % TODO: Have fileMaint
% automatically detect this

% notes:
% WARNING absolutely do not run on anything except synapse data!!!!
% WARNING this is only operating upon EEGdata files for now!!!
% WARNING a few locations are hardcoded!

if nargin < 2
    disp('hasTankIndices not set. Assuming this animal is associated with the tank indices');
    hasTankIndices = 1;
end

forceReimport = 0;
forceReimportTrials = 0;

% 1. SET DRUG PARAMETERS
manuallySetGlobalParamUI(animal); 

% get list of experiments for use throughout this script
listOfAnimalExpts = getExperimentsByAnimal(animal);
% descOfAnimalExpts = listOfAnimalExpts(:,2);
listOfAnimalExpts = listOfAnimalExpts(:,1);

% 2. CHECK PROBE INFORMATION 
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

% loop through list of experiments
for iList = 1:length(listOfAnimalExpts)
    date = listOfAnimalExpts{iList}(1:5);
    index = listOfAnimalExpts{iList}(7:9);
    
    if hasTankIndices
        blockLocation = [date '-' index];
    else %if not, then assume the index immediately before is the tank index... TODO: find a better way to handle this
        tempIndex = str2double(index)-1;
        if length(num2str(tempIndex)) < 2
            tempIndex = ['00' num2str(tempIndex)];
        else
            tempIndex = ['0' num2str(tempIndex)];
        end
        blockLocation = [date '-' tempIndex];
    end

    dirStrAnalysis = ['\\MEMORYBANKS\Data\PassiveEphys\' '20' date(1:2) '\' date '-' index '\'];
    dirStrRecSource = ['\\144.92.237.183\Data\PassiveEphys\' '20' date(1:2) '\' date '-' index '\']; 
    dirStrRawData = ['W:\Data\PassiveEphys\' '20' date(1:2) '\' date '-' index '\'];
    disp(['$$$ Processing ' date '-' index ' $$$']);
    
    % 3a. MOVE TANK FILE FROM RECORDING COMPUTER TO W DRIVE 
    try
        moveDataRecToRaw(dirStrRecSource,dirStrRawData);
    catch
        disp('moveDataRecToRaw didn''t run.');
    end
    
    % 3b. COPY CAM2 FILE TO SEPARATE INDEX
    if ~strcmp([date '-' index],blockLocation)
        tankDir = ['W:\Data\PassiveEphys\' '20' date(1:2) '\' blockLocation '\'];
        dirCheck = dir(dirStrRawData);
        if isempty(dirCheck) || dirCheck(1).bytes==0
            mkdir(dirStrRawData);
            tank_Cam2_name = [tankDir '20' date(1:2) '_' blockLocation '_Cam2.avi'];
            if isfile(tank_Cam2_name)
               copy_Cam2_name = [dirStrRawData '20' date(1:2) '_' date '-' index '_Cam2.avi'];
               copyfile(tank_Cam2_name,copy_Cam2_name); 
               disp([tank_Cam2_name ' copied to ' copy_Cam2_name]);
            end
        else
            warning([dirStrRawData ' exists, are you sure you wanted to copy Cam2 here?']);
        end
    end
    
    % 4. IMPORT DATA TO M: DRIVE aka MEMORYBANKS
    dirCheck = dir([dirStrAnalysis '*data*']); % check to see if ephys info is imported
    if isempty(dirCheck) || forceReimport
        disp('Handing info to existing importData function.  This will take a few minutes.');
        try
            importDataSynapse_dual(date,index,blockLocation);
        catch
            disp([date '-' index ' not imported!!']);
        end
    elseif forceReimportTrials
        disp('Data already imported, but updating trialinfo');
        updateStimInfoSynapse(date,index);
    end
    
    % 5. MOVE PROCESSED DATA BACK TO W (sadly)
    % (sadly because analyzed data are going to 'raw data' storage zone)
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
    % insert some method to figure out which index is the control index

    % %% MUA CHECK %% might want to fix up 'artifact rejection' option - some need it, some don't
%     if ~isempty(strfind(descOfAnimalExpts{iList}{:},'Stim'))
%         disp('Running MUA analysis')
%         dirCheck = dir([dirStrAnalysis '*TrshldMUA_Stim*']);
%         if isempty(dirCheck)
%             analyzeMUAthresholdArtifactRejection('PassiveEphys',date,index,index,0,1,0,1,0,-.5,1.5,-.001,3,2,1,false);
%         else
%             disp([date '-' index ' analyze MUA already done.']);
%         end
%     end
end

% 6. RUN ROI-BASED MOVEMENT ANALYSIS
%=========================================================================%
runBatchROIAnalysis(animal); % this script executes the movement analysis

% 7. RUN SPECTRAL ANALYSIS AND PLOT
%=========================================================================%
% add fieldtrip path... they say you're not supposed to do it all at once like this but ¯\_(?)_/¯
addpath('Z:\fieldtrip-20170405\');

runICA = 0; % should usually be set to 0, unless there is "heart rate noise" on the EEG
forceReRun = 0; % will run all dates found for this animal

disp('starting spec analysis') ;

tic
[gBatchParams, gMouseEphys_out] = mouseDelirium_specAnalysis(animal,runICA,forceReRun); 
saveBatchParamsAndEphysOut(gBatchParams,gMouseEphys_out); 
toc

% plot spectra
specFName = plotFieldTripSpectra({animal},gMouseEphys_out,gBatchParams);

% send spectra .png file to delirium slack
% try
%     specDesc = [animal ' spectra'];
%     sendSlackFig(specDesc,[specFName '.png']);
% catch
%     disp('spectra upload failed');
% end

% plot individual band power time series
[timeSeriesName] = plotNewBandPowerTimeSeries(animal,gBatchParams,gMouseEphys_out);

% send power time series to slack channel
% try
%     timeSeriesDesc = [animal ' power time series'];
%     sendSlackFig(timeSeriesDesc,[timeSeriesName '.png']);
% catch
%     disp('4sec movement & power time series upload failed');
% end

% plot old grady plot
try 
    plotTimeDActivityAndBP(animal,'delta',1);
catch
    warning('plotTimeDActivityAndBP failed to run');
end

% plot new version of grady plot using plotWindowedPower
try
    param = 'delta'; 
    smooth = true; % smooth data windows
    nmlz = true; % nmlz to total power
    [gradyplotName] = plotWindowedPower(animal,param,smooth,nmlz); %!! requires animal name to be in M:\mouseEEG\mouseGroupInfo.xlsx
catch
    warning('plotWindowedPower failed to plot');
end

% send grady plot
% try 
%     gradDesc = [animal ' gradyplot'];
%     sendSlackFig(gradDesc,[gradyplotName '.png']);
% catch
%     disp('new gradyplot did not send to slack');
% end

% TODO: add functionality to update a master power table with these data



% 8. RUN WEIGHTED PHASE LAG INDEX (CONNECTIVITY) ANALYSIS & PLOT
%=========================================================================%
% these paths are necessary!
addpath('Z:\DataBanks\Kovach Toolbox Rev 751\trunk\DBT'); 
addpath('C:\Users\Matt Banks\Documents\Code\mouse-delirium\wpli');

% calculate phase lag for a single day (is this preferable?) and save
disp('starting wpli analysis'); 

tic
[gBatchParams, gMouseEphys_conn] = mouseDelirium_WPLI_dbt_Synapse(animal,runICA,forceReRun);
saveBatchParamsAndEphysConn(gBatchParams,gMouseEphys_conn); 
toc

% plot WPLI time series
try
    pliTimeSeries = plotNewWPLITimeSeries(animal,gBatchParams,gMouseEphys_conn);
catch
    warning('wpli failed to plot');
end

% try 
%     pliDesc = [animal ' wpli time series'];
%     sendSlackFig(pliDesc,[pliTimeSeries '.png']);
% catch
%     disp('wpli plot did not send to slack');
% end

% TODO: add functionality to update a master WPLI table with these data

% TODO: add some summary to say what ran/didn't run

% DONE!
disp('By golly you''ve done it');

end








