function fileMaint_dual_videoOnly(animal,hasTankIndices)

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

    dirStrAnalysis = [getPathGlobal('M') 'PassiveEphys\' '20' date(1:2) '\' date '-' index '\'];
    dirStrRecSource = ['\\' getPathGlobal('REC') '\Data\PassiveEphys\' '20' date(1:2) '\' date '-' index '\']; 
    dirStrRawData = [getPathGlobal('W') 'PassiveEphys\' '20' date(1:2) '\' date '-' index '\'];
    disp(['$$$ Processing ' date '-' index ' $$$']);
    
    % 3a. MOVE TANK FILE FROM RECORDING COMPUTER TO W DRIVE 
    try
        moveDataRecToRaw(dirStrRecSource,dirStrRawData);
    catch
        disp('moveDataRecToRaw didn''t run.');
    end
    
    % 3b. COPY CAM2 FILE TO SEPARATE INDEX
    if ~strcmp([date '-' index],blockLocation)
        tankDir = [getPathGlobal('W') 'PassiveEphys\' '20' date(1:2) '\' blockLocation '\'];
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
end

% 6. RUN ROI-BASED MOVEMENT ANALYSIS
%=========================================================================%
runBatchROIAnalysis(animal); % this script executes the movement analysis