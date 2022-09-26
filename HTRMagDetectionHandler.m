function [htrEventTimes] = HTRMagDetectionHandler(exptID,plotEnable,localSave)
% exptID = '21415-001'
% plotEnable = true;
if ~exist("localSave","var")
    localSave = false;
end
% adding a feature for local saves for Cody's lab (or others)
if localSave
    saveLocation = [getPathGlobal('CodyLocalHTRData') '20' exptID(1:2) '\'  exptID '\' ];
else
    saveLocation = [getPathGlobal('importedData') '20' exptID(1:2) '\'  exptID '\' ];
    % saveLocation = ['M:\PassiveEphys\20' exptID(1:2) '\'  exptID '\' ];
end
redoEventSelection = 0;
if exist([saveLocation exptID '-HTRevents.mat'],'file') == 2 && redoEventSelection == 0
    load([saveLocation exptID '-HTRevents.mat'],'htrEventTimes');
else
    % load data
    [magData,magDT] = HTRMagLoadData(exptID); 
    % window, then turn to variance
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
    HTRMagFindEventTimes(localVar,windowedVarTimes,plotEnable,magData,magDT,exptID,localSave);
    load([saveLocation exptID '-HTRevents.mat'],'htrEventTimes');
end


