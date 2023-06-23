function fileMaint_passiveEphys(animalName,exptDate)
% test params
% animalName = 'EEG223';
% exptDate = '22d18';

% 1
fileMaint(animalName);
% promts user for drug information "audit experiment parameters"
% promts user for HTR information
% automtically copies files, imports and saves a matlab readable array, and
% a few other lab specific tasks (see comments inside program)

% 2
cleanDataByThresholdAnimalDateEEG(animalName,exptDate);
% This checks for outlier (imported) data points and offers a chance to
% remove them

% 3 
patientAnalysis.runAnalysis(@specAnalysis, 'Subjects',{animalName},'Blocks',{exptDate},'isMouse',true,'OptionSet','SegLength4');
% this is the "ecog" pipeline that creates the spectra data.  Be warned it
% takes a while - maybe 15-20 mins per animal 

% 4
chansToExclude = nan;
setName = 'combined';
sendToSlack = false;
plotSpectraEEG(animalName,exptDate,chansToExclude,setName,sendToSlack);
% This takes the output from #3, and produces three different ways to
% visualize these data: average spectra by hour, bandpower, and spectrogram

% 5
PSMTableForR2(animalName,exptDate);
% creates a table for R to read in, to then run the PSM

% 6 
reportPlot = true;
textNotes = 'Seeking evaluation';
qualityAssuranceEEG(animalName,exptDate,reportPlot,textNotes);
% sends a report to the Slack channel


% Next steps:
% 7. update table here: M:\PassiveEphys\mouseEEG\_______groupInfo.xlsx
% 8. run some R code: C:\Users\Matt Banks\Documents\Code\TDTUtilities\PSMRunList.R (or ZZ version)
% 9. run this collectSpectraDataFromExptList(setName)
% 10. run this plotBandPowerSummaries(setName)


