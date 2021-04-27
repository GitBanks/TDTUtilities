
function [htrEventTimes] = HTRMagDetectionHandler(exptID,plotEnable)
% load data
[magData,magDT] = HTRMagLoadData(exptID); 
% window, then turn to variance
warning('off','all');
[localVar,windowedVarTimes] = HTRMagConvertToVarWin(filterData_dbVer(magData,30,59,magDT),magDT); 
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
%plotEnable = true;
redoEventSelection = 0;

saveLocation = ['M:\PassiveEphys\20' exptID(1:2) '\'  exptID '\' ];
if exist([saveLocation exptID '-HTRevents.mat'],'file') == 2 && redoEventSelection == 0
    load([saveLocation exptID '-HTRevents.mat'],'htrEventTimes');
else
    HTRMagFindEventTimes(localVar,windowedVarTimes,plotEnable,magData,magDT,exptID);
    load([saveLocation exptID '-HTRevents.mat'],'htrEventTimes');
end


