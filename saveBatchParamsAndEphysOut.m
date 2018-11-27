function saveBatchParamsAndEphysOut(gBatchParams,gMouseEphys_out)
% only processes one animal


% Hardcoded :( please consider making a config file...
outFileName = 'mouseEphys_out_noParse.mat';
computerSpecPath = '\\144.92.218.131\Data\Data\PassiveEphys\EEG animal data\';


% % what are these?
% gBehavParams = mouseDelirium_getBehavParams(behavPath);
% gBehavNames = fieldnames(gBehavParams);



gName = fieldnames(gBatchParams);
gName = gName{1,1};

% Given: gBatchParams structure with animal data (all of one animal)
% 1. load the existing 'all animal' save file
% 2. add updated animal
% 3. save



if ~exist([computerSpecPath outFileName],'file')
    error([outFileName ' does not exist! check path.'])
end


% this take like 30 sec to load... is this sustainable?
load([computerSpecPath outFileName],'mouseEphys_out','batchParams','behavParams');


% sNames = fieldnames(batchParams);
% % Check whether the animal list from the generated batchParams is the
% % same as the animal list from the saved batchParams.
% newGenIndx = ~ismember(gName,sNames);
% if sum(newGenIndx)>0
%     % Add these new animal to the saved batchParams if it isn't in there
%     newGenAnimal = gName(newGenIndx);
%     batchParams.(newGenAnimal) = gBatchParams.(newGenAnimal);
% end


batchParams.(gName) = gBatchParams.(gName);

mouseEphys_out.(gName) = gMouseEphys_out.(gName);


% template for structure in case we want to run only selected days (for
% speed) - will need to make this change in mouseDelirium_specAnalysis_Synapse(animalName)
% mouseEphys_out.(thisName).(thisDate).(thisExpt).trialsKept = theseTrials




save([computerSpecPath outFileName],'mouseEphys_out','batchParams','behavParams');


