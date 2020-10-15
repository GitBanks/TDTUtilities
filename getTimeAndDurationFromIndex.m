function [duration,timeOfDay] = getTimeAndDurationFromIndex(date,index)
% test params
% fileN = 'W:\Data\PassiveEphys\2020\20o08-000';
% date='20o08'
% index='001'
fileN = ['W:\Data\PassiveEphys\20' date(1:2) '\' date '-' index];
dataX = TDTbin2mat(fileN,'TYPE',{'scalars'});
if isempty(dataX)
    tempIndex = num2str(str2num(index)-1);
    while size(tempIndex) <3
        tempIndex = ['0' tempIndex];
    end
    fileN = ['W:\Data\PassiveEphys\20' date(1:2) '\' date '-' tempIndex];    
    dataX = TDTbin2mat(fileN,'TYPE',{'scalars'});
    if isempty(dataX)
        error('Not a proper index');
    end
end

timeOfDay = dataX.info.utcStartTime;
%dataX.info.utcStopTime
duration = dataX.info.duration;

