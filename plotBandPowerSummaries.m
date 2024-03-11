function plotBandPowerSummaries(setName)
% this is the "box plot" or comparison plot
% be sure you've run collectSpectraDataFromExptList(setName)

% dummy variables
% setName = 'combined'
% setName = 'DOIKetanserin';

switch setName
    case 'FLVX' 
        saveFileName = getPathGlobal([setName '-matTableBandpower']);
    case '2020_PSYLOCYBIN_LPS'
%         saveFileName = getPathGlobal([setName '-matTableBandpower']);
    case 'LPS2020' % untested - this is framework only
%         saveFileName = getPathGlobal([setName '-matTableBandpower']);
    case 'Sigma1' % untested - this is framework only
        saveFileName = getPathGlobal([setName '-matTableBandpower']);
    case 'combined' % untested - this is framework only
        saveFileName = getPathGlobal([setName '-matTableBandpower']);
        xtickLabelstart = {'Sal,Sal','Sal,LPS','Flvx,LPS','DMT2.5,LPS','DMT10,LPS','DMT10,Sal','Flvx,Sal'}; % changed!
        groupIncr = [0 0 0 0 0 0 0 1 1 2 2 3 3 4 4 5 5 6 6 7 7]; % this will need to be updated whenever you add groups!!!!!!!
    case 'ZZ' % untested - this is framework only
        saveFileName = getPathGlobal([setName '-matTableBandpower']);
        xtickLabelstart = {'Sal','Psil','4ACO','6FDET'};  % TODO: pull this from the xls file instead, or save that info in the .mat file to pass along to this point..
    case 'DOIKetanserin' % untested - this is framework only
        saveFileName = getPathGlobal([setName '-matTableBandpower']);
        xtickLabelstart = {'Sal,Sal','Sal,LPS','DOI,Sal','DOI,LPS','DOI+Ket,Sal','DOI+Ket,LPS'};  % TODO: pull this from the xls file instead, or save that info in the .mat file to pass along to this point..
        groupIncr = [0 0 0 0 0 0 1 1 2 2 3 3 4 4 5 5 6 6]; 

    case 'poster2023'
        saveFileName = getPathGlobal([setName '-matTableBandpower']);
        xtickLabelstart = {'Sal,Sal','Sal,LPS','Flvx,Sal','Flvx,LPS','DMT10,Sal','DMT2.5,LPS','DMT10,LPS','DOI,Sal','DOI,LPS','DOI+Ket,Sal','DOI+Ket,LPS'};  % TODO: pull this from the xls file instead, or save that info in the .mat file to pass along to this point..
        groupIncr = [0 0 0 0 0 0 0 0 0 0 0 1 1 2 2 3 3 4 4 5 5 6 6 7 7 8 8 9 9 10 10 11 11]; 
    
    case '2020PsilocybinKetWay'
        saveFileName = getPathGlobal([setName '-matTableBandpower']);
        xtickLabelstart = {'DMSO,Sal','DMSO,Psilo','Ketamine','Ketan,Sal','Ketan,Psilo','Sal,Sal','Sal,Psilo','WAY,Sal','Way,Psilo'};  % TODO: pull this from the xls file instead, or save that info in the .mat file to pass along to this point..
        groupIncr = [0 0 0 0 0 0 0 0 0 1 1 2 2 3 3 4 4 5 5 6 6 7 7 8 8 9 9]; 
    
    otherwise
        error('Need an appropriate table name from a recognized list: ''FLVX'' or ''LPS2020'' or ''ZZ'' so far ');
end
load(saveFileName);



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
%         group(iGroup).Sex{ii,1} = tempT.Sex(ii);
    end
end



% % % % boxplot better! % % % %
% nColsForBoxPlot = 2*3*1+3+6; % number will be: nChans (2) x treatments (4) x just delta (1) + movement (just nTreatment) (4) 
% nColsForBoxPlot = 12; % movement (4) + treatments (4) * front/rear (2) = 12
nColsForEphysBoxPlot = nGroups*2; % we're using front and rear
nColsForMoveBoxPlot = nGroups*1; % we're splitting off the movement plot
boxplotEphysArray = nan(nColsForEphysBoxPlot,30);
boxplotMoveArray = nan(nColsForMoveBoxPlot,30);

colorCodeTreatment = {'k','r','b','g','m','c','k','r','b','g','m','c','k','r','b'};
indexT = 1;

for iGroup = 1:nGroups
    groupSize = length(group(iGroup).movePre);
    boxplotMoveArray(indexT,1:groupSize) = group(iGroup).movePost./group(iGroup).movePre;
    xtickLabelArray{indexT} = [xtickLabelstart{iGroup} '-move'];
    colorCodeMove{indexT} = colorCodeTreatment{iGroup};
    category{indexT} = 'Move';
    indexT = indexT+1;
end

indexT = 1;
if isfield(group(end),'PSMDeltaPre') % if we have PSM data all the way through the end
    titleText = '';
    for iGroup = 1:nGroups
        groupSize = length(group(iGroup).movePre);
        boxplotEphysArray(indexT,1:groupSize) = group(iGroup).PSMDeltaPost(:,1)./group(iGroup).PSMDeltaPre(:,1);
        xtickLabelArray{indexT} = [xtickLabelstart{iGroup} '-ante'];
        colorCodeEphys{indexT} = colorCodeTreatment{iGroup};
        category{indexT} = 'Delta';
        indexT = indexT+1;
        boxplotEphysArray(indexT,1:groupSize) = group(iGroup).PSMDeltaPost(:,2)./group(iGroup).PSMDeltaPre(:,2);
        xtickLabelArray{indexT} = [xtickLabelstart{iGroup} '-post'];
        colorCodeEphys{indexT} = colorCodeTreatment{iGroup};
        category{indexT} = 'Delta';
        indexT = indexT+1;
    end
end

figure();
subplot(1,3,1)
scatter(1:nColsForMoveBoxPlot,boxplotMoveArray,'k*');
hold on
subplot(1,3,2:3)
scatter(1:nColsForEphysBoxPlot,boxplotEphysArray,'k*');
hold on




% ==========
% this is if you want to label the data with names or sex or whatever
% find th first non movement column
% round(ii/2) is the way we'll step through the 'double groups'
% ==========
% bandStart = find(groupIncr>0,1);
% for ii = 1:nColsForEphysBoxPlot
%     yLocations = boxplotEphysArray(ii,~isnan(boxplotEphysArray(ii,:)));
%     xLocations = ones(size(yLocations,2),1)*ii;
% 
% %     theseNames = group(round(ii/2)).names;
% %     text(xLocations,yLocations,theseNames);
% 
%     theseNames = group(round(ii/2)).Sex;
%     text(xLocations,yLocations,theseNames);
% end
% ==========



subplot(1,3,1)
boxplot(boxplotMoveArray','Colors',char(colorCodeMove));
ax = gca;
ax.YAxis.Scale ="log";
yline(1,'--');
xlim([0.5,nColsForMoveBoxPlot+.5]);
ylabel('Post injection values (t=0:60) divided by baseline values');
title([titleText ' movement changes']);
ylim([0.08,1.4]);

subplot(1,3,2:3)
boxplot(boxplotEphysArray','Colors',char(colorCodeEphys));
ax = gca;
ax.YAxis.Scale ="log";
yline(1,'--');
xlim([0.5,nColsForEphysBoxPlot+.5]);
ylabel('Post injection values (t=0:60) divided by baseline values');
title([titleText 'PSMDelta bandpower changes']);
ylim([0.5,3.5]);



a = findall(gca,'Tag','Box');
switch setName
    case 'FLVX'         
    case '2020_PSYLOCYBIN_LPS'
    case 'LPS2020' % untested - this is framework only
    case 'Sigma1' % untested - this is framework only        saveFileName = getPathGlobal([setName '-matTableBandpower']);
    case 'combined' % untested - this is framework only
        legend([a(14) a(12) a(10) a(8) a(6) a(4) a(2) ], xtickLabelstart,'Location','northeast');
    case 'ZZ' % untested - this is framework only
        legend([a(8) a(6) a(4) a(2)], xtickLabelstart,'Location','northeast');
    case 'DOIKetanserin'
        legend([a(12) a(10) a(8) a(6) a(4) a(2)], xtickLabelstart,'Location','northeast');
    case 'poster2023'
        legend([a(22) a(20) a(18) a(16) a(14) a(12) a(10) a(8) a(6) a(4) a(2)], xtickLabelstart,'Location','northeast');
    case '2020PsilocybinKetWay'
        legend([a(18) a(16) a(14) a(12) a(10) a(8) a(6) a(4) a(2)], xtickLabelstart,'Location','northeast');
    otherwise
end
%     legend([a(3) a(2) a(1)], {'Saline Saline','Saline LPS','Fluvoxamine LPS'},'Location','southwest');
% 


ax = gca;
ax.XTickLabels = xtickLabelArray; %{'Sal move','Psil move','4ACO move','6FDET move',...
%     'Sal-1','Sal-2','Psil-1','Psil-2','4ACO-1','4ACO-2',...
%     '6FDET-1','6FDET-2'};









