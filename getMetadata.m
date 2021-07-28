function [exptInfo] = getMetadata(exptDate,exptIndex)
% make sure it is a data structure that contains the followiing info:
% File time/day/animal etc
% Stim site
% Time of peak re stim time
% Response magnitude (pk, inner product) (two flavors)
% Time of stim relative to start of file

% test data
% exptDate = '21727';
% exptIndex = '002'; 
% exptIndex = '001'; % test this ZZ09

exptInfo = struct;
% Stim site
[exptInfo.electrodeLocations,~,exptInfo.stimLocation] = getElectrodeLocationFromDateIndex(exptDate,exptIndex);
% File time/day
[exptInfo.indexDur,exptInfo.timeOfDay] = getTimeAndDurationFromIndex(exptDate,exptIndex);
% animal
exptInfo.animal = getAnimalByDateIndex(exptDate,exptIndex);




% Time of peak re stim time
% Response magnitude (pk, inner product)
% Time of stim relative to start of file





