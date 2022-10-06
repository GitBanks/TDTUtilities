function abfMagnetPlot(exptDate)

% example input
% exptDate = '22o03';



% this is all stuff we should be getting from the xls sheet, and maybe we
% want to think about where some of this goes
% abfChannel = [1,2,3]; %which mouse - remember channels start at zero, but matlab arrays start at 1
% animalName = {'Mag037','Mag038','Mag039'}; 
% exptID = {'22801000';
% '22801001'
% '22801002'
% };
% treatmentText = 'DMT 5mg/kg';

thisFile = getPathGlobal('CodyLocalMetaDataSave');
opts = detectImportOptions(thisFile);
opts = setvartype(opts, "RecordingID", 'string');
workingTable = readtable(thisFile,opts);

% for this function we're going to filter by exptDate
workingTable = workingTable(startsWith(workingTable.RecordingID,exptDate),:);


allMice = unique(workingTable.AnimalName);
nMice = size(allMice,1);
summaryEvents = nan(nMice,80);
figure
maxTime = 0;
minTime = 0;

for iMouse = 1:nMice
    thisMouse = allMice{iMouse};
    plotEnable = true; % toggle plots
    localSave = true; % local save will be what Cody uses
    injectionTime = []; % now handled by getTreatmentInfo
    fullTimeArray = [];
    fullMagStream = [];
    fullEventTimes = [];
    timeSteps = 2;     % TODO this should be detected !!!!!!!!!!!!!!!!!!!!!!!
    previousIndexTimeElapsed = 0;
    theseExptsLogical = strcmp(workingTable.AnimalName,{thisMouse});
    tempTable = workingTable(theseExptsLogical,:);
    for iExpt = 1:size(tempTable,1) 
        abfChannel = tempTable.ChannelID(iExpt);
        exptID = num2str(tempTable.RecordingID(iExpt));
        [htrEventTimes,magData,magDT,metaData] = HTRMagDetectionHandlerABF(exptID,plotEnable,localSave,abfChannel,{thisMouse});
        % magData = magData(:,thisStream); % fixed this to be the only
        % channel from inside
        timeArray = 0:magDT:length(magData)*magDT;
        while length(timeArray) > length(magData) %sometimes time is a mystery
            timeArray = timeArray(1:end-1);
        end
        fullTimeArray = cat(2,fullTimeArray,(timeArray+previousIndexTimeElapsed));
        fullMagStream = cat(2,fullMagStream,magData);
        fullEventTimes = cat(2,fullEventTimes,htrEventTimes+previousIndexTimeElapsed);
        previousIndexTimeElapsed = previousIndexTimeElapsed+timeArray(end);
        timeSteps(iExpt) = previousIndexTimeElapsed;
    end

    timeGiven = timeSteps(1)+tempTable.injTime1(2);
    treatmentText = [tempTable.Drug1{2} ' ' tempTable.dose1{2}];
    fullTimeArray = fullTimeArray-timeGiven;
    fullEventTimes = fullEventTimes-timeGiven;
    minuteTimeArray = fullTimeArray/60;
    minuteTimeGiven = 0;

    % start plotting.  
    subtightplot(nMice,1,iMouse);
    plot(minuteTimeArray,envelope(abs(fullMagStream)));
    drawnow;
    hold on
    minuteFullEventTimes = fullEventTimes/60;
    for iPlot = 1:length(fullEventTimes)
       xline(minuteFullEventTimes(iPlot),'r');
    end

    xline(minuteTimeGiven,'.',treatmentText,'DisplayName',treatmentText,'LineWidth',4);
    ylabel(thisMouse);
    maxTime = max(fullTimeArray(end),maxTime);
    minTime = min(fullTimeArray(1)/60,minTime);
    % quick grab just the events
    summaryEvents(iMouse,1:length(fullEventTimes)) = fullEventTimes-timeGiven;
end

% might want to do the plot limits as another step through subplots if
% displaying multiple
for iMouse = 1:nMice
    subtightplot(nMice,1,iMouse);
    ylim([5,17]);
    minuteMaxTime = maxTime/60;
    xlim([-30,55]);
%     xlim([minTime,minuteMaxTime]);
end
xlabel('Minutes')















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

