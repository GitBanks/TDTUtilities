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

%animal = 'ZZ05';

listOfAnimalExpts = getExperimentsByAnimal(animal);

forceReimport = 0;
forceReimportTrials = 0;

% before full automation, we can use this to set drug parameters in the DB so that below we can run
manuallySetGlobalParamUI(animal); 

listOfAnimalExpts = listOfAnimalExpts(:,1);

% check to see if probe has been entered, if not, copy existing template
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
    elseif strcmp(animal(1:2),'ZZ')
        %setElectrodeLocationFromAnimal('DREADD07',animal);
        error('please enter probe configuration for this animal')
    else
        error('Animal type not recognized.')
    end
end

for iList = 1:length(listOfAnimalExpts)
%for iList = 54:55
    date = listOfAnimalExpts{iList}(1:5);
    index = listOfAnimalExpts{iList}(7:9);
    dirStrAnalysis = [mousePaths.M 'PassiveEphys\' '20' date(1:2) '\' date '-' index '\'];
    dirStrRecSource = ['\\144.92.237.187\Data\PassiveEphys\' '20' date(1:2) '\' date '-' index '\']; 
    dirStrRawData = [mousePaths.W 'data\PassiveEphys\' '20' date(1:2) '\' date '-' index '\'];
    disp(['$$$ Processing ' date '-' index ' $$$']);
    
    % STEP 1 MOVE TDT TANK FILE TO W DRIVE
    try
        moveDataRecToRaw(dirStrRecSource,dirStrRawData);
    catch
        disp('moveDataRecToRaw didn''t run.');
    end
    
    % STEP 2 CONVERT FROM TDT TANK FILE TO MATLAB FORMAT, SAVE TO MEMORYBANKS
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
end

% STEP 3: RUN MOVEMENT ANALYSIS
try
    runBatchROIAnalysis(animal) % ADDED 5/13/2019
catch
    warning('failed to run movement analysis');
end
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






