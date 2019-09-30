% use this script to automatically gather relevant recordings for selected
% animals and run movement analysis roiVidAnalysisBinary

%list of animals to run batch analysis on
animals = {'EEG82'}; 

%set search criterion
query = 'Spon'; 

for iAnimal = 1:length(animals)
    animal = animals{iAnimal};
    
    % get list of experiments
    listOfExpts = getExperimentsByAnimal(animal,query); 
    if isempty(listOfExpts{1})
        warning(['No experiments found for ' animal ' under ' query '. Trying again with no query']);
        listOfExpts = getExperimentsByAnimal(animal);
    end
    
    dates = unique(cellfun(@(x) x(1:5), listOfExpts(:,1), 'UniformOutput',false),'stable'); 

    for idate = 1:length(dates)
        date = dates{idate};
        list = getExperimentsByAnimalAndDate(animal,date,query);
        if ~isempty(list)
            exptIDs = cellfun(@(x) x(end-2:end),list(:,1),'UniformOutput',false);
            failed.(animal)(idate,:) = rerunBinary(animal,date,exptIDs);
        end
    end
    clear dates listOfExpts list
end