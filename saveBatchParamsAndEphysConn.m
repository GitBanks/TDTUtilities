function saveBatchParamsAndEphysConn(gBatchParams,gMouseEphys_conn)
% only processes one animal

% Given: gBatchParams structure with animal data (all of one animal)
% 1. load the existing 'all animal' save file
% 2. add updated animal
% 3. save

% Hardcoded :( please consider making a config file...
outFileName = 'mouseEphys_conn_dbt_noParse_20sWin_0p5sTrial_psychedelics.mat';
computerSpecPath = '\\144.92.218.131\Data\Data\PassiveEphys\EEG animal data\';
% if ~exist([computerSpecPath outFileName],'file')
try
    load([computerSpecPath outFileName],'mouseEphys_conn','batchParams');
catch
    warning([outFileName ' does not exist! check path.'])
end

gName = fieldnames(gBatchParams);
gName = gName{1,1};

%check for multiple dates in gBatchParams
batchDates = fieldnames(gBatchParams.(gName));
batchDates = batchDates(contains(batchDates,'date'));
ephysDates = fieldnames(gMouseEphys_conn.WPLI.(gName));
eDates = intersect(batchDates,ephysDates);

% animals = fieldnames(batchParams);

batchParams.(gName).ephysInfo = gBatchParams.(gName).ephysInfo;

for iDate = 1:length(eDates)
    thisDate = eDates{iDate};
    batchParams.(gName).(thisDate) = gBatchParams.(gName).(thisDate);
    mouseEphys_conn.WPLI.(gName).(thisDate) = gMouseEphys_conn.WPLI.(gName).(thisDate);
end
save([computerSpecPath outFileName],'mouseEphys_conn','batchParams');
disp('mouseEphys_conn and batchParams saved!');

%WIP 18d07 ZS
% sNames = fieldnames(mouseEphys_conn.WPLI);
% if ismember(gName,sNames) 
    %If the animal is already part of the ephys_conn structure, 
    % then the following code should make sure not to save over previous dates
%     tempNames = fieldnames(gBatchParams.(gName));
%     gDates = tempNames(contains(tempNames,'date'));
% %     sDates = fieldnames(mouseEphys_conn.WPLI.EEG57);
%     addThisDate = gDates(~ismember(gDates,sDates));
%     
%     batchParams.(gName).(addThisDate{:}) = gBatchParams.(gName);
%     mouseEphys_conn.WPLI.(gName).(addThisDate{:}) = gMouseEphys_conn.WPLI.(gName);
% else
%     batchParams.(gName) = gBatchParams.(gName);
%     mouseEphys_conn.WPLI.(gName) = gMouseEphys_conn.WPLI.(gName);
% end


% sNames = fieldnames(batchParams);
% % Check whether the animal list from the generated batchParams is the
% % same as the animal list from the saved batchParams.
% newGenIndx = ~ismember(gName,sNames);
% if sum(newGenIndx)>0
%     % Add these new animal to the saved batchParams if it isn't in there
%     newGenAnimal = gName(newGenIndx);
%     batchParams.(newGenAnimal) = gBatchParams.(newGenAnimal);
% end

% template for structure in case we want to run only selected days (for
% speed) - will need to make this change in mouseDelirium_specAnalysis_Synapse(animalName)
% mouseEphys_out.(thisName).(thisDate).(thisExpt).trialsKept = theseTrials





