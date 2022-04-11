function medianVals = plotMovementCDFAcrossDays(animalName,subset,filterText,sendToSlack)

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

if ~exist('sendToSlack','var')
    sendToSlack = false;
end

if ~exist('filterText','var')
    filterText = 'Spon';
end

useCDF = true;
thisFigure = figure();
for iExpt = 1:size(subset,1)
    subplot(1,size(subset,1),iExpt);
    workingList = getExperimentsByAnimalAndDate(animalName,subset{iExpt},filterText);
    %workingList = workingList(1,:);
    medianVals = nan(size(subset,1),size(workingList,1));
    for iIndex = 1:size(workingList,1)
        h = getMovementDataFromHTRByDateIndex(workingList{iIndex,1}(1:5),workingList{iIndex,1}(7:9),useCDF);
        % return median values for summary across animals or other
        % comparisons
        midPoint = find(h.YData>0.5,1);
        medianVals(iExpt,iIndex) = h.XData(midPoint);
        % draw the data now
        hold on
        drawnow;
        exptDescription = workingList{iIndex,2}{1,1};
        [~,hourText,~] = getParsedExperimentDescriptionFromText(exptDescription);
        listBuilder{iIndex} = hourText;
    end
    [exptTitle,~,~] = getParsedExperimentDescriptionFromText(exptDescription);
    thisTitle = [animalName ' Movement CDF During ' exptTitle];
    title(thisTitle);
    legend(listBuilder,'Location','SouthEast');
    xlim([0,4]);
    ylabel('Probability');
    xlabel('Arbitrary movement units');
end

figName = thisTitle;
[outPath] = getPathGlobal('animalSaves');
if ~isdir([outPath animalName '\'])
    alertOutput = mkdir(outPath,animalName);
end
outPath = [outPath animalName '\'];
fileName = [outPath figName];
%saveas(thisFigure,[outPath figName]); % this is too large... wtf is
%happening...


print(thisFigure,'-painters',fileName,'-r300','-dpng');
if sendToSlack
    try
        desc = [figName];
        sendSlackFig(desc,[fileName '.png']);
    catch
        disp(['failed to upload ' fileName ' to Slack']);
    end
end

