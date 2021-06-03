
%Ephys analysis script


%% ==== file management =============================
% % % % !!!!! IMPORTANT NOTE: DO NOT run fileMaint on an animal while data
% are being collected for it.  This might more INCOMPLETE files with unexpected results,
% including data corruption!!!

% READ THE WARNING!
fileMaint('ZZ06'); 
% READ THE WARNING!

%% ==== Stim / response specific plots ==============

% exptDate = '21517';
% exptIndex = '002';
% evokedStimResp_userInput(exptDate,exptIndex);

exptDate = '21520';
exptIndex = '005';
evokedStimResp_userInput(exptDate,exptIndex);



%% ==== whole day plasticity plots ==================

%Session 2 day of injection
exptDate = '21512';
exptIndices = {'004','008','010'}; %wrong stim file used on 008???
plotPlasticityAmplitudePeaks(exptDate,exptIndices)

%Session 3 day 2
exptDate = '21513';
exptIndices = {'003','005'};%,'007'}; 007 not working
plotPlasticityAmplitudePeaks(exptDate,exptIndices)

%Session 4 day 3
exptDate = '21515';
exptIndices = {'003','009','012'};
plotPlasticityAmplitudePeaks(exptDate,exptIndices)

%Session 5 day7
exptDate = '21519';
exptIndices = {'002','004','006'};
plotPlasticityAmplitudePeaks(exptDate,exptIndices)

