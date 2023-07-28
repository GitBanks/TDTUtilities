function finalOutputTable = getMetaDataSetByFilters(o)
% TODO
% we need to take the 'metaData' produced by getMetaDataByAnimal and filter
% / find specific experiments of interest.  These could be drug type, stim
% type, etc.  (we might incorporate this into getMetaDataByAnimal, but
% we're starting with a standalone thing that calls it)


% given: metaData
% Do: filter through metaData.conditions for keywords

% drugSelection = {'saline','psilocybin'};
% recordingSelection = {'Spon'};


% drugSelection = {'NoDrug'};
% recordingSelection = {'Stim'};
% drugSelection = {'NoDrug'};
% recordingSelection = {'Spon'};

% animalName = 'ZZ14';
% overWrite = false;

% instead of this full range, we want to allow a single parameter/structure
% as input
% drugSelection,recordingSelection,animalName,overWrite



animalName = o.Subjects; %only set to run one mouse - runAnalysis is set to run on multiple
if iscell(animalName)
    animalName = animalName{1};
end
% Do we want to try loading an existing?
overWrite = true; % toggle this if we've added recordings to animals
[metaDataMouse] = getMetaDataByAnimal(animalName,overWrite);


if ~isempty(o.Blocks) && ~isempty(o.Conditions)
    error('use either Conditions or Blocks, but not both for mouse data')
    %error(['Subjects'',{''EEG220''},''Conditions'',{''saline','Inj''}'])
end

if ~isempty(o.Blocks)
    useThese = contains(metaDataMouse.block,o.Blocks);
    tempTable = metaDataMouse(useThese,:);
end
    
if ~isempty(o.Conditions)
    recordingSelection = o.Conditions(1);  %shitty hardcode for now.  TODO fix this!
    drugSelection = o.Conditions(2);
    tempTableIteration = 1;
    for i = 1:size(metaDataMouse,1)
        if contains(metaDataMouse.conditions(i),recordingSelection)
            for ii = 1:size(drugSelection,2)
                if contains(metaDataMouse.conditions(i),drugSelection(ii))
                    tempTable(tempTableIteration,:) = metaDataMouse(i,:);
                    tempTableIteration = tempTableIteration + 1;
                end
            end
        end
    end
end



% now that we have newTable with just the selection of interest, we need to
% combine indices on the same row (each row should represent an experiment
% / manipulation)
% first, find the unique experiment days (this assumes there will not be
% two experiments on any day)
for i = 1:size(tempTable,1)
    daysInBlock(i,:) = char(tempTable.block(i));
    justDates(i,:) = {daysInBlock(i,1:5)};
end
uniqueDates = unique(justDates);

% create a new empty table with all the same parameters
finalOutputTable = tempTable;
finalOutputTable(logical(1:size(finalOutputTable,1)),:) = [];


% refTime = cell(1,joinSize);
% blockTime = cell(1,joinSize);

for i = 1:size(uniqueDates,1)
    joinThese = contains(tempTable.block,uniqueDates{i});
    finalOutputTable.block(i) = join(tempTable.block(joinThese,:),',');
    finalOutputTable.conditions(i) = join(tempTable.conditions(joinThese,:),','); 
    finalOutputTable.electrodeSheet(i) = tempTable.electrodeSheet(i);
    finalOutputTable.dataPrefix(i) = tempTable.dataPrefix(i);
    finalOutputTable.dateTime(i) = join(tempTable.dateTime(joinThese,:),',');
    finalOutputTable.startMin(i) = NaT;
    finalOutputTable.stopMin(i) = NaT;
%     finalOutputTable.startMin(i) = join(tempTable.startMin(joinThese,:),',');
%     finalOutputTable.stopMin(i) = join(tempTable.stopMin(joinThese,:),',');  
    finalOutputTable.timePostOp(i) = ''; 
    finalOutputTable.patientID(i) = tempTable.patientID(i);
%     blockTime{iRow}(iBlock) = refTime{iRow}
    blockTime{i} = tempTable.blockTime(joinThese);
    finalOutputTable.ECoGchannels(i) = tempTable.ECoGchannels(i);
    finalOutputTable.electrodeRev(i) = tempTable.electrodeRev(i);
end

finalOutputTable.refTime = {tempTable.refTime(joinThese(1))};
finalOutputTable.blockTime = blockTime;


% Table Differences
% 1. optional: clean up block + condition so we only see unique strings
% 2. EcogChannels format
% 3.......I think thats it!!












    
    