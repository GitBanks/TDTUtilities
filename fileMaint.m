
% fileMaint.m

% notes
% absolutely do not run on anything except synapse data!!!!
% WARNING this is only operating upon EEGdata files!!!
% WARNING a few locations are hardcoded!!!

animal = 'DREADD07';
listOfAnimalExpts = getExperimentsByAnimal(animal,'Spon');
forceReimport = 0;

% % possibly use in getBatchParams program?
% for iList = 1:length(listOfAnimalExpts)
%     b(iList,1) = str2num(listOfAnimalExpts{iList,1}(1:5));
% end
% c = unique(b)

listOfAnimalExpts = listOfAnimalExpts(:,1);

if ~exist(['W:\Data\PassiveEphys\EEG animal data\' animal '\'],'dir')
    mkdir(['W:\Data\PassiveEphys\EEG animal data\' animal '\']);
    display(['making dir: W:\Data\PassiveEphys\EEG animal data\' animal '\']);
end

for iList = 1:length(listOfAnimalExpts)
    date = listOfAnimalExpts{iList}(1:5);
    index = listOfAnimalExpts{iList}(7:9);
    dirStrAnalysis = ['M:\PassiveEphys\' '20' date(1:2) '\' date '-' index '\'];
    dirStrRecSource = ['\\144.92.237.187\c\Data\20' date(1:2) '\' date '-' index '\'];
    dirStrRawData = ['W:\Data\PassiveEphys\' '20' date(1:2) '\' date '-' index '\'];
    % %% STEP 1 MOVE 
    moveDataRecToRaw(dirStrRecSource,dirStrRawData);
    % %% STEP 2 IMPORT 
    dirCheck = dir([dirStrAnalysis '*data*']); % check to see if ephys info is imported
    if isempty(dirCheck) || forceReimport
        display('Handing info to existing importData function.  This will take a few minutes.');
        try
        importDataSynapse(date,index);
        catch
            display([date '-' index 'not imported!!']);
        end
    else
        display('Data already imported.');
    end
    % %% STEP 3 (sadly) move to W (sadly because analyzed data are going to 'raw data' storage zone)
    if ~exist(['W:\Data\PassiveEphys\EEG animal data\' animal '\' date '-' index '\'],'dir')
        mkdir(['W:\Data\PassiveEphys\EEG animal data\' animal '\'  date '-' index '\']);
        display(['making dir: W:\Data\PassiveEphys\EEG animal data\' animal '\'  date '-' index '\']);
    end
    currentDir = dir(dirStrAnalysis);
    for iDir = 1:length(currentDir)
        if strfind(currentDir(iDir).name,'EEGdata') >0
            fileString = [dirStrAnalysis currentDir(iDir).name];
            load(fileString);
            DSephysData = ephysData;
            DSdT = dT;
            save(['W:\Data\PassiveEphys\EEG animal data\' animal '\' date '-' index '\DS-' currentDir(iDir).name],'DSephysData','DSdT');
            clear ephysData
            clear DSephysData
        end
        if strfind(currentDir(iDir).name,'trial') >0;
            display(['Copying ' currentDir(iDir).name]);
            copyfile([dirStrAnalysis currentDir(iDir).name],['W:\Data\PassiveEphys\EEG animal data\' animal '\' date '-' index '\' currentDir(iDir).name])
        end
    end
    
    
    % add this, then run
   % videoFrameGridMakerSynapse(fileName);
    
    
    
    
    
    
end
