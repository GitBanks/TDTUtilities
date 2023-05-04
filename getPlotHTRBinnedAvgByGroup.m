function [avgCenters,avgCounts] = getPlotHTRBinnedAvgByGroup(thisGroup,thisFile,displayEachAnimal,binSize,displaySummary)
% for now, this works by giving the function a drug name, but we also would
% like it to accept a list of animals

% treatments = {
% % 'saline0p9_vol'
% 'Anlg_5_MeO_DET';
% 'Anlg_Pyr_T'; 
% 'Anlg_6_FDET'; 
% 'Anlg_5_MeO_MiPT'; 
% 'Anlg_4_AcO_DMT'; 
% 'Anlg_5_MeO_pyrT';
% 'Anlg_5_6_DiMeO_MiPT';
% 'DOI_conc'
% 'psilocybin';
% };
% treatmentDisplay = treatments;
% 
% treatment = 'Anlg_6_FDET';
% % treatment = 'psilocybin';
% animalDateTable = getAnimalDayTableByTreatment(treatment); we're no
% longer loading in using this getAnimalDayTableByTreatment

% test params
% displayEachAnimal = false;
% binSize = 5;
% thisGroup = 2; % work this in as a parameter
% thisFile = getPathGlobal('banksLocalHTRData');
% displaySummary = true


opts = detectImportOptions(thisFile);
% opts = setvartype(opts, "RecordingID", 'string');
workingTable = readtable(thisFile,opts);

animalDateTable = workingTable(workingTable.exptGroup == thisGroup,:);
treatment = animalDateTable.drug{1};

for iExpt = 1:size(animalDateTable,1)
    animalName = char(animalDateTable.animalName(iExpt));
    disp(['finding bins for: ' animalName]);
    exptDate = char(animalDateTable.exptDate(iExpt));
    [allCenters,allCounts] = getPlotHTRBinnedByAnimalDate(animalName,exptDate,binSize,displayEachAnimal);
    S(iExpt).allCenters = allCenters;
    S(iExpt).allCounts = allCounts;
end

% We want to find the shortest length pre injection period, and trim the
% others to fit that.  Start by checking all the pre inj bin lengths
for iExpt = 1:size(animalDateTable,1)
    preInjBins(iExpt) = sum(S(iExpt).allCenters < 0);
end
% find the shortest
shortestDurationPreInj = min(preInjBins);
% while we're at it, make the bin centers consistant
newCenters = -binSize/2:-binSize:-shortestDurationPreInj*binSize-binSize/2;
newCenters = sort(newCenters(1:shortestDurationPreInj));
% trim the others to fit
for iExpt = 1:size(animalDateTable,1)
    skipThisNumberOfElements = preInjBins(iExpt)-shortestDurationPreInj;
    S(iExpt).allCenters = S(iExpt).allCenters(skipThisNumberOfElements+1:end);
    S(iExpt).allCenters(1:shortestDurationPreInj) = newCenters;
    S(iExpt).allCounts = S(iExpt).allCounts(skipThisNumberOfElements+1:end);
end


avgCenters = S(1).allCenters;
avgCounts = S(1).allCounts;

for iExpt = 2:size(S,2)
    avgCounts = S(iExpt).allCounts+avgCounts;
end
avgCounts = avgCounts/size(S,2);


if displaySummary
    figure;
    bar(avgCenters,avgCounts);
    title([treatment ' n=' num2str(size(S,2))]);
    xlabel('min (5 min bins)');
    ylabel('Average HTR');
end




% seed Counts and centers
% validCounts = S(1).allCenters > 0;
% avgCenters = S(1).allCenters(validCounts);
% avgCounts = S(1).allCounts(validCounts);
% preInjCounts = S(1).allCenters < 0;
% preInjAvg = sum(S(1).allCounts(preInjCounts))/sum(preInjCounts);
% avgCounts = avgCounts/preInjAvg;
% 
% for iExpt = 2:size(S,2)
%     validCounts = S(iExpt).allCenters > 0;
%     preInjCounts = S(iExpt).allCenters < 0;
%     preInjAvg = sum(S(iExpt).allCounts(preInjCounts))/sum(preInjCounts);
%     avgCounts = avgCounts+(S(iExpt).allCounts(validCounts)/preInjAvg);
% end



