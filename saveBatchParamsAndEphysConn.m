function saveBatchParamsAndEphysConn(params_new,ephysData_new)
% only processes one animal

% Given: gBatchParams structure with animal data (all of one animal)
% 1. load the existing 'all animal' save file
% 2. add updated animal
% 3. save

pliFile = EEGUtils.pliFile; % load from EEGUtils class

try
    load(pliFile,'mouseEphys_conn','batchParams');
catch
    warning([pliFile ' does not exist! check path.']);
    keyboard
end

gName = fieldnames(params_new);
gName = gName{1,1};

% check for multiple dates in gBatchParams
batchDates = fieldnames(params_new.(gName));
batchDates = batchDates(contains(batchDates,'date'));
ephysDates = fieldnames(ephysData_new.(gName));
eDates = intersect(batchDates,ephysDates);

batchParams.(gName).ephysInfo = params_new.(gName).ephysInfo;

for iDate = 1:length(eDates)
    thisDate = eDates{iDate};
    batchParams.(gName).(thisDate) = params_new.(gName).(thisDate);
    mouseEphys_conn.(gName).(thisDate) = ephysData_new.(gName).(thisDate);
end

save(pliFile,'mouseEphys_conn','batchParams');
disp('mouseEphys_conn and batchParams saved!');