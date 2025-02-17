clear all
% load('C:\Users\Matt Banks\Desktop\paper data sets\poster2023BandpowerData4.mat',"newWorkingTable")
load('C:\Users\Matt Banks\Desktop\paper data sets\poster2023BandpowerData6.mat',"newWorkingTable")
cytokineList = {'IL6','TNF','IL10'};
groups = unique(newWorkingTable.groupID);
% remove DOI groups for now
groups = groups(groups<8);
groups = groups(~isnan(groups));
groups = groups(groups>0)';
indexHere = 1;
for iGroup = groups %just step through the ones we found
    orderedGroupName{indexHere} = newWorkingTable(newWorkingTable.groupID==groups(indexHere),:).groupText(1,1);
    indexHere = indexHere+1;
end
% crappy hack for this label
orderedGroupName{4} = string([char(orderedGroupName{4}) '_2.5']);
orderedGroupName{5} = string([char(orderedGroupName{4}) '_10']);

% !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
% 12/3/24 SAVE WORKBOOK PAGE #1 (original) HERE!
% remake this 
outputTable = newWorkingTable;
outputTable(:,{'dt','treatments','fullMoveStream','fullTimeArray','fullTimeArrayTOD','data','Animal_proteinTable','IL6first','TNFfirst','delta'}) = [];
writetable(outputTable, 'C:\Users\Matt Banks\Desktop\CytokineDeltaTableStep0.csv');


% ===== new feature 10/21/24 ==============================================
% in this version, we need to figure out which plate these came from to use
% the cytokine data - in order to normalize it to the saline/saline control
fileName = 'W:\Data\Protein Analysis\2024 - unified set\ELISA unified set 23d20.xlsx';
opts = detectImportOptions(fileName);
opts.VariableTypes(13:20) = {'double'}; % needed to clean up how it was imported
% load in the data
fullTable = readtable(fileName,opts);
% just look at wells where we had samples
testWellsTable = fullTable(contains(fullTable.animalName,'EEG'),:);
% grab lists of unique data
uniqueMice = unique(testWellsTable.animalName);
newCol = nan(height(newWorkingTable),1);
newWorkingTable.plateNumber = newCol;
newWorkingTable.plate = newCol;
for iMice = 1:size(uniqueMice,1)
    thisMouse = uniqueMice{iMice};
    uniqueMice{iMice,2} = testWellsTable(contains(testWellsTable.animalName,thisMouse),:).groupID(1);
    [thisRow,~] = find(contains(newWorkingTable.Animal_workingTable,thisMouse),1);
    newWorkingTable(thisRow,"plateNumber") = {uniqueMice{iMice,2}};
end
% we now added a column in newWorkingTable called plateNumber we can
% calculate original salinesaline plate normalization from
% =========================================================================

% let's do all our calculations ahead of time because there are a few steps
% now.  !! careful, these are different groups than the loop below!!! 
% this is for the total protein count
for iCytokine = 1:size(cytokineList,2)
    thisCytokine = cytokineList{iCytokine};
    newWorkingTable.(thisCytokine)=newWorkingTable.(thisCytokine).*newWorkingTable.scaleFactor;
end
% these are now scaled to the total protein count! don't double calculate
% this!


% !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
% 12/3/24 SAVE WORKBOOK PAGE #2 (protein count normalized) HERE!
outputTable = newWorkingTable;
outputTable(:,{'dt','treatments','fullMoveStream','fullTimeArray','fullTimeArrayTOD','data','Animal_proteinTable','IL6first','TNFfirst','delta'}) = [];
writetable(outputTable, 'C:\Users\Matt Banks\Desktop\CytokineDeltaTableStep1.csv');



% now normalize to the saline/saline of each respective plate.
% The two plate groups we want are 1 and three  notes from 10/11/24
% 1,2,5,6 divide by 1
% 3,4,7,8, divide by 3
% making sure these make sense, here are the expected groups:
% 1 = saline/saline (plate 1)
% 2 = saline LPS (plate 1)
% 3 = saline/saline (plate 2)
% 4 = saline / LPS (plate 2)
% 5 = Fluvoxamine / LPS
% 6 = DMT 2.5 / LPS
% 7 = DMT 10 / LPS
% 8 = DOI / LPS
% 9 = DOI / saline!
plateArray = [1,2,5,6,9;...
              3,4,7,8,nan];
for iCytokine = 1:size(cytokineList,2)
    thisCytokine = cytokineList{iCytokine};
    for iPlate = 1:size(plateArray,1)
        ctrlGroup = plateArray(iPlate,1); % this will be the first element of each row
        iPlateLogical = newWorkingTable.plateNumber==ctrlGroup;
        iPlateMean = mean(newWorkingTable(iPlateLogical,:).(thisCytokine),'omitnan');
        for jPlate = 1:size(plateArray,2)
            thisPlateGroup = plateArray(iPlate,jPlate);
%             if thisPlateGroup==8; keyboard; end
            jPlateLogical = newWorkingTable.plateNumber==thisPlateGroup;
            newWorkingTable(jPlateLogical,:).(thisCytokine) = newWorkingTable(jPlateLogical,:).(thisCytokine)./iPlateMean;
%             repmat(iPlate, sum(jPlateLogical), 1)
%             newWorkingTable(jPlateLogical,:).plate = iPlate;
            newWorkingTable.plate(jPlateLogical) = repmat(iPlate, sum(jPlateLogical), 1);
        end 
    end
end
% plate specific saline/saline control performed

% !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
% 12/3/24 SAVE WORKBOOK PAGE #3 (saline/saline plate normalized) HERE!
outputTable = newWorkingTable;
outputTable(:,{'dt','treatments','fullMoveStream','fullTimeArray','fullTimeArrayTOD','data','Animal_proteinTable','IL6first','TNFfirst','delta'}) = [];
writetable(outputTable, 'C:\Users\Matt Banks\Desktop\CytokineDeltaTableStep2.csv');


outputTable = table;
colorSequence = {'b','r','g','c','k','m','y'};
figure
% take the log of data, plot on linear scale, run regression
for iCytokine = 1:size(cytokineList,2)
    thisCytokine = cytokineList{iCytokine};
    subplot(1,3,iCytokine);
    x=[];
    y=[];
    for iGroup = 1:2
        subgroup = newWorkingTable(newWorkingTable.groupID==groups(iGroup),:);
%         thisTag = subgroup.groupLabel{1};
        thisTag = subgroup.groupText{1};
        x = [x;subgroup.(thisCytokine)];
%         y = [y;subgroup.delta];
        y = [y;subgroup.gFitDelta];
        removeThese = isnan(x);
        x(removeThese)=[]; % get rid of nans
        y(removeThese)=[]; 
    end
    x = log10(x);
    tbl = table(x , y);
    mdl = fitlm(tbl,'linear');
    plot(mdl,'LineWidth',1);
    hold on
    mdlStruct(iCytokine).cytokine = thisCytokine;
    mdlStruct(iCytokine).mdl = mdl;
    x=[];
    y=[];
    for iGroup = 1:size(groups,2)
        subgroup = newWorkingTable(newWorkingTable.groupID==groups(iGroup),:);
        thisTag = subgroup.groupText{1};
        x = subgroup.(thisCytokine);
        x = log10(x);
%         y = subgroup.delta;
        y = [subgroup.gFitDelta];
        scatter(x,y,"filled",colorSequence{iGroup});
        hold on
        removeThese = isnan(x);
        x(removeThese)=[]; % get rid of nans
        y(removeThese)=[]; 
        yMean = mean(y);
        xMean = mean(x);
        yStdErr = std(y)/sqrt((size(y,1)-1));
        xStdErr = std(x)/sqrt((size(x,1)-1));
        scatter(xMean,yMean,100,colorSequence{iGroup},"filled");
        hold on
        errorbar(xMean,yMean,-yStdErr,+yStdErr,-xStdErr,+xStdErr,colorSequence{iGroup},'MarkerSize',16);
        outputTable = [outputTable;subgroup];
    end
    title(thisCytokine);
    p1 = scatter(NaN,NaN,"filled",'b');
    p2 = scatter(NaN,NaN,"filled",'r');
    p3 = scatter(NaN,NaN,"filled",'g');
    p4 = scatter(NaN,NaN,"filled",'c');
    p5 = scatter(NaN,NaN,"filled",'k');
%     p6 = scatter(NaN,NaN,"filled",'m');
%     p7 = scatter(NaN,NaN,"filled",'y');
%     legend([p1,p2,p3,p4,p5,p6,p7],orderedGroupName,'Interpreter','none');
    legend([p1,p2,p3,p4,p5],orderedGroupName,'Interpreter','none');
    ylabel('delta change');
    xlabel('cytokine level 4 hours post');
end

% if something will annoy Matt, it's confusing output.  This table is the
% result of numerous attempts using a wide variety of cleaning strategies.
% No need to leave old or irrelevant information there.
outputTable(:,{'dt','treatments','fullMoveStream','fullTimeArray','fullTimeArrayTOD','data','Animal_proteinTable','IL6first','TNFfirst','plateNumber','delta'}) = [];
% writetable(outputTable, 'C:\Users\Matt Banks\Desktop\paper data sets\myTable.csv');
writetable(outputTable, 'C:\Users\Matt Banks\Desktop\CytokineDeltaTableStep3.csv');

