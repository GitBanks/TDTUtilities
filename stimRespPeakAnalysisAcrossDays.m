function [plotH] = stimRespPeakAnalysisAcrossDays(animal,subset)
% % test params
% animal = 'ZZ10';
% subset={
% '21716'
% '21717'
% '21718'
% '21719'
% '21720'
% '21721'
% '21722'
% '21723'
% };


% % ========= Set up the list of animals to run ===============
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
        disp(['loaded ' subset{iDay} ' with ' num2str(msg) ' seconds elapsed.']);
    end
end   
exptList = stimRespExptTable.DateIndex;


% % % ========= step through the new list and perform calculations ========
nIndex = size(exptList,1);
nROI = 3;
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


% % % ============= Here's a table of peaks and times =====================
% this is necessary to be sure we're looking at the same peaks across days
% we need to account for the number - if an inconsistant number of peaks
% were selected we could be comparing incorrectly.  There was some previous
% code that automatically reran the selection, but it's better to check
% manually
varTypes = {'string','string','double','double','double','double'};
varNames = {'ROI','File','Peak1','Peak2','Peak3','Peak4'};
sz = [length(exptList)*nROI length(varNames)];
stimTimeTable = table('Size',sz,'VariableTypes',varTypes,'VariableNames',varNames);
for iROI = 1:nROI
    for iList = 1:nIndex
        indexList = ((iROI-1)*nIndex)+iList;
        stimTimeTable.ROI(indexList) = [peakData.ROILabels(iROI)];
        stimTimeTable.File(indexList) = data(iList).index;
        for iPeaks = 1:length(data(iList).ROI(iROI).peakTimes)
            stimTimeTable.(['Peak' num2str(iPeaks)])(indexList) = data(iList).ROI(iROI).peakTimes(iPeaks);
        end
    end
end
stimTimeTable
disp('Please review this table and be sure the peak times and counts make sense.');
pause(3);


% ================== find the datetimes for recordings ====================
% this section uses getTimeAndDurationFromIndex to get the exact datetime
% of the index for the x axis. 
% if there's an injection index, include it here
if exist('injectionIndex','var') % this will run if we didn't already define 
    strExpt = char(injectionIndex);
    thisDate = strExpt(1:5);
    thisIndex = strExpt(7:9);
    dateExpt = houseConvertDateTo_dbForm(thisDate);
    [~,timeOfDay] = getTimeAndDurationFromIndex(thisDate,thisIndex);
    injMoment = datetime([dateExpt ' ' char(timeOfDay)]);
end
for ii = 1:length(exptList)
    strExpt = char(exptList(ii));
    thisDate = strExpt(1:5);
    thisIndex = strExpt(7:9);
    dateExpt = houseConvertDateTo_dbForm(thisDate);
    [~,timeOfDay] = getTimeAndDurationFromIndex(thisDate,thisIndex);
    exptSeq(ii) = datetime([dateExpt ' ' char(timeOfDay)]);
end


% ===================== finally we plot ===================================
plotH = figure();
manualPeakEntry = [2,1,1];
for iROI = 1:nROI
    subtightplot(3,1,iROI);
    for ii = 1:length(data)
        plotMatrix(ii,:) = data(ii).ROI(iROI).maxPeaks(manualPeakEntry(iROI));
    end
    plot(exptSeq,plotMatrix,'x-');
    hold on
    clear plotMatrix
    xl = xline(injMoment,'.',drugInj,'DisplayName',drugInj,'LineWidth',1,'Interpreter', 'none');
    xl.LabelVerticalAlignment = 'middle';
    if iROI == 1
        title([animal ' stim/resp peak value over time']);
    end
    ylabel([peakData.ROILabels(iROI)]);
    %ylim([0,900]);
    %xlim([0,nIndex+1]);
    %xticks(1:nIndex);
%     if iROI == 3
%         set(gca,'xticklabel',exptList);
%         xtickangle( 45 );
%     end
end



% ======== stuff I really thought I'd need, but didn't ===========
% keep this in case we do.  we've discussed a few features already 
% [exptInfo] = getMetadata(exptDate,exptIndex);  % we're not doing anything with this?
% outPath2 = ['M:\PassiveEphys\AnimalData\' animal '\'];
% load([outPath2 animal '_peakDataOverTime'],'peakDataOverTime');



