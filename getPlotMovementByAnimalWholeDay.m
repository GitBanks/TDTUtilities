function h = getPlotMovementByAnimalWholeDay(animalName,exptDate,showHTR,downsampleFactor,sendToSlack)
% animalName = 'Mag024';
% exptDate = '21d07';

if ~exist('showHTR','var')
    showHTR = false;
end
if ~exist('downsampleFactor','var')
    downsampleFactor = 10; %safe for movement data, since it is collected at a high sample rate
end
if ~exist('sendToSlack','var')
    sendToSlack = false;
end

outputList = getExperimentsByAnimalAndDate(animalName,exptDate);
%step through each index for that day
%injectionTime = []; % now handled by getTreatmentInfo
fullTimeArray = [];
fullMagStream = [];
fullEventTimes = [];
timeSteps = zeros(1,size(outputList,1));
previousIndexTimeElapsed = 0;
for idx = 1:size(outputList,1)
    [magData,magDT] = HTRMagLoadData(outputList{idx,1});
    plotEnable = false;
    [htrEventTimes] = HTRMagDetectionHandler(outputList{idx,1},plotEnable);% get HTR times 
    timeArray = 0:magDT:length(magData)*magDT;
    while length(timeArray) > length(magData) %sometimes time is a mystery - this is in case the sample points are one longer than what we calculated by dT
        timeArray = timeArray(1:end-1);
    end
    
    timeArray = downsample(timeArray,downsampleFactor);
    magData = downsample(magData,downsampleFactor);
    
    fullTimeArray = cat(2,fullTimeArray,(timeArray+previousIndexTimeElapsed));
    fullMagStream = cat(2,fullMagStream,magData);
    fullEventTimes = cat(2,fullEventTimes,htrEventTimes+previousIndexTimeElapsed);
    previousIndexTimeElapsed = previousIndexTimeElapsed+timeArray(end);
    timeSteps(idx) = previousIndexTimeElapsed;
    clear timeArray magData
end

%change to minutes
fullTimeArray = fullTimeArray/60;
fullEventTimes = fullEventTimes/60;
timeSteps = timeSteps/60;

%clean up magnet signal

% allow different ways to present - either smooth or not?
%dataToPlot = envelope(abs(fullMagStream)); % version from usual HTR overlay
dataToPlot = smooth(abs(fullMagStream-mean(fullMagStream)),(1/magDT)*4,'sgolay',2);


% start plotting.  
h = figure();
plot(fullTimeArray,dataToPlot);
drawnow;
hold on

%OK, we're going to assume that the treatment variable is the reference
%point, so will adjust all our times according to it
treatments = getTreatmentInfo(animalName,exptDate);
for iTreatment = 1:size(treatments.pars,1)
    treatGiven = treatments.injIndex(iTreatment,:);
    doseGiven = treatments.vals(iTreatment,treatGiven);
    % time steps represents the last time of the index, so we need the previous last time
    lastTime = find(treatGiven == 1)-1;
    if lastTime == 0
        warning('is injection index set correctly?  No control period detected.')
        lastTime = 1;
    end
    timeGiven = timeSteps(lastTime); 
    treatmentText = [treatments.pars{iTreatment,treatGiven} ' ' num2str(doseGiven)];

    %may need to handle cases where we record a day later with no
    %obvious 'timepoint' in the system (for that day)
    if ~isempty(timeGiven)
        xline(timeGiven,'.',treatmentText,'DisplayName',treatmentText,'LineWidth',4);
    end
end

if showHTR
    for iPlot = 1:length(fullEventTimes)
       xline(fullEventTimes(iPlot),'r');
    end
end

hold off
ylabel([animalName]);
xlabel('Minutes');


xlim([0,fullTimeArray(end)]);
%ylim([5,17]); %if we toggle different smoothing, we will want to
%toggle this, too.
ylim([0,max(dataToPlot)*1.5]);
    








figName = [animalName ' Movement For Day'];
[outPath] = getPathGlobal('animalSaves');
if ~isdir([outPath animalName '\'])
    alertOutput = mkdir(outPath,animalName);
end
outPath = [outPath animalName '\'];
fileName = [outPath figName];
%saveas(thisFigure,[outPath figName]); % this is too large... wtf is
%happening...
print(h,'-painters',fileName,'-r300','-dpng');
if sendToSlack
    try
        desc = [figName];
        sendSlackFig(desc,[fileName '.png']);
    catch
        disp(['failed to upload ' fileName ' to Slack']);
    end
end





