
%Ephys analysis script


%% ==== file management =============================
% % % % !!!!! IMPORTANT NOTE: DO NOT run fileMaint on an animal while data
% are being collected for it.  This might move INCOMPLETE files with unexpected results,
% including data corruption!!!

% READ THE WARNING!
fileMaint('ZZ06'); 
% READ THE WARNING!

%% ==== Stim / response specific plots ==============

% exptDate = '21517';
% exptIndex = '002';
% evokedStimResp_userInput(exptDate,exptIndex);

% exptDate = '21520';
% exptIndex = '005';
% evokedStimResp_userInput(exptDate,exptIndex);

% exptDate = '21521';
% exptIndex = '009';
% evokedStimResp_userInput(exptDate,exptIndex);

% exptDate = '21415';
% exptIndex = '007';
% evokedStimResp_userInput(exptDate,exptIndex);

% exptDate = '21524';
% exptIndex = '009';
% evokedStimResp_userInput(exptDate,exptIndex);

% exptDate = '21525';
% exptIndex = '003';
% evokedStimResp_userInput(exptDate,exptIndex); % test no magnet

% exptDate = '21525';
% exptIndex = '004';
% evokedStimResp_userInput(exptDate,exptIndex); % test with magnet
% exptDate = '21603';
% exptIndex = '002';
% evokedStimResp_userInput(exptDate,exptIndex,false); % test with magnet




%% ==== whole day plasticity plots ==================

% %Session 2 day of injection
% exptDate = '21512';
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


% % ======== ZZ06 4-AcO-DMT ==============
% % pre injection (day7 of post saline) 400uA
% exptDate = '21519';
% exptIndices = {'002','004','006'};
% plotPlasticityAmplitudePeaks(exptDate,exptIndices)
% % 4 hours post injection 4 AcO DMT 400uA
% exptDate = '21520';
% exptIndices = {'010','012','015'}; 
% plotPlasticityAmplitudePeaks(exptDate,exptIndices)
% % 1 day post 4 AcO DMT 200uA
% exptDate = '21521';
% exptIndices = {'010','014','018'}; 
% plotPlasticityAmplitudePeaks(exptDate,exptIndices)
% % 5 days post injection 4 AcO DMT 300uA
% exptDate = '21525';
% exptIndices = {'005','007','009'}; 
% plotPlasticityAmplitudePeaks(exptDate,exptIndices)
% % 7 days post injection 4 AcO DMT 400uA
% exptDate = '21527';
% exptIndices = {'001','003','005'}; 
% plotPlasticityAmplitudePeaks(exptDate,exptIndices)


% % ======== ZZ06 DOI ==============
% % Pre injection DOI 400uA
% exptDate = '21527';
% exptIndices = {'001','003','005'}; 
% plotPlasticityAmplitudePeaks(exptDate,exptIndices)
% % 24 hours post injection DOI 400uA
% exptDate = '21528';
% exptIndices = {'002','004','006'}; 
% plotPlasticityAmplitudePeaks(exptDate,exptIndices)
% % 24 hours post injection DOI 400uA
% exptDate = '21530';
% exptIndices = {'002','004','006'}; 
% plotPlasticityAmplitudePeaks(exptDate,exptIndices)

% exptDate = '21607';
% exptIndices = {'002','004','006','009'}; 
% plotPlasticityAmplitudePeaks(exptDate,exptIndices)
% exptDate = '21609';
% exptIndices = {'005','007'}; 
% plotPlasticityAmplitudePeaks(exptDate,exptIndices)
exptDate = '21611';
exptIndices = {'004','006','008'}; 
plotPlasticityAmplitudePeaks(exptDate,exptIndices)



