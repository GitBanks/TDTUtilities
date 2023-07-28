function collectSpectraDataFromExptList(setName)
% This will collect all the necessary data to make the boxplots of
% bandpower, and also set it up for the PSM version of the same.

% maybe we should make this a global reference in getPathGlobal instead of
% these switches
% setName = 'FLVX'
% setName = 'combined'
% setName = 'DOIKetanserin'
isLFP = false;

switch setName
    case 'FLVX' 
        tname = getPathGlobal([setName '-xlsTableGroupInfo']);
        saveFileName = getPathGlobal([setName '-matTableBandpower']);

    case '2020_PSYLOCYBIN_LPS'
%         tname = getPathGlobal([setName '-xlsTableGroupInfo']);
%         saveFileName = getPathGlobal([setName '-matTableBandpower']);
        error('you need to reedit this table before using it - add an ''include column'' for starters');

    case 'LPS2020' % untested - this is framework only
%         tname = getPathGlobal([setName '-xlsTableGroupInfo']);
%         saveFileName = getPathGlobal([setName '-matTableBandpower']);
        error('you need to reedit this table before using it - add an include column for starters');

    case 'Sigma1' % untested - this is framework only
        tname = getPathGlobal([setName '-xlsTableGroupInfo']);
        saveFileName = getPathGlobal([setName '-matTableBandpower']);

    case 'combined' % untested - this is framework only
        tname = getPathGlobal([setName '-xlsTableGroupInfo']);
        saveFileName = getPathGlobal([setName '-matTableBandpower']);

    case 'ZZ' % untested - this is framework only
        tname = getPathGlobal([setName '-xlsTableGroupInfo']);
        saveFileName = getPathGlobal([setName '-matTableBandpower']);

    case 'DOIKetanserin'
        tname = getPathGlobal([setName '-xlsTableGroupInfo']);
        saveFileName = getPathGlobal([setName '-matTableBandpower']);

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

    case 'DOIKetanserin'

    case 'ZZ'
        isLFP = true;
       
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
    if ~isLFP
        mattsData = plotSpectraEEG(animalName,exptDate,chansToExclude,setName,reportPlot,skipTheActualPlotting);
    else
        mattsData = plotSpectraLFP(animalName,exptDate,chansToExclude);
    end

    workingTable(ii).data = mattsData;
    % we're making PSM collection standard now.
    try
        fileNameCSVA = ['\\144.92.237.185\Data\PassiveEphys\AnimalData\' animalName '\PSM_' animalName '_' exptDate '_deltaPSM_matchedMovement_wMeanTDA.csv'];
        TA = readtable(fileNameCSVA);
        fileNameCSVP = ['\\144.92.237.185\Data\PassiveEphys\AnimalData\' animalName '\PSM_' animalName '_' exptDate '_deltaPSM_matchedMovement_wMeanTDP.csv'];
        TP = readtable(fileNameCSVP);
        workingTable(ii).data.pre.PSMavgDelta = [TA.grandMean(1),TP.grandMean(1)];
        workingTable(ii).data.post.PSMavgDelta = [TA.grandMean(2),TP.grandMean(2)];

        % TODO: add section for alpha **OR** better, load in a single table
        % if we figure out the R syntax

    catch
        disp([fileNameCSVA ' or P NOT FOUND']);
        disp(['Please run PSM R code on ' animalName ' ' exptDate]);
        error('STOPPING NOW!');
    end
end





save(saveFileName,"workingTable");


