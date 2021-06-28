%%

% %treatment = 'Anlg_6_FDET'; 
% treatment = 'DOI_conc';
% %treatment = 'Anlg_5_MeO_MiPT'; 
% treatment = 'Anlg_Pyr_T'; 
% %treatment = 'Anlg_4_AcO_DMT'; 
% treatment = 'Anlg_5_MeO_pyrT';
% treatment = 'Anlg_5_6_DiMeO_MiPT';
%  treatment = 'Anlg_5_MeO_DET';

clear all
gaussLength = 100;
treatments = {
'Anlg_Pyr_T'
'Anlg_5_MeO_pyrT'
'Anlg_5_6_DiMeO_MiPT'
'Anlg_5_MeO_DET'
'DOI_conc'
};

for iTreatment = 1:size(treatments,1)

treatment = treatments{iTreatment};

HTRPlotEventsScriptKDE(treatment,gaussLength)






try

dateTable = getDateAnimalUniqueByTreatment(treatment);
excludeAnimal = 'ZZ05'; % there should really be a 'hasMagnet' flag in the database
dateTable = dateTable(excludeAnimal~=dateTable.AnimalName,:);
excludeAnimal = 'Dummy_Test';
dateTable = dateTable(excludeAnimal~=dateTable.AnimalName,:);
excludeAnimal = 'ZZ07';
dateTable = dateTable(excludeAnimal~=dateTable.AnimalName,:);
excludeAnimal = 'ZZ06';
dateTable = dateTable(excludeAnimal~=dateTable.AnimalName,:);
excludeAnimal = 'ZZ08';
dateTable = dateTable(excludeAnimal~=dateTable.AnimalName,:);


removeRows = zeros(size(dateTable,1),1);
for iList = 1:size(dateTable,1)
    listToCheck = getExperimentsByAnimalAndDate(dateTable.AnimalName{iList},dateTable.Date{iList});
    % we'll assume that if index 1 doesn't have a magnet, none of the others
    % will
    dirStrAnalysis = [mousePaths.M 'PassiveEphys\' '20' listToCheck{1,1}(1:2) '\' listToCheck{1,1}(1:5) '-' listToCheck{1,1}(7:9) '\'];
    if ~isempty(dir([dirStrAnalysis '*skipMagnet*']))
        removeRows(iList) = true;
    end 
end
dateTable(logical(removeRows),:) = [];

% gaussLength = 60;
subTable = dateTable;
for iList = 1:size(subTable,1)
    
    
    rootFolder = ['M:\PassiveEphys\AnimalData\' subTable.AnimalName{iList}];
    fileName = [rootFolder '\pdfHTRevents-' num2str(gaussLength) '-' treatment];
    load(fileName,'yEvents','fullTimeArray');

    pdfStruct(iList).pdfArray = yEvents;
    pdfStruct(iList).timeArray = fullTimeArray;
    clear yEvents fullTimeArray
end

lowest = size(pdfStruct(iList).pdfArray,2);
for iList = 2:size(pdfStruct,2)
    lowest = min(size(pdfStruct(iList).pdfArray,2),lowest);
end

%figure();
eventArray = zeros(size(subTable,1),lowest);
for iList = 1:size(pdfStruct,2)
    eventArray(iList,:) = pdfStruct(iList).pdfArray(1:lowest);
    plot(pdfStruct(iList).pdfArray)
    %hold on
end


meanPdf = mean(eventArray,1);


HTRevents = figure();
dataFinal = smooth(pdfStruct(iList).timeArray(1:lowest),2000);
plot(dataFinal,meanPdf);
hold on
xl = xline(3600,'.',treatment,'DisplayName',treatment,'LineWidth',4,'Interpreter', 'none');
xl.LabelVerticalAlignment = 'middle';
xl.LabelHorizontalAlignment = 'center';

desc = ['pdf HTR events, ' 'n animals=' num2str(size(pdfStruct,2)) ', width:' num2str(gaussLength) ', drug: ' treatment];


title(desc,'Interpreter', 'none');
xlabel('Seconds')


fileName = ['M:\PassiveEphys\AnimalData\\pdfHTRevents-' num2str(gaussLength) '-' treatment];
saveas(HTRevents,fileName);

print('-painters',fileName,'-r300','-dpng');
try
    sendSlackFig(desc,[fileName '.png']);
catch
    disp(['failed to upload ' fileName ' to Slack']);
end


catch
    display(['failed to run ' treatment]);
end

    
end

