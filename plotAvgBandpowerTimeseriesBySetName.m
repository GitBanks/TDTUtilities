function plotAvgBandpowerTimeseriesBySetName(setName)

% 3/5/24
% Thanks. The first step needs to be identifying the time windows of interest, 
% which means creating band power time series averaged across animals treated 
% with the same drugs.
%
% new function outline
% load in that set and plot out the average bandpower over time *by group*
% setName = '2020PsilocybinKetWay'; % input argument

bands = {
'delta';
'theta';
'alpha';
'beta';
'gamma';
};  % could do better and establish bands for the whole function in case they change

% main code
saveFileName = getPathGlobal([setName '-matTableBandpower']);
load(saveFileName);
tableCount = struct2table(workingTable);
saveFolder = getPathGlobal([setName '-savePath']);
for iGroup = unique(tableCount.group)' % --- STEP THROUGH DRUG GROUP
%     subTable = struct2table(workingTable);
    subTable = tableCount(tableCount.group==iGroup,:);
    thisTreat = subTable.treatments(1,1).pars{1,1}(1:4);
    if size(subTable.treatments(1,1).pars,1)>1
        thisTreat = [thisTreat ',' subTable.treatments(1,1).pars{2,1}(1:4)];
    end 
    for iExpt = 1:size(subTable,1) % --- STEP THROUGH EXPERIMENT DAY
        animalName = subTable.Animal{iExpt};
        exptDate = subTable.Date{iExpt};
        load([saveFolder animalName '_' exptDate '_bandpowerSet.mat'],"dataSet");
        for iHour = 1:size(dataSet,2) % --- STEP THROUGH HOURS
            tempData(iExpt).(['hour' num2str(iHour)]).delta = dataSet(iHour).delta;
            tempData(iExpt).(['hour' num2str(iHour)]).theta = dataSet(iHour).theta;
            tempData(iExpt).(['hour' num2str(iHour)]).alpha = dataSet(iHour).alpha;
            tempData(iExpt).(['hour' num2str(iHour)]).beta = dataSet(iHour).beta;
            tempData(iExpt).(['hour' num2str(iHour)]).gamma = dataSet(iHour).gamma;
            tempData(iExpt).(['hour' num2str(iHour)]).time = dataSet(iHour).time;
        end
    end
    % we have a choice of lining everythign up by time to injection
    % then average BUT, they may vary too much between recording
    % pairs.  So for now, we'll just trim off the excess and use
    % the shortest time then align the hours to average that way.
%     tempData(iExpt).(['hour' num2str(iHour)]).limit = max(size(dataSet(iHour).time,1))
    % now we want to step through all the experiments for this group and
    % find the minimum number of 4 sec intervals so we can cleanly average
    % them
    hourSteps = fields(tempData);
    maxForHour = nan(size(hourSteps,1),1);
    for iHour = 1:size(hourSteps,1)
        for iExpt = 1:size(tempData,2)
            maxForHour(iHour,1) = min(size(tempData(iExpt).(hourSteps{iHour}).time,1),maxForHour(iHour),'omitnan');
        end
    end
    
    for iHour = 1:size(hourSteps,1)
        % create an array of (experiments, bands, intervals, front/rear)
        nBands = size(bands,1); 
        windowedIntervals = maxForHour(iHour,1);
        nChannels = 2; % front and rear
        superArray = nan(size(tempData,2),nBands,windowedIntervals,nChannels);
        for iExpt = 1:size(tempData,2)
            superArray(iExpt,1,:,:) = tempData(iExpt).(['hour' num2str(iHour)]).delta(1:windowedIntervals,:);
            superArray(iExpt,2,:,:) = tempData(iExpt).(['hour' num2str(iHour)]).theta(1:windowedIntervals,:);
            superArray(iExpt,3,:,:) = tempData(iExpt).(['hour' num2str(iHour)]).alpha(1:windowedIntervals,:);
            superArray(iExpt,4,:,:) = tempData(iExpt).(['hour' num2str(iHour)]).beta(1:windowedIntervals,:);
            superArray(iExpt,5,:,:) = tempData(iExpt).(['hour' num2str(iHour)]).gamma(1:windowedIntervals,:);
        end
        averageBandpower.(['hour' num2str(iHour)]) = squeeze(median(superArray,1));
        averageBandpowerTimes(iHour).time = tempData(1).(['hour' num2str(iHour)]).time(1:windowedIntervals,:);
    end

    % need to quick find limits, but ignore outliers
    for iHour = 1:size(dataSet,2)
        for iBand = 1:nBands
            % try std() and multiply to set limits?
            scaleThisPlot(1,iBand,iHour) = std(averageBandpower.(['hour' num2str(iHour)])(iBand,:,1),'omitnan');
            scaleThisPlot(2,iBand,iHour) = std(averageBandpower.(['hour' num2str(iHour)])(iBand,:,2),'omitnan');
            scaleThisPlotMin(iBand,iHour) = min(averageBandpower.(['hour' num2str(iHour)])(iBand,:,1));
        end
    end
    scaleThisPlot = squeeze(mean(scaleThisPlot,3));
    scaleThisPlot = squeeze(mean(scaleThisPlot,1)); % we should now have an array of band standard deviations (more or less)
    scaleThisPlotMin = min(scaleThisPlotMin,[],2);
  

    bandPower = figure(); 
    for iHour = 1:size(dataSet,2)
        for iBand = 1:nBands
            subtightplot(nBands,1,iBand);
            plot(averageBandpowerTimes(iHour).time,averageBandpower.(['hour' num2str(iHour)])(iBand,:,1),"Color",'r');
            hold on
            plot(averageBandpowerTimes(iHour).time,averageBandpower.(['hour' num2str(iHour)])(iBand,:,2),"Color",'b');
            yS = scaleThisPlot(iBand);
            ylim([scaleThisPlotMin(iBand),yS+yS*16]);
        end
    end

    subtightplot(5,1,5);
    legend({'Front','Rear'});


    for iBand = 1:nBands
        subtightplot(5,1,iBand);
        ylabel(bands{iBand});
    end


%     for i = 1:6
%         subtightplot(5,1,i);
% %             xlim([adjMoveTimes(1),adjMoveTimes(end)]);
%     end
    subtightplot(5,1,1);
    title(thisTreat)


    clear tempData    % need this?
end



