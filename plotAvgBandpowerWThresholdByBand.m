function plotAvgBandpowerWThresholdByBand(bandToUse)
% work in progress

% test parameters
% bandToUse = 'alpha';
% bandToUse = 'delta';


%load('C:\Users\Matt Banks\Desktop\bandpower_psilocybin_210701.mat');
load('C:\Users\Matt Banks\Desktop\bandpower_psilocybin_nmlz=0_21714');

drugToUse = 'PSIL';
drugLabel = 'Psilocybin';


oneMinuteInPoints = 20;
injectionOffsetTimePre = 2; % in min
injectionOffsetTimePost = 1; % in min
injectionOffsetPreZero = oneMinuteInPoints*injectionOffsetTimePre;
injectionOffsetPostZero = oneMinuteInPoints*injectionOffsetTimePost;
smoothingVar = oneMinuteInPoints*2; % 2 minutes
dT = abs(diff(bandPowerData.timeArray(1:2,1,1)));



figure;
useTheseDays = contains(bandPowerData.drug,drugToUse);
trimmedSet = bandPowerData.(bandToUse)(:,:,useTheseDays);
allTimeArray = squeeze(bandPowerData.timeArray(:,:,useTheseDays));
doOnce = 1;
for iAnimal = 1:size(trimmedSet,3)
%     thisDay = fields(bandPowerData.(drugToUse).(animalList{iAnimal}));
%     bandDrugDataForThisAnimal = bandPowerData.(drugToUse).(animalList{iAnimal}).(thisDay{:}).(bandToUse);
%     timeArray = bandPowerData.(drugToUse).(animalList{iAnimal}).(thisDay{:}).timeArray;
    bandDrugDataForThisAnimal = trimmedSet(:,:,iAnimal);
    timeArray = allTimeArray(:,iAnimal);
    
    
    % split data at t=0 and accoutn for the injection period
	tZero = find(timeArray>0,1)-1;
    
    newArray = bandDrugDataForThisAnimal(1:tZero,:);
    newArray = cat(1,newArray,nan(injectionOffsetPreZero,4));
    newArray = cat(1,newArray,nan(injectionOffsetPostZero,4));
    newArray = cat(1,newArray,bandDrugDataForThisAnimal(tZero:end-1,:));
    bandDrugDataForThisAnimal = newArray;
    injectionOffsetTimes = timeArray(tZero-injectionOffsetPreZero:tZero-1);
    newTimeArray = timeArray(1:tZero-1)+injectionOffsetTimes(1);
    newTimeArray = cat(1,newTimeArray,injectionOffsetTimes);
    newTimeArray = cat(1,newTimeArray,timeArray(tZero:end));
    appendToTime = newTimeArray(end):dT:newTimeArray(end)+injectionOffsetTimePost;
    newTimeArray = cat(1,newTimeArray,appendToTime(2:end)');
    timeArray = newTimeArray;
    
    
    
    

    
    
    
    tempArrayA(:,1) = bandDrugDataForThisAnimal(:,1);
    tempArrayA(:,2) = bandDrugDataForThisAnimal(:,4);
    channelMeanA = mean(tempArrayA,2,'includenan');
    channelMeanA = channelMeanA-mean(channelMeanA(prctile(channelMeanA,30)>channelMeanA));
    %channelMeanA = channelMeanA-mean(channelMeanA(prctile(channelMeanA,16)<channelMeanA & prctile(channelMeanA,84)>channelMeanA));
%     tempA = channelMeanA
    setNans = isnan(channelMeanA);
    tempA = smooth(channelMeanA,smoothingVar);
%     tempA = smooth(abs(channelMeanA),smoothingVar);
    tempA(setNans) = nan;


    tempArrayB(:,1) = bandDrugDataForThisAnimal(:,2);
    tempArrayB(:,2) = bandDrugDataForThisAnimal(:,3);
    channelMeanB = mean(tempArrayB,2,'includenan');
    channelMeanB = channelMeanB-mean(channelMeanB(prctile(channelMeanB,30)>channelMeanB));
    %channelMeanB = channelMeanB-mean(channelMeanB(prctile(channelMeanB,16)<channelMeanB & prctile(channelMeanB,84)>channelMeanB));
%     tempB = channelMeanB
    setNans = isnan(channelMeanB);
    tempB = smooth(channelMeanB,smoothingVar);
%     tempB = smooth(channelMeanB,smoothingVar);
    tempB(setNans) = nan;
    
    
    
    startElement = find(timeArray>-55,1);
    endElement = find(timeArray>238,1);
    
    if doOnce
        arrayMax = endElement - startElement - 122;
        doOnce = 0; 
    end
    
    if (endElement-startElement) > arrayMax
        endElement = endElement-(endElement-startElement-arrayMax);
    end
    
    timeArray = timeArray(startElement:endElement);
    justFront(:,iAnimal) = tempA(startElement:endElement);
    justRear(:,iAnimal) = tempB(startElement:endElement);
    
    clear tempArrayA tempArrayB tempA tempB
    subplot(2,1,1);
    plot(timeArray,justFront(:,iAnimal));
    hold on
    xlim([-45,235]);
    %ylim([0,1e-4]);
    title('Frontal');
    
    subplot(2,1,2);
    plot(timeArray,justRear(:,iAnimal));
    hold on
    xlim([-45,235]);
    %ylim([0,1e-4]);
    title('Rear');
    xlabel('time (min)');
end


avgData(:,1) = mean(justFront,2,'omitnan');
avgData(:,2) = mean(justRear,2,'omitnan');


% figure
% subplot(2,1,1);
% frontDy = std(justFront,0,2,'omitnan');
% hold on
% % plot(timeArray,avgData(:,1)-frontDy,'LineWidth',4);
% % plot(timeArray,avgData(:,1)+frontDy,'LineWidth',4);
% h = fill([timeArray flip(timeArray)],[avgData(:,1)+frontDy flip(avgData(:,1)-frontDy)],'k');
% set(h,'facealpha',.1);
% plot(timeArray,avgData(:,1),'k','LineWidth',4);



figure;
% parameters for this loop
timeWindow = [0 200]; % find the minimum within a given time window (minutes)
baseLine = [-45 -3]; % basline window relative to t=0 injection/manipulation

t = timeArray;
ROI = {'Anterior','Posterior'};
smoothingTime = t(smoothingVar+1)-t(1);
for iROI = 1:size(avgData,2)
    x = avgData(:,iROI);
    plotInjMin = min(x(t>timeWindow(1) & t<timeWindow(2))); % this is the minimum value of x within the time window specified
    firstMinElement = find(x==plotInjMin,1); % the element of the array where the minumum occurs
    timeAtMin = t(firstMinElement); % the time where the min occurs
    % plot minimum value before t=200min
    %     plot(timeAtMin,plotInjMin,'o','linewidth',4);
    % find the midway point (not median) between (average of x t<0) and timeAtMin
    baselineTimeSpan = t>baseLine(1) & t<(baseLine(2)-injectionOffsetTimePre);
    Baseline = x(baselineTimeSpan); %give a small margin before the end of recording, and don;t forget to account for the gap we've made
    BaseMean = mean(Baseline); % take average between the start and end point
    SDMean = std(Baseline);  
    LineEq = (BaseMean - (2* SDMean));
    midLine = LineEq*ones(size(t)); % line indicating midpoint
    subplot(2,1,iROI);
    plot(t,x,'LineWidth',2); % plot smoothed line
    hold on
    xlabel('time (minutes)');
    ylabel([bandToUse ' power (mV^2)']);
    
    avgLine(1,1:size(t,1)) = BaseMean;
    plot(t,avgLine,':r');
    
    upperBandToUse = [upper(bandToUse(1)),bandToUse(2:end)];
    title([drugLabel ' ' 'Average ' upperBandToUse ' Band Power: ' ROI{iROI}]); % add title
    % plot out a line indicating this midpoint
    plot(t,midLine,':','LineWidth',2);
    
    

    
    foundStart = nan;
    foundEnd = nan;
    searchIndex = find(t==0); % time 0
    scannableArray = (x-LineEq);
    % here's a strategy to find positive going halfpeak values - mixed
    % results though....
%     if mean(scannableArray(searchIndex:searchIndex+200),'omitnan')>0
%         scannableArray = scannableArray*-1;
%     end
    while isnan(foundStart)
        if scannableArray(searchIndex)<0
            foundStart = searchIndex;
        else
            searchIndex = searchIndex+1;
        end
        if searchIndex > size(x,1)
            error('Couldn''t find value that meets criteria.');
        end
    end
    while isnan(foundEnd)
        if scannableArray(searchIndex)>=0
            foundEnd = searchIndex;
        else
            searchIndex = searchIndex+1;
        end
        if searchIndex > size(x,1)
            error('Couldn''t find value that meets criteria.');
        end
    end
    
    

%     % find second intersection between the x and midLine for P2
%     PartData = x(t>30 & t<70);  %USE WITH PSIL
%     % PartData = x(t>7 & t<25);
%     % find val closest to threshold by subtracting threshold from data and
%     % making all neg. vals pos., then choosing val closest to zero
%     [c, index2] = min(abs(PartData-LineEq));
%     ClosestVal = PartData(index2);
%     [c4, index5] = min(abs(x-ClosestVal));
%     tP2 = t(index5);
%     DataHalf = x(index5);
%     % finding time at P1 by looking at specified data set
%     SnipData = x(t>-3 & t<7); %PSIL not normalized
%     % SnipData = data(t>0 & t<7);
%     [c2, index3] = min(abs(SnipData-LineEq));
%     ClosestVal2 = SnipData(index3);
%     [c3, index4] = min(abs(x-ClosestVal2));
%     TimeAtP1 = t(index4);
%     HalfTime = tP2 - TimeAtP1;
%     plot(tP2,DataHalf,'oy','linewidth',4);
%     plot(TimeAtP1,LineEq,'oy','linewidth',4);
    
    
    halfTime = t(foundEnd)-t(foundStart);
    plot(t(foundStart),LineEq,'ok','linewidth',4);
    plot(t(foundEnd),LineEq,'ok','linewidth',4);
    
    %baselineAvgLine(1:sum(baselineTimeSpan)) = BaseMean;
 
  
%     plot(t(baselineTimeSpan),baselineAvgLine,':r','LineWidth',3);
    plot([t(foundStart) t(foundEnd)],[LineEq LineEq],'k','LineWidth',3);
       
    %create the legend with all things we're interested in
    legend(['smooth=' num2str(smoothingTime) 'min'],'baselineAvg','y=Mn-2*SD',['Duration=' num2str(halfTime) 'min'],'Location','northeast'); % legends '4sec band power',
    % create new variables only focusing on the data between t=0 & the local (?) maxima
%     firstTimeWin = t(t>0 & t<timeAtMin);
%     data_firstTimeWin = x(t>0 & t<timeAtMin);
    xlim([-45,235]);
end






















