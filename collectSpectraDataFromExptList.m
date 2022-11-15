function collectSpectraDataFromExptList(setName)
% This will collect all the necessary data to make the boxplots of
% bandpower, and also set it up for the PSM version of the same.

% maybe we should make this a global reference in getPathGlobal instead of
% these switches
% setName = 'FLVX'

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
workingTable = getExptSummaryFromTable(tname,true);
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
       
    case 'ZZ'
       
    otherwise
        error('Need an appropriate table name from a recognized list: ''FLVX'' or ''LPS2020'' or ''ZZ'' so far ');
end


for ii = 1:size(workingTable,2)
    animalName = workingTable(ii).Animal;
    exptDate = workingTable(ii).Date;
    chansToExclude = workingTable(ii).ChansToExclude;
    mattsData = plotSpectraEEG(animalName,exptDate,chansToExclude,setName);
    workingTable(ii).data = mattsData;
end





save(saveFileName,"workingTable");


