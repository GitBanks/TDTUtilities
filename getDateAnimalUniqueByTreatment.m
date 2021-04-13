function dateTable = getDateAnimalUniqueByTreatment(treatment)

%treatment = 'DOI_conc';

%Given a treatment
% 1. load table of expts with getAnimalsByTreatment
% 2. sort table by date (then animal)


[exptTable] = getAnimalsByTreatment(treatment);
exptTable = sortrows(exptTable,'Date');

dateList = unique(exptTable.Date);

sz = [1 3];
varTypes = {'string','string','string'};
varNames = {'AnimalName','Date','DrugList'};
dateTable = table('Size',sz,'VariableTypes',varTypes,'VariableNames',varNames);

indexer = 1;
warning('off');
for iDate = 1:length(dateList)
    % logical array of just the animal names for a specific date
    animalsToday = unique(exptTable.AnimalName(exptTable.Date == dateList(iDate)));
    for iAnimals = 1:length(animalsToday)
        dateTable.AnimalName(indexer) = animalsToday(iAnimals);
        dateTable.Date(indexer) = dateList(iDate);
        logicalRange = (exptTable.Date == dateList(iDate))&(exptTable.AnimalName == animalsToday(iAnimals));
        theseDrugs = exptTable.Druglist(logicalRange);
        dateTable.DrugList(indexer) = theseDrugs(1);
        indexer = indexer+1;
    end
    clear animalsToday
end
warning('on');






