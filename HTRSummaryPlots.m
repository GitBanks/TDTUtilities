function HTRSummaryPlots(treatment,selection,acceptedPermutations)


%  before proceeding please check out MagnetAnalysisScript for the full
%  workflow 


% summary plots

% (side project to make this better)
% -find recordings within 24 hours (group them) 
% BETTER/TODO create database (eNotebook) tracking for grouped expts
% for right now, let's just ID specific expts to group
% WORKING PLAN: use the notebookDesc to tag which index is associated with
% what experiment

% we have a few different conditions for each drug type.  A pop-up
% selection thing could make this cleaner, but this works for now.
% presumably this  will be arranged by database tags or something
% clever, otherwise we're stuck making lists each time we need a summary
% % ========================
% treatment = 'psilocybin';
% selection = 6; % selection is a choice of drug combinations
% dateTable = getDateAnimalUniqueByTreatment(treatment);
% plotsToMake = unique(dateTable.DrugList);
% subTable = dateTable(plotsToMake(selection)==dateTable.DrugList,:);
% acceptedPermutations = [1,2];
% % ========================
% treatment = 'DOI_conc';
% selection = 2; % selection is a choice of drug combinations
% dateTable = getDateAnimalUniqueByTreatment(treatment);
% excludeAnimal = 'ZZ05'; % there should really be a 'hasMagnet' flag in the database
% dateTable = dateTable(excludeAnimal~=dateTable.AnimalName,:);
% plotsToMake = unique(dateTable.DrugList);
% subTable = dateTable(plotsToMake(selection)==dateTable.DrugList,:);
% subTable = subTable(5:end,:); % for now, based on our data, just exclude the recording lengths that don;t fit together
% acceptedPermutations = [1,2,3,4,5,8,9,10];
% % ========================
% treatment = '5-MeO-MiPT';
% selection = 1; % selection is a choice of drug combinations
% dateTable = getDateAnimalUniqueByTreatment(treatment);
% plotsToMake = unique(dateTable.DrugList);
% subTable = dateTable(plotsToMake(selection)==dateTable.DrugList,:);
% acceptedPermutations = [1,2];
% % ========================
% treatment = 'Pyr-T';
% selection = 1; % selection is a choice of drug combinations
% dateTable = getDateAnimalUniqueByTreatment(treatment);
% plotsToMake = unique(dateTable.DrugList);
% subTable = dateTable(plotsToMake(selection)==dateTable.DrugList,:);
% acceptedPermutations = [1,2];
% % ========================
% treatment = '6-FDET';
% selection = 1; % selection is a choice of drug combinations
% dateTable = getDateAnimalUniqueByTreatment(treatment);
% plotsToMake = unique(dateTable.DrugList);
% subTable = dateTable(plotsToMake(selection)==dateTable.DrugList,:);
% acceptedPermutations = [1,2];
% % ========================
% treatment = '4-AcO-DMT';
% selection = 1; % selection is a choice of drug combinations
% dateTable = getDateAnimalUniqueByTreatment(treatment);
% plotsToMake = unique(dateTable.DrugList);
% subTable = dateTable(plotsToMake(selection)==dateTable.DrugList,:);
% acceptedPermutations = [1,2];
% % ========================
% treatment = '5-MeO-PyrT';
% selection = 1; % selection is a choice of drug combinations
% acceptedPermutations = [1,2];

% treatment = 'Mifepristone_conc'; 
% selection = 1; 
% acceptedPermutations = [1,2]; 


dateTable = getDateAnimalUniqueByTreatment(treatment);

excludeAnimal = 'ZZ09'; % there should really be a 'hasMagnet' flag in the database
dateTable = dateTable(excludeAnimal~=dateTable.AnimalName,:);

plotsToMake = unique(dateTable.DrugList);
subTable = dateTable(plotsToMake(selection)==dateTable.DrugList,:);



% loop through expts of interest.  Create a structure animalData that 
% contains everything we need.  We will sort it below
animalData = struct();
for iList = 1:size(subTable,1)
    disp(['Loading session ' num2str(iList) ' of ' num2str(size(subTable,1))]);
    animalData(iList).data = getHTRExperimentInfoFromDateName(subTable.Date{iList},subTable.AnimalName{iList}); 
end

% This standalone function will merge experiments that happen 24 hours
% later into the same recognized 'set'
animalData= mergeHTRExperimentInfo(animalData);

% for animals with odd combinations of recording hours (DOI for now) find
% appropriate spans to pool: all animals that share *exclusive* sets only
% this section relies on the acceptedPermutations variable entered at the
% beginning
for iList = 1:size(animalData,2)
    useThese = ismember(animalData(iList).data.hourOfRecording,acceptedPermutations);
    if sum(useThese) ~= size(acceptedPermutations,2)
        useThese = false(size(useThese));
    end
    theseFields = fields(animalData(iList).data);
    for iFields = 2:size(theseFields,1)
        trimmedAnimalData(iList).data.(theseFields{iFields}) = animalData(iList).data.(theseFields{iFields})(1,useThese);
    end
end

% look in each list for all hours and start grouping events by those hours
hourData(1:25) = struct(); %TODO! 25 should not be hardcoded! use existing hours instead? 
hourData(1).events = [];
hourData(1).nMice = [];
hourData(1).maxLength = [];
hourData(1).dt = [];
for iList = 1:size(trimmedAnimalData,2)
    for iHour = 1:size(trimmedAnimalData(iList).data.hourOfRecording,2)
        thisHour = trimmedAnimalData(iList).data.hourOfRecording(iHour);
        hourData(thisHour).events = cat(1,hourData(thisHour).events,trimmedAnimalData(iList).data.eventArray(1,iHour).events);
        if isempty(hourData(thisHour).nMice)
            hourData(thisHour).nMice = 0;
            hourData(thisHour).maxLength = 0;
            hourData(thisHour).dt = 0;
        end
        hourData(thisHour).nMice = hourData(thisHour).nMice+1;
        hourData(thisHour).maxLength = max(trimmedAnimalData(iList).data.timeLength(iHour),hourData(thisHour).maxLength);
        hourData(thisHour).dt = trimmedAnimalData(iList).data.timeDT(iHour);
    end
end



%we need to output these to a table for other people
%binsByAnimal = zeros();
binSize = 10; 
for iList = 1:size(animalData,2)
    for iHour = 1:size(trimmedAnimalData(iList).data.hourOfRecording,2)
        thisHour = trimmedAnimalData(iList).data.hourOfRecording(iHour);
        binSizeMin = binSize*60;
        timeArray = (0:hourData(thisHour).dt:hourData(iHour).maxLength*hourData(thisHour).dt);
        edges = timeArray(1):binSizeMin:timeArray(end);
        centers = edges+(binSizeMin/2);
        centers = centers(1:end-1);
        Y = discretize(hourData(iHour).events,edges);
        nBins = length(edges)-1;    
    end
end







% Finally, we plot
figure();
nHours = size(acceptedPermutations,2);
plotIndex = 1;
binSize = 5;  %in minutes
clear meanHist
maxHistY = 0;
maxMeanY = 0;
for iHour = 1:size(hourData,2)
    if ~isempty(hourData(iHour).events)
        hourData(iHour).events = sort(hourData(iHour).events); % units = seconds
        binSizeMin = binSize*60;
        timeArray = (0:hourData(thisHour).dt:hourData(iHour).maxLength*hourData(thisHour).dt);
        edges = timeArray(1):binSizeMin:timeArray(end);
        centers = edges+(binSizeMin/2);
        centers = centers(1:end-1);
        Y = discretize(hourData(iHour).events,edges);
        subtightplot(2,nHours,plotIndex);
        nBins = length(edges)-1;
        histogram(Y,nBins);
        %ylim([0,24]);
        if iHour ~=1; yticklabels([]); end
        timeSteps = [ 15 30 45 ];
        xticks(timeSteps/binSize); % 2 min
        xticklabels({'15' '30' '45' });
        if iHour == 1
            ylabel('Cumulative HTR');
            title(['Pre inj  n=' num2str(hourData(iHour).nMice)]);
        else
            title(['Hour ' num2str(iHour) '  n=' num2str(hourData(iHour).nMice)]);
        end
        counts = hist(Y,nBins);
        maxHistY = max(maxHistY,max(counts));
        meanHist(plotIndex,:) = counts/hourData(iHour).nMice;
        subtightplot(2,nHours,plotIndex+nHours);
        smoothedMean = smooth(counts/hourData(iHour).nMice);
        maxMeanY = max(maxMeanY,max(smoothedMean));
%         err = zeros(1,length(smoothedMean));
%         err(:) = std(smoothedMean)/(sqrt(hourData(iHour).nMice));
        for iError = 1:size(counts,2)
            err(iError) = std(smoothedMean)/(sqrt(counts(iError)));
            %err(iError) = std(counts)/(sqrt(counts(iError)));
        end
        %errorbar(centers/60,smoothedMean,err,'*r');
        plot(centers/60,smoothedMean,'*r');
        
        xlim([edges(1)/60,edges(end)/60]);
        if iHour ~=1; yticklabels([]); end
        if iHour == 1
            ylabel('smoothed average of HTR')
        end
        plotIndex = plotIndex+1;
    end
end
% A little loop to rescale plots after a max has been found above.
plotIndex = 1;
for iHour = 1:size(hourData,2)
    if ~isempty(hourData(iHour).events)
    subtightplot(2,nHours,plotIndex);
    ylim([0,maxHistY*1.2]);
    subtightplot(2,nHours,plotIndex+nHours);
    ylim([0,maxMeanY*1.05]);
    plotIndex = plotIndex+1;
    end
end
















% TODO make animalData a table?
% sz = [1 4];
% varTypes = {'string','string','double','double'};
% varNames = {'AnimalName','Date','TimeArray','EventArray'};
% eventTable = table('Size',sz,'VariableTypes',varTypes,'VariableNames',varNames);



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

