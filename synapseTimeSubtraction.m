function timeOut = synapseTimeSubtraction(timeInOne,timeInTwo)
% this finds time differences from the synapse beginning time stamp
% given two times in the Synapse format
% return the difference in seconds
% timeInOne='19:23:31';
% timeInTwo='18:58:01';

% str2num(stimSet(2).timeOfDayStart)
% datestr(stimSet(2).timeOfDayStart)
rem = timeInOne;
[hr1,rem] = strtok(rem,':');
[mn1,rem] = strtok(rem,':');
[sc1,rem] = strtok(rem,':');
timeOne = str2num(hr1)*3600;
timeOne = timeOne+str2num(mn1)*60;
timeOne = timeOne+str2num(sc1);

rem = timeInTwo;
[hr2,rem] = strtok(rem,':');
[mn2,rem] = strtok(rem,':');
[sc2,rem] = strtok(rem,':');
timeTwo = str2num(hr2)*3600;
timeTwo = timeTwo+str2num(mn2)*60;
timeTwo = timeTwo+str2num(sc2);

timeOut = timeOne-timeTwo;


