% Magnet analysis scripts

%% ==== Files =================================
% Run these, in this format, for each day
% This will move data files to where they need to be
% fileMaint_Mag('21514','Mag013','Mag014')
% fileMaint_Mag('21514','Mag015','Mag016')
% fileMaint_Mag('21514','Mag018','Mag019')
% fileMaint_Mag('21505','Mag016','Mag017')
% fileMaint_Mag('21506','Mag018','Mag019')
% fileMaint_Mag('21507','Mag010','Mag011')
% fileMaint_Mag('21507','Mag012','Mag013') %failed
% fileMaint_Mag('21507','Mag014','Mag015')

fileMaint('Mag015'); % new fileMaint as of 6/15/21

%% ==== Analysis ===============================
% Run this after each day or when a drug is done
% this finds and verifies HTR events and saves them
% User will need to select 'correct' events
%treatment = '6-FDET'; %treatment = 'DOI_conc';%treatment = '5-MeO-MiPT'; %treatment = 'Pyr-T'; %treatment = '4-AcO-DMT'; %treatment = '5-MeO-pyrT'; %treatment = '5,6-DiMeO-MiPT'; %treatment = '5-MeO-DET';

%treatment = 'Anlg_6_FDET'; 
%treatment = 'DOI_conc';
%treatment = 'Anlg_5_MeO_MiPT'; 
%treatment = 'Anlg_Pyr_T'; 
treatment = 'Anlg_4_AcO_DMT'; 
%treatment = 'Anlg_5_MeO_pyrT';
%treatment = 'Anlg_5_6_DiMeO_MiPT';
% treatment = 'Anlg_5_MeO_DET';

HTRPlotEventsScript(treatment);



%% ==== Plotting ================================
%treatment = '5-MeO-DET'; % use the treatment from above
selection = 1; % selection is a choice of drug combinations - we may need 
% to open up the method it uses to select combinations if there's a range of choices
% i.e., TODO: make this better
acceptedPermutations = [1,2]; % this is a selection of hours to use
HTRSummaryPlots(treatment,selection,acceptedPermutations)



