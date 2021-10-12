
%Ephys analysis script


%% ==== file management =============================
% % % % !!!!! IMPORTANT NOTE: DO NOT run fileMaint on an animal while data
% are being collected for it.  This might move INCOMPLETE files with unexpected results,
% including data corruption!!!

% READ THE WARNING!
fileMaint('ZZ10'); 
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

%exptDate = '21611';
%exptIndex = '003';
%evokedStimResp_userInput(exptDate,exptIndex);
% 
% exptDate = '21616';
% exptIndex = '024';
% noTank = false;
% evokedStimResp_userInput(exptDate,exptIndex,noTank);

exptDate = '21621';
exptIndex = '004';
evokedStimResp_userInput(exptDate,exptIndex);

exptDate = '21727';
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
%exptDate = '21611';
%exptIndices = {'004','006','008'};
%plotPlasticityAmplitudePeaks(exptDate,exptIndices)



exptDate = '21617';
exptIndices = {'004','008','012'};
plotPlasticityAmplitudePeaks(exptDate,exptIndices)
exptDate = '21617';
exptIndices = {'005','009','013'}; 
plotPlasticityAmplitudePeaks(exptDate,exptIndices)


exptDate = '21621';
exptIndices = {'006','010','014'}; 
plotPlasticityAmplitudePeaks(exptDate,exptIndices)
exptDate = '21621';
exptIndices = {'007','011','015'};
plotPlasticityAmplitudePeaks(exptDate,exptIndices)





% consider automating this by looking for the following key phrases in the
% description: 'pre LTP/LTD' 'Post LTP / stim' 'Post LTD / stim'
% 1. be sure these keywords are consistant
% 2. load in a day using getExperimentsByAnimalAndDate()
% 3. generate the three exptIndices = {,,,} above
% 4. feed them to plotPlasticityAmplitudePeaks

exptDate = '21623';
exptIndices = {'014','018','022'};
plotPlasticityAmplitudePeaks(exptDate,exptIndices)
exptDate = '21623';
exptIndices = {'015','019','023'};
plotPlasticityAmplitudePeaks(exptDate,exptIndices)
%Pre-inj DOI 
exptDate = '21615';
exptIndices = {'004','006','008'};
plotPlasticityAmplitudePeaks(exptDate,exptIndices)







