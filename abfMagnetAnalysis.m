% this will be used - so make sure this goes to the correct area
% getPathGlobal('CodyLocalHTRData')

clear all % just for now

% this is all stuff we should be getting from the xls sheet, and maybe we
% want to think about where some of this goes
abfChannel = [1,2,3]; %which mouse - remember channels start at zero, but matlab arrays start at 1
animalName = {'Mag037','Mag038','Mag039'}; 
exptID = {'22801000';
'22801001'
'22801002'
};
treatmentText = 'DMT 5mg/kg';


summaryEvents = nan(3,40);

tableSize = size(animalName,2);
figure
maxTime = 0;
minTime = 0;
for iMouse = 1:tableSize
    thisStream = abfChannel(iMouse);
    thisMouse = animalName{iMouse};
    plotEnable = true; % toggle plots
    localSave = true; % local save will be what Cody uses
    injectionTime = []; % now handled by getTreatmentInfo
    fullTimeArray = [];
    fullMagStream = [];
    fullEventTimes = [];
    timeSteps = zeros(1,size(exptID,1));
    previousIndexTimeElapsed = 0;
    for iExpt = 1:size(exptID,1)
        [htrEventTimes,magData,magDT,metaData] = HTRMagDetectionHandlerABF(exptID{iExpt},plotEnable,localSave,thisStream,thisMouse);
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

    % firure out where the injection was (manually here for now) then
    % adjust time array.
    timeGiven = timeSteps(1);
    fullTimeArray = fullTimeArray-timeGiven;
    fullEventTimes = fullEventTimes-timeGiven;
    minuteTimeArray = fullTimeArray/60;
    %timeGiven = timeGiven-timeGiven;
    minuteTimeGiven = 0;
%     minuteTimeGiven = timeGiven/60;
    
    % start plotting.  
    subtightplot(tableSize,1,iMouse);
    plot(minuteTimeArray,envelope(abs(fullMagStream)));
    drawnow;
    hold on
    minuteFullEventTimes = fullEventTimes/60;
    for iPlot = 1:length(fullEventTimes)
       xline(minuteFullEventTimes(iPlot),'r');
    end
    
    xline(minuteTimeGiven,'.',treatmentText,'DisplayName',treatmentText,'LineWidth',4);
    ylabel(animalName{iMouse});
    maxTime = max(fullTimeArray(end),maxTime);
    minTime = min(fullTimeArray(1)/60,minTime);
    % quick grab just the events
    summaryEvents(iMouse,1:length(fullEventTimes)) = fullEventTimes-timeGiven;

end

% might want to do the plot limits as another step through subplots if
% displaying multiple
for iMouse = 1:tableSize
    subtightplot(tableSize,1,iMouse);
    ylim([5,17]);
    minuteMaxTime = maxTime/60;
    xlim([minTime,minuteMaxTime]);
end
xlabel('Minutes')





% summary plots
binSize = 5; %min
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





% %we need to output these to a table for other people
% %binsByAnimal = zeros();
% binSize = 10; 
% for iList = 1:size(animalData,2)
%     for iHour = 1:size(trimmedAnimalData(iList).data.hourOfRecording,2)
%         thisHour = trimmedAnimalData(iList).data.hourOfRecording(iHour);
%         binSizeMin = binSize*60;
%         timeArray = (0:hourData(thisHour).dt:hourData(iHour).maxLength*hourData(thisHour).dt);
%         edges = timeArray(1):binSizeMin:timeArray(end);
%         centers = edges+(binSizeMin/2);
%         centers = centers(1:end-1);
%         Y = discretize(hourData(iHour).events,edges);
%         nBins = length(edges)-1;    
%     end
% end




% % Finally, we plot
% figure();
% nHours = size(acceptedPermutations,2);
% plotIndex = 1;
% binSize = 5;  %in minutes
% clear meanHist
% maxHistY = 0;
% maxMeanY = 0;
% for iHour = 1:size(hourData,2)
%     if ~isempty(hourData(iHour).events)
%         hourData(iHour).events = sort(hourData(iHour).events); % units = seconds
%         binSizeMin = binSize*60;
%         timeArray = (0:hourData(thisHour).dt:hourData(iHour).maxLength*hourData(thisHour).dt);
%         edges = timeArray(1):binSizeMin:timeArray(end);
%         centers = edges+(binSizeMin/2);
%         centers = centers(1:end-1);
%         Y = discretize(hourData(iHour).events,edges);
%         subtightplot(2,nHours,plotIndex);
%         nBins = length(edges)-1;
%         histogram(Y,nBins);
%         %ylim([0,24]);
%         if iHour ~=1; yticklabels([]); end
%         timeSteps = [ 15 30 45 ];
%         xticks(timeSteps/binSize); % 2 min
%         xticklabels({'15' '30' '45' });
%         if iHour == 1
%             ylabel('Cumulative HTR');
%             title(['Pre inj  n=' num2str(hourData(iHour).nMice)]);
%         else
%             title(['Hour ' num2str(iHour) '  n=' num2str(hourData(iHour).nMice)]);
%         end
%         counts = hist(Y,nBins);
%         maxHistY = max(maxHistY,max(counts));
%         meanHist(plotIndex,:) = counts/hourData(iHour).nMice;
%         subtightplot(2,nHours,plotIndex+nHours);
%         smoothedMean = smooth(counts/hourData(iHour).nMice);
%         maxMeanY = max(maxMeanY,max(smoothedMean));
% %         err = zeros(1,length(smoothedMean));
% %         err(:) = std(smoothedMean)/(sqrt(hourData(iHour).nMice));
%         for iError = 1:size(counts,2)
%             err(iError) = std(smoothedMean)/(sqrt(counts(iError)));
%             %err(iError) = std(counts)/(sqrt(counts(iError)));
%         end
%         %errorbar(centers/60,smoothedMean,err,'*r');
%         plot(centers/60,smoothedMean,'*r');
%         
%         xlim([edges(1)/60,edges(end)/60]);
%         if iHour ~=1; yticklabels([]); end
%         if iHour == 1
%             ylabel('smoothed average of HTR')
%         end
%         plotIndex = plotIndex+1;
%     end
% end
% % A little loop to rescale plots after a max has been found above.
% plotIndex = 1;
% for iHour = 1:size(hourData,2)
%     if ~isempty(hourData(iHour).events)
%     subtightplot(2,nHours,plotIndex);
%     ylim([0,maxHistY*1.2]);
%     subtightplot(2,nHours,plotIndex+nHours);
%     ylim([0,maxMeanY*1.05]);
%     plotIndex = plotIndex+1;
%     end
% end

















% % =========================================================================
% % this section is the KDE and some better saving by animal
% 
% rootFolder = ['M:\PassiveEphys\AnimalData\' animalName];
% if exist(rootFolder,'dir') ~=7
%     mkdir(rootFolder)
% end
% saveTreatment = treatment;
% saveTreatment = strrep(saveTreatment,';','');
% saveTreatment = strrep(saveTreatment,' ','');
% fileName = [rootFolder '\pdfHTRevents-' num2str(gaussLength) '-' saveTreatment '.mat'];
% 
% 
% 
% fullTimeArray = fullTimeArray(1:10:end);
% fullMagStream = fullMagStream(1:10:end);
% magDT_DS = magDT*10;
% 
% % TODO need to be sure the following calculation is correct
% %             pdEvents = fitdist(fullEventTimes','Kernel','BandWidth',gaussLength);
% %             yEvents = pdf(pdEvents,fullTimeArray);
% % concat all events
% % convolve
% % / nAnimals
% % / by time resolution
% yEvents = zeros(1,size(fullTimeArray,2));
% for iTrial = 1:size(fullEventTimes,2)
%     yEvents(find(fullTimeArray>fullEventTimes(iTrial),1,'first')) = 1;
% end
% 
% 
% % numbers are seconds, so 8 minutes wide, with a sigma of
% % gaussLength (seconds)
% gaussFilt = normpdf([-240:magDT_DS:240],1,gaussLength);
% yEvents = conv(yEvents,gaussFilt,'same');
% 
% 
% save(fileName,'yEvents','fullTimeArray','fullMagStream','fullEventTimes','timeSteps');







% old treatment handling.  For Cody we will pull this from a spreadsheet / table
% % %OK, we're going to assume that the treatment variable is the reference
% % %point, so will adjust all our times according to it
% % treatments = getTreatmentInfo(subTable.AnimalName{iList},subTable.Date{iList});
% % 
% % for iTreatment = 1:size(treatments.pars,1)
% %     treatGiven = treatments.injIndex(iTreatment,:);
% %     doseGiven = treatments.vals(iTreatment,treatGiven);
% %     % time steps represents the last time of the index, so we need the previous last time
% %     lastTime = find(treatGiven == 1)-1;
% %     if lastTime == 0
% %         warning('is injection index set correctly?  No control period detected.')
% %         lastTime = 1;
% %     end
% %     timeGiven = timeSteps(lastTime); 
% %     treatmentText = [treatments.pars{iTreatment,treatGiven} ' ' num2str(doseGiven)];
% %     
% %     %may need to handle cases where we record a day later with no
% %     %obvious 'timepoint' in the system (for that day)
% %     if ~isempty(timeGiven)
% %         xline(timeGiven,'.',treatmentText,'DisplayName',treatmentText,'LineWidth',4);
% %     end
% % end
% % 


































