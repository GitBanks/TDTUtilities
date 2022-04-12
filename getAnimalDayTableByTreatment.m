function animalDateTable = getAnimalDayTableByTreatment(treatment)
% test input
% treatment = 'Fluvoxamine'

workingTable = getAnimalsByTreatment(treatment);
theseDates = unique(workingTable.Date);
animalDateTable = table();
tempIndex = 1;
for iDate = 1:length(theseDates)
    oneDateTable = workingTable(workingTable.Date==theseDates(iDate),:);
    theseDrugs = unique(oneDateTable.Druglist);
%     if size(theseDrugs) > 1
%        warning('more than one treatment this day may result in inaccurate listing'); 
%     end

    theseSubjects = unique(oneDateTable.AnimalName);
    for iSubject = 1:length(theseSubjects)
        %add treatment information
        treatments = getTreatmentInfo(char(theseSubjects(iSubject)),char(theseDates(iDate)));
        warning('off','all');
        
        animalDateTable.AnimalName(tempIndex) = theseSubjects(iSubject);
        animalDateTable.Date(tempIndex) = theseDates(iDate);
        
        animalDateTable.Drug1(tempIndex) = convertCharsToStrings(treatments.pars{1,1});
        animalDateTable.Drug1Dose(tempIndex) = treatments.vals(1,size(treatments.vals,2));
        animalDateTable.Drug2(tempIndex) = convertCharsToStrings(treatments.pars{2,1});
        animalDateTable.Drug2Dose(tempIndex) = treatments.vals(2,size(treatments.vals,2));

        animalDateTable.Druglist(tempIndex) = theseDrugs(1);
        warning('on','all');
        tempIndex = tempIndex+1;
    end
    
    
end