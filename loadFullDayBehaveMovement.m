function [fullDayMovement,fullDayTimestamps] = loadFullDayBehaveMovement(animalName,exptDate)

% animalName = 'MC12';
% exptDate = '19313';

exptList = getExperimentsByAnimalAndDate(animalName,exptDate);
fullDayMovement = 0;
fullDayTimestamps = 0;

for i = 1:size(exptList,1)
    loadX = dir(['M:\PassiveEphys\20' exptList{1,1}(1:2)  '\' exptList{i,1} '\*split*']);
    load([loadX.folder '\' loadX.name],'frameGrid','frameTimeStamps');
    frameDelay = size(frameGrid,3)-size(frameTimeStamps,1);
    if frameDelay > 0
        frameGrid = frameGrid(:,:,frameDelay+1:end);
    end
    fullDayMovement = cat(1,fullDayMovement,behaviorSmoothing(frameGrid));
    fullDayTimestamps = cat(1,fullDayTimestamps,(frameTimeStamps(1:end-1)+fullDayTimestamps(end)));
    clear frameGrid frameTimeStamps
end









