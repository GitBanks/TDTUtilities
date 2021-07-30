function [plotH] = stimRespPeakAnalysisAcrossDays(animal,subset)
% test params
% animal = 'ZZ10';

% First set up our list. 
% Note: This is nearly the same as fileMaint, so consider combining
% these. e.g., have this program instead take a list of expts from
% fileMaint and just plot the stim/resp peaks
listOfAnimalExpts = getExperimentsByAnimal(animal);
descOfAnimalExpts = listOfAnimalExpts(:,2);
listOfAnimalExpts = listOfAnimalExpts(:,1);
sz = [length(listOfAnimalExpts) 3];
varTypes = {'string','string','logical'};
varNames = {'DateIndex','Description','StimRespData'};
exptTable = table('Size',sz,'VariableTypes',varTypes,'VariableNames',varNames);
root = 'M:\PassiveEphys\20';
for iList = 1:length(listOfAnimalExpts)
    exptTable.Description(iList) = descOfAnimalExpts{iList}{1};
    exptDate = listOfAnimalExpts{iList}(1:5);
    exptIndex = listOfAnimalExpts{iList}(7:9);
    exptTable.DateIndex(iList) = [exptDate '-' exptIndex];
    dirStrAnalysis = [root exptDate(1:2) '\' exptDate '-' exptIndex '\'];
    % both description must match and saved data must be there
    if contains(exptTable.Description(iList),'stim/resp') && ~isempty(dir([dirStrAnalysis '*_peakData*']))
        exptTable.StimRespData(iList) = true;
    else
        exptTable.StimRespData(iList) = false;
    end
end
% let's prune our list to just the stim/resp expts
stimRespExptTable = exptTable(exptTable.StimRespData == 1,:);

%here's a way to prune further: a subset of experiments from a user input
% subset={
% '21716'
% '21717'
% '21718'
% '21719'
% '21720'
% '21721'
% '21722'
% '21723'
% };
if exist('subset','var') % if we're working with a subset, we can get some specifics
    stimRespExptTable = stimRespExptTable(contains(stimRespExptTable.DateIndex,subset),:);



    for iDay = 1:size(subset,1)
        treats = getTreatmentInfo(S.animalName,subset{iDay});
        if sum(treats.injIndex) == 1
            listQ = getExperimentsByAnimalAndDate(S.animalName,subset{iDay});
            injectionIndex = listQ{treats.injIndex};
        end
    end


end

% step through the new list
nStimResp = size(stimRespExptTable,1);
nROI = 3;
plotMatrix = zeros(nStimResp,nROI);

exptList = stimRespExptTable.DateIndex;
for iList = 1:nStimResp
    exptDate = exptList{iList}(1:5);
    exptIndex = exptList{iList}(7:9);
    dirStrAnalysis = [root exptDate(1:2) '\' exptDate '-' exptIndex '\'];
    %[exptInfo] = getMetadata(exptDate,exptIndex);  % we're not doing anything?
    load([dirStrAnalysis exptDate '-' exptIndex '_peakData'],'peakData');
    for iROI = 1:size(peakData.ROILabels,1)
%         iPeak = 1;
%         iStim = 1;
        [V,I] = max(max(peakData.pkVals(iROI).data(:,:)));
%         plotMatrix(iList,iROI) = peakData.stimArrayNumeric(I);
        plotMatrix(iList,iROI) = V;
    end
end


plotH = figure();
for iROI = 1:nROI
    subtightplot(4,1,iROI);
    plot(plotMatrix(:,iROI),'x-');
    if iROI == 1
        title([animal ' stim/resp peak value over time']);
    end
    ylabel([peakData.ROILabels(iROI)]);
    %ylim([0,900]);
    xlim([0,nStimResp+1]);
    xticks(1:nStimResp);
    if iROI == 3
        set(gca,'xticklabel',stimRespExptTable.DateIndex);
        xtickangle( 45 );
    end
end







