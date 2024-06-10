function [arrayOut,pInclude,gaussParams] = fitGaussMix(dataToFit,plotOption)
% clustering with gaussian mixture model.  Similar to k-means clustering, 
% but the variance parameter varies... (also we're applying it to 
% dimension, and applying it to this specific problem)
% dataToFit will be an array - for us usually the array of pre-segmented 
% values for movement
% arrayOut will be the logical values
% gaussParams in case the parameters are important


% Sean Grady & Zarmeen Zahid 5/28/24
% inspired and directed by Bryan's original code in R, he pointed out a
% matlab function.
% Given: an array (usually time segments, usually 4 seconds taken from 
% control and drug treatment periods in one large array of movement values) 
% do the following:
% 1. use sqrt of movement values
% 3. sum the two gaussians using fitgmdist and cluster
% 4. take larger mean (more active movement) and exclude those not in it
% 4b. ---be sure to track how many are included or not
% 4c. allow plotting to show results
% 5. output logical of what we're keeping and also gaussian params

% from Bryan
% We combine baseline and peak movement values, take square root, fit two 
% gaussian distributions to the data, exclude the data that better fit the 
% smaller mean distribution ("still"/perhaps asleep), retaining the data 
% with movement scores corresponding to the distribution with larger mean
if ~exist("plotOption","var")
    plotOption = true;
end
% STEP 1 & 2: can be in the same line
% we had 1 element of 1000s across 100s of animals be negative and it
% messed with everything.  Let's just nip that bud here and now and hope
% nothing bad happens down the line...
dataToFit(dataToFit < 0) = 0;
mvmt = sqrt(dataToFit);
% STEP 3
X = [mvmt];
gaussParams = fitgmdist(X,2);
clusterX = cluster(gaussParams,X); % Cluster index 
% for extracting the high movement data:
[~,ia] = max(gaussParams.mu); % ia will be the index of the cluster with larger mean
arrayOut = clusterX == ia(1);
pInclude = sum(arrayOut)/size(mvmt,1);


z = (0:0.02:2)';  % Note the crucial '
pdfz = pdf(gaussParams,z);




if plotOption
    figure
    %     scatter(mvmt(~arrayOut),rand(size(mvmt(~arrayOut),1),1),'kx');
    %     hold on
    %     scatter(mvmt(arrayOut),rand(size(mvmt(arrayOut),1),1),'b');
    h1 = histogram(mvmt(~arrayOut));
    hold on
    h2 = histogram(mvmt(arrayOut));
    h1.Normalization = 'probability';
    h1.BinWidth = 0.02;
    h2.Normalization = 'probability';
    h2.BinWidth = 0.02;
    plot(z,pdfz/(size(pdfz,1)/2),'k');
    legend({ ...
        ['excluded: ' num2str(round(pInclude*100)) '% of total'], ...
        ['accepted ' ], ...
        });
    title(['Segment view of 1D clustering with gaussian mixture model' ]);
    ylabel('random values for better illustration');
    xlabel('movement value');
end




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




















