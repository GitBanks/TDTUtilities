%'EEG21','EEG27','EEG28','EEG30','EEG22','EEG24','LFP2','EEG26','EEG29',
% animals = {'Opto-01'};%'EEG34','EEG33','EEG35','EEG36','EEG37','EEG49','EEG55','EEG56','EEG57','EEG58','EEG59','EEG60','EEG61','EEG62','EEG65','EEG66','EEG52','EEG53','EEG54','EEG63','EEG64','EEG70','EEG68','EEG69','EEG74','EEG75','EEG76','EEG77','EEG78','EEG79','EEG80','EEG81','EEG14','EEG19'}; %'EEG10'
%'EEG10','EEG11',
animals = {'EEG78'};
% animals = {'EEG18','EEG48',...%125
%     'EEG22','EEG24','LFP2','EEG26','EEG29','EEG34','Opto-01',...%25 %,'Opto01'
%     'EEG21','EEG27','EEG28','EEG30',... %12.5 'EEG19',
%     'EEG14','EEG39','EEG40','EEG41','EEG50','EEG51',... %sham %,'EEG43'
%     'EEG33','EEG35','EEG36','EEG37','EEG49'}; %historic aged
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
        list = getExperimentsByAnimalAndDate(animal,date);
        if ~isempty(list)
            exptIDs = cellfun(@(x) x(end-2:end),list(:,1),'UniformOutput',false);
            if contains(animal,'Opto') %since Opto-01 has a dash, and dashes don't play nicely with structures
                name = 'Opto01';
                failed.(name)(idate,:) = rerunBinary(animal,date,exptIDs);
            else
                failed.(animal)(idate,:) = rerunBinary(animal,date,exptIDs);
            end
        end
    end
    clear dates a listOfExpts
end
    
    