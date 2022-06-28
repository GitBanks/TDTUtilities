
%A few things to remember:
%1) On line 25 you need to change iDrug to the number of the drug you are
%looking for in these experiments (my experiments are DOI so I will set
%iDrug=3
%
%2)You need to change the titles for the drug you are using- these are
%hardcoded

animal = 'ZZ15';
subset={'22216','22217'};


%Make a table of the expts we want to pull
[exptTable] = getExptPlasticitySetByAnimal(animal);

%We now want to make a table that pulls data from indices from the subset we give it
stimRespExptTable = exptTable(contains(exptTable.DateIndex,subset(:)),:);
stimRespExptTable = stimRespExptTable(stimRespExptTable.stimResp == true,:);

%Only grab the first one
drugsToUse = {'Saline','Psilocybin','DOI','4-AcO-DMT','6-FDET'};
tempTable = table();
for idrug = 2
    % create a logical of matching experiments
    logicalTests(1,:) = contains(stimRespExptTable.Description,drugsToUse{idrug}); % include
    logicalTests(2,:) = ~contains(stimRespExptTable.Description,'Mifepristone'); % exclude
    foundTheseExpts = all(logicalTests);

    % now, a dead simple way to grab the next one would be to make every
    % entry *after* a valid experiment to true (may be redundant for
    % consecutive experiments that are true) 
    indexOfFoundExpt = find(foundTheseExpts==true);
    iiExpt = 1;
    for iExpt = 1:size(indexOfFoundExpt,2)
        useThisIndex = indexOfFoundExpt(iExpt);
        fullListOfExpts(iiExpt) = useThisIndex;
        iiExpt = iiExpt+1;
        fullListOfExpts(iiExpt) = useThisIndex+1;
        iiExpt = iiExpt+1;
    end
    fullListOfExpts = unique(fullListOfExpts);
    
    % we're only interested in the pre injection and the 24 hour later.  we
    % need to step through each day and be sure there's only one.
    
    % the following  will fail if there's only one entry.  we need to look at each
    % day to be sure.
%     killList = diff(fullListOfExpts);
%     killList(end+1) = 2;
%     killList = find(killList>1)-1;
%     fullListOfExpts(killList) = [];
    moreDates = true;
    iExpt = 1;
    while moreDates
        thisDate = char(stimRespExptTable(fullListOfExpts(iExpt),:).DateIndex);
        nextDate = char(stimRespExptTable(fullListOfExpts(iExpt+1),:).DateIndex);
        if contains(thisDate(1:5),nextDate(1:5))
            % if this date and the next are the same, get rid of the next date
            fullListOfExpts(iExpt+1) = [];
        else
            %otherwise, move on to the next date
            iExpt = iExpt+1;
        end
        if iExpt > size(fullListOfExpts,2)-1
            % since we're using a while loop, need to be careful to get
            % out.
            moreDates = false;
        end
    end
    stimRespExptTable = stimRespExptTable(fullListOfExpts,:);
    tempTable = [tempTable;stimRespExptTable];
end

stimRespExptTable = tempTable;

%Turn into list
exptList = stimRespExptTable.DateIndex;

%Because we have multiple dates and indices we need a unique list
for i=1:size(stimRespExptTable,1)
    dateList{i} = char(stimRespExptTable.DateIndex(i));
    dateList{i} = dateList{i}(1:5);
end
uniqueDates = unique(dateList);

%Load in data- this will rerun the curves and pull all important stuff- it
%will error out bc we are not finishing the plots
nExpts = size(exptList,1);
nIndex = size(exptList,1);
ourIndex = 1;
for iExptDate = 1:nExpts 
    for iExptIndex = 1:nIndex
        thisDate = char(stimRespExptTable.DateIndex(ourIndex));
        thisIndex = thisDate(7:9);
        thisDate = thisDate(1:5);
        [peakData.date(iExptDate).expt(iExptIndex).data] = evokedStimResp_userInput(thisDate,thisIndex);
        ourIndex = ourIndex+1;
   end
end

%% Plotting
figure();

%First experiment trace
subplot(1,3,1)
nROIs = 1; 
nExpts = 1;
nIndex = 1;
for iExpt = 1:nExpts
   for iROI = 1: nROIs
         hold on
       for iStim = 1:length(peakData.date.expt(iExpt).data.avgTraces)
        plot(peakData.date.expt(iExpt).data.plotTimeArray,peakData.date.expt(iExpt).data.avgTraces(iStim).stimSet(iROI,:));
       end
       ax = gca;
       ax.XLim = [peakData.date.expt(iExpt).data.plotTimeArray(1),peakData.date.expt(iExpt).data.plotTimeArray(end)];
       ax.YLim = [-5.0e-05, 10.0e-05]%[1.05*peakData.plotMin(iROI),1.05*peakData.plotMax(iROI)];
       ax.XLabel.String = 'time(sec)','FontSize',10;
       if iROI == 1
           ax.YLabel.String = 'avg dataSub (V)','FontSize',10;
       end
         ax.Title.String = 'Example Response Traces at Baseline','FontSize',25;
       for ii = 1:size(peakData.date.expt(iExpt).data.avgTraces,2)
             stimArrayNumeric(ii) = peakData.date.expt(iExpt).data.avgTraces(ii).stimArrayNumeric;
             hold off
       end
    end
end

%Second expt trace
subplot(1,3,2)
nROIs = 1; 
nExpts = 2;
nIndex = 2;
for iExpt = 1:nExpts
   for iROI = 1: nROIs
         hold on
       for iStim = 1:length(peakData.date.expt(iExpt).data.avgTraces)
        plot(peakData.date.expt(iExpt).data.plotTimeArray,peakData.date.expt(iExpt).data.avgTraces(iStim).stimSet(iROI,:));
       end
       ax = gca;
       ax.XLim = [peakData.date.expt(iExpt).data.plotTimeArray(1),peakData.date.expt(iExpt).data.plotTimeArray(end)];
       ax.YLim = [-5.0e-05, 10.0e-05]%[1.05*peakData.plotMin(iROI),1.05*peakData.plotMax(iROI)];
       ax.XLabel.String = 'time(sec)','FontSize',10;
       if iROI == 1
           ax.YLabel.String = 'avg dataSub (V)','FontSize',10;
       end
         ax.Title.String = 'Example Response Traces 24hr Post Psilocybin','FontSize',25;
       for ii = 1:size(peakData.date.expt(iExpt).data.avgTraces,2)
             stimArrayNumeric(ii) = peakData.date.expt(iExpt).data.avgTraces(ii).stimArrayNumeric;
             hold off
       end
    end
end

%% Stim resp curve

subplot(1,3,3);
for iExpt = 1:nExpts
    for iROI = 1:nROIs
        nPks = size(peakData.date.expt(iExpt).data.pkVals(iROI).data,1);
        hold on
        for iPk = 1:nPks
%             if plotLog
%                 semilogx(stimArrayNumeric,peakData.pkSearchData(iROI).pkSign(iPk)*peakData.pkVals(iROI).data(iPk,:),'-o');
%             else
               plot(peakData.date.expt(iExpt).data.stimArrayNumeric,peakData.date.expt(iExpt).data.pkSearchData(iROI).pkSign(iPk)*peakData.date.expt(iExpt).data.pkVals(iROI).data(iPk,:),'-o');
%             end
        end
        ax = gca;
        ax.XLabel.String = 'Stim intensity (\muA)','FontSize',10;
        if iROI == 1
        ax.YLabel.String = 'Pk resp (V)','FontSize',10;
        end
        ax.Title.String = 'Psilocybin Stimulus Response Curves','FontSize',25;
         ax.XLim = [0,400];
        %ax.YLim = [0,7e-05];
        legendLabs = [];
    for iExpt = 1
        legendLabs{iExpt} = ['Baseline'];
    end
    for iExpt = 2
        legendLabs{iExpt} = ['24hr Post Injection'];
    end
        legend(legendLabs,'FontSize',15,'Location','NorthWest');
        legend('boxoff');
        hold off
end
end

