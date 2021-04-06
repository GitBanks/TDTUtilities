function repeatLastExperiment()


        
        

%%%%RepeatLastExperiment
dbConn = dbConnect();
% == Find appropriate place to put new entry
% The following will get the last notebook SQL entry
%lastEntry = fetchAdjust(dbConn,'SELECT * FROM masterexpt ORDER BY exptID DESC LIMIT 1');
% lastEntryID = fetchAdjust(dbConn,'SELECT MAX(exptID) FROM masterexpt');
% lastEntry = fetchAdjust(dbConn,['SELECT * FROM masterexpt WHERE exptID= ''' num2str(lastEntryID{1}) '''']);
% .
% .
% .
%for some reason, * isn't working with masterexpt... no idea why.  It's
%really pissing me off, so I'll just load them 1 by 1
lastEntryID = fetchAdjust(dbConn,'SELECT MAX(exptID) FROM masterexpt');
hardware = fetchAdjust(dbConn,['SELECT hardware FROM masterexpt WHERE exptID=' num2str(lastEntryID{1})]);
grandExpt = fetchAdjust(dbConn,['SELECT grandExpt FROM masterexpt WHERE exptID=' num2str(lastEntryID{1})]);
animalID = fetchAdjust(dbConn,['SELECT animalID FROM masterexpt WHERE exptID=' num2str(lastEntryID{1})]);
exptDate = fetchAdjust(dbConn,['SELECT exptDate FROM masterexpt WHERE exptID=' num2str(lastEntryID{1})]);
exptIndex = fetchAdjust(dbConn,['SELECT exptIndex FROM masterexpt WHERE exptID=' num2str(lastEntryID{1})]);
experimenterID = fetchAdjust(dbConn,['SELECT experimenterID FROM masterexpt WHERE exptID= ''' num2str(lastEntryID{1}) '''']);
 
% == Add the main information
% check date, make sure if date is different index is reset
if isequal(houseTodayDateIn_dbForm,exptDate{1})
    thisDate = exptDate{1};
    thisIndex = exptIndex{1}+1;
else
    thisDate = houseTodayDateIn_dbForm;
    thisIndex = 0;
end

thisID = lastEntryID{1}+1;
% addNotebookEntry = ['INSERT INTO masterexpt (exptIndex, hardware, grandExpt, exptDate, animalID, experimenterID) VALUES (' num2str(thisIndex) ',''' lastEntry{5} ''',''' lastEntry{6} ''',''' thisDate ''',' num2str(lastEntry{8}) ',2)'];
addNotebookEntry = ['INSERT INTO masterexpt (exptIndex, hardware, grandExpt, exptDate, animalID, experimenterID) VALUES (' num2str(thisIndex) ',''' hardware{1} ''',''' grandExpt{1} ''',''' thisDate ''',' num2str(animalID{:}) ',' num2str(experimenterID{:}) ')'];
exec(dbConn,addNotebookEntry);

%Add a check to be sure we did it correctly
%thisEntry = fetchAdjust(dbConn,'SELECT * FROM masterexpt ORDER BY exptID DESC LIMIT 1');
% the above line doesn't work for some reason.  May not like incomplete
% entries?

% == Add the details
SQLdetail_ephys = fetchAdjust(dbConn,['SELECT * FROM detail_ephys WHERE exptID= ''' num2str(lastEntryID{1}) '''']);
addDetailEphys = ['INSERT INTO detail_ephys (exptID,filter_lowcut,filter_highcut,amp_gain,sample_freq,chamber,headstage,preamp,spkrCenter,recordingBox) VALUES (' num2str(thisID) ',' num2str(SQLdetail_ephys{3}) ',' num2str(SQLdetail_ephys{4}) ',' num2str(SQLdetail_ephys{5}) ',' num2str(SQLdetail_ephys{6}) ',''' num2str(SQLdetail_ephys{7}) ''',''' num2str(SQLdetail_ephys{8}) ''',''' num2str(SQLdetail_ephys{10}) ''',''' SQLdetail_ephys{13} ''',''' SQLdetail_ephys{14} ''')'];    
exec(dbConn,addDetailEphys);

% == Make sure description makes sense
% check to see if it's a linked expt.  We may not want that link info
% because it will interfere with split32
SQLdescription = fetchAdjust(dbConn,['SELECT notebookDesc FROM masterexpt WHERE exptID= ''' num2str(lastEntryID{1}) '''']);
if ~isempty(strfind(SQLdescription{1},'xLINK'))
    %warning, if notebook ids have skipped around, this will throw an error
    %if making 
    addDescription = fetchAdjust(dbConn,['SELECT notebookDesc FROM masterexpt WHERE exptID= ''' num2str(lastEntryID{1}-1) '''']);
    addDescription = ['UPDATE masterexpt SET notebookDesc= ''' addDescription{1}(1:strfind(SQLdescription{1},'xLINK')-1) ''' WHERE exptID= ''' num2str(thisID) ''''];
else
    addDescription = ['UPDATE masterexpt SET notebookDesc= ''' SQLdescription{1} ''' WHERE exptID= ''' num2str(thisID) ''''];
end
display(['Description will be: ' addDescription ' Be sure you are happy with that']);
exec(dbConn,addDescription);


% == Add global stim params
%TODO: check if first expt - if so, ignore drug info?
SQLGlobalStimParams = fetchAdjust(dbConn,['SELECT * FROM  global_stimparams WHERE exptID= ''' num2str(lastEntryID{1}) '''']);
if isempty(SQLGlobalStimParams) == 1 || isempty(SQLGlobalStimParams{3}) || isempty(SQLGlobalStimParams{4}) == 1
    display('Drug information missing.  Is this a drug day?');
%     drugChoice = questdlg('No drug information found.  Is this a drug day?',...
%             'Drug day?',...
%             'Yes','No','Yes');
%     if strcmp(drugChoice,'Yes') == 1
%         error('Drug information missing. please fill it in');
%     end
else
    addGlobalStimParams = ['INSERT INTO global_stimparams (exptID, paramfield, paramvalue) VALUES (' num2str(thisID) ',''' SQLGlobalStimParams{3} ''',' num2str(SQLGlobalStimParams{4}) ')'];
    exec(dbConn,addGlobalStimParams);
end                                   


close(dbConn);



end