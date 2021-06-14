
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

% exptDate = '21609';
% exptIndex = '004';
% evokedStimResp_userInput(exptDate,exptIndex);

% exptDate = '21610';
% exptIndex = '001';
% evokedStimResp_userInput(exptDate,exptIndex);

% exptDate = '21611';
% exptIndex = '003';
% evokedStimResp_userInput(exptDate,exptIndex);

exptDate = '21611';
exptIndex = '003';
evokedStimResp_userInput(exptDate,exptIndex);

%% ==== whole day plasticity plots ==================

% %Session 2 day of injection
% exptDate = '21530';
% exptIndices = {'004','008','010'}; %wrong stim file used on 008???
% plotPlasticityAmplitudePeaks(exptDate,exptIndices)
% 
% %Session 3 day 2
% exptDate = '21513';
% exptIndices = {'003','005'};%,'007'}; 007 not working
% plotPlasticityAmplitudePeaks(exptDate,exptIndices)
% 
% %Session 4 day 3
% exptDate = '21515';
% exptIndices = {'003','009','012'};
% plotPlasticityAmplitudePeaks(exptDate,exptIndices)

%Session 5 day7
%exptDate = '21530';
%exptIndices = {'002','004','006'};
% plotPlasticityAmplitudePeaks(exptDate,exptIndices)

%LTD Protocol Test
%exptDate = '21607';
%exptIndices = {'002','004'};
%plotPlasticityAmplitudePeaks(exptDate,exptIndices)

%LTD Protocol Test 2
% exptDate = '21610';
% exptIndices = {'002','004','006'};
% plotPlasticityAmplitudePeaks(exptDate,exptIndices)

%LTD Protocol Test 3
exptDate = '21611';
exptIndices = {'004','006','008'};
plotPlasticityAmplitudePeaks(exptDate,exptIndices)
