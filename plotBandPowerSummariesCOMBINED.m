
% remember to run collectSpectraDataFromExptList(setName) to get an updated
% list 


saveFileName = 'M:\PassiveEphys\mouseEEG\combinedBandpowerData.mat';
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

        group(iGroup).avgDeltaPre(ii,:) = tempT.data(ii,1).pre.avgDelta;
        group(iGroup).avgThetaPre(ii,:) = tempT.data(ii,1).pre.avgTheta;
        group(iGroup).avgAlphaPre(ii,:) = tempT.data(ii,1).pre.avgAlpha;
        group(iGroup).avgBetaPre(ii,:) = tempT.data(ii,1).pre.avgBeta;
        group(iGroup).avgGammaPre(ii,:) = tempT.data(ii,1).pre.avgGamma;

        group(iGroup).avgDeltaPost(ii,:) = tempT.data(ii,1).post.avgDelta;
        group(iGroup).avgThetaPost(ii,:) = tempT.data(ii,1).post.avgTheta;
        group(iGroup).avgAlphaPost(ii,:) = tempT.data(ii,1).post.avgAlpha;
        group(iGroup).avgBetaPost(ii,:) = tempT.data(ii,1).post.avgBeta;
        group(iGroup).avgGammaPost(ii,:) = tempT.data(ii,1).post.avgGamma;
        
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
% nColsForBoxPlot = 2*3*1+3+6; % number will be: front/rear (2) x treatments (3) x bands (5) + movement (3) +3 PSM single side
nColsForBoxPlot = 27; % movement (6) + treatments (6) * front/rear (2) = 18
boxplotArray = nan(nColsForBoxPlot,15);

xtickLabelstart = {'Sal,Sal','Sal,LPS','Flvx,LPS','DMT2.5,LPS','DMT10,LPS','BD1063 5,LPS','BD1063 1,LPS','BD1063 .1,LPS','BD1063,Saline'}; % changed!
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
        xtickLabelArray{indexT} = ['Delta ' xtickLabelstart{iGroup} ' A'];
        colorCode{indexT} = colorCodeTreatment{iGroup};
        category{indexT} = 'Delta';
        indexT = indexT+1;
        boxplotArray(indexT,1:groupSize) = group(iGroup).PSMDeltaPost(:,2)./group(iGroup).PSMDeltaPre(:,2);
        xtickLabelArray{indexT} = ['Delta ' xtickLabelstart{iGroup} ' P'];
        colorCode{indexT} = colorCodeTreatment{iGroup};
        category{indexT} = 'Delta';
        indexT = indexT+1;
    end
else
    titleText = 'Delta';
    for iGroup = 1:nGroups
        groupSize = length(group(iGroup).movePre);
        boxplotArray(indexT,1:groupSize) = group(iGroup).avgDeltaPost(:,1)./group(iGroup).avgDeltaPre(:,1);
        xtickLabelArray{indexT} = ['Delta ' xtickLabelstart{iGroup} ' A'];
        colorCode{indexT} = colorCodeTreatment{iGroup};
        category{indexT} = 'Delta';
        indexT = indexT+1;
        boxplotArray(indexT,1:groupSize) = group(iGroup).avgDeltaPost(:,2)./group(iGroup).avgDeltaPre(:,2);
        xtickLabelArray{indexT} = ['Delta ' xtickLabelstart{iGroup} ' P'];
        colorCode{indexT} = colorCodeTreatment{iGroup};
        category{indexT} = 'Delta';
        indexT = indexT+1;
    end
end


figure();
%scatter(1:nColsForBoxPlot,boxplotArray,'k*');
hold on

groupIncr = [0 0 0 0 0 0 0 0 0 1 1 2 2 3 3 4 4 5 5 6 6 7 7 8 8 9 9];
for ii = 10:nColsForBoxPlot
    yLocations = boxplotArray(ii,~isnan(boxplotArray(ii,:)));
    xLocations = ones(size(yLocations,2),1)*ii;
    useThese = ~isnan(boxplotArray(ii,:));
% %     theseNames = group(groupIncr(ii)).names(useThese);
    theseNames = group(groupIncr(ii)).Sex(useThese);
    try
    text(xLocations,yLocations,theseNames);
    catch
    end
end

boxplot(boxplotArray','Colors',char(colorCode));
xlim([0.5,nColsForBoxPlot+.5]);
ylabel('Post injection values (t=60:120) divided by baseline values (t=-90:-30)');
title([titleText ' bandpower changes']);
yline(1,'--');
xline(9.5);
% xline(12.5);
% xline(15.5);
% xline(21.5);
% xline(27.5);
% xline(33.5);
a = findall(gca,'Tag','Box');
ylim([0,3]);
%     legend([a(3) a(2) a(1)], {'Saline Saline','Saline LPS','Fluvoxamine LPS'},'Location','southwest');
legend([a(18) a(16) a(14) a(12) a(10) a(8) a(6) a(4) a(2)], xtickLabelstart,'Location','northeast');
    
ax = gca;
ax.XTickLabels = {'Sal/Sal move','Sal/LPS move','Flv/LPS move','DMT2.5/LPS move','DMT10/LPS move','BD5/LPS move','BD1/LPS move','BD.1/LPS move','BD/Sal move'...
    'Sal/Sal-A','Sal/Sal-P','Sal/LPS-A','Sal/LPS-P','Flv/LPS-A','Flv/LPS-P',...
    'DMT2.5/LPS-A','DMT2.5/LPS-P','DMT10/LPS-A','DMT10/LPS-P','BD5/LPS-A','BD5/LPS-P','BD1/LPS-A','BD1/LPS-P','BD.1/LPS-A','BD.1/LPS-P', 'BD/Sal-A','BD/Sal-P'};









