function collectSpectraDataFromExptList(setName)
% This will collect all the necessary data to make the boxplots of
% bandpower, and also set it up for the PSM version of the same.

% maybe we should make this a global reference in getPathGlobal instead of
% these switches
% setName = 'FLVX'
% setName = 'combined'

switch setName
    case 'FLVX' % working
        tname = 'M:\PassiveEphys\mouseEEG\FLVXGroupInfo.xlsx';
        saveFileName = 'M:\PassiveEphys\mouseEEG\FLVXBandpowerData.mat';

    case '2020_PSYLOCYBIN_LPS'
        tname = 'M:\PassiveEphys\mouseEEG\2020PsilocybinLPSGroupInfo.xlsx';
        saveFileName = 'M:\PassiveEphys\mouseEEG\2020PsilocybinLPSBandpowerData.mat';

    case 'LPS2020' % untested - this is framework only
        tname = 'M:\PassiveEphys\mouseEEG\mouseGroupInfo.xlsx';
        saveFileName = 'M:\PassiveEphys\mouseEEG\LPS2020BandpowerData.mat';

    case 'Sigma1' % untested - this is framework only
        tname = 'M:\PassiveEphys\mouseEEG\Sigma1GroupInfo.xlsx';
        saveFileName = 'M:\PassiveEphys\mouseEEG\Sigma1BandpowerData.mat';

    case 'combined' % untested - this is framework only
        tname = 'M:\PassiveEphys\mouseEEG\combinedGroupInfo.xlsx';
        saveFileName = 'M:\PassiveEphys\mouseEEG\combinedBandpowerData.mat';

    case 'ZZ' % untested - this is framework only
        tname = 'M:\PassiveEphys\mouseEEG\ZZGroupInfo.xlsx';
        saveFileName = 'M:\PassiveEphys\mouseEEG\ZZBandpowerData.mat';
        disp('If you tried using ZZ here - if you see this message, be sure the xls file exists, then take out this disp and keyboard statements.  This entry here is only to show how to add ZZ data to this switch')
        keyboard

    otherwise
        error('Need an appropriate table name from a recognized list: ''FLVX'' or ''LPS2020'' or ''ZZ'' so far ');

end

% this will take a while since it loads movement for each day in addition
% to the drug info, etc.
disp('Loading movement for:');
workingTable = getExptSummaryFromTable(tname);
% Trim workingTable into just the 'approved' experiments

switch setName
    case 'FLVX'
        % % ===== assign mice into group numbers based on treatment =====
        % add a little thing to assign a group to the mice using
        % workingTable(1).data.TheseDrugs.what
        for ii = 1:size(workingTable,2)
            workingTable(ii).group = nan;
            if contains(workingTable(ii).drugTOD(1).what,'Fluvoxamine')
                workingTable(ii).group = 3;
            else
                if contains(workingTable(ii).drugTOD(2).what,'LPS')
                    workingTable(ii).group = 2;
                end
                if contains(workingTable(ii).drugTOD(2).what,'saline')
                    workingTable(ii).group = 1;
                end
            end
        end

    case '2020_PSYLOCYBIN_LPS'
        % % ===== assign mice into group numbers based on treatment =====
        % add a little thing to assign a group to the mice using
        % workingTable(1).data.TheseDrugs.what
        for ii = 1:size(workingTable,2)
            workingTable(ii).group = nan;
            if contains(workingTable(ii).drugTOD(1).what,'saline')
                workingTable(ii).group = 1;
            else
                if size(workingTable(ii).drugTOD,2) == 2 % only true in this case for LPS condition
                    workingTable(ii).group = 3;
                else
%                 if contains(workingTable(ii).drugTOD(1).what,'psilocybin')
                    workingTable(ii).group = 2;
                end

            end
        end

    case 'LPS2020'

    case 'Sigma1'
%         for ii = 1:size(workingTable,2)
%             workingTable(ii).group
%         end
        % we've added a .group assignment a few levels above this, so just
        % pass those values along
%         for ii = 1:size(workingTable,2)
%             workingTable(ii).group = nan;
%             if contains(workingTable(ii).drugTOD(1).what,'saline')
%                 workingTable(ii).group = 1;
%             end
%         end
    case 'combined'

    case 'ZZ'
       
    otherwise
        error('Need an appropriate table name from a recognized list: ''FLVX'' or ''LPS2020'' or ''ZZ'' so far ');
end


disp('Loading spectra data for:');
for ii = 1:size(workingTable,2)
    animalName = workingTable(ii).Animal;
    exptDate = workingTable(ii).Date;
    disp([animalName ' ' exptDate]);
    chansToExclude = workingTable(ii).ChansToExclude;
    reportPlot = false;
    skipTheActualPlotting = true;
    mattsData = plotSpectraEEG(animalName,exptDate,chansToExclude,setName,reportPlot,skipTheActualPlotting);
    workingTable(ii).data = mattsData;
end





save(saveFileName,"workingTable");


