function fileMaint_Sigma1(animalName,exptDate)
fileMaint(animalName);
% animalName = 'EEG223';
% exptDate = '22d18';
chansToExclude = nan;
setName = 'combined';
patientAnalysis.runAnalysis(@specAnalysis, 'Subjects',{animalName},'Blocks',{exptDate},'isMouse',true,'OptionSet','SegLength4');
sendToSlack = true;
plotSpectraEEG(animalName,exptDate,chansToExclude,setName,sendToSlack);
PSMTableForR2(animalName,exptDate);
