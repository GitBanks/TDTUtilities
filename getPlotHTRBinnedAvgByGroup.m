function [avgCenters,avgCounts,avgSTD] = getPlotHTRBinnedAvgByGroup(thisGroup,thisFile,displayEachAnimal,binSize,displaySummary,nHourPost)
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

if ~exist("nHourPost","var")
    nHours = 2;
end

opts = detectImportOptions(thisFile);
% opts = setvartype(opts, "RecordingID", 'string');
workingTable = readtable(thisFile,opts);

animalDateTable = workingTable(workingTable.exptGroup == thisGroup,:);
treatment = animalDateTable.drug{1};
nHours = animalDateTable.nHours(1);

for iExpt = 1:size(animalDateTable,1)
    animalName = char(animalDateTable.animalName(iExpt));
    disp(['finding bins for: ' animalName]);
    exptDate = char(animalDateTable.exptDate(iExpt));
    [allCenters,allCounts] = getPlotHTRBinnedByAnimalDate(animalName,exptDate,binSize,displayEachAnimal,nHours);
    S(iExpt).allCenters = allCenters;
    S(iExpt).allCounts = allCounts;
end

% We want to find the shortest length pre injection period, and trim the
% others to fit that.  Start by checking all the pre inj bin lengths
for iExpt = 1:size(animalDateTable,1)
    preInjBins(iExpt) = sum(S(iExpt).allCenters < 0);
    postInjBins(iExpt) = sum(S(iExpt).allCenters < 0); % not finished, but we might want to also trim the end, since it will fail if these don;t line up.
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
    % fix any weird center values that may not match exactly (sometimes off
    % by 20 seconds - no big deal)
    S(iExpt).allCenters(1:shortestDurationPreInj) = newCenters; 
    S(iExpt).allCounts = S(iExpt).allCounts(skipThisNumberOfElements+1:end);
end


avgCenters = S(1).allCenters; % these will all be the same.  We made sure of that above.

% avgCounts = S(1).allCounts;
% avgSTD = std(avgCounts);
max(length(S))
newCountArray = zeros(length(S),length(S(1).allCounts));
for iExpt = 1:size(S,2)
    newCountArray(iExpt,:) = S(iExpt).allCounts;
end
avgCounts = mean(newCountArray,1);
avgSTD = std(newCountArray);

err = avgSTD/sqrt(length(avgCounts));

% for iExpt = 2:size(S,2)
%     avgCounts = S(iExpt).allCounts+avgCounts;
% end
% avgCounts = avgCounts/size(S,2);


if displaySummary
    figure;
    bar(avgCenters,avgCounts);
    hold on
    er = errorbar(avgCenters,avgCounts,err);
    er.Color = [0 0 0];                            
    er.LineStyle = 'none';
    
%     xlim([-30,60]);
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



