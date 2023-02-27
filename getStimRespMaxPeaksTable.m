%Create table of peak responses on stim resp days and export as CSV

%% Define animal and subset


animal = {'ZZ06', 'ZZ07','ZZ08','ZZ09','ZZ10','ZZ11','ZZ12','ZZ13','ZZ14','ZZ15','ZZ16','ZZ19', 'ZZ20', 'ZZ21', 'ZZ22'};
%animal = {'ZZ16'}
% subset={'21804','22117','22203'};
% drug =;
% % ========= Set up the list of animals to run ===============

%This will loop through the cell array of animals we create above and pull
%all plasticity recordings for these animals
exptTableComplete = table();
for ianimal = 1:size(animal,2);
[exptTable] = getExptPlasticitySetByAnimal(animal{ianimal});
exptTableComplete =  [exptTableComplete ; exptTable];
end

%% We now want to make a table that pulls data from indices from the subset we give it
% stimRespExptTable = exptTableComplete(contains(exptTableComplete.DateIndex,subset(:)),:);
% stimRespExptTable = stimRespExptTable(stimRespExptTable.stimResp == true,:);

%% This is to prune without subset
stimRespExptTable = exptTableComplete(exptTableComplete.spon == true,:);

% stimRespExptTable.Saline = contains(stimRespExptTable.Description, 'Saline');
% stimRespExptTable.Psilocybin = contains(stimRespExptTable.Description, 'Psilocybin');
% 
% SalineTable = stimRespExptTable(stimRespExptTable.Saline == true,:)
% PsilTable = stimRespExptTable(stimRespExptTable.Psilocybin == true,:)

%%
% % % ========= step through the new list and pull data ========

exptList = [stimRespExptTable.DateIndex stimRespExptTable.Animal];

nIndex = size(exptList,1);
nROI = 1;
data = struct();
for iList = 1:nIndex
    exptDate = exptList{iList}(1:5);
    exptIndex = exptList{iList}(7:9);
    dirStrAnalysis = [ getPathGlobal('M') 'PassiveEphys\20' exptDate(1:2) '\' exptDate '-' exptIndex '\'];
    data(iList).index = exptList{iList};
    data(iList).Animal = stimRespExptTable.Animal;
    data(iList).Drug = stimRespExptTable.Description{iList};
   if contains(exptList{iList,2},'ZZ06')
    manualPeakEntry = [2];
    end 
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
    if contains(exptList{iList,2},'ZZ16')
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
    if contains(exptList{iList,2},'ZZ22')
        manualPeakEntry = [2];
    end
    try 
        load([dirStrAnalysis exptDate '-' exptIndex '_peakData'],'peakData');
        %for iROI = 1:size(peakData.ROILabels,1) %look to remove this for loop
            % this is where we grab the calculated peaks.
            %[data(iList).ROI(iROI).maxPeaks] = max(peakData.pkVals(iROI).data,[],2);
            peakAbs = abs(peakData.pkVals(1).data);
            [peakMax, peakIndex] = max(peakAbs,[],2);
            peakIndexUse = peakIndex(manualPeakEntry,1);
            %for ii = 1:size(peakData.pkVals.data,1) %(iROI).peakTimeCalc,1)
                data(iList).ROI(1).peakTimes(1) = peakData.pkVals(1).peakTimeCalc(manualPeakEntry,peakIndexUse);
                data(iList).ROI(1).maxPeaks(1) = peakMax(manualPeakEntry,1);
            %end        
%             data(iList).ROI(iROI).peakTimes = peakData.pkSearchData(iROI).tPk; % this will change
            if isempty(data(iList).ROI(iROI).maxPeaks) % if someone didn't select a peak
                error('The program requires the number of peaks selected to be the same, every day, for an animal')
            end
        %end
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
        stimPeakTable.Drug(indexList) = data(iList).Drug;
        stimPeakTable.ROI(indexList) = [peakData.ROILabels(iROI)];
        stimPeakTable.File(indexList) = data(iList).index;
        stimPeakTable.MaxPeak(indexList) = data(iList).ROI(iROI).maxPeaks(1,1);
        stimPeakTable.PeakTime(indexList) = data(iList).ROI(iROI).peakTimes(1,1);
    end
end
%stimPeakTable

%% Export as CSV for prism

outPath = ['C:\Users\Grady\Documents\Zarmeen Data\PeakMax'];
tableOutPath = fullfile(outPath, 'stimPeakTable23120.csv')
writetable(stimPeakTable, tableOutPath)





