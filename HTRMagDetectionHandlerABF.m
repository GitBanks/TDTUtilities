function [htrEventTimes,magData,magDT,metaData] = HTRMagDetectionHandlerABF(exptID,plotEnable,localSave,abfChannel,thisMouse)
% had to add a mouse specific feature for these ABF data

if localSave
    pathToFiles = [getPathGlobal('CodyLocalHTRData') '20' exptID(1:2) '\'  exptID '\' ];
else
    pathToFiles = [getPathGlobal('importedData') '20' exptID(1:2) '\'  exptID '\' ];
    % pathToFiles = ['M:\PassiveEphys\20' exptID(1:2) '\'  exptID '\' ];
end

fileAndPath = [pathToFiles exptID '-HTRevents_' thisMouse '.mat'];
redoEventSelection = 0;


rawDataFile = [exptID '.abf'];
% abf files are stored here:
ORIGpathAndFileName = [getPathGlobal('CodyLocalHTRData') rawDataFile];
% %
% % % COPY RAW DATA TO CORRECT DIRECTORY HERE
% % 
% we will move them to here:
pathToFiles = [getPathGlobal('CodyLocalHTRData') '20' exptID(1:2) '\'  exptID '\' ];
pathAndFileName = [pathToFiles rawDataFile];
% load the data here
[magData,magDT,metaData] = abfload(pathAndFileName); 
magDT = magDT/1000000; % note dT is in microseconds.  This puts it into seconds
magData = magData(:,abfChannel)';

if exist(fileAndPath,'file') == 2 && redoEventSelection == 0
    load(fileAndPath,'htrEventTimes');
else
    % NOTE!  we will need to step through mice.  for now check the first:
    localSave = true;
    plotEnable = true;
    warning('off','all');
    temp = filterData_dbVer(magData,30,59,magDT);
    [localVar,windowedVarTimes] = HTRMagConvertToVarWin(temp,magDT); 
    warning('on','all');
    %light cleaning of var over time
    nearDiff = localVar;
    for iPass = 1:10
        for iDiff = 5:length(nearDiff)
            nearDiff(iDiff) = localVar(iDiff) - mean(localVar(iDiff-4:iDiff-2));
        end
        nearDiff(nearDiff<0) = 0;
    end
    %output detected times
    HTRMagFindEventTimes(localVar,windowedVarTimes,plotEnable,magData,magDT,exptID,localSave,thisMouse);
    load(fileAndPath,'htrEventTimes');
end
