function [p] = getPathGlobal(str)
% Description: a function to help avoid hardcoding important file
% directories. Save a copy locally on your machine and don't add to the git
% repository. Based on a function used in the Banks Lab ECoG code.

% Necessary for runEEGAnalysis scripts.

% original: ZS November 2021
% this version: SG Jan 2022

% W = '\\144.92.218.131\Data\Data\';
W = '\\128.104.83.123\BanksData\Data\'; %Username: ANESFS3\BanksLab %Password: WIb3cZFbXR
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
        p = [M 'Ziyad\Psychedelics\EEG\DataTables\']; % please don't code in specific project names like this
    case 'figures'
        p = [M 'Ziyad\Psychedelics\EEG\Figures']; % or this
    case 'animalSaves'
        p = [M 'PassiveEphys\AnimalData\'];
    case 'pipelineSaves'
        p = [M 'PassiveEphys\AnimalData\initial\'];
    case 'banksLocalHTRData'
        p = [M 'PassiveEphys\AnimalData\HTRDrugGroupList.xlsx']; % using the animal saves location

    % group references
    % xlsTableGroupInfo is an xls table of a specific group of mice - this 
    % will be used in bandpower comparisons between groups, but can also be
    % useful in other programs.
    % matTableBandpower is a matlab format bandbower data for use in
    % comparison plotting
    case 'FLVX-xlsTableGroupInfo'
        p = [M 'PassiveEphys\mouseEEG\FLVXGroupInfo.xlsx'];
    case 'FLVX-matTableBandpower'
        p = [M 'PassiveEphys\mouseEEG\FLVXBandpowerData.mat'];

    case '2020_PSYLOCYBIN_LPS-xlsTableGroupInfo'
        p = [M 'PassiveEphys\mouseEEG\2020PsilocybinLPSGroupInfo.xlsx'];
    case '2020_PSYLOCYBIN_LPS-matTableBandpower'
        p = [M 'PassiveEphys\mouseEEG\2020PsilocybinLPSBandpowerData.mat'];

    case 'LPS2020-xlsTableGroupInfo'
        p = [M 'PassiveEphys\mouseEEG\mouseGroupInfo.xlsx'];
    case 'LPS2020-matTableBandpower'
        p = [M 'PassiveEphys\mouseEEG\LPS2020BandpowerData.mat'];

    case 'Sigma1-xlsTableGroupInfo'
        p = [M 'PassiveEphys\mouseEEG\Sigma1GroupInfo.xlsx'];
    case 'Sigma1-matTableBandpower'
        p = [M 'PassiveEphys\mouseEEG\Sigma1BandpowerData.mat'];

    case 'combined-xlsTableGroupInfo'
        p = [M 'PassiveEphys\mouseEEG\combinedGroupInfo.xlsx'];
    case 'combined-matTableBandpower'
        p = [M 'PassiveEphys\mouseEEG\combinedBandpowerData.mat'];

    case 'ZZ-xlsTableGroupInfo'
        p = [M 'PassiveEphys\mouseLFP\ZZGroupInfo.xlsx'];
    case 'ZZ-matTableBandpower'
        p = [M 'PassiveEphys\mouseLFP\ZZBandpowerData.mat'];
  


    % for specific file paths (old)
    case 'masterLog'
        p = [W 'PassiveEphys\EEG animal data\Mouse Psychedelics Master Log.xlsx'];
    case 'bandPow'
        p = [W 'PassiveEphys\EEG animal data\mouseEphys_out_psychedelics.mat'];
    case '4secPSD'
        p = [W 'PassiveEphys\EEG animal data\mouseEphys_out_ft_4secPSD'];
    case 'wPLI'
        p = [W 'PassiveEphys\EEG animal data\mouseEphys_conn_dbt_noParse_20sWin_0p5sTrial_psychedelics.mat'];

    % Cody's lab paths !!! this is local, not global!!!   
    case 'CodyLocalHTRDataSource'
        p = 'C:\Users\soplab\Documents\Molecular Devices\pCLAMP\Data\';
    case 'CodyLocalHTRDataSave'
        p = 'C:\WenthurLab\Data\';
    case 'CodyLocalMetaDataSave'
        p = 'C:\WenthurLab\Data\HTR-2022-mouse-DMT.xlsx';
    case 'CodyLocalHTRData'
        p = 'C:\Users\Matt Banks\Documents\Molecular Devices\pCLAMP\Data\';

    otherwise
        disp('wtf nothing assigned');
end
end