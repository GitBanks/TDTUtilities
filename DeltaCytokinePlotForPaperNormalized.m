clear all
% load('C:\Users\Matt Banks\Desktop\paper data sets\poster2023BandpowerData4.mat',"newWorkingTable")
load('C:\Users\Matt Banks\Desktop\paper data sets\poster2023BandpowerData5.mat',"newWorkingTable")
cytokineList = {'IL6','TNF','IL10'};
groups = unique(newWorkingTable.groupID);
groups = groups(~isnan(groups));
groups = groups(groups>0)';
indexHere = 1;
for iGroup = groups %just step through the ones we found
    orderedGroupName{indexHere} = newWorkingTable(newWorkingTable.groupID==groups(indexHere),:).groupText(1,1);
    indexHere = indexHere+1;
end

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


% now normalize to the saline/saline of each respective plate.
% The two plate groups we want are 1 and three  notes from 10/11/24
% 1,2,5,6 divide by 1
% 3,4,7,8, divide by 3
plateArray = [1,2,5,6;...
              3,4,7,8];
for iCytokine = 1:size(cytokineList,2)
    thisCytokine = cytokineList{iCytokine};
    for iPlate = 1:size(plateArray,1)
        ctrlGroup = plateArray(iPlate,1); % this will be the first element of each row
        iPlateLogical = newWorkingTable.plateNumber==ctrlGroup;
        iPlateMean = mean(newWorkingTable(iPlateLogical,:).(thisCytokine),'omitnan');
        for jPlate = 1:size(plateArray,2)
            thisPlateGroup = plateArray(iPlate,jPlate);
            jPlateLogical = newWorkingTable.plateNumber==thisPlateGroup;
            newWorkingTable(jPlateLogical,:).(thisCytokine) = newWorkingTable(jPlateLogical,:).(thisCytokine)./iPlateMean;
        end
    end
end
% plate specific saline/saline control performed

figure
colorSequence = {'b','r','g','c','k','m','y'};
sx = scatter(1:7,1:7);



figure
% take the log of data, plot on linear scale, run regression
for iCytokine = 1:size(cytokineList,2)
    thisCytokine = cytokineList{iCytokine};
    subplot(1,3,iCytokine);
    x=[];
    y=[];
    for iGroup = 1:2
        subgroup = newWorkingTable(newWorkingTable.groupID==groups(iGroup),:);
        thisTag = subgroup.groupLabel{1};
        x = [x;subgroup.(thisCytokine)];
        y = [y;subgroup.delta];
        removeThese = isnan(x);
        x(removeThese)=[]; % get rid of nans
        y(removeThese)=[]; 
    end
    x = log10(x);
    tbl = table(x , y);
    mdl = fitlm(tbl,'linear');
    p1 = plot(mdl,'LineWidth',1);
    hold on
    mdlStruct(iCytokine).cytokine = thisCytokine;
    mdlStruct(iCytokine).mdl = mdl;
    x=[];
    y=[];
    for iGroup = 1:size(groups,2)
        subgroup = newWorkingTable(newWorkingTable.groupID==groups(iGroup),:);
        thisTag = subgroup.groupLabel{1};
        x = subgroup.(thisCytokine);
        x = log10(x);
        y = subgroup.delta;
        s1 = scatter(x,y,"filled",colorSequence{iGroup});
        hold on

        removeThese = isnan(x);
        x(removeThese)=[]; % get rid of nans
        y(removeThese)=[]; 

        yMean = mean(y);
        xMean = mean(x);
        yStdErr = std(y)/sqrt((size(y,1)-1));
        xStdErr = std(x)/sqrt((size(x,1)-1));
        s2 = scatter(xMean,yMean,100,colorSequence{iGroup},"filled");
        hold on
        e1 = errorbar(xMean,yMean,-yStdErr,+yStdErr,-xStdErr,+xStdErr,colorSequence{iGroup},'MarkerSize',20);
        % color code
%         errorbar(xMean,yMean,yStdErr,xStdErr,'MarkerSize',20);
    end
    title(thisCytokine);
%     legend([p1(1),s1(1),s2(1)],'From data1','From data2','From data3');
    % colorSequence = {'b','r','g','c','k','m','y'};
    % orderedGroupName = {'sal_sal','sal_LPS','Flu_LPS','DMT_LPS','DMT_LPS','DOI_sal','DOI_LPS'}
%     legend('sal sal','sal LPS','Flu LPS','DMT LPS','DMT LPS','DOI Sal','DOI LPS');
%     legend(orderedGroupName,colorSequence);
%     legend([sx(1),sx(2),sx(3),sx(4),sx(5),sx(6),sx(7)],orderedGroupName);
%     legend([sx(1)],orderedGroupName);
%     legend(orderedGroupName);
    p1 = plot(NaN,NaN,'b');
    p2 = plot(NaN,NaN,'r');
    p3 = plot(NaN,NaN,'g');
    p4 = plot(NaN,NaN,'c');
    p5 = plot(NaN,NaN,'k');
    p6 = plot(NaN,NaN,'m');
    p7 = plot(NaN,NaN,'y');
%     legend([p(1),p(2),p(3),p(4),p(5),p(6),p(7)],orderedGroupName);
    legend([p1,p2,p3,p4,p5,p6,p7],orderedGroupName,'Interpreter','none');
    ylabel('delta change');
    xlabel('cytokine level 4 hours post');
end










% %TODO confirm pg/ml
% for iPlot = 1:size(cytokineList,2)
%     subplot(1,3,iPlot);
% %     if iPlot == 1
% % %         a = findall(gca,'Tag','Scatter');
% % %         legend([a(6) a(5) a(4) a(3) a(2) a(1)], xtickLabelstart,'Location','northeast');
% %         legend(orderedGroupName,'Interpreter','none');
% %     end
% %     ylim([0.25,3]);
% %     set(gca, 'XScale', 'log');
% end
% % Matt gacve this code
%  data1 = 10*ones(10,4)+randn(10,4);
%  t1    = (0:1:9);
%  figure();
%  p1 = plot(t1,data1,'bo');
%  hold on
%  data2 = 25*ones(100,4)+2*randn(100,4);
%  t2    = (0:0.1:9.9);
%  p2 = plot(t2,data2,'rx');
%  legend([p1(1),p2(1)],'From data1','From data2');