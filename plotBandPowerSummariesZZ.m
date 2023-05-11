

% remember to run collectSpectraDataFromExptList(setName) to get an updated
% list 


saveFileName = getPathGlobal('ZZ-matTableBandpower');
load(saveFileName);


% temp adjustment
% we're excluding 5 because not enough matched
% workingTable = [workingTable(1:4) workingTable(6:41) workingTable(43:end)]; % eliminate 5, 42 and 48 for PSM
% animals with no PSM data because there are not enough matches: EEG234 


% Now assemble the different sets into a structure we can average across
% groups with 
workingTable = struct2table(workingTable);
nGroups = max(workingTable.group);

%workingTable = sortrows(workingTable,'group'); %not strictly necessary, just looks better
for iGroup = 1:nGroups
    tempT = workingTable(workingTable.group == iGroup,:);
    groupSize = size(tempT,1);
    for ii = 1:groupSize
        group(iGroup).movePre(ii,:) = tempT.data(ii,1).pre.move;
        group(iGroup).movePost(ii,:) = tempT.data(ii,1).post.move;

%         group(iGroup).avgDeltaPre(ii,:) = tempT.data(ii,1).pre.avgDelta;
%         group(iGroup).avgThetaPre(ii,:) = tempT.data(ii,1).pre.avgTheta;
%         group(iGroup).avgAlphaPre(ii,:) = tempT.data(ii,1).pre.avgAlpha;
%         group(iGroup).avgBetaPre(ii,:) = tempT.data(ii,1).pre.avgBeta;
%         group(iGroup).avgGammaPre(ii,:) = tempT.data(ii,1).pre.avgGamma;
% 
%         group(iGroup).avgDeltaPost(ii,:) = tempT.data(ii,1).post.avgDelta;
%         group(iGroup).avgThetaPost(ii,:) = tempT.data(ii,1).post.avgTheta;
%         group(iGroup).avgAlphaPost(ii,:) = tempT.data(ii,1).post.avgAlpha;
%         group(iGroup).avgBetaPost(ii,:) = tempT.data(ii,1).post.avgBeta;
%         group(iGroup).avgGammaPost(ii,:) = tempT.data(ii,1).post.avgGamma;
        
        if isfield(tempT.data(groupSize,1).post,'PSMavgDelta')
            group(iGroup).PSMDeltaPre(ii,:) = tempT.data(ii,1).pre.PSMavgDelta;
            group(iGroup).PSMDeltaPost(ii,:) = tempT.data(ii,1).post.PSMavgDelta;
        else
            warning(['NO PSM DATA FOUND! animal: '  tempT.Animal{ii}])
        end
        group(iGroup).names{ii,1} = tempT.Animal(ii);
        group(iGroup).Sex{ii,1} = tempT.Sex(ii);
    end
end


% % % % boxplot better! % % % %
% nColsForBoxPlot = 2*3*1+3+6; % number will be: nChans (2) x treatments (4) x just delta (1) + movement (just nTreatment) (4) 
nColsForBoxPlot = 12; % movement (4) + treatments (4) * front/rear (2) = 12
boxplotArray = nan(nColsForBoxPlot,15);

xtickLabelstart = {'Sal','Psil','4ACO','6FDET'}; % TODO: pull this from the xls file instead, or save that info in the .mat file to pass along to this point..
colorCodeTreatment = {'k','r','b','g','m','c','k','r','b'};
indexT = 1;

for iGroup = 1:nGroups
    groupSize = length(group(iGroup).movePre);
    boxplotArray(indexT,1:groupSize) = group(iGroup).movePost./group(iGroup).movePre;
    
    xtickLabelArray{indexT} = ['Move ' xtickLabelstart{iGroup}];
    colorCode{indexT} = colorCodeTreatment{iGroup};
    category{indexT} = 'Move';
    indexT = indexT+1;
end

if isfield(group(end),'PSMDeltaPre') % if we have PSM data all the way through the end
    titleText = 'PSMDelta';
    for iGroup = 1:nGroups
        groupSize = length(group(iGroup).movePre);
        boxplotArray(indexT,1:groupSize) = group(iGroup).PSMDeltaPost(:,1)./group(iGroup).PSMDeltaPre(:,1);
        xtickLabelArray{indexT} = ['Delta ' xtickLabelstart{iGroup} ' 1'];
        colorCode{indexT} = colorCodeTreatment{iGroup};
        category{indexT} = 'Delta';
        indexT = indexT+1;
        boxplotArray(indexT,1:groupSize) = group(iGroup).PSMDeltaPost(:,2)./group(iGroup).PSMDeltaPre(:,2);
        xtickLabelArray{indexT} = ['Delta ' xtickLabelstart{iGroup} ' 2'];
        colorCode{indexT} = colorCodeTreatment{iGroup};
        category{indexT} = 'Delta';
        indexT = indexT+1;
    end
end


figure();
scatter(1:nColsForBoxPlot,boxplotArray,'k*');
hold on

% this is if you want to label the data with names or sex or whatever
% groupIncr = [0 0 0 0 1 1 2 2 3 3 4 4];
% for ii = 10:nColsForBoxPlot
%     yLocations = boxplotArray(ii,~isnan(boxplotArray(ii,:)));
%     xLocations = ones(size(yLocations,2),1)*ii;
%     useThese = ~isnan(boxplotArray(ii,:));
% % %     theseNames = group(groupIncr(ii)).names(useThese);
%     theseNames = group(groupIncr(ii)).Sex(useThese);
%     try
%     text(xLocations,yLocations,theseNames);
%     catch
%     end
% end

boxplot(boxplotArray','Colors',char(colorCode));
xlim([0.5,nColsForBoxPlot+.5]);
ylabel('Post injection values (t=0:60) divided by baseline values');
title([titleText ' bandpower changes']);
yline(1,'--');
xline(4.5);
% xline(12.5);
% xline(15.5);
% xline(21.5);
% xline(27.5);
% xline(33.5);
a = findall(gca,'Tag','Box');
ylim([0,3]);
%     legend([a(3) a(2) a(1)], {'Saline Saline','Saline LPS','Fluvoxamine LPS'},'Location','southwest');
% legend([a(18) a(16) a(14) a(12) a(10) a(8) a(6) a(4) a(2)], xtickLabelstart,'Location','northeast');
legend([a(8) a(6) a(4) a(2)], xtickLabelstart,'Location','northeast');


ax = gca;
ax.XTickLabels = {'Sal move','Psil move','4ACO move','6FDET move',...
    'Sal-1','Sal-2','Psil-1','Psil-2','4ACO-1','4ACO-2',...
    '6FDET-1','6FDET-2'};









