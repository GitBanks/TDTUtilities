function plotMovementCDFAcrossDays(animalName,subset,filterText)

%subset is chosen in the UI - set of expts
% example data:
% animalName = 'ZZ10';
% subset = {'21624';'21626';'21630'};
% filterText = {'spon'}
% 
% animalName = 'Mag024';
% subset = {'21d07'};
% filterText = {'Spon'}


%filterText = 'stim/resp';

if ~exist('filterText','var')
    filterText = 'Spon';
end

useCDF = true;
figure();
for iExpt = 1:size(subset,1)
    subplot(1,size(subset,1),iExpt);
    workingList = getExperimentsByAnimalAndDate(animalName,subset{iExpt},filterText);
    %workingList = workingList(1,:);
    for iIndex = 1:size(workingList,1)
        h = getMovementDataFromHTRByDateIndex(workingList{iIndex,1}(1:5),workingList{iIndex,1}(7:9),useCDF);
        hold on
        drawnow;
        exptDescription = workingList{iIndex,2}{1,1};
        [~,hourText,~] = getParsedExperimentDescriptionFromText(exptDescription);
        listBuilder{iIndex} = hourText;
    end

    [exptTitle,~,~] = getParsedExperimentDescriptionFromText(exptDescription);
    title([animalName ' Movement During ' exptTitle]);
    legend(listBuilder,'Location','SouthEast');
    xlim([0,4]);
end



