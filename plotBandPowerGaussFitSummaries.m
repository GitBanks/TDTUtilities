function plotBandPowerGaussFitSummaries(workingTable)
% I rewrote this to work on the Gaussian fits and to accept a table
% setName = 'poster2023';

nGroups = max(workingTable.group);
xtickLabelstart = {'Sal,Sal','Sal,LPS','Flvx,Sal','Flvx,LPS','DMT10,Sal','DMT2.5,LPS','DMT10,LPS','DOI,Sal','DOI,LPS','DOI+Ket,Sal','DOI+Ket,LPS'}; 
bands = {'delta','theta','alpha','beta','gamma'};

%workingTable = sortrows(workingTable,'group'); %not strictly necessary, just looks better
for iGroup = 1:nGroups
    tempT = workingTable(workingTable.group == iGroup,:);
    groupSize = size(tempT,1);
    for ii = 1:groupSize
        group(iGroup).delta(ii,1) = tempT.gFitDelta(ii);
        group(iGroup).theta(ii,1) = tempT.gFitTheta(ii);
        group(iGroup).gamma(ii,1) = tempT.gFitGamma(ii);
        group(iGroup).alpha(ii,1) = tempT.gFitAplha(ii);
        group(iGroup).beta(ii,1) = tempT.gFitBeta(ii);
%         group(iGroup).names{ii,1} = tempT.Animal(ii);
        group(iGroup).Sex{ii,1} = tempT.Sex(ii);
    end
end

% %create a nice table for matt - alternatively, just do this and save and
% %skip plotting?
% newTabCol = nan(height(workingTable), 1);
% workingTable.("gTrimRatio") = newTabCol;
% workingTable.("PSMavgRatio") = newTabCol;
% for iRow = 1:size(workingTable,1)
%     trimChange = workingTable.data(iRow,1).post.GTrimAvgDelta/workingTable.data(iRow,1).pre.GTrimAvgDelta; 
%     workingTable(iRow,"gTrimRatio") = {trimChange};
%     trimChange = workingTable.data(iRow,1).post.PSMavgDelta/workingTable.data(iRow,1).pre.PSMavgDelta; 
%     workingTable(iRow,"PSMavgRatio") = {trimChange};
%     workingTable(iRow,"groupLabel") = xtickLabelstart(workingTable(iRow,"group").group);
% end
% save(saveFileName,"workingTable");


for iBand = 1:size(bands,2)
    thisBand = bands{iBand};

    nColsForEphysBoxPlot = nGroups; % we're using front and rear
    boxplotEphysArray = nan(nColsForEphysBoxPlot,30);
    colorCodeTreatment = {'k','r','b','g','m','c','k','r','b','g','m','c','k','r','b'};
    indexT = 1;
    for iGroup = 1:nGroups
        groupSize = length(group(iGroup).delta);
        boxplotEphysArray(indexT,1:groupSize) = group(iGroup).(thisBand)(:,1);
        xtickLabelArray{indexT} = [xtickLabelstart{iGroup}];
        colorCodeEphys{indexT} = colorCodeTreatment{iGroup};
        category{indexT} = thisBand;
        indexT = indexT+1;
    end
    
    
    figure();
    scatter(1:nColsForEphysBoxPlot,boxplotEphysArray,'k*');
    hold on

    % ==========
    % this is if you want to label the data with names or sex or whatever
    % find th first non movement column
    % round(ii/2) is the way we'll step through the 'double groups'
    % ==========
%     bandStart = find(groupIncr>0,1);
%     for ii = 1:nColsForEphysBoxPlot
%         yLocations = boxplotEphysArray(ii,~isnan(boxplotEphysArray(ii,:)));
%         xLocations = ones(size(yLocations,2),1)*ii;
% %         theseNames = group(round(ii/2)).names;
% %         text(xLocations,yLocations,theseNames);
%         theseNames = group(ii).Sex;
%         text(xLocations,yLocations,theseNames);
%         clear yLocations xLocations theseNames
%     end

    % % ==========
    boxplot(boxplotEphysArray','Colors',char(colorCodeEphys));
    ax = gca;
    ax.YAxis.Scale ="log";
    yline(1,'--');
    xlim([0.5,nColsForEphysBoxPlot+.5]);
    ylabel('Post injection window values divided by baseline values');
    title(['mixed model Gaussian fit ' thisBand ' changes']);
    
    ylim([0.5,3.5]);
    a = findall(gca,'Tag','Box');
    % legend([a(22) a(20) a(18) a(16) a(14) a(12) a(10) a(8) a(6) a(4) a(2)], xtickLabelstart,'Location','northeast');
    legend([a(11) a(10) a(9) a(8) a(7) a(6) a(5) a(4) a(3) a(2) a(1)], xtickLabelstart,'Location','northeast');
    ax = gca;
    ax.XTickLabels = xtickLabelArray;


end





