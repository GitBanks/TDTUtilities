function [exptDate,exptIndex,exptIndexLast] = createNewNotebookEntryTDT(exptDescTemp,animalName)

% animalName = Animal Name
% exptIndexLast = this is used by calling program to track last index (the
% possibility exists another user got the sequential index, so simple
% incremental assignment won't do.
% exptDate = date 
% exptIndex = present index.  see: exptIndexLast above
% exptDescTemp = string, description of expt for db entry
% % listOfExperimentsRunToday = a cell array of the full experiment descriptions 
% % nExptsRecordedToday = an index for the above listOfExperimentsRunToday - to place

% exptDescTemp = 'this is a test. please ignore';
% animalName = 'EEGRoboMouse';
% exptIndexLast = -1;
% exptDate = '2019-02-12';
% exptIndex = '0';

dbConn = dbConnect(); % opens a database connection.  closed at bottom.
% it's possible a db object exists so this is redundant, so we might want
% to check for it, or require it as a parameter?  but for now, no big deal.


% !!!TODO!!!
% set this up so that if exptDescTemp doesn't exist, it will behave like 'repeatlastexpt()'
% if animalName doesn't exist, it will behave like 'repeatlastexpt()', but use the last animal (from the very last expt
% and exptIndexLast,exptDate,exptIndex are only needed in specific cases.

if ~exist('exptDescTemp','var')
    error('Need animal name');
end

if ~exist('animalName','var')
    error('Need animal name');
end



lastEntryID = fetch(dbConn,'SELECT MAX(exptID) FROM masterexpt');
hardware = 'TDT'; %this is always a TDT specific program.
grandExpt = 'PassiveEphys'; %this is another assumption
animalID = fetch(dbConn,['SELECT animalID FROM animals WHERE animalName=''' animalName '''']);
% find the last date and index in the notebook


if isVersionNewerThan(8.5)
if istable(lastEntryID)
    lastEntryID = table2cell(lastEntryID);
end
if istable(animalID)
    animalID = table2cell(animalID);
end
end

exptDate = fetch(dbConn,['SELECT exptDate FROM masterexpt WHERE exptID=' num2str(lastEntryID{1})]);
exptIndex = fetch(dbConn,['SELECT exptIndex FROM masterexpt WHERE exptID=' num2str(lastEntryID{1})]);
experimenterID = fetch(dbConn,['SELECT experimenterID FROM masterexpt WHERE exptID= ''' num2str(lastEntryID{1}) '''']);
if isVersionNewerThan(8.5)
if istable(exptDate)
    exptDate = table2cell(exptDate);
end
if istable(exptIndex)
    exptIndex = table2cell(exptIndex);
end
if istable(experimenterID)
    experimenterID = table2cell(experimenterID);
end
end

% check today's date, make sure if date is different index is reset
if isequal(houseTodayDateIn_dbForm,exptDate{1})
    exptIndexLast = exptIndex{1};
    exptDate = exptDate{1};
    exptIndex = exptIndex{1}+1;
else
    exptDate = houseTodayDateIn_dbForm;
    exptIndex = 0;
    exptIndexLast = [];
end
thisID = lastEntryID{1}+1;
% == Add the main information
addNotebookEntry = ['INSERT INTO masterexpt (exptIndex, hardware, grandExpt,'...
    'exptDate, animalID, experimenterID) VALUES (' num2str(exptIndex) ','''...
    hardware ''',''' grandExpt ''',''' exptDate ''',' num2str(animalID{:})...
    ',' num2str(experimenterID{:}) ')'];
% == Add the details
SQLdetail_ephys = fetch(dbConn,['SELECT * FROM detail_ephys WHERE exptID= ''' num2str(lastEntryID{1}) '''']);
if isVersionNewerThan(8.5)
if istable(SQLdetail_ephys)
    SQLdetail_ephys = table2cell(SQLdetail_ephys);
end
end
exptID = num2str(thisID);
if ~isempty(SQLdetail_ephys)
    filter_lowcut = num2str(SQLdetail_ephys{3});
    filter_highcut = num2str(SQLdetail_ephys{4});
    amp_gain = num2str(SQLdetail_ephys{5});
    sample_freq = num2str(SQLdetail_ephys{6});
    chamber = num2str(SQLdetail_ephys{7});
    headstage = num2str(SQLdetail_ephys{8});
    preamp = num2str(SQLdetail_ephys{10});
    spkrCenter = num2str(SQLdetail_ephys{13});
    recordingBox = num2str(SQLdetail_ephys{14});
else  %defaults... not sure if this is correct
    filter_lowcut = '0.2';
    filter_highcut = '8545'; % default
    amp_gain = '1'; % according to TDT, Synapse output is saved at 'unity' gain
    sample_freq = '24414'; % default
    chamber = 'Bottom';
    headstage = 'ZC16';
    preamp = 'PZ5';
    spkrCenter = 'blank';
    recordingBox = 'blank';
end
addDetailEphys = ['INSERT INTO detail_ephys (exptID,filter_lowcut,filter'...
    '_highcut,amp_gain,sample_freq,chamber,headstage,preamp,spkrCenter,'...
    'recordingBox) VALUES (' exptID ',' filter_lowcut ...
    ',' filter_highcut ',' amp_gain ','...
    sample_freq ',''' chamber ''','''...
    headstage ''',''' preamp ''','''...
    spkrCenter ''',''' recordingBox ''')'];
addDescription = ['UPDATE masterexpt SET notebookDesc= ''' ...
    exptDescTemp ''' WHERE exptID= '''...
    num2str(thisID) ''''];
display(['Description will be: ' exptDescTemp ' Be sure you are happy with that']);
%! we're editing the notebook here!!! be careful when changing syntax!
exec(dbConn,addNotebookEntry);
exec(dbConn,addDetailEphys);
exec(dbConn,addDescription);

close(dbConn);