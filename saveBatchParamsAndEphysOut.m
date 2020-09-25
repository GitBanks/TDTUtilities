function saveBatchParamsAndEphysOut(gBatchParams,gMouseEphys_out)
% DESCRIPTION:
% Given: gBatchParams structure with animal data (all of one animal)
% 1. load the existing 'all animal' save file
% 2. add updated animal
% 3. save

% Hardcoded :( please consider making a config file...
outFileName = 'mouseEphys_out_psychedelics_extendedDelta.mat';
computerSpecPath = '\\144.92.218.131\Data\Data\PassiveEphys\EEG animal data\';

% if ~exist([computerSpecPath outFileName],'file')
%     error([outFileName ' does not exist! check path.'])
% end
try
    load([computerSpecPath outFileName],'mouseEphys_out','batchParams');
catch
    warning([computerSpecPath outFileName ' not found. Creating new save file']);
end

gName = fieldnames(gBatchParams);
gName = gName{1,1};
dates = fieldnames(gMouseEphys_out.(gName));

batchParams.(gName).ephysInfo = gBatchParams.(gName).ephysInfo;
% batchParams.(gName).bandInfo = gBatchParams.(gName).bandInfo;
batchParams.(gName).windowLength = gBatchParams.(gName).windowLength;
batchParams.(gName).windowOverlap = gBatchParams.(gName).windowOverlap;

for iDate = 1:length(dates)
    thisDate = dates{iDate};
    batchParams.(gName).(thisDate) = gBatchParams.(gName).(thisDate);
    mouseEphys_out.(gName).(thisDate) = gMouseEphys_out.(gName).(thisDate);
end

save([computerSpecPath outFileName],'mouseEphys_out','batchParams');
disp('mouseEphys_out and batchParams saved!');


% OLD: 
% % what are these?
% gBehavParams = mouseDelirium_getBehavParams(behavPath);
% gBehavNames = fieldnames(gBehavParams);
% sNames = fieldnames(batchParams);
% % Check whether the animal list from the generated batchParams is the
% % same as the animal list from the saved batchParams.
% newGenIndx = ~ismember(gName,sNames);
% if sum(newGenIndx)>0
%     % Add these new animal to the saved batchParams if it isn't in there
%     newGenAnimal = gName(newGenIndx);
%     batchParams.(newGenAnimal) = gBatchParams.(newGenAnimal);
% end


