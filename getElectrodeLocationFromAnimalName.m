function [electrodeLocation,map,stmInfo] = getElectrodeLocationFromAnimalName(animalName)
% written by Jack!
allAnimalExpt = getExperimentsByAnimal(animalName);
ElectrodeLocationDate = allAnimalExpt{1}(1:5);
ElectrodeLocationIndex = allAnimalExpt{1}(7:9);
[electrodeLocation,map,stmInfo] = getElectrodeLocationFromDateIndex(ElectrodeLocationDate,ElectrodeLocationIndex);
%electrodeLocationplot = find(~rem(map,2)==0);