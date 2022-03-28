function [indexDur,timeOfDay] = getTimeAndDurationFromIndex(thisDate,thisIndex)
% test params
% fileN = 'W' ':\Data\PassiveEphys\2020\20o08-000';
% thisDate='21318'
% thisIndex='002'
thisDate = strrep(thisDate,'date','');
try
fileN = [getPathGlobal('W') 'PassiveEphys\20' thisDate(1:2) '\' thisDate '-' thisIndex];

dataX = TDTbin2mat(fileN,'TYPE',{'scalars'});

if isempty(dataX)
    tempIndex = num2str(str2double(thisIndex)-1);
    while size(tempIndex) <3
        tempIndex = ['0' tempIndex];
    end
    fileN = [getPathGlobal('W') 'PassiveEphys\20' thisDate(1:2) '\' thisDate '-' tempIndex];    
    dataX = TDTbin2mat(fileN,'TYPE',{'scalars'});
    if isempty(dataX)
        error('Not a proper index');
    end
end

indexDur = dataX.info.duration;
timeOfDay = datetime(dataX.info.date,'TimeZone','UTC') + timeofday(datetime(dataX.info.utcStartTime,'TimeZone','UTC'));
%timeOfDay = datetime(dataX.info.utcStartTime,'Format','HH:mm:ss','TimeZone','UTC'); % convert from UTC to local time, adjusting for daylight savings time
timeOfDay.TimeZone = 'America/Chicago';

catch why
    warning(why.message);
    indexDur = [];
    timeOfDay = [];
end
%dataX.info.utcStopTime
end


