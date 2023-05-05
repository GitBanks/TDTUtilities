function [plotH] = stimRespPeakAnalysisAcrossDays(animal,subset)

% ====== attention user: this needs to be set for each animal! ============
% this sets which peak to plot in each ROI for an animal. If you haven't 
% set it for the animal, this will error after the table is presented 

% test params
 animal = {'ZZ09', 'ZZ10', 'ZZ14', 'ZZ15', 'ZZ19', 'ZZ20', 'ZZ21'};


% % ========= Set up the list of animals to run ===============

exptTableComplete = table();

for ianimal = 1:size(animal,2);
    [exptTable] = getExptPlasticitySetByAnimal(animal{ianimal});
    exptTableComplete =  [exptTableComplete ; exptTable];
end

stimRespExptTable = exptTableComplete(exptTableComplete.stimResp == true,:);


%% ===============================================================================================
exptList = [stimRespExptTable.DateIndex stimRespExptTable.Animal];

nIndex = size(exptList,1);
nROI = 1;
data = struct();
for iList = 1:nIndex
    exptDate = exptList{iList}(1:5);
    exptIndex = exptList{iList}(7:9);
    dirStrAnalysis = [ getPathGlobal('M') 'PassiveEphys\20' exptDate(1:2) '\' exptDate '-' exptIndex '\'];
    data(iList).index = exptList{iList};
    if contains(exptList{iList,2},'ZZ09')
    manualPeakEntry = [2];
    end
    if contains(exptList{iList,2},'ZZ10')
        manualPeakEntry = [2];
    end
    if contains(exptList{iList,2},'ZZ14')
        manualPeakEntry = [1];
    end
    if contains(exptList{iList,2},'ZZ15')
        manualPeakEntry = [1];
    end
    if contains(exptList{iList,2},'ZZ19')
        manualPeakEntry = [1];
    end
    if contains(exptList{iList,2},'ZZ20')
        manualPeakEntry = [1];
    end
    if contains(exptList{iList,2},'ZZ21')
        manualPeakEntry = [1];
    end
    try 
        load([dirStrAnalysis exptDate '-' exptIndex '_peakData'],'peakData');
        for iROI = 1
            % this is where we grab the calculated peaks.
            %[data(iList).ROI(iROI).maxPeaks] = max(peakData.pkVals(iROI).data,[],2);
            peakAbs = abs(peakData.pkVals(1).data);
            [peakMax, peakIndex] = max(max(peakAbs));
            
            for ii = 1 %:size(peakData.pkVals.data) %(iROI).peakTimeCalc,1)
                data(iList).ROI(iROI).peakTimes(ii) = peakData.pkVals(1).peakTimeCalc(manualPeakEntry,peakIndex);
                data(iList).ROI(iROI).maxPeaks(ii) = peakMax;
            end        
%             data(iList).ROI(iROI).peakTimes = peakData.pkSearchData(iROI).tPk; % this will change
            if isempty(data(iList).ROI(iROI).maxPeaks) % if someone didn't select a peak
                error('The program requires the number of peaks selected to be the same, every day, for an animal')
            end
        end
    catch
        
        for iROI = 1:nROI
            data(iList).ROI(iROI).maxPeaks = NaN;
            data(iList).ROI(iROI).peakTimes = NaN;
        end
    end
end


%% =================================================================================================
for i = 1:size(stimRespExptTable)   
    [data(i).Description] = stimRespExptTable.Description(i); 
    [data(i).Animal] = stimRespExptTable.Animal(i); 
end


newTable = struct2table(data)


varTypes = {'string','string','string','string','double'};
varNames = {'Animal','Description','ROI','File','MaxPeak'};
nROI = 1;
sz = [length(exptList)*nROI length(varNames)];
stimPeakTable = table('Size',sz,'VariableTypes',varTypes,'VariableNames',varNames);


nIndex = size(exptList,1);

for iROI = 1
    for iList = 1:nIndex
        indexList = ((iROI-1)*nIndex)+iList;
        stimPeakTable.Animal(indexList) = stimRespExptTable.Animal(iList);
        stimPeakTable.Description(indexList) = data(iList).Description;
        stimPeakTable.ROI(indexList) = [peakData.ROILabels(iROI)];
        stimPeakTable.File(indexList) = data(iList).index;
        stimPeakTable.MaxPeak(indexList) = data(iList).ROI(iROI).maxPeaks(1,1);
        stimPeakTable.PeakTime(indexList) = data(iList).ROI(iROI).peakTimes(1,1);
    end
end


subsetPsil = 'Psilocybin';
PsilTable = stimPeakTable(contains(stimPeakTable.Description,subsetPsil),:);

subsetSal = 'Saline'
SalineTable = stimPeakTable(contains(stimPeakTable.Description,subsetSal),:);

subset6f = '6-FDET'
SalineTable = stimPeakTable(contains(stimPeakTable.Description,subset6f),:);


%% plotting

    
subsetAnimal = 'ZZ14';
ZZ14Table = PsilTable(contains(PsilTable.Animal,subsetAnimal),:);
figure()
plot(ZZ14Table.MaxPeak)
xticks(1:size(ZZ14Table.Description))
xticklabels(ZZ14Table.Description)


subsetAnimal = 'ZZ10';
ZZ10Table = PsilTable(contains(PsilTable.Animal,subsetAnimal),:);


subsetAnimal = 'ZZ19';
ZZ19Table = PsilTable(contains(PsilTable.Animal,subsetAnimal),:);
figure()
plot(ZZ19Table.MaxPeak)
xticks(1:size(ZZ19Table.Description))
xticklabels(ZZ19Table.Description)



%%
% ============================================================
% This block is to find which of the expts is the injection index
% here's a way to prune further: a subset of experiments from a user input
if exist('subset','var') 
    disp('Loading drug information for selected experiments.');
    tic;
    for iDay = 1:size(subset,1)
        treatments = getTreatmentInfo(animal,subset{iDay});
        if ~isempty(treatments.injIndex)  
            listQ = getExperimentsByAnimalAndDate(animal,subset{iDay});
            %this previously assumed 1 drug manipulation.  It still won't
            %like it if the same injection is listed twice or some other
            %nonesense.
            for iTreat = 1:size(treatments.pars,1)
                injectionIndex{iTreat} = listQ{treatments.injIndex(iTreat,:)};
                drugInj{iTreat} = treatments.pars{iTreat,treatments.injIndex(iTreat,:)};
            end
        end
        msg = toc;
        disp(['loaded ' subset{iDay} ' with ' num2str(msg) ' seconds elapsed.']);
    end
end

% =========================================================================
% % % ======= Here's a table of peaks and times relative to stim ==========
% this is necessary to be sure we're looking at the same peaks across days
% we need to account for the number - if an inconsistant number of peaks
% were selected we could be comparing incorrectly. 
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
if ~exist('manualPeakEntry','var')
    error('Please set the peaks to use for this animal!')
end


% ================== find the datetimes for recordings ====================
% this section uses getTimeAndDurationFromIndex to get the exact datetime
% of the index for the x axis. 
% if there's an injection index, include it here
if exist('injectionIndex','var') % this will run if we didn't already define
    for iTreat = 1:size(injectionIndex,2)
        strExpt = char(injectionIndex(iTreat));
        thisDate = strExpt(1:5);
        thisIndex = strExpt(7:9);
        dateExpt = houseConvertDateTo_dbForm(thisDate);
        [~,timeOfDay] = getTimeAndDurationFromIndex(thisDate,thisIndex);
        injMoment(iTreat) = datetime([dateExpt ' ' char(timeOfDay)]);
    end
end

for ii = 1:length(exptList)
    strExpt = char(exptList(ii));
    thisDate = strExpt(1:5);
    thisIndex = strExpt(7:9);
    dateExpt = houseConvertDateTo_dbForm(thisDate);
    [~,timeOfDay] = getTimeAndDurationFromIndex(thisDate,thisIndex);
    exptSeq(ii) = datetime([dateExpt ' ' char(timeOfDay)]);
end


% % % ========= step through the new list and perform calculations ========
nIndex = size(exptList,1);
nROI = 1;
data = struct();
for iList = 1:nIndex
    exptDate = exptList{iList}(1:5);
    exptIndex = exptList{iList}(7:9);
    dirStrAnalysis = [ getPathGlobal('M') 'PassiveEphys\20' exptDate(1:2) '\' exptDate '-' exptIndex '\'];
    data(iList).index = exptList{iList};  
    try 
        load([dirStrAnalysis exptDate '-' exptIndex '_peakData'],'peakData');
        for iROI = 1
            % this is where we grab the calculated peaks.
            [data(iList).ROI(iROI).maxPeaks,peakIndex] = max(peakData.pkVals(iROI).data,[],2);
            for ii = 1:size(peakData.pkVals(iROI).peakTimeCalc,1)
                data(iList).ROI(iROI).peakTimes(ii) = peakData.pkVals(iROI).peakTimeCalc(ii,peakIndex(ii));
            end        
%             data(iList).ROI(iROI).peakTimes = peakData.pkSearchData(iROI).tPk; % this will change
            if isempty(data(iList).ROI(iROI).maxPeaks) % if someone didn't select a peak
                error('The program requires the number of peaks selected to be the same, every day, for an animal')
            end
        end
    catch
        
        for iROI = 1
            data(iList).ROI(iROI).maxPeaks = NaN;
            data(iList).ROI(iROI).peakTimes = NaN;
        end
    end
end

% ===================== finally we plot ===================================
% optional display of one of the stim/resp peaks
exptDate = exptList{1}(1:5);
exptIndex = exptList{1}(7:9);
outPath = ['M:\PassiveEphys\20' exptDate(1:2) '\' exptDate '-' exptIndex '\'];
try
    load([outPath exptDate '-' exptIndex '_peakData'],'peakData','plotTimeArray','avgTraces');
catch
    error(['Problem loading ' [outPath exptDate '-' exptIndex '_peakData']]);
end

%Create the plot matrix of the maximum peak values here
for iROI = 1
    for ii = 1:length(data)
        plotMatrix(ii,iROI) = data(ii).ROI(iROI).maxPeaks(1,1);
    end
end

plotA = figure();


for iROI = 1
    % plot the peaks over time
    subtightplot(4,10,(1:8)+10*(iROI-1));
    plot(exptSeq,plotMatrix(:,iROI),'x-');
    hold on
    iTreat = 1;
    xl = xline(injMoment(iTreat),'.',drugInj{iTreat},'DisplayName',drugInj{iTreat},'LineWidth',1,'Interpreter', 'none');
    xl.LabelVerticalAlignment = 'middle';
    x2.LabelVerticalAlignment = 'middle';
    if iROI == 1
        title([animal ' Stimulus Response Peak Value Over Time']);
    end
    ylabel([peakData.ROILabels(iROI)]);
    set(gca,'xticklabel',[]);
    
    % Plot examples!
    subtightplot(4,10,(9:10)+10*(iROI-1));
    for iStim = 1:length(avgTraces)
        plot(plotTimeArray,avgTraces(iStim).stimSet(iROI,:));
        hold on;
        for iUI = 1:length(peakData.pkSearchData(iROI).tPk)
            plot(peakData.pkSearchData(iROI).tPk(iUI),peakData.pkSearchData(iROI).yPk(iUI),'+r','MarkerSize',12);
            if manualPeakEntry(iROI) == iUI
                plot(peakData.pkSearchData(iROI).tPk(iUI),peakData.pkSearchData(iROI).yPk(iUI),'ob','MarkerSize',14);
            end
        end
    end
    ax = gca;
    ax.XLim = [plotTimeArray(1),plotTimeArray(end)];
    ax.YLim = [1.2*peakData.plotMin(iROI),1.2*peakData.plotMax(iROI)];
    ax.XLabel.String = 'time(sec)';
    if iROI == 1
        title('Stimulus Response Traces');
    end
    set(gca,'yticklabel',[]);
end

% movement plots (an afterthought)
doPlot = false; % no need to plot each index, just the final
for ii = 1:length(exptList)
    strExpt = char(exptList(ii));
    thisDate = strExpt(1:5);
    thisIndex = strExpt(7:9);   
    singleValueForIndex(ii) = plotStimAndMovement(thisDate,thisIndex,doPlot);
end
subtightplot(4,10,31:38);
plot(exptSeq,singleValueForIndex);
hold on

iTreat = 1;
xl = xline(injMoment(iTreat),'.',drugInj{iTreat},'DisplayName',drugInj{iTreat},'LineWidth',1,'Interpreter', 'none');
xl.LabelVerticalAlignment = 'middle';
%x2 = xline(injMoment(iTreat)+1,'.','24h post','DisplayName','24h post','LineWidth',1,'Interpreter', 'none');
x2.LabelVerticalAlignment = 'middle';
set(gca,'ytick',[]);
set(gca,'yticklabel',[]);
ylabel('Movement');






