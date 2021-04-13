
% summary plots

% (side project to make this better)
% -find recordings within 24 hours (group them) 
% BETTER/TODO create database (eNotebook) tracking for grouped expts
% for right now, let's just ID specific expts to group
% WORKING PLAN: use the notebookDesc to tag which index is associated with
% what experiment


clear all
% we have a few different conditions for each drug type.  A pop-up
% selection thing could make this cleaner, but this works for now.
% presumably this  will be arranged by database tags or something
% clever, otherwise we're stuck making lists each time we need a summary
% ========================
treatment = 'DOI_conc';
selection = 2; % selection is a choice of drug combinations
dateTable = getDateAnimalUniqueByTreatment(treatment);
excludeAnimal = 'ZZ05'; % there should really be a 'hasMagnet' flag in the database
dateTable = dateTable(excludeAnimal~=dateTable.AnimalName,:);
plotsToMake = unique(dateTable.DrugList);
subTable = dateTable(plotsToMake(selection)==dateTable.DrugList,:);
subTable = subTable(5:end,:); % for now, based on our data, just exclude the recording lengths that don;t fit together

% ========================
% treatment = '5-MeO-MiPT';
% selection = 1; % selection is a choice of drug combinations
% dateTable = getDateAnimalUniqueByTreatment(treatment);
% plotsToMake = unique(dateTable.DrugList);
% subTable = dateTable(plotsToMake(selection)==dateTable.DrugList,:);

% ========================
% treatment = 'Pyr-T';
% selection = 1; % selection is a choice of drug combinations
% dateTable = getDateAnimalUniqueByTreatment(treatment);
% plotsToMake = unique(dateTable.DrugList);
% subTable = dateTable(plotsToMake(selection)==dateTable.DrugList,:);

% ========================




% loop through expts of interest
% TODO make animalData a table?
% sz = [1 4];
% varTypes = {'string','string','double','double'};
% varNames = {'AnimalName','Date','TimeArray','EventArray'};
% eventTable = table('Size',sz,'VariableTypes',varTypes,'VariableNames',varNames);
animalData = struct();
for iList = 1:size(subTable,1)
    disp(['Loading session ' num2str(iList) ' of ' num2str(size(subTable,1))]);
    animalData(iList).data = getHTRExperimentInfoFromDateName(subTable.Date{iList},subTable.AnimalName{iList}); 
    %we now have a structure that contains everything we need.  We still
    %need to sort it below (find matching experiments, etc)
end



% for animals with odd combinations of recording hours (DOI for now) find
% appropriate spans to pool: all animals that share *exclusive* sets only
acceptedPermutations = [1,2];

for iList = 1:size(animalData,2)
    animalData(iList).data.hourOfRecording == acceptedPermutations
  
    
    
end







hourData(1:25) = struct();
hourData(1).events = [];
hourData(1).nMice = [];
hourData(1).maxLength = [];
hourData(1).dt = [];
%hourData.events = 0;
% look in each list for all hours and start grouping events by those hours
for iList = 1:size(animalData,2)
    for iHour = 1:size(animalData(iList).data.hourOfRecording,2)
        thisHour = animalData(iList).data.hourOfRecording(iHour);
        hourData(thisHour).events = cat(1,hourData(thisHour).events,animalData(iList).data.eventArray(1,iHour).events);
        if isempty(hourData(thisHour).nMice)
            hourData(thisHour).nMice = 0;
            hourData(thisHour).maxLength = 0;
            hourData(thisHour).dt = 0;
        end
        hourData(thisHour).nMice = hourData(thisHour).nMice+1;
        hourData(thisHour).maxLength = max(animalData(iList).data.timeLength(iHour),hourData(thisHour).maxLength);
        hourData(thisHour).dt = animalData(iList).data.timeDT(iHour);
    end
end



figure();
% nHours = 6; % grab this more intelligently in the future please
nHours = 2;
plotIndex = 1;
binSize = 2;  %in minutes
for iHour = 1:size(hourData,2)
    if ~isempty(hourData(iHour).events)
        
        hourData(iHour).events = sort(hourData(iHour).events); % units = seconds
        
        binSizeMin = binSize*60;
        timeArray = (0:hourData(thisHour).dt:hourData(iHour).maxLength*hourData(thisHour).dt);
        edges = timeArray(1):binSizeMin:timeArray(end); 
        Y = discretize(hourData(iHour).events,edges);
        subtightplot(2,nHours,plotIndex);
      
        
        histogram(Y,length(edges));
        ylim([0,24]);
        if iHour ~=1; yticklabels([]); end
        
        timeSteps = [ 15 30 45 ];
        xticks(timeSteps/binSize); % 2 min
        xticklabels({'15' '30' '45' });
        
        
        
        title(['Hour ' num2str(iHour) '  n=' num2str(hourData(iHour).nMice)]);
        counts = hist(Y,length(edges));
        meanHist(plotIndex,:) = counts/hourData(iHour).nMice;
        
        subtightplot(2,nHours,plotIndex+nHours);
        plot(edges/60,smooth(counts/hourData(iHour).nMice));
        ylim([0,3]);
        if iHour ~=1; yticklabels([]); end
        
        
        
        plotIndex = plotIndex+1;
    end
end







% figure();
% nHours = 6; 
% for iHour = 1:size(meanHist,1)
%     subtightplot(1,size(meanHist,1),iHour);
%     timeArray = edges/60;
%     plot(edges/60,smooth(meanHist(iHour,:)));
% %     xticks(timeSteps/binSize); % 2 min
% %     xline(60/binSize,'r--'); %xline(45,'r--'); % 2 min
% %     xlim([0,timeSteps(end)/binSize]); % 2 min
% %     %xticklabels({'-30','-15',[uniqueA{iManipA} ' ' uniqueB{iManipB}],'15','30'});
% %     %ylabel([uniqueA{iManipA} ' ' uniqueB{iManipB}]);
% %     %xlabel('minutes');
%     ylim([0,3]);
%     if iHour ~=1; yticklabels([]); end
%     %timeSteps = [ 15 30 45 ];
%     %xticks(timeSteps/binSize); % 2 min
%     %xticklabels({'15' '30' '45' });
% 
% end
















% allEventTimes = [];
% for iList = 1:size(animalList,1)
%     allEventTimes = [allEventTimes summaryAnimalData(iList).data.eventArray];
% end
% fullTimeArray = summaryAnimalData(2).data.TimeArray;
% 
% 
% % 5. plot histogram (code below)
% binSize = 2;  %in minutes
% binSizeMin = binSize*60;
% figure();
% cleanedEventTimes = sort(allEventTimes);
% fullTimeArray(end)/60;
% edges = fullTimeArray(1):binSizeMin:fullTimeArray(end); % 2 min
% Y = discretize(cleanedEventTimes,edges);
% histogram(Y,length(edges));
% timeSteps = [0 60 120 180 240 300 360];
% xticks(timeSteps/binSize); % 2 min
% xline(60/binSize,'r--'); %xline(45,'r--'); % 2 min
% xlim([0,timeSteps(end)/binSize]); % 2 min
% 
% 
% % plot averages
% counts = hist(Y,length(edges)); %uses histogram stuff figured out above
% nMice = size(animalList,1);
% newY = counts/nMice;
% figure();
% timeArray = edges/60;
% plot(timeArray,newY);
%     xticks(timeSteps/binSize); % 2 min
%     xline(60/binSize,'r--'); %xline(45,'r--'); % 2 min
%     xlim([0,timeSteps(end)/binSize]); % 2 min
%     %xticklabels({'-30','-15',[uniqueA{iManipA} ' ' uniqueB{iManipB}],'15','30'});
% %ylabel([uniqueA{iManipA} ' ' uniqueB{iManipB}]);
% %xlabel('minutes');
% ylim([0,3]);


%             eventsFiveToFifteen = cleanedEventTimes(cleanedEventTimes > 300);
%             eventsFiveToFifteen = eventsFiveToFifteen(eventsFiveToFifteen < 900)';


% sz = [1 2];
% varTypes = {'string','struct'};
% varNames = {'AnimalName','data'};
% summaryAnimalData = table('Size',sz,'VariableTypes',varTypes,'VariableNames',varNames);
%newAnimalData(1).timeOfDay(1) = [];
%newAnimalData(1).injTOD = 0;
% sort through animal data, match related experiments
% animalList = unique(subTable.AnimalName);
% for iList = 1:size(animalList,1)
%     newAnimalData = struct();
%     newAnimalData(1).TimeArray(1) = 0;
%     newAnimalData(1).eventArray = 0;
%     newAnimalData(1).injTime = 0;
%     mergeThese = animalData(contains(subTable.AnimalName,animalList(iList)));
%     newAnimalData = mergeThese(:).data;
%     if size(mergeThese,2) > 1
%     for iMerge = 2:size(mergeThese,2)
%         mergeThese(iMerge).data.TimeArray = mergeThese(iMerge).data.TimeArray+newAnimalData.TimeArray(end);
%         newAnimalData.TimeArray = [newAnimalData.TimeArray mergeThese(iMerge).data.TimeArray];
%         mergeThese(iMerge).data.eventArray = mergeThese(iMerge).data.eventArray +newAnimalData.TimeArray(end);
%         newAnimalData.eventArray = [newAnimalData.eventArray mergeThese(iMerge).data.eventArray];
%         newAnimalData.desc = [newAnimalData.desc mergeThese(iMerge).data.desc];
%         newAnimalData.timeOfDay = [newAnimalData.timeOfDay mergeThese(iMerge).data.timeOfDay];
%     end
%     end
%     summaryAnimalData(iList).AnimalName = animalList(iList);
%     summaryAnimalData(iList).data = newAnimalData;
% end

