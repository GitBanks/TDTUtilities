function fileMaintABF

% things that need to happen to analyze data at Rennebohm

% 1. make sure code is loaded
% 2. check xls file and move recent recorded data to storage folder
% 3. move files as necessary
% 4. run HTRMagDetectionHandlerABF with the new recordings


% 1. make sure code is loaded
addpath('C:\Users\soplab\Documents\Code\TDTUtilities\');

% 2. check xls file and move recent recorded data to storage folder
thisFile = getPathGlobal('CodyLocalMetaDataSave');
opts = detectImportOptions(thisFile);
opts = setvartype(opts, "RecordingID", 'string');
workingTable = readtable(thisFile,opts);

% 3. move files as necessary
% we're only moving files if they're described in the xls sheet, so if we
% have unassociated files they might accumulate in that directory
uniqueExptIDs = unique(workingTable.RecordingID);

disp('Checking for saved date to move.')
for iDir = 1:size(uniqueExptIDs,1)
    thisID = num2str(uniqueExptIDs(iDir));
    thisIDpath = [getPathGlobal('CodyLocalHTRDataSave') '20' thisID(1:2) '\' thisID '\'];
    if ~isfolder(thisIDpath) %make folder if necessary
        mkdir(thisIDpath);
    end
    fileNameSource = [getPathGlobal('CodyLocalHTRDataSource') thisID '.abf'];
    fileNameDest = [thisIDpath thisID '.abf'];
    if ~isfile(fileNameDest)
        disp(['Copying ' fileNameSource]);
        copyfile(fileNameSource,fileNameDest);
    else
        disp(['Already there: ' fileNameDest]);
    end
end

% Next run the analysis program!  
% TODO, add a check for if it's been run and if we want to skip rerunning
% it.
for iMagData = 1:size(workingTable,1)
    exptID = num2str(workingTable.RecordingID(iMagData));
    plotEnable = true;
    localSave = true;
    abfChannel = workingTable.ChannelID(iMagData);
    thisMouse = workingTable.AnimalName(iMagData);
    [htrEventTimes,magData,magDT,metaData] = HTRMagDetectionHandlerABF(exptID,plotEnable,localSave,abfChannel,thisMouse);
end


abfMagnetAnalysis




