function fileMaint_Sigma1(animalName,exptDate)
fileMaint(animalName);
% animalName = 'EEG223';
% exptDate = '22d18';
cleanDataByThresholdAnimalDateEEG(animalName,exptDate);
% keyboard
chansToExclude = nan;
setName = 'combined';
patientAnalysis.runAnalysis(@specAnalysis, 'Subjects',{animalName},'Blocks',{exptDate},'isMouse',true,'OptionSet','SegLength4');
sendToSlack = false;
plotSpectraEEG(animalName,exptDate,chansToExclude,setName,sendToSlack);
PSMTableForR2(animalName,exptDate);

reportPlot = true;
textNotes = 'Seeking evaluation';
qualityAssuranceEEG(animalName,exptDate,reportPlot,textNotes);
