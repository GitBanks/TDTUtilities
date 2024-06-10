function [avgHighMvtRatio,avgHighDeltaRatio,pInclude] = gaussTrim(animalName,exptDate,plotOption)


% rename gaussTrim to fitGaussMix  (clustering with gaussian mixture model,
% k-means clustering, but the variance parameter varies... (also we're
% applying it to 1 dimension, and applying it to this specific problem)
%
% rewrite this to output highMvtIndices
% ALSO, accept any single  segment array (movement) - one input vector
% THEN, (in another function) do the delta or whatever calculations -
% output 



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




% also try histograms and distributions overlay; 
% normalize so that area is = 1, use gauss function to overlay, mean and 
% std to gauss, try plotting against the functions, all about getting 
% vertical scaling right.  divide bins by total number; 

% % bin mvmt
% edges = linspace(0,2,100); % i think these should be dynamic
% mvmtCtrlBin = discretize(mvmtCtrl,edges);
% mvmtPeakBin = discretize(mvmtPeak,edges);
% 
% % % old hist seems to work
% figure
% hist(mvmtCtrlBin);
% hold on
% hist(mvmtPeakBin);
% 
% % % new histogram works better. 
% figure
% histogram(mvmtCtrlBin);
% hold on
% histogram(mvmtPeakBin);
% legend({'Ctrl','Peak'})
% % %  But we're only plotting the discretized output and instead we want normalized
% 
% 
% a = mvmtCtrl/length(mvmtCtrl);
% b = mvmtPeak/length(mvmtPeak);
% sum(b)
% figure
% histogram(a);
% hold on
% histogram(b);
% legend({'Ctrl','Peak'})
% 
% 
% f = histcounts(mvmtCtrl/length(mvmtCtrl));
% g = histcounts(mvmtPeak/length(mvmtPeak));
% figure
% bar(f);
% hold on
% bar(g);
% 
% 
% % this one seems to be off
% [f,fedge] = histcounts(mvmtCtrl/length(mvmtCtrl),20);
% [g,gedge] = histcounts(mvmtPeak/length(mvmtPeak),20);
% figure
% bar(fedge(1:end-1),f);
% hold on
% bar(gedge(1:end-1),g);
% 
% 
% [f,fedge] = histcounts(mvmtCtrl,20);
% [g,gedge] = histcounts(mvmtPeak,20);
% figure
% bar(fedge(1:end-1),f);
% hold on
% bar(gedge(1:end-1),g);


% % best so far
% [f,fedge] = histcounts(mvmtCtrl,20);
% [g,gedge] = histcounts(mvmtPeak,20);
% f = f/length(mvmtCtrl);
% g = g/length(mvmtPeak);
% figure
% bar(fedge(1:end-1),f);
% hold on
% bar(gedge(1:end-1),g);
% 
% figure
% % 1) Estimate the mean and standard deviation using normfit
% % 2) Calculate the probability estimates using normpdf
% % 3) Plot the data and the estimates using plot
% [m,s] = normfit(f);
% y = normpdf(f,m,s);
% plot(f,y,'.');
% hold on
% [m,s] = normfit(g);
% y = normpdf(g,m,s);
% plot(g,y,'.');




% mvmtCtrl;
% deltaCtrl;
% 
% mvmtPeak;
% deltaPeak;




















