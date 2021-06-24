function saveBatchParamsAndEphysOut(gBatchParams,gMouseEphys_out)
% DESCRIPTION:
% Given: gBatchParams structure with animal data (all of one animal)
% 1. load the existing 'all animal' save file
% 2. add updated animal
% 3. save

specFile = EEGUtils.specFile;

if ~exist([specFile '.mat'],'file') % check if the .mat file exists
    warning([specFile ' does not exist! check path.'])
end

try
    load(specFile,'mouseEphys_out','batchParams'); % load file
catch
    warning([specFile ' not found. Creating new save file']);
end

gName = fieldnames(gBatchParams);
gName = gName{1,1};
dates = fieldnames(gMouseEphys_out.(gName));

batchParams.(gName).ephysInfo = gBatchParams.(gName).ephysInfo;

for iDate = 1:length(dates)
    thisDate = dates{iDate};
    batchParams.(gName).(thisDate) = gBatchParams.(gName).(thisDate);
    mouseEphys_out.(gName).(thisDate) = gMouseEphys_out.(gName).(thisDate);
end

save(specFile,'mouseEphys_out','batchParams');
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


