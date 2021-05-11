
function [batchParams] = mouseDelirium_getBatchParamsManual(outPath,defaultPath)
batchParams = struct;
if ~exist('outPath','var')
    outPath = '\\MEMORYBANKS\Data\mouseEEG\videoScoring\';
%     outPath = '/Users/bankslaptop/Box Sync/My documents/Data and analysis/mouseDeliriumEphys/Data/';
    % outPath = 'D:\Box Sync\My documents\Data and analysis\mouseDeliriumEphys\Data\';
end
% Ensure output directory exists
if ~exist(outPath, 'dir')
    mkdir(outPath);
end
disp(['Data will be saved to `' outPath '`']);

if ~exist('defaultPath','var')
    defaultPath = '\\144.92.218.131\Data\Data\PassiveEphys\EEG animal data\';
%     defaultPath = '/Users/bankslaptop/Box Sync/My documents/Data and analysis/mouseDeliriumEphys/Data/';
    % defaultPath = 'D:\Box Sync\My documents\Data and analysis\mouseDeliriumEphys\Data\';
end
pars.windowLength = 4; %sec
pars.windowOverlap = 0.25; %fractional overlap
electrodeFile = 'mouse delirium - electrodes for analysis';

%% %% mice for EEG analysis
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % % %EEG4 %1 is front right; 2 is rear right; 3 is rear left; 4 is front left
pars.windowLength =4; %sec
pars.windowOverlap = 0.25; %fractional overlap
electrodeSheet = 'EEG4';
animalName = 'EEG4';
ephysInfo.chanNums = 1:4; %brain ephys channels
ephysInfo.recMode = 'EEG';
ephysInfo.EMGchan = 5;
ephysInfo.chanLabels = {'AR','PR','PL','AL'}; %Labels for EEG channels

salineDate = '15826';
pars.expt(1).dataPath = [defaultPath animalName filesep salineDate filesep];
pars.expt(1).exptDate = ['date' salineDate];
pars.expt(1).exptIndex = {'000','001','002','003','004'};
pars.expt(1).timeReInj = [-1:3];
pars.expt(1).treatment = 'saline';
pars.expt(1).dose = 0;

LPSDate = '15828';
pars.expt(2).dataPath = [defaultPath animalName filesep LPSDate filesep];
pars.expt(2).exptDate = ['date' LPSDate];
% pars.expt(2).exptIndex = {'000','001','002','003','004','005'};
% pars.expt(2).timeReInj = [-1:4]; %hours re injection
pars.expt(2).exptIndex = {'000','001','002','003','004'};
pars.expt(2).timeReInj = [-1:3]; %hours re injection
pars.expt(2).treatment = 'LPS';
pars.expt(2).dose = 125;
batchParams.(animalName) = fillBatchParams(pars,ephysInfo);
clear pars ephysInfo

% %%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % % %EEG6 %1 is front right; 2 is rear right; 3 is rear left; 4 is front left
pars.windowLength = 4; %sec
pars.windowOverlap = 0.25; %fractional overlap
electrodeSheet = 'EEG6';
animalName = 'EEG6';
ephysInfo.chanNums = 1:4; %brain ephys channels
ephysInfo.recMode = 'EEG';
ephysInfo.EMGchan = 5;
ephysInfo.chanLabels = {'AR','PR','PL','AL'}; %Labels for EEG channels

salineDate = '15922';
pars.expt(1).dataPath = [defaultPath animalName filesep salineDate filesep];
pars.expt(1).exptDate = ['date' salineDate];
pars.expt(1).exptIndex = {'000','001','002','003','004'};
pars.expt(1).timeReInj = [-1:3];
pars.expt(1).treatment = 'saline';
pars.expt(1).dose = 0;

LPSDate = '15923';
pars.expt(2).dataPath = [defaultPath animalName filesep LPSDate filesep];
pars.expt(2).exptDate = ['date' LPSDate];
pars.expt(2).exptIndex = {'000','002','003','004','005'};
pars.expt(2).timeReInj = [-1:3]; %hours re injection
pars.expt(2).treatment = 'LPS';
pars.expt(2).dose = 125;
batchParams.(animalName) = fillBatchParams(pars,ephysInfo);
clear pars ephysInfo

% %%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % %EEG10 %1 is front right; 2 is rear right; 3 is rear left; 4 is front
% left %

%UPDATE 11/27/18 CHANNEL MAP WAS PREVIOUSLY LISTED AS 5:8. INSTEAD IT
%SHOULD HAVE BEEN 1:4
pars.windowLength = 4; %sec
pars.windowOverlap = 0.25; %fractional overlap
electrodeSheet = 'EEG10';
animalName = 'EEG10';
ephysInfo.chanNums = 1:4; %brain ephys channels
ephysInfo.recMode = 'EEG';
ephysInfo.EMGchan = 5:8;
ephysInfo.chanLabels = {'AR','PR','PL','AL'}; %Labels for EEG channels

salineDate = '16506';
pars.expt(1).dataPath = [defaultPath animalName filesep salineDate filesep];
pars.expt(1).exptDate = ['date' salineDate];
pars.expt(1).exptIndex = {'001','002','003','004','005'};
pars.expt(1).timeReInj = [-1:3];
pars.expt(1).treatment = 'saline';
pars.expt(1).dose = 0;

LPSDate = '16509';
pars.expt(2).dataPath = [defaultPath animalName filesep LPSDate filesep];
pars.expt(2).exptDate = ['date' LPSDate];
pars.expt(2).exptIndex = {'000','001','002','003','004'};
pars.expt(2).timeReInj = [-1:3]; %hours re injection
pars.expt(2).treatment = 'LPS';
pars.expt(2).dose = 125;
batchParams.(animalName) = fillBatchParams(pars,ephysInfo);
clear pars ephysInfo

% %%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % %EEG11 %3 is front right; 4 is rear right; 5 is rear left; 6 is front left
pars.windowLength = 4; %sec
pars.windowOverlap = 0.25; %fractional overlap
electrodeSheet = 'EEG11';
animalName = 'EEG11';
ephysInfo.chanNums = 3:6; %brain ephys channels
ephysInfo.recMode = 'EEG';
ephysInfo.EMGchan = 8;
ephysInfo.chanLabels = {'AR','PR','PL','AL'}; %Labels for EEG channels

salineDate = '16515';
pars.expt(1).dataPath = [defaultPath animalName filesep salineDate filesep];
pars.expt(1).exptDate = ['date' salineDate];
pars.expt(1).exptIndex = {'000','001','002','003','004'};
pars.expt(1).timeReInj = [-1:3];
pars.expt(1).treatment = 'saline';
pars.expt(1).dose = 0;

LPSDate = '16517';
pars.expt(2).dataPath = [defaultPath animalName filesep LPSDate filesep];
pars.expt(2).exptDate = ['date' LPSDate];
pars.expt(2).exptIndex = {'000','001','003','004'};
pars.expt(2).timeReInj = [-1,0,2,3]; %hours re injection
pars.expt(2).treatment = 'LPS';
pars.expt(2).dose = 125;
batchParams.(animalName) = fillBatchParams(pars,ephysInfo);
clear pars ephysInfo

% %%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % %EEG13 %3 is front right; 4 is rear right; 5 is rear left; 6 is front left
% pars.windowLength = 4; %sec
% pars.windowOverlap = 0.25; %fractional overlap
% electrodeSheet = 'EEG13';
% animalName = 'EEG13';
% ephysInfo.chanNums = 3:6; %brain ephys channels
% ephysInfo.recMode = 'EEG';
% ephysInfo.EMGchan = 7;
% ephysInfo.chanLabels = {'AR','PR','PL','AL'}; %Labels for EEG channels
% 
% salineDate = '16712';
% pars.expt(1).dataPath = [defaultPath animalName filesep salineDate filesep];
% pars.expt(1).exptDate = ['date' salineDate];
% pars.expt(1).exptIndex = {'000','001','002','003','004'};
% pars.expt(1).timeReInj = [-1:3];
% pars.expt(1).treatment = 'saline';
% pars.expt(1).dose = 0;
% 
% LPSDate = '16713';
% pars.expt(2).dataPath = [defaultPath animalName filesep LPSDate filesep];
% pars.expt(2).exptDate = ['date' LPSDate];
% pars.expt(2).exptIndex = {'000','001','002','003','004'};
% pars.expt(2).timeReInj = [-1:3]; %hours re injection
% pars.expt(2).treatment = 'LPS';
% pars.expt(2).dose = 500;
% batchParams.(animalName) = fillBatchParams(pars,ephysInfo);
% clear pars ephysInfo

% %%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % %EEG14 %1 is front right; 2 is rear right; 3 is rear left; 4 is front left
%NOTE: since the LPS day from this animal is not being used, the LPS day
%noted here is actually the second saline day and this is being included in
%the sham group. 
pars.windowLength = 4; %sec
pars.windowOverlap = 0.25; %fractional overlap
electrodeSheet = 'EEG14';
animalName = 'EEG14';
ephysInfo.chanNums = 1:4; %brain ephys channels
ephysInfo.recMode = 'EEG';
ephysInfo.EMGchan = 8;
ephysInfo.chanLabels = {'AR','PR','PL','AL'}; %Labels for EEG channels

salineDate = '16707';
pars.expt(1).dataPath = [defaultPath animalName filesep salineDate filesep];
pars.expt(1).exptDate = ['date' salineDate];
pars.expt(1).exptIndex = {'000','002','003','004'};
pars.expt(1).timeReInj = [-1,1:3];
pars.expt(1).treatment = 'saline';
pars.expt(1).dose = 0;

LPSDate = '16708';
pars.expt(2).dataPath = [defaultPath animalName filesep LPSDate filesep];
pars.expt(2).exptDate = ['date' LPSDate];
pars.expt(2).exptIndex = {'000','001','002','003','004'};
pars.expt(2).timeReInj = [-1:3]; %hours re injection
pars.expt(2).treatment = 'LPS';
pars.expt(2).dose = 0;
batchParams.(animalName) = fillBatchParams(pars,ephysInfo);
clear pars ephysInfo

% %%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % %EEG16 %1 is front right; 2 is rear right; 3 is rear left; 4 is front left
pars.windowLength = 4; %sec
pars.windowOverlap = 0.25; %fractional overlap
electrodeSheet = 'EEG16';
animalName = 'EEG16';
ephysInfo.chanNums = 1:4; %brain ephys channels
ephysInfo.recMode = 'EEG';
ephysInfo.EMGchan = 7;
ephysInfo.chanLabels = {'AR','PR','PL','AL'}; %Labels for EEG channels

salineDate = '16o13';
pars.expt(1).dataPath = [defaultPath animalName filesep salineDate filesep];
pars.expt(1).exptDate = ['date' salineDate];
pars.expt(1).exptIndex = {'000','001','002','003','004'};
pars.expt(1).timeReInj = [-1:3];
pars.expt(1).treatment = 'saline';
pars.expt(1).dose = 0;

LPSDate = '16o17';
pars.expt(2).dataPath = [defaultPath animalName filesep LPSDate filesep];
pars.expt(2).exptDate = ['date' LPSDate];
pars.expt(2).exptIndex = {'000','001','002','003','004'};
pars.expt(2).timeReInj = [-1:3]; %hours re injection
pars.expt(2).treatment = 'LPS';
pars.expt(2).dose = 125;
batchParams.(animalName) = fillBatchParams(pars,ephysInfo);
clear pars ephysInfo

% %%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % %EEG18 %1 is front right; 2 is rear right; 3 is rear left; 4 is front left
pars.windowLength = 4; %sec
pars.windowOverlap = 0.25; %fractional overlap
electrodeSheet = 'EEG18';
animalName = 'EEG18';
ephysInfo.chanNums = 1:4; %brain ephys channels
ephysInfo.recMode = 'EEG';
ephysInfo.EMGchan = 7;
ephysInfo.chanLabels = {'AR','PR','PL','AL'}; %Labels for EEG channels

salineDate = '16o25';
pars.expt(1).dataPath = [defaultPath animalName filesep salineDate filesep];
pars.expt(1).exptDate = ['date' salineDate];
pars.expt(1).exptIndex = {'000','001','002','003','004'};
pars.expt(1).timeReInj = [-1:3];
pars.expt(1).treatment = 'saline';
pars.expt(1).dose = 0;

LPSDate = '16o27';
pars.expt(2).dataPath = [defaultPath animalName filesep LPSDate filesep];
pars.expt(2).exptDate = ['date' LPSDate];
pars.expt(2).exptIndex = {'000','001','002','003','004'};
pars.expt(2).timeReInj = [-1:3]; %hours re injection
pars.expt(2).treatment = 'LPS';
pars.expt(2).dose = 125;
batchParams.(animalName) = fillBatchParams(pars,ephysInfo);
clear pars ephysInfo

% %%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % % %LFP1 %5 is front right; 6 is rear right; 7 is rear left; 8 is front left
% pars.windowLength = 4; %sec
% pars.windowOverlap = 0.25; %fractional overlap
% electrodeSheet = 'LFP1';
% animalName = 'LFP1';
% ephysInfo.chanNums = 5:8; %brain ephys channels
% ephysInfo.recMode = 'LFP';
% ephysInfo.EMGchan = 3;
% ephysInfo.chanLabels = {'AR','PR','PL','AL'}; %Labels for EEG channels
% 
% salineDate = '16n22';
% pars.expt(1).dataPath = [defaultPath animalName filesep salineDate filesep];
% pars.expt(1).exptDate = ['date' salineDate];
% pars.expt(1).exptIndex = {'000','001','002','003','004'};
% pars.expt(1).timeReInj = [-1:3];
% pars.expt(1).treatment = 'saline';
% pars.expt(1).dose = 0;
% 
% LPSDate = '16n28';
% pars.expt(2).dataPath = [defaultPath animalName filesep LPSDate filesep];
% pars.expt(2).exptDate = ['date' LPSDate];
% pars.expt(2).exptIndex = {'000','001','002','003','004'};
% pars.expt(2).timeReInj = [-1:3]; %hours re injection
% pars.expt(2).treatment = 'LPS';
% pars.expt(2).dose = 125;
% batchParams.(animalName) = fillBatchParams(pars,ephysInfo);
% clear pars ephysInfo

% %%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % %EEG19 %1 is front right; 2 is rear right; 3 is rear left; 4 is front left
pars.windowLength = 4; %sec
pars.windowOverlap = 0.25; %fractional overlap
electrodeSheet = 'EEG19';
animalName = 'EEG19';
ephysInfo.chanNums = 1:4; %brain ephys channels
ephysInfo.recMode = 'EEG';
ephysInfo.EMGchan = 7;
ephysInfo.chanLabels = {'AR','PR','PL','AL'}; %Labels for EEG channels

salineDate = '16d19';
pars.expt(1).dataPath = [defaultPath animalName filesep salineDate filesep];
pars.expt(1).exptDate = ['date' salineDate];
pars.expt(1).exptIndex = {'001','002','003','004','005'};%,'006','007','008'};
pars.expt(1).timeReInj = [-1:3];
pars.expt(1).treatment = 'saline';
pars.expt(1).dose = 0;

LPSDate = '16d20';
pars.expt(2).dataPath = [defaultPath animalName filesep LPSDate filesep];
pars.expt(2).exptDate = ['date' LPSDate];
pars.expt(2).exptIndex = {'000','001','002','003','004'};%,'005','006','007'};
pars.expt(2).timeReInj = [-1:3]; %hours re injection
pars.expt(2).treatment = 'LPS';
pars.expt(2).dose = 12.5;
batchParams.(animalName) = fillBatchParams(pars,ephysInfo);
clear pars ephysInfo

% %%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % %EEG20 %1 is front right; 2 is rear right; 3 is rear left; 4 is front left
pars.windowLength = 4; %sec
pars.windowOverlap = 0.25; %fractional overlap
electrodeSheet = 'EEG20';
animalName = 'EEG20';
ephysInfo.chanNums = 1:4; %brain ephys channels
ephysInfo.recMode = 'EEG';
ephysInfo.EMGchan = 7;
ephysInfo.chanLabels = {'AR','PR','PL','AL'}; %Labels for EEG channels

salineDate = '16d27';
pars.expt(1).dataPath = [defaultPath animalName filesep salineDate filesep];
pars.expt(1).exptDate = ['date' salineDate];
pars.expt(1).exptIndex = {'001','002','003','004','005'}; %,'006','007','008'};
pars.expt(1).timeReInj = [-1:3];
pars.expt(1).treatment = 'saline';
pars.expt(1).dose = 0;

LPSDate = '16d28';
pars.expt(2).dataPath = [defaultPath animalName filesep LPSDate filesep];
pars.expt(2).exptDate = ['date' LPSDate];
pars.expt(2).exptIndex = {'000','001','002','003','004'};%,'005','006','007'};
pars.expt(2).timeReInj = [-1:3]; %hours re injection
pars.expt(2).treatment = 'LPS';
pars.expt(2).dose = 12.5;
batchParams.(animalName) = fillBatchParams(pars,ephysInfo);
clear pars ephysInfo

% %%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % %EEG21 %1 is front right; 2 is rear right; 3 is rear left; 4 is front left
pars.windowLength = 4; %sec
pars.windowOverlap = 0.25; %fractional overlap
electrodeSheet = 'EEG21';
animalName = 'EEG21';
ephysInfo.chanNums = 1:4; %brain ephys channels
ephysInfo.recMode = 'EEG';
ephysInfo.EMGchan = 7;
ephysInfo.chanLabels = {'AR','PR','PL','AL'}; %Labels for EEG channels

salineDate = '17109';
pars.expt(1).dataPath = [defaultPath animalName filesep salineDate filesep];
pars.expt(1).exptDate = ['date' salineDate];
pars.expt(1).exptIndex = {'001','002','003','004','005'};%,'006','007','008'};
pars.expt(1).timeReInj = [-1:3];
pars.expt(1).treatment = 'saline';
pars.expt(1).dose = 0;

LPSDate = '17110';
pars.expt(2).dataPath = [defaultPath animalName filesep LPSDate filesep];
pars.expt(2).exptDate = ['date' LPSDate];
pars.expt(2).exptIndex = {'001','002','003','004','005'};%,'006','007','008'};
pars.expt(2).timeReInj = [-1:3]; %hours re injection
pars.expt(2).treatment = 'LPS';
pars.expt(2).dose = 12.5;
batchParams.(animalName) = fillBatchParams(pars,ephysInfo);
clear pars ephysInfo

% %%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % %EEG22 %1 is front right; 2 is rear right; 3 is rear left; 4 is front left
pars.windowLength = 4; %sec
pars.windowOverlap = 0.25; %fractional overlap
electrodeSheet = 'EEG22';
animalName = 'EEG22';
ephysInfo.chanNums = 1:4; %brain ephys channels
ephysInfo.recMode = 'EEG';
ephysInfo.EMGchan = 7;
ephysInfo.chanLabels = {'AR','PR','PL','AL'}; %Labels for EEG channels

salineDate = '17131';
pars.expt(1).dataPath = [defaultPath animalName filesep salineDate filesep];
pars.expt(1).exptDate = ['date' salineDate];
pars.expt(1).exptIndex = {'001','002','003','004','005'};%,'006','007','008'};
pars.expt(1).timeReInj = [-1:3];
pars.expt(1).treatment = 'saline';
pars.expt(1).dose = 0;

LPSDate = '17202';
pars.expt(2).dataPath = [defaultPath animalName filesep LPSDate filesep];
pars.expt(2).exptDate = ['date' LPSDate];
pars.expt(2).exptIndex = {'000','001','002','003','004'};%,'005','006}%,'007'};
pars.expt(2).timeReInj = [-1:3]; %hours re injection
pars.expt(2).treatment = 'LPS';
pars.expt(2).dose = 25;
batchParams.(animalName) = fillBatchParams(pars,ephysInfo);
clear pars ephysInfo

% % 
% % %%
% % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % % %EEG23 %1 is front right; 2 is rear right; 3 is rear left; 4 is front left
% pars.windowLength = 4; %sec
% pars.windowOverlap = 0.25; %fractional overlap
% electrodeSheet = 'EEG23';
% animalName = 'EEG23';
% ephysInfo.chanNums = 1:4; %brain ephys channels
% ephysInfo.recMode = 'EEG';
% ephysInfo.EMGchan = 7;
% ephysInfo.chanLabels = {'AR','PR','PL','AL'}; %Labels for EEG channels
% 
% salineDate = '17207';
% pars.expt(1).dataPath = [defaultPath animalName filesep salineDate filesep];
% pars.expt(1).exptDate = ['date' salineDate];
% pars.expt(1).exptIndex = {'001','002','003','004','005','006','007','008'};
% pars.expt(1).timeReInj = [-1:6];
% pars.expt(1).treatment = 'saline';
% pars.expt(1).dose = 0;
% 
% LPSDate = '17209';
% pars.expt(2).dataPath = [defaultPath animalName filesep LPSDate filesep];
% pars.expt(2).exptDate = ['date' LPSDate];
% pars.expt(2).exptIndex = {'000','001','002','003','004','005','006','007'};
% pars.expt(2).timeReInj = [-1:6]; %hours re injection
% pars.expt(2).treatment = 'LPS';
% pars.expt(2).dose = 25;
% batchParams.(animalName) = fillBatchParams(pars,ephysInfo);
% clear pars ephysInfo

% % 
% % %%
% % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % % %LFP2 %1 is front right; 2 is rear right; 3 is rear left; 4 is front left
pars.windowLength = 4; %sec
pars.windowOverlap = 0.25; %fractional overlap
electrodeSheet = 'LFP2';
animalName = 'LFP2';
ephysInfo.chanNums = 1:4; %brain ephys channels
ephysInfo.recMode = 'EEG';
ephysInfo.EMGchan = 7;
ephysInfo.chanLabels = {'AR','PR','PL','AL'}; %Labels for EEG channels

salineDate = '17214';
pars.expt(1).dataPath = [defaultPath animalName filesep salineDate filesep];
pars.expt(1).exptDate = ['date' salineDate];
pars.expt(1).exptIndex = {'001','002','003','004','005'};%,'006'};
pars.expt(1).timeReInj = [-1:3];
pars.expt(1).treatment = 'saline';
pars.expt(1).dose = 0;

LPSDate = '17215';
pars.expt(2).dataPath = [defaultPath animalName filesep LPSDate filesep];
pars.expt(2).exptDate = ['date' LPSDate];
pars.expt(2).exptIndex = {'000','001','002','003','004'};%,'005','006'};%,'007'};
pars.expt(2).timeReInj = [-1:3]; %hours re injection
pars.expt(2).treatment = 'LPS';
pars.expt(2).dose = 25;
batchParams.(animalName) = fillBatchParams(pars,ephysInfo);
clear pars ephysInfo

% % 
% %%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%EEG24 %1 is front right; 2 is rear right; 3 is rear left; 4 is front left
pars.windowLength = 4; %sec
pars.windowOverlap = 0.25; %fractional overlap
electrodeSheet = 'EEG24';
animalName = 'EEG24';
ephysInfo.chanNums = 1:4; %brain ephys channels
ephysInfo.recMode = 'EEG';
ephysInfo.EMGchan = 7;
ephysInfo.chanLabels = {'AR','PR','PL','AL'}; %Labels for EEG channels

salineDate = '17221';
pars.expt(1).dataPath = [defaultPath animalName filesep salineDate filesep];
pars.expt(1).exptDate = ['date' salineDate];
pars.expt(1).exptIndex = {'000','001','002','003','004'};%,'005'};
pars.expt(1).timeReInj = [-1:3];
pars.expt(1).treatment = 'saline';
pars.expt(1).dose = 0;

LPSDate = '17222';
pars.expt(2).dataPath = [defaultPath animalName filesep LPSDate filesep];
pars.expt(2).exptDate = ['date' LPSDate];
pars.expt(2).exptIndex = {'000','001','002','003','004'};%,'005','006'};
pars.expt(2).timeReInj = [-1:3]; %hours re injection
pars.expt(2).treatment = 'LPS';
pars.expt(2).dose = 25;
batchParams.(animalName) = fillBatchParams(pars,ephysInfo);
clear pars ephysInfo

% %%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %Opto-01 %1 is front right; 2 is rear right; 3 is rear left; 4 is front left
pars.windowLength = 4; %sec
pars.windowOverlap = 0.25; %fractional overlap
electrodeSheet = 'Opto01';
animalName = 'Opto01';
ephysInfo.chanNums = 1:4; %brain ephys channels
ephysInfo.recMode = 'EEG';
ephysInfo.EMGchan = 7;
ephysInfo.chanLabels = {'AR','PR','PL','AL'}; %Labels for EEG channels

salineDate = '17321';
pars.expt(1).dataPath = [defaultPath animalName filesep salineDate filesep];
pars.expt(1).exptDate = ['date' salineDate];
pars.expt(1).exptIndex = {'000','001','002','003','004'};%,'005','006','007'};
pars.expt(1).timeReInj = [-1:3];
pars.expt(1).treatment = 'saline';
pars.expt(1).dose = 0;

LPSDate = '17323';
pars.expt(2).dataPath = [defaultPath animalName filesep LPSDate filesep];
pars.expt(2).exptDate = ['date' LPSDate];
pars.expt(2).exptIndex = {'000','001','002','003','004'};
pars.expt(2).timeReInj = [-1:3]; %hours re injection
pars.expt(2).treatment = 'LPS';
pars.expt(2).dose = 25;
batchParams.(animalName) = fillBatchParams(pars,ephysInfo);
clear pars ephysInfo

% %%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % %EEG26 %1 is front right; 2 is rear right; 3 is rear left; 4 is front left
pars.windowLength = 4; %sec
pars.windowOverlap = 0.25; %fractional overlap
electrodeSheet = 'EEG26';
animalName = 'EEG26';
ephysInfo.chanNums = 1:4; %brain ephys channels
ephysInfo.recMode = 'EEG';
ephysInfo.EMGchan = [];
ephysInfo.chanLabels = {'AR','PR','PL','AL'}; %Labels for EEG channels

salineDate = '17412';
pars.expt(1).dataPath = [defaultPath animalName filesep salineDate filesep];
pars.expt(1).exptDate = ['date' salineDate];
pars.expt(1).exptIndex = {'001','002','004','005'};
pars.expt(1).timeReInj = [-1,0,2,3];
pars.expt(1).treatment = 'saline';
pars.expt(1).dose = 0;

LPSDate = '17413';
pars.expt(2).dataPath = [defaultPath animalName filesep LPSDate filesep];
pars.expt(2).exptDate = ['date' LPSDate];
pars.expt(2).exptIndex = {'000','001','002','003','004'};
pars.expt(2).timeReInj = [-1:3]; %hours re injection
pars.expt(2).treatment = 'LPS';
pars.expt(2).dose = 25;
batchParams.(animalName) = fillBatchParams(pars,ephysInfo);
clear pars ephysInfo

% %%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % %EEG27 %1 is front right; 2 is rear right; 3 is rear left; 4 is front left
pars.windowLength = 4; %sec
pars.windowOverlap = 0.25; %fractional overlap
electrodeSheet = 'EEG27';
animalName = 'EEG27';
ephysInfo.chanNums = 1:4; %brain ephys channels
ephysInfo.recMode = 'EEG';
ephysInfo.EMGchan = [];
ephysInfo.chanLabels = {'AR','PR','PL','AL'}; %Labels for EEG channels

salineDate = '17418';
pars.expt(1).dataPath = [defaultPath animalName filesep salineDate filesep];
pars.expt(1).exptDate = ['date' salineDate];
pars.expt(1).exptIndex = {'000','001','002','003','004'};
pars.expt(1).timeReInj = [-1:3];
pars.expt(1).treatment = 'saline';
pars.expt(1).dose = 0;

LPSDate = '17419';
pars.expt(2).dataPath = [defaultPath animalName filesep LPSDate filesep];
pars.expt(2).exptDate = ['date' LPSDate];
pars.expt(2).exptIndex = {'000','001','002','003','004'};
pars.expt(2).timeReInj = [-1:3]; %hours re injection
pars.expt(2).treatment = 'LPS';
pars.expt(2).dose = 12.5;
batchParams.(animalName) = fillBatchParams(pars,ephysInfo);
clear pars ephysInfo

% %%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % %EEG28 %1 is front right; 2 is rear right; 3 is rear left; 4 is front left
pars.windowLength = 4; %sec
pars.windowOverlap = 0.25; %fractional overlap
electrodeSheet = 'EEG28';
animalName = 'EEG28';
ephysInfo.chanNums = 1:4; %brain ephys channels
ephysInfo.recMode = 'EEG';
ephysInfo.EMGchan = [];
ephysInfo.chanLabels = {'AR','PR','PL','AL'}; %Labels for EEG channels

salineDate = '17508';
pars.expt(1).dataPath = [defaultPath animalName filesep salineDate filesep];
pars.expt(1).exptDate = ['date' salineDate];
pars.expt(1).exptIndex = {'001','002','003','004','005'};
pars.expt(1).timeReInj = [-1:3];
pars.expt(1).treatment = 'saline';
pars.expt(1).dose = 0;

LPSDate = '17509';
pars.expt(2).dataPath = [defaultPath animalName filesep LPSDate filesep];
pars.expt(2).exptDate = ['date' LPSDate];
pars.expt(2).exptIndex = {'000','001','002','003','004'};
pars.expt(2).timeReInj = [-1:3]; %hours re injection
pars.expt(2).treatment = 'LPS';
pars.expt(2).dose = 12.5;
batchParams.(animalName) = fillBatchParams(pars,ephysInfo);
clear pars ephysInfo

% %%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %EEG29 %1 is front right; 2 is rear right; 3 is rear left; 4 is front left
pars.windowLength = 4; %sec
pars.windowOverlap = 0.25; %fractional overlap
electrodeSheet = 'EEG29';
animalName = 'EEG29';
ephysInfo.chanNums = 1:4; %brain ephys channels
ephysInfo.recMode = 'EEG';
ephysInfo.EMGchan = [];
ephysInfo.chanLabels = {'AR','PR','PL','AL'}; %Labels for EEG channels

salineDate = '17511';
pars.expt(1).dataPath = [defaultPath animalName filesep salineDate filesep];
pars.expt(1).exptDate = ['date' salineDate];
pars.expt(1).exptIndex = {'001','002','003','004','005'};
pars.expt(1).timeReInj = [-1:3];
pars.expt(1).treatment = 'saline';
pars.expt(1).dose = 0;

LPSDate = '17512';
pars.expt(2).dataPath = [defaultPath animalName filesep LPSDate filesep];
pars.expt(2).exptDate = ['date' LPSDate];
pars.expt(2).exptIndex = {'000','001','002','003','004'};
pars.expt(2).timeReInj = [-1:3]; %hours re injection
pars.expt(2).treatment = 'LPS';
pars.expt(2).dose = 25;
batchParams.(animalName) = fillBatchParams(pars,ephysInfo);
clear pars ephysInfo

% %%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %EEG30 %1 is front right; 2 is rear right; 3 is rear left; 4 is front left
pars.windowLength = 4; %sec
pars.windowOverlap = 0.25; %fractional overlap
electrodeSheet = 'EEG30';
animalName = 'EEG30';
ephysInfo.chanNums = 1:4; %brain ephys channels
ephysInfo.recMode = 'EEG';
ephysInfo.EMGchan = [];
ephysInfo.chanLabels = {'AR','PR','PL','AL'}; %Labels for EEG channels
% 
salineDate = '17517';
pars.expt(1).dataPath = [defaultPath animalName filesep salineDate filesep];
pars.expt(1).exptDate = ['date' salineDate];
pars.expt(1).exptIndex = {'001','002','003','004','005'};
pars.expt(1).timeReInj = [-1:3];
pars.expt(1).treatment = 'saline';
pars.expt(1).dose = 0;

LPSDate = '17518';
pars.expt(2).dataPath = [defaultPath animalName filesep LPSDate filesep];
pars.expt(2).exptDate = ['date' LPSDate];
pars.expt(2).exptIndex = {'000','001','002','003','004'};
pars.expt(2).timeReInj = [-1:3]; %hours re injection
pars.expt(2).treatment = 'LPS';
pars.expt(2).dose = 12.5;
batchParams.(animalName) = fillBatchParams(pars,ephysInfo);
clear pars ephysInfo

% %%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % %EEG31 %1 is front right; 2 is rear right; 3 is rear left; 4 is front left
pars.windowLength = 4; %sec
pars.windowOverlap = 0.25; %fractional overlap
electrodeSheet = 'EEG31';
animalName = 'EEG31';
ephysInfo.chanNums = 1:4; %brain ephys channels
ephysInfo.recMode = 'EEG';
ephysInfo.EMGchan = [];
ephysInfo.chanLabels = {'AR','PR','PL','AL'}; %Labels for EEG channels

salineFosDate = '17523';
pars.expt(1).dataPath = [defaultPath animalName filesep salineFosDate filesep];
pars.expt(1).exptDate = ['date' salineFosDate];
pars.expt(1).exptIndex = {'001','002','003','004','005','006'};
pars.expt(1).timeReInj = -2:3; %19205 ZS changed from [-1.5,-0.5,0:3]
pars.expt(1).treatment = 'saline_fos';
pars.expt(1).dose = 0;
pars.expt(1).other.drug = 'fosA';
pars.expt(1).other.dose = 10;
pars.expt(1).other.time = -1; %19205 ZS changed from -0.5

LPSFosDate = '17524';
pars.expt(2).dataPath = [defaultPath animalName filesep LPSFosDate filesep];
pars.expt(2).exptDate = ['date' LPSFosDate];
pars.expt(2).exptIndex = {'000','001','002','003','004','005'};
pars.expt(2).timeReInj = -2:3; %19205 ZS changed from [-1.5,-0.5,0:3]
pars.expt(2).treatment = 'LPS_fos';
pars.expt(2).dose = 25;
pars.expt(2).other.drug = 'fosA';
pars.expt(2).other.dose = 10;
pars.expt(2).other.time = -1; %19205 ZS changed from -0.5
batchParams.(animalName) = fillBatchParams(pars,ephysInfo);
clear pars ephysInfo

% %%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %EEG33 %1 is front right; 2 is rear right; 3 is rear left; 4 is front left
pars.windowLength = 4; %sec
pars.windowOverlap = 0.25; %fractional overlap
electrodeSheet = 'EEG33';
animalName = 'EEG33';
ephysInfo.chanNums = 1:4; %brain ephys channels
ephysInfo.recMode = 'EEG';
ephysInfo.EMGchan = [];
ephysInfo.chanLabels = {'AR','PR','PL','AL'}; %Labels for EEG channels
% 
salineDate = '17530';
pars.expt(1).dataPath = [defaultPath animalName filesep salineDate filesep];
pars.expt(1).exptDate = ['date' salineDate];
pars.expt(1).exptIndex = {'001','002','003','004','005'};
pars.expt(1).timeReInj = [-1:3];
pars.expt(1).treatment = 'saline';
pars.expt(1).dose = 0;

LPSDate = '17531';
pars.expt(2).dataPath = [defaultPath animalName filesep LPSDate filesep];
pars.expt(2).exptDate = ['date' LPSDate];
pars.expt(2).exptIndex = {'000','001','002','003','004'};
pars.expt(2).timeReInj = [-1:3]; %hours re injection
pars.expt(2).treatment = 'LPS';
pars.expt(2).dose = 25;
batchParams.(animalName) = fillBatchParams(pars,ephysInfo);
clear pars ephysInfo

% 
% % %%
% % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%EEG34 %1 is front right; 2 is rear right; 3 is rear left; 4 is front left
pars.windowLength = 4; %sec
pars.windowOverlap = 0.25; %fractional overlap
electrodeSheet = 'EEG34';
animalName = 'EEG34';
ephysInfo.chanNums = 1:4; %brain ephys channels
ephysInfo.recMode = 'EEG';
ephysInfo.EMGchan = [];
ephysInfo.chanLabels = {'AR','PR','PL','AL'}; %Labels for EEG channels

salineDate = '17601';
pars.expt(1).dataPath = [defaultPath animalName filesep salineDate filesep];
pars.expt(1).exptDate = ['date' salineDate];
pars.expt(1).exptIndex = {'001','002','003','004','005'};
pars.expt(1).timeReInj = [-1:3];
pars.expt(1).treatment = 'saline';
pars.expt(1).dose = 0;

LPSDate = '17602';
pars.expt(2).dataPath = [defaultPath animalName filesep LPSDate filesep];
pars.expt(2).exptDate = ['date' LPSDate];
pars.expt(2).exptIndex = {'000','001','002','003','004'};
pars.expt(2).timeReInj = [-1:3]; %hours re injection
pars.expt(2).treatment = 'LPS';
pars.expt(2).dose = 25;
batchParams.(animalName) = fillBatchParams(pars,ephysInfo);
clear pars ephysInfo

% %%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %EEG35 %1 is front right; 2 is rear right; 3 is rear left; 4 is front left
pars.windowLength = 4; %sec
pars.windowOverlap = 0.25; %fractional overlap
electrodeSheet = 'EEG35';
animalName = 'EEG35';
ephysInfo.chanNums = 1:4; %brain ephys channels
ephysInfo.recMode = 'EEG';
ephysInfo.EMGchan = [];
ephysInfo.chanLabels = {'AR','PR','PL','AL'}; %Labels for EEG channels
% 
salineDate = '17606';
pars.expt(1).dataPath = [defaultPath animalName filesep salineDate filesep];
pars.expt(1).exptDate = ['date' salineDate];
pars.expt(1).exptIndex = {'001','002','003','004','005'};
pars.expt(1).timeReInj = [-1:3];
pars.expt(1).treatment = 'saline';
pars.expt(1).dose = 0;

LPSDate = '17607';
pars.expt(2).dataPath = [defaultPath animalName filesep LPSDate filesep];
pars.expt(2).exptDate = ['date' LPSDate];
pars.expt(2).exptIndex = {'000','001','002','003','004'};
pars.expt(2).timeReInj = [-1:3]; %hours re injection
pars.expt(2).treatment = 'LPS';
pars.expt(2).dose = 25;
batchParams.(animalName) = fillBatchParams(pars,ephysInfo);
clear pars ephysInfo

% %%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %EEG36 %1 is front right; 2 is rear right; 3 is rear left; 4 is front left
pars.windowLength = 4; %sec
pars.windowOverlap = 0.25; %fractional overlap
electrodeSheet = 'EEG36';
animalName = 'EEG36';
ephysInfo.chanNums = 1:4; %brain ephys channels
ephysInfo.recMode = 'EEG';
ephysInfo.EMGchan = [];
ephysInfo.chanLabels = {'AR','PR','PL','AL'}; %Labels for EEG channels
% 
salineDate = '17608';
pars.expt(1).dataPath = [defaultPath animalName filesep salineDate filesep];
pars.expt(1).exptDate = ['date' salineDate];
pars.expt(1).exptIndex = {'001','002','003','004','005'};
pars.expt(1).timeReInj = [-1:3];
pars.expt(1).treatment = 'saline';
pars.expt(1).dose = 0;

LPSDate = '17609';
pars.expt(2).dataPath = [defaultPath animalName filesep LPSDate filesep];
pars.expt(2).exptDate = ['date' LPSDate];
pars.expt(2).exptIndex = {'000','001','002','003','004'};
pars.expt(2).timeReInj = [-1:3]; %hours re injection
pars.expt(2).treatment = 'LPS';
pars.expt(2).dose = 25;
batchParams.(animalName) = fillBatchParams(pars,ephysInfo);
clear pars ephysInfo

% %%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %EEG37 %1 is front right; 2 is rear right; 3 is rear left; 4 is front left
pars.windowLength = 4; %sec
pars.windowOverlap = 0.25; %fractional overlap
electrodeSheet = 'EEG37';
animalName = 'EEG37';
ephysInfo.chanNums = 1:4; %brain ephys channels
ephysInfo.recMode = 'EEG';
ephysInfo.EMGchan = [];
ephysInfo.chanLabels = {'AR','PR','PL','AL'}; %Labels for EEG channels
% 
salineDate = '17615';
pars.expt(1).dataPath = [defaultPath animalName filesep salineDate filesep];
pars.expt(1).exptDate = ['date' salineDate];
pars.expt(1).exptIndex = {'000','001','002','003','004'};
pars.expt(1).timeReInj = [-1:3];
pars.expt(1).treatment = 'saline';
pars.expt(1).dose = 0;

LPSDate = '17616';
pars.expt(2).dataPath = [defaultPath animalName filesep LPSDate filesep];
pars.expt(2).exptDate = ['date' LPSDate];
pars.expt(2).exptIndex = {'000','001','002','003','004'};
pars.expt(2).timeReInj = [-1:3]; %hours re injection
pars.expt(2).treatment = 'LPS';
pars.expt(2).dose = 25;
batchParams.(animalName) = fillBatchParams(pars,ephysInfo);
clear pars ephysInfo

% % %%
% % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % % %EEG38 %1 is front right; 2 is rear right; 3 is rear left; 4 is front left
pars.windowLength = 4; %sec
pars.windowOverlap = 0.25; %fractional overlap
electrodeSheet = 'EEG38';
animalName = 'EEG38';
ephysInfo.chanNums = 1:4; %brain ephys channels
ephysInfo.recMode = 'EEG';
ephysInfo.EMGchan = [];
ephysInfo.chanLabels = {'AR','PR','PL','AL'}; %Labels for EEG channels

salineFosDate = '17620';
pars.expt(1).dataPath = [defaultPath animalName filesep salineFosDate filesep];
pars.expt(1).exptDate = ['date' salineFosDate];
pars.expt(1).exptIndex = {'001','002','003','004','005','006'};
pars.expt(1).timeReInj =  -2:3; %19205 ZS changed from [-1.5,-0.5,0:3]
pars.expt(1).treatment = 'saline_fos';
pars.expt(1).dose = 0;
pars.expt(1).other.drug = 'fosA';
pars.expt(1).other.dose = 10;
pars.expt(1).other.time = -1; %19205 ZS changed from -0.5

LPSFosDate = '17621';
pars.expt(2).dataPath = [defaultPath animalName filesep LPSFosDate filesep];
pars.expt(2).exptDate = ['date' LPSFosDate];
pars.expt(2).exptIndex = {'000','001','002','003','004','005'};
pars.expt(2).timeReInj = -2:3; %19205 ZS changed from [-1.5,-0.5,0:3]
pars.expt(2).treatment = 'LPS_fos';
pars.expt(2).dose = 25;
pars.expt(2).other.drug = 'fosA';
pars.expt(2).other.dose = 10;
pars.expt(2).other.time = -1; %19205 ZS changed from -0.5
batchParams.(animalName) = fillBatchParams(pars,ephysInfo);
clear pars ephysInfo

% %%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %EEG39 %1 is front right; 2 is rear right; 3 is rear left; 4 is front left
pars.windowLength = 4; %sec
pars.windowOverlap = 0.25; %fractional overlap
electrodeSheet = 'EEG39';
animalName = 'EEG39';
ephysInfo.chanNums = 1:4; %brain ephys channels
ephysInfo.recMode = 'EEG';
ephysInfo.EMGchan = [];
ephysInfo.chanLabels = {'AR','PR','PL','AL'}; %Labels for EEG channels

salineDate = '17622';
pars.expt(1).dataPath = [defaultPath animalName filesep salineDate filesep];
pars.expt(1).exptDate = ['date' salineDate];
pars.expt(1).exptIndex = {'001','002','003','004','005'};
pars.expt(1).timeReInj = [-1:3];
pars.expt(1).treatment = 'saline';
pars.expt(1).dose = 0;

LPSDate = '17623';
pars.expt(2).dataPath = [defaultPath animalName filesep LPSDate filesep];
pars.expt(2).exptDate = ['date' LPSDate];
pars.expt(2).exptIndex = {'000','001','002','003','004'};
pars.expt(2).timeReInj = [-1:3]; %hours re injection
pars.expt(2).treatment = 'LPS';
pars.expt(2).dose = 0;

salineFosDate = '17626';
pars.expt(3).dataPath = [defaultPath animalName filesep salineFosDate filesep];
pars.expt(3).exptDate = ['date' salineFosDate];
pars.expt(3).exptIndex = {'000','001','002','003','004','005'};
pars.expt(3).timeReInj = -2:3; %19205 ZS changed from [-1.5,-0.5,0:3]
pars.expt(3).treatment = 'saline_fos';
pars.expt(3).dose = 0;
pars.expt(3).other.drug = 'fosA';
pars.expt(3).other.dose = 10;
pars.expt(3).other.time = -1; %19205 ZS changed from -0.5

LPSFosDate = '17627';
pars.expt(4).dataPath = [defaultPath animalName filesep LPSFosDate filesep];
pars.expt(4).exptDate = ['date' LPSFosDate];
pars.expt(4).exptIndex = {'000','001','002','003','004','005'};
pars.expt(4).timeReInj = -2:3; %19205 ZS changed from [-1.5,-0.5,0:3]
pars.expt(4).treatment = 'LPS_fos';
pars.expt(4).dose = 25;
pars.expt(4).other.drug = 'fosA';
pars.expt(4).other.dose = 10;
pars.expt(4).other.time = -1; %19205 ZS changed from -0.5
batchParams.(animalName) = fillBatchParams(pars,ephysInfo);
clear pars ephysInfo

% 
% %%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % %EEG40 %1 is front right; 2 is rear right; 3 is rear left; 4 is front left
pars.windowLength = 4; %sec
pars.windowOverlap = 0.25; %fractional overlap
electrodeSheet = 'EEG40';
animalName = 'EEG40';
ephysInfo.chanNums = 1:4; %brain ephys channels
ephysInfo.recMode = 'EEG';
ephysInfo.EMGchan = [];
ephysInfo.chanLabels = {'AR','PR','PL','AL'}; %Labels for EEG channels

salineDate = '17630';
pars.expt(1).dataPath = [defaultPath animalName filesep salineDate filesep];
pars.expt(1).exptDate = ['date' salineDate];
pars.expt(1).exptIndex = {'000','002','004','006','008'};
pars.expt(1).timeReInj = [-1:3];
pars.expt(1).treatment = 'saline';
pars.expt(1).dose = 0;

LPSDate = '17703';
pars.expt(2).dataPath = [defaultPath animalName filesep LPSDate filesep];
pars.expt(2).exptDate = ['date' LPSDate];
pars.expt(2).exptIndex = {'001','003','005','007','009'};
pars.expt(2).timeReInj = [-1:3]; %hours re injection
pars.expt(2).treatment = 'LPS';
pars.expt(2).dose = 0;
batchParams.(animalName) = fillBatchParams(pars,ephysInfo);
clear pars ephysInfo

% %%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % %EEG41 %1 is front right; 2 is rear right; 3 is rear left; 4 is front left
pars.windowLength = 4; %sec
pars.windowOverlap = 0.25; %fractional overlap
electrodeSheet = 'EEG41';
animalName = 'EEG41';
ephysInfo.chanNums = 1:4; %brain ephys channels
ephysInfo.recMode = 'EEG';
ephysInfo.EMGchan = [];
ephysInfo.chanLabels = {'AR','PR','PL','AL'}; %Labels for EEG channels

% salineDate = '17630';
% pars.expt(1).dataPath = [defaultPath animalName filesep salineDate filesep];
% pars.expt(1).exptDate = ['date' salineDate];
% pars.expt(1).exptIndex = {'001','003','005','007','009'};
% pars.expt(1).timeReInj = [-1:3];
% pars.expt(1).treatment = 'saline';
% pars.expt(1).dose = 0;

LPSDate = '17703';
pars.expt(1).dataPath = [defaultPath animalName filesep LPSDate filesep];
pars.expt(1).exptDate = ['date' LPSDate];
pars.expt(1).exptIndex = {'000','002','004','006'};
pars.expt(1).timeReInj = [-1:2]; %hours re injection
pars.expt(1).treatment = 'LPS';
pars.expt(1).dose = 0;
batchParams.(animalName) = fillBatchParams(pars,ephysInfo);
clear pars ephysInfo

% %%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % %EEG43 %1 is front right; 2 is rear right; 3 is rear left; 4 is front left
pars.windowLength = 4; %sec
pars.windowOverlap = 0.25; %fractional overlap
electrodeSheet = 'EEG43';
animalName = 'EEG43';
ephysInfo.chanNums = 1:4; %brain ephys channels
ephysInfo.recMode = 'EEG';
ephysInfo.EMGchan = [];
ephysInfo.chanLabels = {'AR','PR','PL','AL'}; %Labels for EEG channels

% salineDate = '17706';
% pars.expt(1).dataPath = [defaultPath animalName filesep salineDate filesep];
% pars.expt(1).exptDate = ['date' salineDate];
% pars.expt(1).exptIndex = {'001','003','004','005','006'};
% pars.expt(1).timeReInj = [-1:3];
% pars.expt(1).treatment = 'saline';
% pars.expt(1).dose = 0;

LPSDate = '17707';
pars.expt(1).dataPath = [defaultPath animalName filesep LPSDate filesep];
pars.expt(1).exptDate = ['date' LPSDate];
pars.expt(1).exptIndex = {'000','001','002','003','004'};
pars.expt(1).timeReInj = [-1:3]; %hours re injection
pars.expt(1).treatment = 'LPS';
pars.expt(1).dose = 0;
batchParams.(animalName) = fillBatchParams(pars,ephysInfo);
clear pars ephysInfo

% %%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % %EEG44 %1 is front right; 2 is rear right; 3 is rear left; 4 is front left
pars.windowLength = 4; %sec
pars.windowOverlap = 0.25; %fractional overlap
electrodeSheet = 'EEG44';
animalName = 'EEG44';
ephysInfo.chanNums = 1:4; %brain ephys channels
ephysInfo.recMode = 'EEG';
ephysInfo.EMGchan = [];
ephysInfo.chanLabels = {'AR','PR','PL','AL'}; %Labels for EEG channels

salineDate = '17712';
pars.expt(1).dataPath = [defaultPath animalName filesep salineDate filesep];
pars.expt(1).exptDate = ['date' salineDate];
pars.expt(1).exptIndex = {'001','003','005','007','009','011'};
pars.expt(1).timeReInj = -2:3; %19205 ZS changed from [-1.5,-0.5,0:3]
pars.expt(1).treatment = 'saline';
pars.expt(1).dose = 0;

salineFosDate = '17713';
pars.expt(2).dataPath = [defaultPath animalName filesep salineFosDate filesep];
pars.expt(2).exptDate = ['date' salineFosDate];
pars.expt(2).exptIndex = {'003','005','007','009','011','013'};
pars.expt(2).timeReInj = -2:3; %19205 ZS changed from [-1.5,-0.5,0:3]
pars.expt(2).treatment = 'saline_fos';
pars.expt(2).dose = 0;
pars.expt(2).other.drug = 'fosA';
pars.expt(2).other.dose = 10;
pars.expt(2).other.time = -1; %19205 ZS changed from -0.5

LPSFosDate = '17714';
pars.expt(3).dataPath = [defaultPath animalName filesep LPSFosDate filesep];
pars.expt(3).exptDate = ['date' LPSFosDate];
pars.expt(3).exptIndex = {'001','003','005','007','009','011'};
pars.expt(3).timeReInj = -2:3; %19205 ZS changed from [-1.5,-0.5,0:3]
pars.expt(3).treatment = 'LPS_fos';
pars.expt(3).dose = 25;
pars.expt(3).other.drug = 'fosA';
pars.expt(3).other.dose = 10;
pars.expt(3).other.time = -1; %19205 ZS changed from -0.5
batchParams.(animalName) = fillBatchParams(pars,ephysInfo);
clear pars ephysInfo
% % 
% % % %%
% % % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % % % %EEG45 %1 is front right; 2 is rear right; 3 is rear left; 4 is front left
pars.windowLength = 4; %sec
pars.windowOverlap = 0.25; %fractional overlap
electrodeSheet = 'EEG45';
animalName = 'EEG45';
ephysInfo.chanNums = 1:4; %brain ephys channels
ephysInfo.recMode = 'EEG';
ephysInfo.EMGchan = [];
ephysInfo.chanLabels = {'AR','PR','PL','AL'}; %Labels for EEG channels

salineDate = '17712';
pars.expt(1).dataPath = [defaultPath animalName filesep salineDate filesep];
pars.expt(1).exptDate = ['date' salineDate];
pars.expt(1).exptIndex = {'000','002','004','006','008','010'};
pars.expt(1).timeReInj = -2:3; %19205 ZS changed from [-1.5,-0.5,0:3]
pars.expt(1).treatment = 'saline';
pars.expt(1).dose = 0;

salineFosDate = '17713';
pars.expt(2).dataPath = [defaultPath animalName filesep salineFosDate filesep];
pars.expt(2).exptDate = ['date' salineFosDate];
pars.expt(2).exptIndex = {'002','004','006','008','010','012'};
pars.expt(2).timeReInj = -2:3; %19205 ZS changed from [-1.5,-0.5,0:3]
pars.expt(2).treatment = 'saline_fos';
pars.expt(2).dose = 0;
pars.expt(2).other.drug = 'fosA';
pars.expt(2).other.dose = 10;
pars.expt(2).other.time = -1; %19205 ZS changed from -0.5

LPSFosDate = '17714';
pars.expt(3).dataPath = [defaultPath animalName filesep LPSFosDate filesep];
pars.expt(3).exptDate = ['date' LPSFosDate];
pars.expt(3).exptIndex = {'000','002','004','006','008','010'};
pars.expt(3).timeReInj = -2:3; %19205 ZS changed from [-1.5,-0.5,0:3]
pars.expt(3).treatment = 'LPS_fos';
pars.expt(3).dose = 25;
pars.expt(3).other.drug = 'fosA';
pars.expt(3).other.dose = 10;
pars.expt(3).other.time = -1; %19205 ZS changed from -0.5
batchParams.(animalName) = fillBatchParams(pars,ephysInfo);
clear pars ephysInfo

% 
% % %%
% % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % % %EEG46 %1 is front right; 2 is rear right; 3 is rear left; 4 is front left
pars.windowLength = 4; %sec
pars.windowOverlap = 0.25; %fractional overlap
electrodeSheet = 'EEG46';
animalName = 'EEG46';
ephysInfo.chanNums = 1:4; %brain ephys channels
ephysInfo.recMode = 'EEG';
ephysInfo.EMGchan = [];
ephysInfo.chanLabels = {'AR','PR','PL','AL'}; %Labels for EEG channels

salineDate = '17716';
pars.expt(1).dataPath = [defaultPath animalName filesep salineDate filesep];
pars.expt(1).exptDate = ['date' salineDate];
pars.expt(1).exptIndex = {'000','001','002','003','004','005'};
pars.expt(1).timeReInj = -2:3; %19205 ZS changed from [-1.5,-0.5,0:3]
pars.expt(1).treatment = 'saline';
pars.expt(1).dose = 0;

salineFosDate = '17717';
pars.expt(2).dataPath = [defaultPath animalName filesep salineFosDate filesep];
pars.expt(2).exptDate = ['date' salineFosDate];
pars.expt(2).exptIndex = {'000','001','002','003','004','005'};
pars.expt(2).timeReInj = -2:3; %19205 ZS changed from [-1.5,-0.5,0:3]
pars.expt(2).treatment = 'saline_fos';
pars.expt(2).dose = 0;
pars.expt(2).other.drug = 'fosA';
% pars.expt(2).other.dose = 10;
pars.expt(2).other.time = -1; %19205 ZS changed from -0.5

LPSFosDate = '17718';
pars.expt(3).dataPath = [defaultPath animalName filesep LPSFosDate filesep];
pars.expt(3).exptDate = ['date' LPSFosDate];
pars.expt(3).exptIndex = {'000','001','002','003','004','005'};
pars.expt(3).timeReInj = -2:3; %19205 ZS changed from [-1.5,-0.5,0:3]
pars.expt(3).treatment = 'LPS_fos';
pars.expt(3).dose = 25;
pars.expt(3).other.drug = 'fosA';
pars.expt(3).other.dose = 10;
pars.expt(3).other.time = -1; %19205 ZS changed from -0.5
batchParams.(animalName) = fillBatchParams(pars,ephysInfo);
clear pars ephysInfo

% 
% % %%
% % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % % %LFP3 %1 is front right; 2 is rear right; 3 is rear left; 4 is front left
pars.windowLength = 4; %sec
pars.windowOverlap = 0.25; %fractional overlap
electrodeSheet = 'LFP3';
animalName = 'LFP3';
ephysInfo.chanNums = [1,2,3,4,9,10,11,12,13,14,15,16]; %brain ephys channels
ephysInfo.recMode = 'EEG';
ephysInfo.EMGchan = [];
ephysInfo.chanLabels = {'AR','PR','PL','AL','V2L','V2L','V1R','V1R','CgR','CgR','CgL','CgL'}; %Labels for EEG channels

% isoDate = '17808';
% pars.expt(1).dataPath = [defaultPath animalName filesep isoDate filesep];
% pars.expt(1).exptDate = ['date' isoDate];
% pars.expt(1).exptIndex = {'006','009','013','016','021'};
% pars.expt(1).timeReInj = [-0.5,0,0.5,1,2];
% pars.expt(1).treatment = 'iso';
% pars.expt(1).dose = 0.6;
% pars.expt(1).other.drug = 'iso';
% pars.expt(1).other.dose = 1.0;
% pars.expt(1).other.time = 0.5;

salineDate = '17810';
pars.expt(1).dataPath = [defaultPath animalName filesep salineDate filesep];
pars.expt(1).exptDate = ['date' salineDate];
pars.expt(1).exptIndex = {'007','009','011','013','015','017','019','021','023','025'};
pars.expt(1).timeReInj = [-1:0.5:3.5];
pars.expt(1).treatment = 'saline';
pars.expt(1).dose = 0;

LPSDate = '17814';
pars.expt(2).dataPath = [defaultPath animalName filesep LPSDate filesep];
pars.expt(2).exptDate = ['date' LPSDate];
pars.expt(2).exptIndex = {'003','005','007','009','011','013','015','017','019','021'};
pars.expt(2).timeReInj = [-1:0.5:3.5]; %hours re injection %updated 1.28.2019
pars.expt(2).treatment = 'LPS';
pars.expt(2).dose = 125;
batchParams.(animalName) = fillBatchParams(pars,ephysInfo);
clear pars ephysInfo

% % 
% % %%
% % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % % %LFP5 %1 is front right; 2 is rear right; 3 is rear left; 4 is front left
pars.windowLength = 4; %sec
pars.windowOverlap = 0.25; %fractional overlap
electrodeSheet = 'LFP5';
animalName = 'LFP5';
ephysInfo.chanNums = [1,2,3,4,9,10,11,12,13,14,15,16]; %brain ephys channels
ephysInfo.recMode = 'EEG';
ephysInfo.EMGchan = [];
ephysInfo.chanLabels = {'AR','PR','PL','AL','V2L','V2L','V1R','V1R','CgR','CgR','CgL','CgL'}; %Labels for EEG channels

% isoDate = '17829';
% pars.expt(1).dataPath = [defaultPath animalName filesep isoDate filesep];
% pars.expt(1).exptDate = ['date' isoDate];
% pars.expt(1).exptIndex = {'002','006','010','013','018'};
% pars.expt(1).timeReInj = [-0.5,0,0.5,1,2];
% pars.expt(1).treatment = 'iso';
% pars.expt(1).dose = 0.6;
% pars.expt(1).other.drug = 'iso';
% pars.expt(1).other.dose = 1.0;
% pars.expt(1).other.time = 0.5;

salineDate = '17831';
pars.expt(1).dataPath = [defaultPath animalName filesep salineDate filesep];
pars.expt(1).exptDate = ['date' salineDate];
pars.expt(1).exptIndex = {'002','004','006','008','010','013','015','017','019','021'};
pars.expt(1).timeReInj = [-1:0.5:3.5];  %updated 1.28.2019
pars.expt(1).treatment = 'saline';
pars.expt(1).dose = 0;

LPSDate = '17901';
pars.expt(2).dataPath = [defaultPath animalName filesep LPSDate filesep];
pars.expt(2).exptDate = ['date' LPSDate];
pars.expt(2).exptIndex = {'001','003','005','007','009','011','013','015','017','019'};
pars.expt(2).timeReInj = [-1:0.5:3.5]; %hours re injection  %updated 1.28.2019
pars.expt(2).treatment = 'LPS';
pars.expt(2).dose = 125;
batchParams.(animalName) = fillBatchParams(pars,ephysInfo);
clear pars ephysInfo

% % %%
% % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % % %LFP6 %1 is front right; 2 is rear right; 3 is rear left; 4 is front left
pars.windowLength = 4; %sec
pars.windowOverlap = 0.25; %fractional overlap
electrodeSheet = 'LFP6';
animalName = 'LFP6';
ephysInfo.chanNums = [1,2,3,4,9,10,11,12,13,14,15,16]; %brain ephys channels
ephysInfo.recMode = 'EEG';
ephysInfo.EMGchan = [];
ephysInfo.chanLabels = {'AR','PR','PL','AL','V2L','V2L','V1R','V1R','CgR','CgR','CgL','CgL'}; %Labels for EEG channels

% isoDate = '17913';
% pars.expt(1).dataPath = [defaultPath animalName filesep isoDate filesep];
% pars.expt(1).exptDate = ['date' isoDate];
% pars.expt(1).exptIndex = {'002','006','010','014','019'};
% pars.expt(1).timeReInj = [-0.5,0,0.5,1,2];
% pars.expt(1).treatment = 'iso';
% pars.expt(1).dose = 0.6;
% pars.expt(1).other.drug = 'iso';
% pars.expt(1).other.dose = 0.9;
% pars.expt(1).other.time = 0.5;

% ketamineDate = '17915';
% pars.expt(2).dataPath = [defaultPath animalName filesep ketamineDate filesep];
% pars.expt(2).exptDate = ['date' ketamineDate];
% pars.expt(2).exptIndex = {'002','007','009','011','013','015','017'};
% pars.expt(2).timeReInj = [-0.5,0.5:0.5:3];
% pars.expt(2).treatment = 'ketamine';
% pars.expt(2).dose = 200;

salineDate = '17918';
pars.expt(1).dataPath = [defaultPath animalName filesep salineDate filesep];
pars.expt(1).exptDate = ['date' salineDate];
pars.expt(1).exptIndex = {'003','006','008','010','012','015','017','020','022','024'};
pars.expt(1).timeReInj = [-1:0.5:3.5];  %updated 1.28.2019
pars.expt(1).treatment = 'saline';
pars.expt(1).dose = 0;

LPSDate = '17919';
pars.expt(2).dataPath = [defaultPath animalName filesep LPSDate filesep];
pars.expt(2).exptDate = ['date' LPSDate];
pars.expt(2).exptIndex = {'001','004','006','008','010','012','014','016','018','020'};
pars.expt(2).timeReInj = [-1:0.5:3.5]; %hours re injection  %updated 1.28.2019
pars.expt(2).treatment = 'LPS';
pars.expt(2).dose = 125;
batchParams.(animalName) = fillBatchParams(pars,ephysInfo);
clear pars ephysInfo

% % 
% % %%
% % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % % %LFP7 %1 is front right; 2 is rear right; 3 is rear left; 4 is front left
pars.windowLength = 4; %sec
pars.windowOverlap = 0.25; %fractional overlap
electrodeSheet = 'LFP7';
animalName = 'LFP7';
ephysInfo.chanNums = [1,2,3,4,9,10,11,12,13,14,15,16]; %brain ephys channels
ephysInfo.recMode = 'EEG';
ephysInfo.EMGchan = [];
ephysInfo.chanLabels = {'AR','PR','PL','AL','V2L','V2L','V1R','V1R','CgR','CgR','CgL','CgL'}; %Labels for EEG channels

% isoDate = '17920';
% pars.expt(1).dataPath = [defaultPath animalName filesep isoDate filesep];
% pars.expt(1).exptDate = ['date' isoDate];
% pars.expt(1).exptIndex = {'003','007','011','014','019'};
% pars.expt(1).timeReInj = [-0.5,0,0.5,1,2];
% pars.expt(1).treatment = 'iso';
% pars.expt(1).dose = 0.6;
% pars.expt(1).other.drug = 'iso';
% pars.expt(1).other.dose = 1.0;
% pars.expt(1).other.time = 0.5;
% 
% ketamineDate = '17922';
% pars.expt(2).dataPath = [defaultPath animalName filesep ketamineDate filesep];
% pars.expt(2).exptDate = ['date' ketamineDate];
% pars.expt(2).exptIndex = {'002','006','008','010','012','015','017'};
% pars.expt(2).timeReInj = [-0.5,0.5:0.5:3];
% pars.expt(2).treatment = 'ketamine';
% pars.expt(2).dose = 200;

salineDate = '17925';
pars.expt(1).dataPath = [defaultPath animalName filesep salineDate filesep];
pars.expt(1).exptDate = ['date' salineDate];
pars.expt(1).exptIndex = {'001','003','005','007','009','011','013','015','017','019'};
pars.expt(1).timeReInj = [-1:0.5:3.5];  %updated 1.28.2019
pars.expt(1).treatment = 'saline';
pars.expt(1).dose = 0;

LPSDate = '17927';
pars.expt(2).dataPath = [defaultPath animalName filesep LPSDate filesep];
pars.expt(2).exptDate = ['date' LPSDate];
pars.expt(2).exptIndex = {'002','004','006','008','010','012','014','016','018','020'};
pars.expt(2).timeReInj = [-1:0.5:3.5]; %hours re injection  %updated 1.28.2019
pars.expt(2).treatment = 'LPS';
pars.expt(2).dose = 125;
batchParams.(animalName) = fillBatchParams(pars,ephysInfo);
clear pars ephysInfo

% % 
% % %%
% % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % % %LFP8 %1 is front right; 2 is rear right; 3 is rear left; 4 is front left
pars.windowLength = 4; %sec
pars.windowOverlap = 0.25; %fractional overlap
electrodeSheet = 'LFP8';
animalName = 'LFP8';
ephysInfo.chanNums = [1,2,3,4,9,10,11,12,13,14,15,16]; %brain ephys channels
ephysInfo.recMode = 'EEG';
ephysInfo.EMGchan = [];
ephysInfo.chanLabels = {'AR','PR','PL','AL','V2L','V2L','V1R','V1R','CgR','CgR','CgL','CgL'}; %Labels for EEG channels

%Commented out 1/13/19 ZS
% isoDate = '17926';
% pars.expt(1).dataPath = [defaultPath animalName filesep isoDate filesep];
% pars.expt(1).exptDate = ['date' isoDate];
% pars.expt(1).exptIndex = {'002','006','009','014','019'};
% pars.expt(1).timeReInj = [-0.5,0,0.5,1,2];
% pars.expt(1).treatment = 'iso';
% pars.expt(1).dose = 0.6;
% pars.expt(1).other.drug = 'iso';
% pars.expt(1).other.dose = 1.0;
% pars.expt(1).other.time = 0.5;
% 
% ketamineDate = '17929';
% pars.expt(2).dataPath = [defaultPath animalName filesep ketamineDate filesep];
% pars.expt(2).exptDate = ['date' ketamineDate];
% pars.expt(2).exptIndex = {'002','006','008','010','012','014','016'};
% pars.expt(2).timeReInj = [-0.5,0.5:0.5:3];
% pars.expt(2).treatment = 'ketamine';
% pars.expt(2).dose = 200;

salineDate = '17o02';
pars.expt(1).dataPath = [defaultPath animalName filesep salineDate filesep];
pars.expt(1).exptDate = ['date' salineDate];
pars.expt(1).exptIndex = {'001','003','005','007','009','011','013','015','017','019'};
pars.expt(1).timeReInj = [-1:0.5:3.5]; %updated 1/22/2019 ZS
pars.expt(1).treatment = 'saline';
pars.expt(1).dose = 0;

LPSDate = '17o13';
pars.expt(2).dataPath = [defaultPath animalName filesep LPSDate filesep];
pars.expt(2).exptDate = ['date' LPSDate];
pars.expt(2).exptIndex = {'001','003','005','007','009','011','013','015','018','020'};
pars.expt(2).timeReInj = [-1:0.5:3.5]; %hours re injection %updated 1/22/2019 ZS
pars.expt(2).treatment = 'LPS';
pars.expt(2).dose = 125;
batchParams.(animalName) = fillBatchParams(pars,ephysInfo);
clear pars ephysInfo

% % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % % %LFP9 %1 is front right; 2 is rear right; 3 is rear left; 4 is front left
pars.windowLength = 4; %sec
pars.windowOverlap = 0.25; %fractional overlap
electrodeSheet = 'LFP9';
animalName = 'LFP9';
ephysInfo.chanNums = [1,2,3,4,9,10,11,12,13,14,15,16]; %brain ephys channels
ephysInfo.recMode = 'EEG';
ephysInfo.EMGchan = [];
ephysInfo.chanLabels = {'AR','PR','PL','AL','V2L','V2L','V1R','V1R','CgR','CgR','CgL','CgL'}; %Labels for EEG channels

%Commented out 1/13/19 ZS
% ketamineDate = '17o20';
% pars.expt(1).dataPath = [defaultPath animalName filesep ketamineDate filesep];
% pars.expt(1).exptDate = ['date' ketamineDate];
% pars.expt(1).exptIndex = {'002','006','008','010','012','014','016'};
% pars.expt(1).timeReInj = [-0.5,0.5:0.5:3];
% pars.expt(1).treatment = 'ketamine';
% pars.expt(1).dose = 200;
% 
% atropineDate = '17o24';
% pars.expt(2).dataPath = [defaultPath animalName filesep atropineDate filesep];
% pars.expt(2).exptDate = ['date' atropineDate];
% pars.expt(2).exptIndex = {'001','003','005','007','009','011','013','015','017','019'};
% pars.expt(2).timeReInj = [-1:0.5:3];
% pars.expt(2).treatment = 'atropine';
% pars.expt(2).dose = 100;
% 
% isoDate = '17o25';
% pars.expt(3).dataPath = [defaultPath animalName filesep isoDate filesep];
% pars.expt(3).exptDate = ['date' isoDate];
% pars.expt(3).exptIndex = {'002','008','011','016','021'};
% pars.expt(3).timeReInj = [-0.5,0,0.5,1,2];
% pars.expt(3).treatment = 'iso';
% pars.expt(3).dose = 0.5;
% pars.expt(3).other.drug = 'iso';
% pars.expt(3).other.dose = 0.8;
% pars.expt(3).other.time = 0.5;

salineDate = '17o26';
pars.expt(1).dataPath = [defaultPath animalName filesep salineDate filesep];
pars.expt(1).exptDate = ['date' salineDate];
pars.expt(1).exptIndex = {'001','003','005','007','009','011','013','015','017','019'};
pars.expt(1).timeReInj = [-1:0.5:3.5]; %NOTE: not congruent with the saved batchParams... ZS 18d16
pars.expt(1).treatment = 'saline';
pars.expt(1).dose = 0;

LPSDate = '17o31';
pars.expt(2).dataPath = [defaultPath animalName filesep LPSDate filesep];
pars.expt(2).exptDate = ['date' LPSDate];
pars.expt(2).exptIndex = {'001','003','005','007','009','011','013','015','017','019'};
pars.expt(2).timeReInj = [-1:0.5:3.5]; %hours re injection %NOTE: not congruent with the saved batchParams... ZS 18d16
pars.expt(2).treatment = 'LPS';
pars.expt(2).dose = 125;
batchParams.(animalName) = fillBatchParams(pars,ephysInfo);
clear pars ephysInfo


% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % %EEG47 %1 is front right; 2 is rear right; 3 is rear left; 4 is front left
pars.windowLength = 4; %sec
pars.windowOverlap = 0.25; %fractional overlap
electrodeSheet = 'EEG47';
animalName = 'EEG47';
ephysInfo.chanNums = 1:4; %brain ephys channels
ephysInfo.recMode = 'EEG';
ephysInfo.EMGchan = [];
ephysInfo.chanLabels = {'AR','PR','PL','AL'}; %Labels for EEG channels

salineDate = '18307';
pars.expt(1).dataPath = [defaultPath animalName filesep salineDate filesep];
pars.expt(1).exptDate = ['date' salineDate];
pars.expt(1).exptIndex = {'000','001','002','003','004'};
pars.expt(1).timeReInj = [-1:3];
pars.expt(1).treatment = 'saline';
pars.expt(1).dose = 0;

LPSDate = '18309';
pars.expt(2).dataPath = [defaultPath animalName filesep LPSDate filesep];
pars.expt(2).exptDate = ['date' LPSDate];
pars.expt(2).exptIndex = {'000','001','002','003','004'};
pars.expt(2).timeReInj = [-1:3]; %hours re injection
pars.expt(2).treatment = 'LPS';
pars.expt(2).dose = 125;
batchParams.(animalName) = fillBatchParams(pars,ephysInfo);
clear pars ephysInfo

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % %EEG48 %1 is front right; 2 is rear right; 3 is rear left; 4 is front left
pars.windowLength = 4; %sec
pars.windowOverlap = 0.25; %fractional overlap
electrodeSheet = 'EEG48';
animalName = 'EEG48';
ephysInfo.chanNums = 1:4; %brain ephys channels
ephysInfo.recMode = 'EEG';
ephysInfo.EMGchan = [];
ephysInfo.chanLabels = {'AR','PR','PL','AL'}; %Labels for EEG channels

salineDate = '18315';
pars.expt(1).dataPath = [defaultPath animalName filesep salineDate filesep];
pars.expt(1).exptDate = ['date' salineDate];
pars.expt(1).exptIndex = {'000','001','002','003','004'};
pars.expt(1).timeReInj = [-1:3];
pars.expt(1).treatment = 'saline';
pars.expt(1).dose = 0;

LPSDate = '18316';
pars.expt(2).dataPath = [defaultPath animalName filesep LPSDate filesep];
pars.expt(2).exptDate = ['date' LPSDate];
pars.expt(2).exptIndex = {'000','001','002','003','004'};
pars.expt(2).timeReInj = [-1:3]; %hours re injection
pars.expt(2).treatment = 'LPS';
pars.expt(2).dose = 125;
batchParams.(animalName) = fillBatchParams(pars,ephysInfo);
clear pars ephysInfo

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % %EEG49 %1 is front right; 2 is rear right; 3 is rear left; 4 is front left
pars.windowLength = 4; %sec
pars.windowOverlap = 0.25; %fractional overlap
electrodeSheet = 'EEG49';
animalName = 'EEG49';
ephysInfo.chanNums = 1:4; %brain ephys channels
ephysInfo.recMode = 'EEG';
ephysInfo.EMGchan = [];
ephysInfo.chanLabels = {'AR','PR','PL','AL'}; %Labels for EEG channels

salineDate = '18327';
pars.expt(1).dataPath = [defaultPath animalName filesep salineDate filesep];
pars.expt(1).exptDate = ['date' salineDate];
pars.expt(1).exptIndex = {'000','001','002','003','004'};
pars.expt(1).timeReInj = [-1:3];
pars.expt(1).treatment = 'saline';
pars.expt(1).dose = 0;

LPSDate = '18328';
pars.expt(2).dataPath = [defaultPath animalName filesep LPSDate filesep];
pars.expt(2).exptDate = ['date' LPSDate];
pars.expt(2).exptIndex = {'000','001','002','003','004'};
pars.expt(2).timeReInj = [-1:3]; %hours re injection
pars.expt(2).treatment = 'LPS';
pars.expt(2).dose = 25;
batchParams.(animalName) = fillBatchParams(pars,ephysInfo);
clear pars ephysInfo

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % %EEG50 %1 is front right; 2 is rear right; 3 is rear left; 4 is front left
pars.windowLength = 4; %sec
pars.windowOverlap = 0.25; %fractional overlap
electrodeSheet = 'EEG50';
animalName = 'EEG50';
ephysInfo.chanNums = 1:4; %brain ephys channels
ephysInfo.recMode = 'EEG';
ephysInfo.EMGchan = [];
ephysInfo.chanLabels = {'AR','PR','PL','AL'}; %Labels for EEG channels

salineDate = '18410';
pars.expt(1).dataPath = [defaultPath animalName filesep salineDate filesep];
pars.expt(1).exptDate = ['date' salineDate];
pars.expt(1).exptIndex = {'000','001','002','003','004'};
pars.expt(1).timeReInj = [-1:3];
pars.expt(1).treatment = 'saline';
pars.expt(1).dose = 0;

LPSDate = '18411';
pars.expt(2).dataPath = [defaultPath animalName filesep LPSDate filesep];
pars.expt(2).exptDate = ['date' LPSDate];
pars.expt(2).exptIndex = {'000','001','002','003','004'};
pars.expt(2).timeReInj = [-1:3]; %hours re injection
pars.expt(2).treatment = 'LPS';
pars.expt(2).dose = 0;
batchParams.(animalName) = fillBatchParams(pars,ephysInfo);
clear pars ephysInfo

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % %EEG51 %1 is front right; 2 is rear right; 3 is rear left; 4 is front left
pars.windowLength = 4; %sec
pars.windowOverlap = 0.25; %fractional overlap
electrodeSheet = 'EEG51';
animalName = 'EEG51';
ephysInfo.chanNums = 1:4; %brain ephys channels
ephysInfo.recMode = 'EEG';
ephysInfo.EMGchan = [];
ephysInfo.chanLabels = {'AR','PR','PL','AL'}; %Labels for EEG channels

salineDate = '18426';
pars.expt(1).dataPath = [defaultPath animalName filesep salineDate filesep];
pars.expt(1).exptDate = ['date' salineDate];
pars.expt(1).exptIndex = {'000','001','002','003','004'};
pars.expt(1).timeReInj = [-1:3];
pars.expt(1).treatment = 'saline';
pars.expt(1).dose = 0;

LPSDate = '18427';
pars.expt(2).dataPath = [defaultPath animalName filesep LPSDate filesep];
pars.expt(2).exptDate = ['date' LPSDate];
pars.expt(2).exptIndex = {'000','001','002','003','004'};
pars.expt(2).timeReInj = [-1:3]; %hours re injection
pars.expt(2).treatment = 'LPS';
pars.expt(2).dose = 0;
batchParams.(animalName) = fillBatchParams(pars,ephysInfo);
clear pars ephysInfo

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % %LFP11 %1 is front right; 2 is rear right; 3 is rear left; 4 is front left
pars.windowLength = 4; %sec
pars.windowOverlap = 0.25; %fractional overlap
electrodeSheet = 'LFP11';
animalName = 'LFP11';
ephysInfo.chanNums = [1,2,3,4,9,10,11,12,13,14,15,16]; %brain ephys channels
ephysInfo.recMode = 'EEG';
ephysInfo.EMGchan = [];
ephysInfo.chanLabels = {'AR','PR','PL','AL','V2L','V2L','V1R','V1R','CgR','CgR','CgL','CgL'}; %Labels for EEG channels

salineDate = '17d07';
pars.expt(1).dataPath = [defaultPath animalName filesep salineDate filesep];
pars.expt(1).exptDate = ['date' salineDate];
pars.expt(1).exptIndex = {'001','003','005','007','009','011','013','015',...
    '017','019'};
pars.expt(1).timeReInj = [-1:0.5:3.5]; %hours re injection
pars.expt(1).treatment = 'saline';
pars.expt(1).dose = 0;

LPSDate = '17d12';
pars.expt(2).dataPath = [defaultPath animalName filesep LPSDate filesep];
pars.expt(2).exptDate = ['date' LPSDate];
pars.expt(2).exptIndex = {'001','003','005','007','009','011','013','015',...
    '017','019'};
pars.expt(2).timeReInj = [-1:0.5:3.5]; %hours re injection
pars.expt(2).treatment = 'LPS';
pars.expt(2).dose = 25;
batchParams.(animalName) = fillBatchParams(pars,ephysInfo);
clear pars ephysInfo



% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % %LFP12 %1 is front right; 2 is rear right; 3 is rear left; 4 is front left
pars.windowLength = 4; %sec
pars.windowOverlap = 0.25; %fractional overlap
electrodeSheet = 'LFP12';
animalName = 'LFP12';
ephysInfo.chanNums = 1:4; %brain ephys channels
ephysInfo.recMode = 'EEG';
ephysInfo.EMGchan = [];
ephysInfo.chanLabels = {'AR','PR','PL','AL'}; %Labels for EEG channels

salineDate = '18116';
pars.expt(1).dataPath = [defaultPath animalName filesep salineDate filesep];
pars.expt(1).exptDate = ['date' salineDate];
pars.expt(1).exptIndex = {'001','003','005','007','009','011','013','015',...
    '017','019','021','023'};
pars.expt(1).timeReInj = -1.5:0.5:4; %ZS 19128
pars.expt(1).treatment = 'a5_saline';
pars.expt(1).dose = 0;
pars.expt(1).other.drug = 'a5';
pars.expt(1).other.dose = 1;
pars.expt(1).other.time = -0.5;

LPSDate = '18117';
pars.expt(2).dataPath = [defaultPath animalName filesep LPSDate filesep];
pars.expt(2).exptDate = ['date' LPSDate];
pars.expt(2).exptIndex = {'001','003','005','007','009','011','013','015',...
    '017','019','021','023'};
pars.expt(2).timeReInj = -1.5:0.5:4; %ZS 19128
pars.expt(2).treatment = 'a5_LPS';
pars.expt(2).dose = 125;
pars.expt(2).other.drug = 'a5';
pars.expt(2).other.dose = 1;
pars.expt(2).other.time = -0.5;
batchParams.(animalName) = fillBatchParams(pars,ephysInfo);
clear pars ephysInfo
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % %LFP13 %1 is front right; 2 is rear right; 3 is rear left; 4 is front left

pars.windowLength = 4; %sec
pars.windowOverlap = 0.25; %fractional overlap
electrodeSheet = 'LFP13';
animalName = 'LFP13';
ephysInfo.chanNums = 1:4; %brain ephys channels
ephysInfo.recMode = 'EEG';
ephysInfo.EMGchan = [];
ephysInfo.chanLabels = {'AR','PR','PL','AL'}; %Labels for EEG channels

salineDate = '18204';
pars.expt(1).dataPath = [defaultPath animalName filesep salineDate filesep];
pars.expt(1).exptDate = ['date' salineDate];
pars.expt(1).exptIndex = {'001','003','005','007','009','011','013','015',...
'017','019'};
pars.expt(1).timeReInj = [-1:0.5:3.5];
pars.expt(1).treatment = 'saline';
pars.expt(1).dose = 0;

LPSDate = '18205';
pars.expt(2).dataPath = [defaultPath animalName filesep LPSDate filesep];
pars.expt(2).exptDate = ['date' LPSDate];
pars.expt(2).exptIndex = {'001','003','006','008','010','012','014','016',...
'018','020'};
pars.expt(2).timeReInj = [-1:0.5:3.5];
pars.expt(2).treatment = 'LPS';
pars.expt(2).dose = 25;

batchParams.(animalName) = fillBatchParams(pars,ephysInfo);
clear pars ephysInfo
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % %LFP14 %1 is front right; 2 is rear right; 3 is rear left; 4 is front left

pars.windowLength = 4; %sec
pars.windowOverlap = 0.25; %fractional overlap
electrodeSheet = 'LFP14';
animalName = 'LFP14';
ephysInfo.chanNums = 1:4; %brain ephys channels
ephysInfo.recMode = 'EEG';
ephysInfo.EMGchan = [];
ephysInfo.chanLabels = {'AR','PR','PL','AL'}; %Labels for EEG channels

salineDate = '18206';
pars.expt(1).dataPath = [defaultPath animalName filesep salineDate filesep];
pars.expt(1).exptDate = ['date' salineDate];
pars.expt(1).exptIndex = {'001','003','005','007','009','011','013','015',...
    '017','019','021','023'};
pars.expt(1).timeReInj = -1.5:0.5:4; %ZS 19128
pars.expt(1).treatment = 'a5_saline';
pars.expt(1).dose = 0;
pars.expt(1).other.drug = 'a5';
pars.expt(1).other.dose = 1;
pars.expt(1).other.time = -0.5;

LPSDate = '18207';
pars.expt(2).dataPath = [defaultPath animalName filesep LPSDate filesep];
pars.expt(2).exptDate = ['date' LPSDate];
pars.expt(2).exptIndex = {'001','003','005','007','009','013','015',...
    '017','019','021','023'};
pars.expt(2).timeReInj = -1.5:0.5:4; %ZS 19128; %hours re injection
pars.expt(2).treatment = 'a5_LPS';
pars.expt(2).dose = 125;
pars.expt(2).other.drug = 'a5';
pars.expt(2).other.dose = 1;
pars.expt(2).other.time = -0.5;
batchParams.(animalName) = fillBatchParams(pars,ephysInfo);
clear pars ephysInfo

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % %LFP15 %1 is front right; 2 is rear right; 3 is rear left; 4 is front left
pars.windowLength = 4; %sec
pars.windowOverlap = 0.25; %fractional overlap
electrodeSheet = 'LFP15';
animalName = 'LFP15';
ephysInfo.chanNums = 1:4; %brain ephys channels
ephysInfo.recMode = 'EEG';
ephysInfo.EMGchan = [];
ephysInfo.chanLabels = {'AR','PR','PL','AL'}; %Labels for EEG channels

salineDate = '18213';
pars.expt(1).dataPath = [defaultPath animalName filesep salineDate filesep];
pars.expt(1).exptDate = ['date' salineDate];
pars.expt(1).exptIndex = {'001','003','005','007','009','011','013','015',...
    '017','019','021','023'};
pars.expt(1).timeReInj = -1.5:0.5:4; %ZS 19128
pars.expt(1).treatment = 'a5_saline';
pars.expt(1).dose = 0;
pars.expt(1).other.drug = 'a5';
pars.expt(1).other.dose = 1;
pars.expt(1).other.time = -0.5;

LPSDate = '18215';
pars.expt(2).dataPath = [defaultPath animalName filesep LPSDate filesep];
pars.expt(2).exptDate = ['date' LPSDate];
pars.expt(2).exptIndex = {'001','003','005','007','009','011','013','015',...
    '017','019','021','023'};
pars.expt(2).timeReInj = -1.5:0.5:4; %ZS 19128 %hours re injection
pars.expt(2).treatment = 'a5_LPS';
pars.expt(2).dose = 125;
pars.expt(2).other.drug = 'a5';
pars.expt(2).other.dose = 1;
pars.expt(2).other.time = -0.5;
batchParams.(animalName) = fillBatchParams(pars,ephysInfo);
clear pars ephysInfo

% % % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % % % %LFP16 %1 is front right; 2 is rear right; 3 is rear left; 4 is front left
pars.windowLength = 4; %sec
pars.windowOverlap = 0.25; %fractional overlap
electrodeSheet = 'LFP16';
animalName = 'LFP16';
ephysInfo.chanNums = 1:4; %brain ephys channels
ephysInfo.recMode = 'EEG';
ephysInfo.EMGchan = [];
ephysInfo.chanLabels = {'AR','PR','PL','AL'}; %Labels for EEG channels

salineDate = '18227';
pars.expt(1).dataPath = [defaultPath animalName filesep salineDate filesep];
pars.expt(1).exptDate = ['date' salineDate];
pars.expt(1).exptIndex = {'004','008','012','016','020','024','028','032','036','040'};
pars.expt(1).timeReInj = [-1:0.5:3.5];  %updated 1.28.2019
pars.expt(1).treatment = 'saline';
pars.expt(1).dose = 0;

LPSDate = '18301';
pars.expt(2).dataPath = [defaultPath animalName filesep LPSDate filesep];
pars.expt(2).exptDate = ['date' LPSDate];
pars.expt(2).exptIndex = {'002','006','010','014','018','022','026','030','034','038'};
pars.expt(2).exptIndex = {'002','006','010','014','018','022','026','030','034','038'};
pars.expt(2).timeReInj = [-1:0.5:3.5]; %hours re injection  %updated 1.28.2019
pars.expt(2).treatment = 'LPS';
pars.expt(2).dose = 125;
batchParams.(animalName) = fillBatchParams(pars,ephysInfo);
clear pars ephysInfo


% % % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % % % %LFP17 %1 is front right; 2 is rear right; 3 is rear left; 4 is front left
pars.windowLength = 4; %sec
pars.windowOverlap = 0.25; %fractional overlap
electrodeSheet = 'LFP17';
animalName = 'LFP17';
ephysInfo.chanNums = 1:4; %brain ephys channels
ephysInfo.recMode = 'EEG';
ephysInfo.EMGchan = [];
ephysInfo.chanLabels = {'AR','PR','PL','AL'}; %Labels for EEG channels

salineDate = '18227';
pars.expt(1).dataPath = [defaultPath animalName filesep salineDate filesep];
pars.expt(1).exptDate = ['date' salineDate];
pars.expt(1).exptIndex = {'005','009','013','017','021','025','029','033','037','041'};
pars.expt(1).timeReInj = [-1:0.5:3.5];  %updated 1.28.2019
pars.expt(1).treatment = 'saline';
pars.expt(1).dose = 0;

LPSDate = '18301';
pars.expt(2).dataPath = [defaultPath animalName filesep LPSDate filesep];
pars.expt(2).exptDate = ['date' LPSDate];
pars.expt(2).exptIndex = {'003','007','011','015','019','023','027','031','035','039'};
pars.expt(2).timeReInj = [-1:0.5:3.5]; %hours re injection  %updated 1.28.2019
pars.expt(2).treatment = 'LPS';
pars.expt(2).dose = 125;
batchParams.(animalName) = fillBatchParams(pars,ephysInfo);
clear pars ephysInfo

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % %DREADD06 %1 is front right; 2 is rear right; 3 is rear left; 4 is front left
pars.windowLength = 4; %sec
pars.windowOverlap = 0.25; %fractional overlap
electrodeSheet = 'DREADD06';
animalName = 'DREADD06';
ephysInfo.chanNums = 1:4; %brain ephys channels
ephysInfo.recMode = 'EEG';
ephysInfo.EMGchan = [];
ephysInfo.chanLabels = {'AR','PR','PL','AL'}; %Labels for EEG channels

salineDate = '18503';
pars.expt(1).dataPath = [defaultPath animalName filesep salineDate filesep];
pars.expt(1).exptDate = ['date' salineDate];
pars.expt(1).exptIndex = {'000','001','002','003','004','005'};
pars.expt(1).timeReInj = [-1.5,-0.5,0:3];
pars.expt(1).treatment = 'saline';
pars.expt(1).dose = 0;
pars.expt(1).other.drug = 'saline';
pars.expt(1).other.dose = 1;
pars.expt(1).other.time = -0.5;

LPSDate = '18504';
pars.expt(2).dataPath = [defaultPath animalName filesep LPSDate filesep];
pars.expt(2).exptDate = ['date' LPSDate];
pars.expt(2).exptIndex = {'000','001','002','003','004','005'};
pars.expt(2).timeReInj = [-1.5,-0.5,0:3]; %hours re injection
pars.expt(2).treatment = 'CNO_saline';
pars.expt(2).dose = 125;
pars.expt(2).other.drug = 'saline';
pars.expt(2).other.dose = 1;
pars.expt(2).other.time = -0.5;

LPSDate = '18507';
pars.expt(3).dataPath = [defaultPath animalName filesep LPSDate filesep];
pars.expt(3).exptDate = ['date' LPSDate];
pars.expt(3).exptIndex = {'000','001','002','003','004','005'};
pars.expt(3).timeReInj = [-2,-1,0:3]; %hours re injection
pars.expt(3).treatment = 'CNO_LPS';
pars.expt(3).dose = 125;
pars.expt(3).other.drug = 'CNO';
pars.expt(3).other.dose = 1;
pars.expt(3).other.time = -0.5;
batchParams.(animalName) = fillBatchParams(pars,ephysInfo);
clear pars ephysInfo



% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % %DREADD07 %1 is front right; 2 is rear right; 3 is rear left; 4 is front left
pars.windowLength = 4; %sec
pars.windowOverlap = 0.25; %fractional overlap
electrodeSheet = 'DREADD07';
animalName = 'DREADD07';
ephysInfo.chanNums = 1:4; %brain ephys channels
ephysInfo.recMode = 'EEG';
ephysInfo.EMGchan = [];
ephysInfo.chanLabels = {'AR','PR','PL','AL'}; %Labels for EEG channels

testDate = '18820'; %No saline was injected (this was a synapse test day)
pars.expt(1).dataPath = [defaultPath animalName filesep testDate filesep];
pars.expt(1).exptDate = ['date' testDate];
pars.expt(1).exptIndex = {'001','003','005','007','009','011','013','015','017','019'};
pars.expt(1).timeReInj = [-1:0.5:3.5];
pars.expt(1).treatment = 'test';
pars.expt(1).dose = 0;

cnoDate = '18821'; %1mg/kg CNO injection
pars.expt(2).dataPath = [defaultPath animalName filesep cnoDate filesep];
pars.expt(2).exptDate = ['date' cnoDate];
pars.expt(2).exptIndex = {'002','004','006','008','010','012','014','016','018','020'}; % playing w/ God
pars.expt(2).timeReInj = [-1:0.5:3.5];
pars.expt(2).treatment = 'CNO_1';
pars.expt(2).dose = 1;


cnoDate = '18823'; %2mg/kg CNO injection
pars.expt(3).dataPath = [defaultPath animalName filesep cnoDate filesep];
pars.expt(3).exptDate = ['date' cnoDate];
pars.expt(3).exptIndex = {'003','005','007','009','011','013','015','017','019','021'};
pars.expt(3).timeReInj = [-1:0.5:3.5]; 
pars.expt(3).treatment = 'CNO_2';
pars.expt(3).dose = 2;

cnoDate = '18824'; %4mg/kg CNO injection
pars.expt(4).dataPath = [defaultPath animalName filesep cnoDate filesep];
pars.expt(4).exptDate = ['date' cnoDate];
pars.expt(4).exptIndex = {'001','003','005','007','009','011','013','015','017','019'};
pars.expt(4).timeReInj = [-1:0.5:3.5]; 
pars.expt(4).treatment = 'CNO_4';
pars.expt(4).dose = 4;

salineDate = '18828'; %Saline
pars.expt(5).dataPath = [defaultPath animalName filesep salineDate filesep];
pars.expt(5).exptDate = ['date' salineDate];
pars.expt(5).exptIndex = {'001','003','005','007','009','011','013','016','019','021'};
pars.expt(5).timeReInj = [-1:0.5:3.5]; 
pars.expt(5).treatment = 'saline';
pars.expt(5).dose = 0;

cnoDate = '18830'; %8mg/kg CNO
pars.expt(6).dataPath = [defaultPath animalName filesep cnoDate filesep];
pars.expt(6).exptDate = ['date' cnoDate];
pars.expt(6).exptIndex = {'001','003','005','008','010','012','014','016','018','020'};
pars.expt(6).timeReInj = [-1:0.5:3.5]; 
pars.expt(6).treatment = 'CNO_8';
pars.expt(6).dose = 8;

cnoDate = '18831'; %12mg/kg CNO
pars.expt(7).dataPath = [defaultPath animalName filesep cnoDate filesep];
pars.expt(7).exptDate = ['date' cnoDate];
pars.expt(7).exptIndex = {'002','004','006','008','010','012','014','016','018','020'};
pars.expt(7).timeReInj = [-1:0.5:3.5]; 
pars.expt(7).treatment = 'CNO_12A';
pars.expt(7).dose = 12;

cnoDate = '18907'; %12mg/kg CNO
pars.expt(8).dataPath = [defaultPath animalName filesep cnoDate filesep];
pars.expt(8).exptDate = ['date' cnoDate];
pars.expt(8).exptIndex = {'001','003','005','007','009','011','013','015','017','019'};
pars.expt(8).timeReInj = [-1:0.5:3.5]; 
pars.expt(8).treatment = 'CNO_12B';
pars.expt(8).dose = 12;
batchParams.(animalName) = fillBatchParams(pars,ephysInfo);
clear pars ephysInfo

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % %LFP18 
...
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % %EEG52 %1 is front right; 2 is rear right; 3 is rear left; 4 is front left
% pars.windowLength = 4; %sec
% pars.windowOverlap = 0.25; %fractional overlap
% electrodeSheet = 'EEG52';
% animalName = 'EEG52';
% ephysInfo.chanNums = 1:4; %brain ephys channels
% ephysInfo.recMode = 'EEG';
% ephysInfo.EMGchan = [];
% ephysInfo.chanLabels = {'AR','PR','PL','AL'}; %Labels for EEG channels
% 
% salineDate = '18o29'; 
% pars.expt(1).dataPath = [defaultPath animalName filesep salineDate filesep];
% pars.expt(1).exptDate = ['date' salineDate];
% pars.expt(1).exptIndex = {'001','002','003','004','005'};
% pars.expt(1).timeReInj = -1:3;
% pars.expt(1).treatment = 'saline';
% pars.expt(1).dose = 0;
% 
% LPSDate = '18o30';
% pars.expt(2).dataPath = [defaultPath animalName filesep LPSDate filesep];
% pars.expt(2).exptDate = ['date' LPSDate];
% pars.expt(2).exptIndex = {'000','001','002','003','004'};
% pars.expt(2).timeReInj = -1:3; %hours re injection
% pars.expt(2).treatment = 'LPS';
% pars.expt(2).dose = 25;
% batchParams.(animalName) = fillBatchParams(pars,ephysInfo);
% clear pars ephysInfo
% 
% % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % % %EEG53 %1 is front right; 2 is rear right; 3 is rear left; 4 is front left
% pars.windowLength = 4; %sec
% pars.windowOverlap = 0.25; %fractional overlap
% electrodeSheet = 'EEG53';
% animalName = 'EEG53';
% ephysInfo.chanNums = 1:4; %brain ephys channels
% ephysInfo.recMode = 'EEG';
% ephysInfo.EMGchan = [];
% ephysInfo.chanLabels = {'AR','PR','PL','AL'}; %Labels for EEG channels
% 
% salineDate = '18o31'; 
% pars.expt(1).dataPath = [defaultPath animalName filesep salineDate filesep];
% pars.expt(1).exptDate = ['date' salineDate];
% pars.expt(1).exptIndex = {'000', '001','002','003','004'};
% pars.expt(1).timeReInj = -1:3;
% pars.expt(1).treatment = 'saline';
% pars.expt(1).dose = 0;
% 
% LPSDate = '18n01';
% pars.expt(2).dataPath = [defaultPath animalName filesep LPSDate filesep];
% pars.expt(2).exptDate = ['date' LPSDate];
% pars.expt(2).exptIndex = {'000','001','002','003','004'};
% pars.expt(2).timeReInj = -1:3; %hours re injection
% pars.expt(2).treatment = 'LPS';
% pars.expt(2).dose = 25;
% batchParams.(animalName) = fillBatchParams(pars,ephysInfo);
% clear pars ephysInfo
% 
% % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % % %EEG54 %1 is front right; 2 is rear right; 3 is rear left; 4 is front left
% pars.windowLength = 4; %sec
% pars.windowOverlap = 0.25; %fractional overlap
% electrodeSheet = 'EEG54';
% animalName = 'EEG54';
% ephysInfo.chanNums = 1:4; %brain ephys channels
% ephysInfo.recMode = 'EEG';
% ephysInfo.EMGchan = [];
% ephysInfo.chanLabels = {'AR','PR','PL','AL'}; %Labels for EEG channels
% 
% salineDate = '18n05'; 
% pars.expt(1).dataPath = [defaultPath animalName filesep salineDate filesep];
% pars.expt(1).exptDate = ['date' salineDate];
% pars.expt(1).exptIndex = {'000', '001','002','003','004'};
% pars.expt(1).timeReInj = -1:3;
% pars.expt(1).treatment = 'saline';
% pars.expt(1).dose = 0;
% 
% LPSDate = '18n06';
% pars.expt(2).dataPath = [defaultPath animalName filesep LPSDate filesep];
% pars.expt(2).exptDate = ['date' LPSDate];
% pars.expt(2).exptIndex = {'000','001','002','003','004'};
% pars.expt(2).timeReInj = -1:3;%hours re injection
% pars.expt(2).treatment = 'LPS';
% pars.expt(2).dose = 25;
% batchParams.(animalName) = fillBatchParams(pars,ephysInfo);
% clear pars ephysInfo

% % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % % %EEG55 %1 is front right; 2 is rear right; 3 is rear left; 4 is front left
% pars.windowLength = 4; %sec
% pars.windowOverlap = 0.25; %fractional overlap
% electrodeSheet = 'EEG55';
% animalName = 'EEG55';
% ephysInfo.chanNums = 1:4; %brain ephys channels
% ephysInfo.recMode = 'EEG';
% ephysInfo.EMGchan = [];
% ephysInfo.chanLabels = {'AR','PR','PL','AL'}; %Labels for EEG channels
% 
% salineDate = '18n07'; 
% pars.expt(1).dataPath = [defaultPath animalName filesep salineDate filesep];
% pars.expt(1).exptDate = ['date' salineDate];
% pars.expt(1).exptIndex = {'000', '001','002','003','004'};
% pars.expt(1).timeReInj = -1:0.5:3.5;
% pars.expt(1).treatment = 'saline';
% pars.expt(1).dose = 0;
% 
% LPSDate = '18n09';
% pars.expt(2).dataPath = [defaultPath animalName filesep LPSDate filesep];
% pars.expt(2).exptDate = ['date' LPSDate];
% pars.expt(2).exptIndex = {'000','001','002','003','004'};
% pars.expt(2).timeReInj = -1:0.5:3; %hours re injection
% pars.expt(2).treatment = 'LPS';
% pars.expt(2).dose = 25;
% batchParams.(animalName) = fillBatchParams(pars,ephysInfo);
% clear pars ephysInfo
% 
% % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % % %EEG56 %1 is front right; 2 is rear right; 3 is rear left; 4 is front left
% pars.windowLength = 4; %sec
% pars.windowOverlap = 0.25; %fractional overlap
% electrodeSheet = 'EEG56';
% animalName = 'EEG56';
% ephysInfo.chanNums = 1:4; %brain ephys channels
% ephysInfo.recMode = 'EEG';
% ephysInfo.EMGchan = [];
% ephysInfo.chanLabels = {'AR','PR','PL','AL'}; %Labels for EEG channels
% 
% salineDate = '18n12'; 
% pars.expt(1).dataPath = [defaultPath animalName filesep salineDate filesep];
% pars.expt(1).exptDate = ['date' salineDate];
% pars.expt(1).exptIndex = {'000', '001','002','004','005'};
% pars.expt(1).timeReInj = -1:0.5:3.5;
% pars.expt(1).treatment = 'saline';
% pars.expt(1).dose = 0;

% LPSDate = '18n09';
% pars.expt(2).dataPath = [defaultPath animalName filesep LPSDate filesep];
% pars.expt(2).exptDate = ['date' LPSDate];
% pars.expt(2).exptIndex = {'000','001','002','003','004'};
% pars.expt(2).timeReInj = -1:0.5:3; %hours re injection
% pars.expt(2).treatment = 'LPS';
% pars.expt(2).dose = 25;
% batchParams.(animalName) = fillBatchParams(pars,ephysInfo);
% clear pars ephysInfo




