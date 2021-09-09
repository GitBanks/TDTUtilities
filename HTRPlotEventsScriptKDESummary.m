%%



clear all
reportPlot = false;
gaussLength = 120;
treatments = {
% 'Anlg_5_MeO_DET';
% 'Anlg_Pyr_T'; 
% 'Anlg_6_FDET'; 
% 'Anlg_5_MeO_MiPT'; 
% 'Anlg_4_AcO_DMT'; 
% 'Anlg_5_MeO_pyrT';
% 'Anlg_5_6_DiMeO_MiPT';
% 'DOI_conc'
% 'psilocybin';

% 'Corticosterone_conc';
% 'Lisuride_conc';
'Mifepristone_conc';
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





dateTable = getDateAnimalUniqueByTreatment(treatment);

% ================== data curating =====================
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
excludeAnimal = 'EEG112'; % excluded for a variety of reasons: initial recording parameters; incorrect entries; no video; etc.
dateTable = dateTable(excludeAnimal~=dateTable.AnimalName,:);
excludeAnimal = 'EEG113'; % excluded for a variety of reasons: initial recording parameters; incorrect entries; no video; etc.
dateTable = dateTable(excludeAnimal~=dateTable.AnimalName,:);
excludeAnimal = 'EEG116'; % excluded for a variety of reasons: initial recording parameters; incorrect entries; no video; etc.
dateTable = dateTable(excludeAnimal~=dateTable.AnimalName,:);
excludeAnimal = 'EEG117'; % excluded for a variety of reasons: initial recording parameters; incorrect entries; no video; etc.
dateTable = dateTable(excludeAnimal~=dateTable.AnimalName,:);
excludeAnimal = 'EEG118'; % excluded for a variety of reasons: initial recording parameters; incorrect entries; no video; etc.
dateTable = dateTable(excludeAnimal~=dateTable.AnimalName,:);
excludeAnimal = 'EEG119'; % excluded for a variety of reasons: initial recording parameters; incorrect entries; no video; etc.
dateTable = dateTable(excludeAnimal~=dateTable.AnimalName,:);

% for now just cycle through the drug combinations.  In the future we can
% add a popup or menu or something more clever
plotsToMake = unique(dateTable.DrugList);
% For now, we're going to remove the multiple treatments
a = strfind(plotsToMake,';');
for iCombo = 1:size(plotsToMake,1)
    if iscell(a)
    if size(a{iCombo},2)>1
        dateTable = dateTable(plotsToMake(iCombo)~=dateTable.DrugList,:);
    end
    end
end
% we now only have DOI alone data

removeRows = zeros(size(dateTable,1),1);
for iList = 1:size(dateTable,1)
    listToCheck = getExperimentsByAnimalAndDate(dateTable.AnimalName{iList},dateTable.Date{iList});
    % we'll assume that if index 1 doesn't have a magnet, none of the others
    % will
    dirStrAnalysis = [mousePaths.M 'PassiveEphys\' '20' listToCheck{1,1}(1:2) '\' listToCheck{1,1}(1:5) '-' listToCheck{1,1}(7:9) '\'];
    if ~isempty(dir([dirStrAnalysis '*skipMagnet*']))
        removeRows(iList) = true;
    end 
     % display(listToCheck{1,2});
    if contains(listToCheck{1,2},'25a')
        removeRows(iList) = true;
    end 
end
dateTable(logical(removeRows),:) = [];
% just for DOI where we ran 30 min expts.  in the future, we should store
% the time length of each index so we can make a better decision
if contains(treatment,'DOI_conc')
    dateTable(1:6,:) = [];
end
% ================== end data curating =====================



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
   % lowest = max(size(pdfStruct(iList).timeArray,2),lowest);
end

eventArray = zeros(size(subTable,1),lowest);
for iList = 1:size(pdfStruct,2)
    eventArray(iList,:) = pdfStruct(iList).pdfArray(1:lowest);
end



% jackknife / error estimate here


















HTRevents = figure();
meanPdf = mean(eventArray,1);
 fullTimeArray = pdfStruct(iList).timeArray(1:lowest);
%fullTimeArray = pdfStruct(iList).timeArray(1:end);
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






end

