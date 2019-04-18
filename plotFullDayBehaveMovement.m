function [fullDayMovement] = plotFullDayBehaveMovement(animalName,exptDate)

% animalName = 'MC12';
% exptDate = '19312';

exptList = getExperimentsByAnimalAndDate(animalName,exptDate);
fullDayMovement = [];
fullDayTimestamps = [];

for i = 1:size(exptList,1)
    loadX = dir(['M:\PassiveEphys\20' exptList{1,1}(1:2)  '\' exptList{i,1} '\*split*']);
    load([loadX.folder '\' loadX.name],'frameGrid','frameTimeStamps');
    fullDayMovement = cat(1,fullDayMovement,behaviorSmoothing(frameGrid));
    fullDayTimestamps = cat(1,fullDayTimestamps,frameTimeStamps);
    clear frameGrid frameTimeStamps
end









