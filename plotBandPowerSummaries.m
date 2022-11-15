function plotBandPowerSummaries(setName)

switch setName
    case 'FLVX'
        saveFileName = 'M:\PassiveEphys\mouseEEG\FLVXBandpowerData.mat';

    case 'LPS2020'
        saveFileName = 'M:\PassiveEphys\mouseEEG\LPS2020BandpowerData.mat';

    case '2020_PSYLOCYBIN_LPS'
        saveFileName = 'M:\PassiveEphys\mouseEEG\2020PsilocybinLPSBandpowerData.mat';

    case 'ZZ'
        saveFileName = 'M:\PassiveEphys\mouseEEG\ZZBandpowerData.mat';
        disp('If you tried using ZZ here - if you see this message, be sure the xls file exists, then take out this disp and keyboard statements.  This entry here is only to show how to add ZZ data to this switch')
        keyboard
    otherwise
        error('Need an appropriate table name from a recognized list: ''FLVX'' or ''LPS2020'' or ''ZZ'' so far ');
end

load(saveFileName);

% Now assemble the different sets into a structure we can average across
% groups with 
workingTable = struct2table(workingTable);
nGroups = size(unique(workingTable.group),1);
%workingTable = sortrows(workingTable,'group'); %not strictly necessary, just looks better
for iGroup = 1:nGroups
    tempT = workingTable(workingTable.group == iGroup,:);
    for ii = 1:size(tempT,1)
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
        
    end
    % also grab some sample text to auto-label things
    nDrugs = size(tempT.drugTOD{ii,1},2);
    xtickLabelstart{1,iGroup} = [];
    legendText{1,iGroup} = [];
    for iii = 1:nDrugs
        xtickLabelstart{1,iGroup} = [xtickLabelstart{1,iGroup} tempT.drugTOD{ii,1}(iii).what(1:3) ' '];
        legendText{1,iGroup} = [legendText{1,iGroup} tempT.drugTOD{ii,1}(iii).what ' '];
    end
end




% % % % boxplot better! % % % %
nColsForBoxPlot = 2*3*5+3; % number will be: front/rear (2) x treatments (3) x bands (5) + movement (3) 
boxplotArray = nan(nColsForBoxPlot,10);
indexT = 1;
% xtickLabelstart = {'Sal,Sal','Sal,LPS','Flvx,LPS'}; % changed!
% legendText = {'Saline Saline','Saline LPS','Fluvoxamine LPS'};
colorCodeTreatment = {'k','r','b'};

for iGroup = 1:nGroups
    groupSize = length(group(iGroup).movePre);
    boxplotArray(indexT,1:groupSize) = group(iGroup).movePost./group(iGroup).movePre;
    xtickLabelArray{indexT} = ['Move ' xtickLabelstart{iGroup}];
    colorCode{indexT} = colorCodeTreatment{iGroup};
    category{indexT} = 'Move';
    indexT = indexT+1;
end

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

for iGroup = 1:nGroups
    groupSize = length(group(iGroup).movePre);
    boxplotArray(indexT,1:groupSize) = group(iGroup).avgThetaPost(:,1)./group(iGroup).avgThetaPre(:,1);
    xtickLabelArray{indexT} = ['Theta ' xtickLabelstart{iGroup} ' A'];
    colorCode{indexT} = colorCodeTreatment{iGroup};
    category{indexT} = 'Theta';
    indexT = indexT+1;
    boxplotArray(indexT,1:groupSize) = group(iGroup).avgThetaPost(:,2)./group(iGroup).avgThetaPre(:,2);
    xtickLabelArray{indexT} = ['Theta ' xtickLabelstart{iGroup} ' P'];
    colorCode{indexT} = colorCodeTreatment{iGroup};
    category{indexT} = 'Theta';
    indexT = indexT+1;
end

for iGroup = 1:nGroups
    groupSize = length(group(iGroup).movePre);
    boxplotArray(indexT,1:groupSize) = group(iGroup).avgAlphaPost(:,1)./group(iGroup).avgAlphaPre(:,1);
    xtickLabelArray{indexT} = ['Alpha ' xtickLabelstart{iGroup} ' A'];
    colorCode{indexT} = colorCodeTreatment{iGroup};
    category{indexT} = 'Alpha';
    indexT = indexT+1;
    boxplotArray(indexT,1:groupSize) = group(iGroup).avgAlphaPost(:,2)./group(iGroup).avgAlphaPre(:,2);
    xtickLabelArray{indexT} = ['Alpha ' xtickLabelstart{iGroup} ' P'];
    colorCode{indexT} = colorCodeTreatment{iGroup};
    category{indexT} = 'Alpha';
    indexT = indexT+1;
end


for iGroup = 1:nGroups
    groupSize = length(group(iGroup).movePre);
    boxplotArray(indexT,1:groupSize) = group(iGroup).avgBetaPost(:,1)./group(iGroup).avgBetaPre(:,1);
    xtickLabelArray{indexT} = ['Beta ' xtickLabelstart{iGroup} ' A'];
    colorCode{indexT} = colorCodeTreatment{iGroup};
    category{indexT} = 'Beta';
    indexT = indexT+1;
    boxplotArray(indexT,1:groupSize) = group(iGroup).avgBetaPost(:,2)./group(iGroup).avgBetaPre(:,2);
    xtickLabelArray{indexT} = ['Beta ' xtickLabelstart{iGroup} ' P'];
    colorCode{indexT} = colorCodeTreatment{iGroup};
    category{indexT} = 'Beta';
    indexT = indexT+1;
end

for iGroup = 1:nGroups
    groupSize = length(group(iGroup).movePre);
    boxplotArray(indexT,1:groupSize) = group(iGroup).avgGammaPost(:,1)./group(iGroup).avgGammaPre(:,1);
    xtickLabelArray{indexT} = ['Gamma ' xtickLabelstart{iGroup} ' A'];
    colorCode{indexT} = colorCodeTreatment{iGroup};
    category{indexT} = 'Gamma';
    indexT = indexT+1;
    boxplotArray(indexT,1:groupSize) = group(iGroup).avgGammaPost(:,2)./group(iGroup).avgGammaPre(:,2);
    xtickLabelArray{indexT} = ['Gamma ' xtickLabelstart{iGroup} ' P'];
    colorCode{indexT} = colorCodeTreatment{iGroup};
    category{indexT} = 'Gamma';
    indexT = indexT+1;
end




figure();
scatter(1:nColsForBoxPlot,boxplotArray,'k*');
hold on
boxplot(boxplotArray','Colors',char(colorCode));

xlim([0.5,nColsForBoxPlot+.5]);
ylabel('Post injection values (t=60:120) divided by baseline values (t=-90:-30)');
title('Movement and bandpower changes under control, acute inflammation, and fluvoxamine pretreatment');
xticklabels(xtickLabelArray);
yline(1,'--');
xline(3.5);
xline(9.5);
xline(15.5);
xline(21.5);
xline(27.5);
a = findall(gca,'Tag','Box');
legend([a(33) a(32) a(31)], legendText);
ylim([0,6])



