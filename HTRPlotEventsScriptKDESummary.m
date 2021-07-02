%%



clear all
reportPlot = false;
gaussLength = 100;
treatments = {
% 'Anlg_5_MeO_DET';
% 'Anlg_Pyr_T'; 
% 'Anlg_6_FDET'; 
% 'Anlg_5_MeO_MiPT'; 
% 'Anlg_4_AcO_DMT'; 
% 'Anlg_5_MeO_pyrT';
% 'Anlg_5_6_DiMeO_MiPT';
'DOI_conc'
'psilocybin';
};



% TODO: for DOI and psilocybin, add descriptions of any additional drugs
% TODO: save the summary data for the grouped animals so we can sort by movement level



for iTreatment = 1:size(treatments,1)

treatment = treatments{iTreatment};

treatmentDisplay = treatment;
if contains(treatment,'_vol')
    treatmentDisplay = strrep(treatmentDisplay,'_vol','');
end
if contains(treatment,'_conc')
    treatmentDisplay = strrep(treatmentDisplay,'_conc','');    
end
if contains(treatment,'Anlg')
    treatmentDisplay = treatment(6:end);
end
if contains(treatment,'_')
    treatmentDisplay = strrep(treatmentDisplay,'_','-');
end



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
    load(fileName,'yEvents','fullTimeArray','fullMagStream');

    pdfStruct(iList).pdfArray = yEvents;
    pdfStruct(iList).timeArray = fullTimeArray;
    pdfStruct(iList).magStream = fullMagStream;
    clear yEvents fullTimeArray
end

% the following will force all experiments displayed here to be the same (minimum length)
lowest = size(pdfStruct(iList).pdfArray,2);
for iList = 2:size(pdfStruct,2)
    lowest = min(size(pdfStruct(iList).pdfArray,2),lowest);
end


HTRevents = figure();


eventArray = zeros(size(subTable,1),lowest);
for iList = 1:size(pdfStruct,2)
    eventArray(iList,:) = pdfStruct(iList).pdfArray(1:lowest);
    %plot(pdfStruct(iList).pdfArray)
end

meanPdf = mean(eventArray,1);
fullTimeArray = pdfStruct(iList).timeArray(1:lowest);
minuteTimeArray = fullTimeArray/60;
plot(minuteTimeArray,meanPdf);
hold on

% TODO!  '60' is hardcoded.  this is easily fixed with getTreatmentInfo()
xl = xline(60,'.',treatmentDisplay,'DisplayName',treatmentDisplay,'LineWidth',4,'Interpreter', 'none');
xl.LabelVerticalAlignment = 'middle';
xl.LabelHorizontalAlignment = 'center';
desc = ['pdf HTR events, ' 'n animals=' num2str(size(pdfStruct,2)) ', width:' num2str(gaussLength) ', drug: ' treatmentDisplay];
title(desc,'Interpreter', 'none');
xlabel('Minutes')
xlim([0,minuteTimeArray(end)]);
fileName = ['M:\PassiveEphys\AnimalData\pdfHTRevents-' num2str(gaussLength) '-' treatment];
saveas(HTRevents,fileName);
print('-painters',fileName,'-r300','-dpng');
if reportPlot
    try
        sendSlackFig(desc,[fileName '.png']);
    catch
        disp(['failed to upload ' fileName ' to Slack']);
    end
end

save(fileName,'meanPdf','minuteTimeArray');






catch
    display(['failed to run ' treatmentDisplay]);
end
end

