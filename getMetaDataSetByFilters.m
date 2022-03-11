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
overWrite = false; % toggle this if we've added recordings to animals

animalName = o.Subjects; %only set to run one mouse - runAnalysis is set to run on multiple
if ~isempty(o.Blocks)
    error('Not presently configured to handle blocks')    
end
    

o.Conditions %e.g.


% Do we want to try loading an existing?
[metaDataMouse] = getMetaDataByAnimal(animalName,overWrite);

recordingSelection = o.Conditions;
drugSelection = o.Conditions;


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
%     finalOutputTable.refTime(i) = tempTable.refTime(joinThese,:);
%     finalOutputTable.blockTime(i) = tempTable.blockTime(joinThese,:);
    finalOutputTable.ECoGchannels(i) = tempTable.ECoGchannels(i);
    finalOutputTable.electrodeRev(i) = tempTable.electrodeRev(i);
end



% Table Differences
% 1. optional: clean up block + condition so we only see unique strings
% 2. EcogChannels format
% 3.......I think thats it!!












    
    