function [p] = getPathGlobal(str)
% Description: a function to help avoid hardcoding important file
% directories. Save a copy locally on your machine and don't add to the git
% repository. Based on a function used in the Banks Lab ECoG code.

% Necessary for runEEGAnalysis scripts.

% original: ZS November 2021
% this version: SG Jan 2022

% W = '\\144.92.218.131\Data\Data\';
W = '\\128.104.83.123\BanksData\Data\'; %Username: ANESFS3\BanksLab %Password: WIb3cZFbXR
W = '\\128.104.83.123\BanksData\Data\';
M = '\\144.92.237.185\Data\';
REC = '144.92.237.183'; % Gilgamesh % avoid network formatting \\ and \ for REC because some input requires just the numbers here
%REC = '144.92.237.187'; % Nessus
SQL = '144.92.237.180';

switch str
    % root level locations, multiple reference options
    case 'W'
        p = W;
    case 'rawData'
        p = W;
    case 'V'
        p = W;
    case 'MemoryBanks'
        p = M;
    case 'M'
        p = M;
    case 'REC'
        p = REC;
    case 'SQL'
        p = SQL;
        
    % for directories
    case 'importedData'
        p = [M 'PassiveEphys\'];
    case 'analyzedData'
        p = [W 'PassiveEphys\EEG animal data\'];
    case 'stats'
        p = [M 'Ziyad\Psychedelics\EEG\DataTables\'];
    case 'figures'
        p = [M 'Ziyad\Psychedelics\EEG\Figures'];
    case 'animalSaves'
        p = [M 'PassiveEphys\AnimalData\'];
        
    % for specific file paths (old)
    case 'masterLog'
        p = [W 'PassiveEphys\EEG animal data\Mouse Psychedelics Master Log.xlsx'];
    case 'bandPow'
        p = [W 'PassiveEphys\EEG animal data\mouseEphys_out_psychedelics.mat'];
    case '4secPSD'
        p = [W 'PassiveEphys\EEG animal data\mouseEphys_out_ft_4secPSD'];
    case 'wPLI'
        p = [W 'PassiveEphys\EEG animal data\mouseEphys_conn_dbt_noParse_20sWin_0p5sTrial_psychedelics.mat'];
    
    otherwise
        disp('wtf nothing assigned');
end
end