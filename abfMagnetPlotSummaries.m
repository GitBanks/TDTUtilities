function abfMagnetPlotSummaries


% WIP
% we're going to add ways to filter by drug or sex or add a column to group
% mice (e.g. to exclude test mice from real data set mice)


thisFile = getPathGlobal('CodyLocalMetaDataSave');
opts = detectImportOptions(thisFile);
opts = setvartype(opts, "RecordingID", 'string');
workingTable = readtable(thisFile,opts);

% for this function we're going to filter by exptDate
workingTable = workingTable(startsWith(workingTable.RecordingID,exptDate),:);



% summary plots
binSize = 5; % minutes
% summary plot 
reshapedSummary = reshape(summaryEvents,[1,size(summaryEvents,1)*size(summaryEvents,2)]);
minuteSummaryEvents = reshapedSummary;

minuteSummaryEvents = sort(minuteSummaryEvents);
minuteTimeArray = fullTimeArray/60;

% = (0:hourData(thisHour).dt:hourData(iHour).maxLength*hourData(thisHour).dt);
edges = minuteTimeArray(1):binSize:minuteTimeArray(end);
centers = edges+(binSize/2);
centers = centers(1:end-1);
Y = discretize(minuteSummaryEvents,edges);
nBins = length(edges)-1;    

% figure;
[counts,centers] = hist(minuteSummaryEvents,nBins);

%hacky adjustment: 
centers = centers+1.5

figure;
bar(centers,counts/3);
xlabel('Time, Mins');
ylabel('average events');
hold on
xline(0,'r','LineWidth',3)
title('DMT 5 mg/kg, n=3');

figure
histogram(Y,nBins)
xticks(1:32);
xticklabels(centers);
xlabel('Time, Mins');
ylabel('Cumulative events')
