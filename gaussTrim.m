function [avgHighMvtRatio,avgHighDeltaRatio,pInclude] = gaussTrim(animalName,exptDate,plotOption)
% NOTE: maybe we want to load by animal name and date instead of handing it
% a table?????? since most of out set is in the animalName Date format?

% Gaussian Trim process outline
% Sean Grady 5/12/24
% inspired and directed by Bryan's original code in R, he pointed out a
% matlab function.
% Given: a table (previously created for PSM) of time segments (usually 4 
% seconds) taken from control and drug treatment periods (usually an hour 
% each) with movement values, do the following:
% 1. combine movement for baseline and peak
% 2. use sqrt of movement values
% 3. sum the two gaussians using fitgmdist and cluster
% 4. take larger mean (more active movement) and exclude those not in it
% 4b. ---be sure to track how many are included or not
% 4c. allow plotting to show results
% 5. output average

% from Bryan
% We combine baseline and peak movement values, take square root, fit two 
% gaussian distributions to the data, exclude the data that better fit the 
% smaller mean distribution ("still"/perhaps asleep), retaining the data 
% with movement scores corresponding to the distribution with larger mean
if ~exist("plotOption","var")
    plotOption = true;
end
% load in a table
% animalName = 'EEG367';
% exptDate = '23906';
tablePath = [getPathGlobal('animalSaves') animalName '\PSM_' animalName '_' exptDate '.csv'];
% tablePath = 'M:\PassiveEphys\AnimalData\EEG367\PSM_EEG367_23906.csv';
segmentTable = readtable(tablePath);
% STEP 1 & 2: can be in the same line
mvmt = sqrt(segmentTable.meanMovement);
deltaPower = (segmentTable.deltaA+segmentTable.deltaP)/2;
% STEP 3
X = [mvmt];
gmfit = fitgmdist(X,2);
clusterX = cluster(gmfit,X); % Cluster index 
% for extracting the high movement data:
[~,ia] = max(gmfit.mu); % ia will be the index of the cluster with larger mean
highMvtIndices = clusterX == ia(1);
pInclude = sum(highMvtIndices)/size(mvmt,1);

% if plotOption
%     figure
%     subplot(2,1,1);
%     scatter(mvmt(~highMvtIndices),deltaPower(~highMvtIndices),'kx');
%     hold on
%     scatter(mvmt(highMvtIndices),deltaPower(highMvtIndices));
%     legend({'exclude','include'});
%     title(['Bryan''s 1D gaussian trim method. total percent included: ' num2str(pInclude)]);
%     xlim([0,2]);
% end

% this is what is included out of everything under consideration.
% What we want is to use these "accepted" results on the two seperate
% periods.
mvmtPeak = mvmt(highMvtIndices & segmentTable.isPeak);
mvmtCtrl = mvmt(highMvtIndices & ~segmentTable.isPeak);
deltaPeak = deltaPower(highMvtIndices & segmentTable.isPeak);
deltaCtrl = deltaPower(highMvtIndices & ~segmentTable.isPeak);

ctrlP = size(mvmtCtrl,1)/size(mvmt(~segmentTable.isPeak),1);
peakP = size(mvmtPeak,1)/size(mvmt(segmentTable.isPeak==1),1);

% if plotOption
%     subplot(2,1,2);
%     scatter(mvmtCtrl,deltaCtrl);
%     hold on
%     scatter(mvmtPeak,deltaPeak);
%     legend({'control','peak'});
%     title(['Trimmed control and peak movement/delta']);
%     xlim([0,2]);
% end

if plotOption
    figure
    scatter(mvmt(~highMvtIndices),deltaPower(~highMvtIndices),'kx');
    hold on
    scatter(mvmtCtrl,deltaCtrl,'b');
    scatter(mvmtPeak,deltaPeak,'r');
    legend({ ...
        ['excluded: ' num2str(round(pInclude*100)) '% of total'], ...
        ['control, seg remain: ' num2str(round(ctrlP*100)) '%'], ...
        ['peak, seg remain: ' num2str(round(peakP*100)) '%']});
    title([animalName ' ' exptDate ' Segment view of Bryan''s 1D Gaussian trim method' ]);
    ylabel('delta power');
    xlabel('movement value');
end

avgHighMvtRatio = mean(mvmtPeak)/mean(mvmtCtrl);
avgHighDeltaRatio = mean(deltaPeak)/mean(deltaCtrl);





