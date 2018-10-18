function setGlobalStimParams(exptDate,exptIndex,globalParNames,globalParVals)
% test params
% exptDate = '18907'
% exptIndex = '001'
% globalParNames = 'CNO_conc';
% globalParVals = 0;
if iscell(globalParNames)
    globalParNames = globalParNames{1};
end
dbConn = dbConnect(); %handle this better?  close db at end?
masterResult = fetch(dbConn,['select exptID from masterexpt where exptDate=''' houseConvertDateTo_dbForm(exptDate) ''' and exptIndex=' num2str(str2num(exptIndex))]);
exptID = masterResult{1,1};
insertGlobalStimParams = ['insert into global_stimparams (exptID,paramfield,paramvalue) values (' num2str(exptID)  ','''  globalParNames ''',' num2str(globalParVals) ')'];
exec(dbConn,insertGlobalStimParams);
try
    updateStimInfoSynapse(exptDate,exptIndex);
catch
    % Data must be handled differently pre-synapse = I didn't write
    % anything for the Brainware data yet.
    display('Error updating stim table with new global stim params.  Data must be handled differently pre-synapse.  Try reimporting.')
end
close(dbConn);