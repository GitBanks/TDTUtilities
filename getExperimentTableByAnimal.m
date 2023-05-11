%This will give you a table of experiments - what kind of experiment it
%was, what drug was used and its dose

animal = {'ZZ06', 'ZZ07','ZZ08','ZZ09','ZZ10','ZZ11','ZZ12','ZZ13','ZZ14','ZZ15','ZZ16','ZZ19', 'ZZ20', 'ZZ21', 'ZZ22','ZZ24','ZZ26','ZZ27'};
% % ========= Set up the list of animals to run ===============

%This will loop through the cell array of animals we create above and pull
%all plasticity recordings for these animals and tell us what kind of
%recoridng it was
exptTableComplete = table();
for ianimal = 1:size(animal,2);
[exptTable] = getExptPlasticitySetByAnimal(animal{ianimal});
exptTableComplete =  [exptTableComplete ; exptTable];
end

%% This is to filter for specific subsets (days) of recordings 
% stimRespExptTable = exptTableComplete(contains(exptTableComplete.DateIndex,subset(:)),:);


%% This is to filter by type of recording
stimRespExptTable = exptTableComplete(exptTableComplete.stimResp == true,:);

%% Get drug info - this step takes a while

for ianimal = 1:size(stimRespExptTable, 1)
  date = char(stimRespExptTable.DateIndex{ianimal});
  date = date (1:5);
  treatmentInfo = getTreatmentInfo(stimRespExptTable.Animal{ianimal},date);
  if isempty(treatmentInfo.pars)
      stimRespExptTable.Treatment(ianimal) = "";
  else
      stimRespExptTable.Treatment(ianimal) = convertCharsToStrings(treatmentInfo.pars{1,1});
  end
  if isempty(treatmentInfo.vals)
      stimRespExptTable.Dose(ianimal) = NaN;
  else
    stimRespExptTable.Dose(ianimal) = treatmentInfo.vals(1,size(treatmentInfo.vals,2);
  end
end

%% Make a pretty end table


varTypes = {'string','string','string','string','double'};
varNames = {'Animal','Index','ExperimentDescription','Treatment','Dose'};
exptList = [stimRespExptTable.DateIndex stimRespExptTable.Animal];
nROI = 1;
nIndex = size(exptList,1);
sz = [length(exptList)*nROI length(varNames)];
finalTable = table('Size',sz,'VariableTypes',varTypes,'VariableNames',varNames);

 for iList = 1:nIndex
 exptDate = exptList{iList}(1:5);
 exptIndex = exptList{iList}(7:9);
 finalTable.Animal(iList) = stimRespExptTable.Animal{iList};
 finalTable.Index(iList) = exptList{iList};
 finalTable.ExperimentDescription(iList) = stimRespExptTable.Description{iList};
 finalTable.Treatment(iList) = stimRespExptTable.Treatment{iList};
 finalTable.Dose(iList) = stimRespExptTable.Dose(iList,:);
 end

%% Save

outPath = ['C:\Users\Grady\Documents\Zarmeen Data\'];
tableOutPath = fullfile(outPath, 'StimRespMasterTable.csv')
writetable(finalTable, tableOutPath)
