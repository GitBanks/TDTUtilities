%Create table of peak responses on stim resp days and export as CSV

%% Define animal and subset


animal = {'ZZ19' 'ZZ20' 'ZZ21' 'ZZ22'};
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

%% We now want to make a table that pulls data from indices from the subset we give it
% stimRespExptTable = exptTableComplete(contains(exptTableComplete.DateIndex,subset(:)),:);
% stimRespExptTable = stimRespExptTable(stimRespExptTable.stimResp == true,:);

%% This is to prune without subset
stimRespExptTable = exptTableComplete(exptTableComplete.stimResp == true,:);

%% If we want to toggle for a certain drug do that here

drug1 = 'Psilocybin'
drug2 = 'Stim alone'
stimRespExptTable1 = stimRespExptTable(contains(stimRespExptTable.Description,drug1),:);
stimRespExptTable2 = stimRespExptTable(contains(stimRespExptTable.Description,drug2),:);
stimRespExptTableNew = [stimRespExptTable1; stimRespExptTable2];

%%
% % % ========= step through the new list and pull data ========

exptList = stimRespExptTableNew.DateIndex;

nIndex = size(exptList,1);
nROI = 1;
data = struct();
for iList = 1:nIndex
    exptDate = exptList{iList}(1:5);
    exptIndex = exptList{iList}(7:9);
    dirStrAnalysis = [ getPathGlobal('M') 'PassiveEphys\20' exptDate(1:2) '\' exptDate '-' exptIndex '\'];
    data(iList).index = exptList{iList};
    data(iList).Animal = stimRespExptTableNew.Animal;
    data(iList).Drug = stimRespExptTableNew.Description{iList};
    try 
        load([dirStrAnalysis exptDate '-' exptIndex '_peakData'],'peakData');
        for iROI = 1:size(peakData.ROILabels,1)
            % this is where we grab the calculated peaks.
            %[data(iList).ROI(iROI).maxPeaks] = max(peakData.pkVals(iROI).data,[],2);
            peakAbs = abs(peakData.pkVals.data);
            [peakMax, peakIndex] = max(peakAbs);
            for ii = 1:size(peakData.pkVals.data) %(iROI).peakTimeCalc,1)
                data(iList).ROI(iROI).peakTimes(ii) = peakData.pkVals.peakTimeCalc(1,peakIndex);
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
tableOutPath = fullfile(outPath, 'stimResp3.csv')
writetable(stimRespExptTable,tableOutPath)




