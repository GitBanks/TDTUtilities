
animals = {'LFP11','LFP13'};

for iAnimal = 1:length(animals)
    animal = animals{iAnimal};
    query = 'Spon';
    listOfExpts = getExperimentsByAnimal(animal,query);
    if isempty(listOfExpts{1})
        warning(['No experiments found for ' animal ' under ' query '. Trying again with no query']);
        listOfExpts = getExperimentsByAnimal(animal);
    end
    
    for k = 1:length(listOfExpts)
        a(k) = {listOfExpts{k}(1:5)};
    end
    dates = unique(a)';
    
    for idate = 1:length(dates)
        date = dates{idate};
        list = getExperimentsByAnimalAndDate(animal,date,query);
        if ~isempty(list)
            exptIDs = cellfun(@(x) x(end-2:end),list(:,1),'UniformOutput',false);
            failed.(animal)(idate,:) = rerunBinary(animal,date,exptIDs);
        end
    end
    clear dates a listOfExpts
end


% if contains(animal,'Opto') %since Opto-01 has a dash, and dashes don't play nicely with structures
%     name = 'Opto01';
%     failed.(name)(idate,:) = rerunBinary(animal,date,exptIDs);
% else
% end
    