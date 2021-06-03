function  HTRPlotEventsScript(treatment)

%clear all

% 3. step through dates - use get treatmentInfo to get exact times of
% treatment
% 4. plot each day (as before) but respect time

% Warning!  must be very accurate with the exact spelling of the treatment.
%  Consider a pull-down menu or something

%treatment = '6-FDET'; %     '6-FDET'
%treatment = 'DOI_conc';
%treatment = '5-MeO-MiPT'; %  '5-MeO-MiPT'
%treatment = 'Pyr-T'; %   'Pyr-T'
%treatment = '4-AcO-DMT'; % '4-AcO-DMT'
%treatment = '5-MeO-pyrT'; %'5-MeO-PyrT'
%treatment = '5,6-DiMeO-MiPT';   %'5,6-DiMeO-MiPT'
%treatment =   '5-MeO-DET';


dateTable = getDateAnimalUniqueByTreatment(treatment);


excludeAnimal = 'ZZ05'; % there should really be a 'hasMagnet' flag in the database
dateTable = dateTable(excludeAnimal~=dateTable.AnimalName,:);


% for now just cycle through the drug combinations.  In the future we can
% add a popup or menu or something more clever
plotsToMake = unique(dateTable.DrugList);
for iCond = 1:size(plotsToMake,1)
    subTable = dateTable(plotsToMake(iCond)==dateTable.DrugList,:);
    % we need a way to sort away treatments that aren't related (DOI +
    % Miphepristone, e.g.)
    HTRevents = figure;
    maxTime = 0;
    for iList = 1:size(subTable,1)
        outputList = getExperimentsByAnimalAndDate(subTable.AnimalName{iList},subTable.Date{iList});
        %step through each index for that day
        injectionTime = []; % now handled by getTreatmentInfo
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
            while length(timeArray) > length(magData) %sometimes time is a mystery
                timeArray = timeArray(1:end-1);
            end
            fullTimeArray = cat(2,fullTimeArray,(timeArray+previousIndexTimeElapsed));
            fullMagStream = cat(2,fullMagStream,magData);
            fullEventTimes = cat(2,fullEventTimes,htrEventTimes+previousIndexTimeElapsed);
            previousIndexTimeElapsed = previousIndexTimeElapsed+timeArray(end);
            timeSteps(idx) = previousIndexTimeElapsed;
        end

      
        % start plotting.  
        figure(HTRevents);
        subtightplot(size(subTable,1),1,iList);
        plot(fullTimeArray,envelope(abs(fullMagStream)));
        drawnow;
        hold on
       
        %OK, we're going to assume that the treatment variable is the reference
        %point, so will adjust all our times according to it
        treatments = getTreatmentInfo(subTable.AnimalName{iList},subTable.Date{iList});
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
        
        % TODO adjust these relative to treatment time.  may need to do
        % this, then plot afterwards, scale the x axis
%         fullEventTimes
%         fullTimeArray


        for iPlot = 1:length(fullEventTimes)
           xline(fullEventTimes(iPlot),'r');
        end
%         if iList == 1
%             title(plotsToMake(iList));
%         end
        hold off
        ylabel(subTable.AnimalName{iList});
        
        

        xlabel('Seconds')
        %xlim([-1800,6000]);%if times are adjusted, change to something
        %like this
        maxTime = max(fullTimeArray(end),maxTime);
        drawnow;
    end
    
    %replot
    for iList = 1:size(subTable,1)
        subtightplot(size(subTable,1),1,iList);
        xlim([0,maxTime]);
        ylim([5,17]);
        drawnow
    end
end

