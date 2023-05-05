function fileMaint_Sigma1(animalName,exptDate)
% test params
% animalName = 'EEG223';
% exptDate = '22d18';

fileMaint(animalName);

cleanDataByThresholdAnimalDateEEG(animalName,exptDate);

patientAnalysis.runAnalysis(@specAnalysis, 'Subjects',{animalName},'Blocks',{exptDate},'isMouse',true,'OptionSet','SegLength4');

chansToExclude = nan;
setName = 'combined';
sendToSlack = false;
plotSpectraEEG(animalName,exptDate,chansToExclude,setName,sendToSlack);

PSMTableForR2(animalName,exptDate);

reportPlot = true;
textNotes = 'Seeking evaluation';
qualityAssuranceEEG(animalName,exptDate,reportPlot,textNotes);
