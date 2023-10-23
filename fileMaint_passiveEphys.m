function fileMaint_passiveEphys(animalName,exptDate)
% test params
% animalName = 'EEG223';
% exptDate = '22d18';
% animalName = 'ZZ29';
% exptDate = '23427';
% animalName = 'EEG336';
% exptDate = '23725';
% animalName = 'EEG338';
% animalName = 'EEG339';
% exptDate = '23802';
% animalName = 'EEG347';
% exptDate = '23814';





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

% add 60Hz filter here?
% 1. pick 3 bad days: 
% animalName = 'EEG308'; exptDate = '23612'    
% animalName = 'EEG309'; exptDate = '23619'   
% animalName = 'EEG323'; exptDate = '23706'
% 2. run a simple notch filter
% 3. compare





% 3 
patientAnalysis.runAnalysis(@specAnalysis, 'Subjects',{animalName},'Blocks',{exptDate},'isMouse',true,'OptionSet','SegLength4');
% this is the "ecog" pipeline that creates the spectra data.  Be warned it
% takes a while - maybe 15-20 mins per animal 

% 4
% This takes the output from #3, and produces three different ways to
% visualize these data: average spectra by hour, bandpower, and spectrogram
sendToSlack = false;
chansToExclude = nan;
if ~contains(animalName,'ZZ') 
    setName = 'DOIKetanserin';
    plotSpectraEEG(animalName,exptDate,chansToExclude,setName,sendToSlack);
else
    plotSpectraLFP(animalName,exptDate,chansToExclude,sendToSlack)
end

% 5
% WORK IN PROGRESS: saveWindowedArray(animalName,exptDate) will soon save
% the full windowed (4 sec typically) experiment for the day, and we'll
% want to rewrite step 5
PSMTableForR2(animalName,exptDate);
% remember to respect channels Sean
% creates a table for R to read in, to then run the PSM (fairly simple, just saves this table)

% 6 
sendToSlack = false;
textNotes = 'Seeking evaluation';
qualityAssuranceEEG(animalName,exptDate,sendToSlack,textNotes);
% sends a report to the Slack channel


% Next steps:

% 7. update table here: M:\PassiveEphys\mouseEEG\_______groupInfo.xlsx  %
% this is where we track all recordings related to a specific experimental
% set / group.  This table will be used to combine mouse data.

% 8. run some R code: C:\Users\Matt
% Banks\Documents\Code\TDTUtilities\PSMRunList.R (or ZZ version) this is
% the PSM (weighting) code that uses the data from step 5

% setName = 'DOIKetanserin';
% setName = 'combined';
% 9. run this collectSpectraDataFromExptList(setName) this pulls the data
% from the list of mice in 7 (according to specified setName) and combines
% listed PSM (step 8) and movement data into a matlab readable table. "why
% is this so complicated?" A: because I've been asked for these data 8
% different ways, 10 different times, and this covers them all.

% 10. run this plotBandPowerSummaries(setName) this plots the table from
% step 9 - right now it's the pre/post delta PSM(movement weighted) ratio
% of anterior and posterior for each drug condition.




% file location references:
% {repositoryLocation}\TDTUtilities\fileMaint_passiveEphys -these instructions
% M:\PassiveEphys\mouseEEG\  -xls data files here


% setName = 'DOIKetanserin'; plotBandPowerSummaries(setName); 
% setName = 'combined'; plotBandPowerSummaries(setName); 

