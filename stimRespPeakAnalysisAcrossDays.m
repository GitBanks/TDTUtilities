function [plotH] = stimRespPeakAnalysisAcrossDays(animal,subset)
% test params
animal = 'ZZ10';
subset={
'21716'
'21717'
'21718'
'21719'
'21720'
'21721'
'21722'
'21723'
};

% First set up our list. 
% Note: This is nearly the same as fileMaint, so consider combining
% these. e.g., have this program instead take a list of expts from
% fileMaint and just plot the stim/resp peaks
listOfAnimalExpts = getExperimentsByAnimal(animal);
descOfAnimalExpts = listOfAnimalExpts(:,2);
listOfAnimalExpts = listOfAnimalExpts(:,1);
sz = [length(listOfAnimalExpts) 3];
varTypes = {'string','string','logical'};
varNames = {'DateIndex','Description','StimRespData'};
exptTable = table('Size',sz,'VariableTypes',varTypes,'VariableNames',varNames);
root = 'M:\PassiveEphys\20';
for iList = 1:length(listOfAnimalExpts)
    exptTable.Description(iList) = descOfAnimalExpts{iList}{1};
    exptDate = listOfAnimalExpts{iList}(1:5);
    exptIndex = listOfAnimalExpts{iList}(7:9);
    exptTable.DateIndex(iList) = [exptDate '-' exptIndex];
    dirStrAnalysis = [root exptDate(1:2) '\' exptDate '-' exptIndex '\'];
    % both description must match and saved data must be there
    if contains(exptTable.Description(iList),'stim/resp') && ~isempty(dir([dirStrAnalysis '*_peakData*']))
        exptTable.StimRespData(iList) = true;
    else
        exptTable.StimRespData(iList) = false;
    end
end

% let's prune our list to just the stim/resp expts
stimRespExptTable = exptTable(exptTable.StimRespData == 1,:);

% This block is to find which of the expts is the injection index
% here's a way to prune further: a subset of experiments from a user input
if exist('subset','var') % if we're working with a subset, we can get some specifics
    stimRespExptTable = stimRespExptTable(contains(stimRespExptTable.DateIndex,subset),:);
    % check each day for drug/injection information
    disp('Loading drug information for selected experiments.');
    tic;
    for iDay = 1:size(subset,1)
        treats = getTreatmentInfo(animal,subset{iDay});
        if sum(treats.injIndex) == 1 %warning! this assumes 1 drug manipulation
            listQ = getExperimentsByAnimalAndDate(animal,subset{iDay});
            injectionIndex = listQ{treats.injIndex};
            drugInj = treats.pars{treats.injIndex};
        end
        msg = toc;
        display(['loaded ' subset{iDay} ' with ' num2str(msg) ' seconds elapsed.']);
    end
    
end   
exptList = stimRespExptTable.DateIndex;

% step through the new list
nIndex = size(exptList,1);
nROI = 3;
%plotMatrix = zeros(nStimResp,nROI);
data = struct();
for iList = 1:nIndex
    exptDate = exptList{iList}(1:5);
    exptIndex = exptList{iList}(7:9);
    dirStrAnalysis = [root exptDate(1:2) '\' exptDate '-' exptIndex '\'];
    data(iList).index = exptList{iList};  
    try 
        load([dirStrAnalysis exptDate '-' exptIndex '_peakData'],'peakData');
        for iROI = 1:size(peakData.ROILabels,1)
            [data(iList).ROI(iROI).maxPeaks,~] = max(peakData.pkVals(iROI).data,[],2);
            
            
            
            data(iList).ROI(iROI).peakTimes = peakData.pkSearchData(iROI).tPk; % this will change
            
            
            
            if isempty(data(iList).ROI(iROI).maxPeaks) % if someone didn't select a peak
                data(iList).ROI(iROI).maxPeaks = 0;
            end
        end
    catch
        for iROI = 1:nROI
            data(iList).ROI(iROI).maxPeaks = NaN;
            data(iList).ROI(iROI).peakTimes = NaN;
        end
    end
end



for iROI = 1:nROI
    % we need to account for the number - if an inconsistant number of
    % peaks were selected
    for iList = 1:nIndex
        sizeCheck(iList) = size(data(iList).ROI(iROI).peakTimes,1);
    end
    wrongSize = (sizeCheck ~= round(mean(sizeCheck)));
    for iStep = 1:sum(wrongSize)
        % we need to decide if we want to rerun the original program (to
        % select the correct number of peaks), or if we want the program to
        % use the 'common' times to find the peaks on the suspect day.
        
        
        
        evokedStimResp_userInput(exptDate,exptIndex)
        
        
        
        
    end
    
    for iList = 1:nIndex
        data(iList).ROI(iROI).peakTimes
%     % Matt suggested index alone may be sufficient.  Here's how we could
%     % grab exact times, though
%     [drugIndexDur,drugTimeOfDay] = getTimeAndDurationFromIndex(injectionIndex(1:5),injectionIndex(7:9));
%     [indexDur,timeOfDay] = getTimeAndDurationFromIndex(thisDate,thisIndex);
%     [exptInfo] = getMetadata(exptDate,exptIndex);  % we're not doing anything?
    end
end


% if there's an injection index, include it here
if ~exist('injectionIndex','var') % this will run if we didn't already define 
    exptList(end+1) = injectionIndex;
    exptList = sort(exptList);
end






% this block will no longer work - need to update plotMatrix to structure 'data'
injectionsHere = isnan(plotMatrix);


injIndex = find((injectionsHere(:,1)==true));
plotH = figure();
for iROI = 1:nROI
    subtightplot(4,1,iROI);
    plot(plotMatrix(:,iROI),'x-');
    xl = xline(injIndex,'.',drugInj,'DisplayName',drugInj,'LineWidth',6,'Interpreter', 'none');
    xl.LabelVerticalAlignment = 'middle';
    
    if iROI == 1
        title([animal ' stim/resp peak value over time']);
    end
    ylabel([peakData.ROILabels(iROI)]);
    %ylim([0,900]);
    xlim([0,nIndex+1]);
    xticks(1:nIndex);
    if iROI == 3
        set(gca,'xticklabel',exptList);
        xtickangle( 45 );
    end
end







