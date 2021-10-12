function plotMovementCDFAcrossDays(animalName,subset,filterText)

%subset is chosen in the UI - set of expts
% example data:
% animalName = 'ZZ10';
% subset = {'21624';'21626';'21630'};
% filterText = {'spon'}
%filterText = 'stim/resp';

if ~exist('filterText','var')
    filterText = 'spon';
end

useCDF = true;
figure();
for iExpt = 1:size(subset,1)
%     subplot(1,size(subset,1),iExpt);
    workingList = getExperimentsByAnimalAndDate(animalName,subset{iExpt},filterText);
    workingList = workingList(1,:);
    for iIndex = 1:size(workingList,1)
        h = getMovementDataFromHTRByDateIndex(workingList{iIndex,1}(1:5),workingList{iIndex,1}(7:9),useCDF);
        hold on
        drawnow;
    end
end

legend(subset,'Location','SouthEast');
workingList = getExperimentsByAnimalAndDate(animalName,subset{1},filterText); % just grab the first expt from list
workingList = workingList(1,:);
title(['Movement Across Days: ' workingList{1,2}{1,1}(1:10)]);
xlim([0,2]);

% for iExpt = 1:size(subset,1)
%     subplot(1,size(subset,1),iExpt);
%     title(workingList{iIndex,1}(1:5));
% end


