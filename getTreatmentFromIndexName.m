function treatment = getTreatmentFromIndexName(animalName,exptDate)

% requires TDTUtilities on path
% note: probably not the best way to do this. Referencing the drug info
% directly is probably a safer way to do this, but just as an initial fix

[outputList] = getExperimentsByAnimalAndDate(animalName,exptDate,'Spon');
treatment = outputList{contains(outputList(:,1),exptDate(5:end)),2};
treatment = treatment{:};
treatment(strfind(treatment,'Pre-Inj')-1:end) = [];
end