%Create table of peak responses on stim resp days and export as CSV

%% Define animal and subset


animal = {'ZZ19'};
% subset={'21804','22117','22203'};
% drug =;

if contains(animal,'ZZ10')
    manualPeakEntry = [2,1,1];
end
if contains(animal,'ZZ09')
    manualPeakEntry = [2,2,1];
end
if contains(animal,'ZZ14')
    manualPeakEntry = [2,2,1];
end
if contains(animal,'ZZ15')
    manualPeakEntry = [2,1,1];
end
if contains(animal,'ZZZZexample')
    manualPeakEntry = [1,1,1];
end
if ~exist('manualPeakEntry','var')
    warning('The peaks haven''t been set for this animal.');
    warning('We''ll show you a table but then error out.')
end


% % ========= Set up the list of animals to run ===============

%This will loop through the cell array of animals we create above and pull
%all plasticity recordings for these animals
exptTableComplete = table();
for ianimal = 1:size(animal,2);
[exptTable] = getExptPlasticitySetByAnimal(animal{ianimal});
exptTableComplete =  [exptTableComplete ; exptTable];
end

%We now want to make a table that pulls data from indices from the subset we give it
% stimRespExptTable = exptTableComplete(contains(exptTableComplete.DateIndex,subset(:)),:);
% stimRespExptTable = stimRespExptTable(stimRespExptTable.stimResp == true,:);

%% This is to prune without subset
% stimRespExptTable = exptTableComplete(exptTableComplete.stimResp == true,:);

%% If we want to toggle for a certain drug do that here

% stimRespExptTable = stimRespExptTable(contains(stimRespExptTable.Description,drug),:);

%%
%list of drugs
drugsToUse = {'Saline','Psilocybin','DOI','4-AcO-DMT','6-FDET'};

% we need to step through the list of drugs; find the days with the named
% drug in the description, then grab the *next* valid experiment, which
% will be the 24 hour timepoint.
tempTable = table();
for idrug = 1:size(drugsToUse,2)
    stimRespExptTable = exptTableComplete(exptTableComplete.stimResp == true,:);
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

%%
% % % ========= step through the new list and pull data ========

exptList = stimRespExptTable.DateIndex;

nIndex = size(exptList,1);
nROI = 1;
data = struct();
for iList = 1:nIndex
    exptDate = exptList{iList}(1:5);
    exptIndex = exptList{iList}(7:9);
    dirStrAnalysis = [ getPathGlobal('M') 'PassiveEphys\20' exptDate(1:2) '\' exptDate '-' exptIndex '\'];
    data(iList).index = exptList{iList};
    data(iList).Animal = stimRespExptTable.Animal;
    data(iList).Drug = stimRespExptTable.Description;
    %Here rewrite the drug description using drugsToUse and doing a
    %contains if it contains the drug then say drug - baseline if it does
    %not say drug 24hr post
    try 
        load([dirStrAnalysis exptDate '-' exptIndex '_peakData'],'peakData');
        for iROI = 1:size(peakData.ROILabels,1)
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
        
        for iROI = 1:nROI
            data(iList).ROI(iROI).maxPeaks = NaN;
            data(iList).ROI(iROI).peakTimes = NaN;
        end
    end
end


%% Create table

varTypes = {'string','string','string','string','double'};
varNames = {'Animal','Drug','ROI','File','MaxPeak'};
nROI = 1;
sz = [length(exptList)*nROI length(varNames)];
stimPeakTable = table('Size',sz,'VariableTypes',varTypes,'VariableNames',varNames);

for iROI = 1
    for iList = 1:nIndex
        indexList = ((iROI-1)*nIndex)+iList;
        stimPeakTable.Animal(indexList) = data(iList).Animal(iList);
        stimPeakTable.Drug(indexList) = data(iList).Drug(iList);
        stimPeakTable.ROI(indexList) = [peakData.ROILabels(iROI)];
        stimPeakTable.File(indexList) = data(iList).index;
        stimPeakTable.MaxPeak(indexList) = data(iList).ROI(iROI).maxPeaks(1,1); 
    end
end
%stimPeakTable

%% Export as CSV for prism

outPath = ['C:\Users\Grady\Documents\Zarmeen Data\PeakMax'];
tableOutPath = fullfile(outPath, 'stimPeakTable.csv')
writetable(stimPeakTable,tableOutPath)

%% Plotting bar plot for summary and average traces at each time point

% 1. step through the list weve made based on drugsToUse 

% drugsToUse = {'Saline','Psilocybin','DOI','4-AcO-DMT','6-FDET'};
figure;

 
for idrug = 1:size(drugsToUse,2)
    subplot(1,size(drugsToUse,2),idrug)
    title([drugsToUse{idrug}]);
    useThese = contains(stimPeakTable.Drug,drugsToUse{idrug});
    peaksIndexBaselineToUse = find(useThese==true);
    peaksIndexPostToUse = peaksIndexBaselineToUse+1;
    
    plotArray(1,:) = stimPeakTable.MaxPeak(peaksIndexBaselineToUse);
    plotArray(2,:) = stimPeakTable.MaxPeak(peaksIndexPostToUse);
    
    plot(plotArray);
    xlim([0.9,2.1]);
    ylim([15*10^-5]);
    
%     scatter(ones(1,size(plotArray,2)),plotArray(1,:));
%     hold on
%     scatter(ones(1,size(plotArray,2))+1,plotArray(2,:));
%     xlim([0,3]);
    clear plotArray
    title([drugsToUse{idrug}]);
end




%Change relative to baseline values across drugs 


