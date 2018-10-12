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
updateStimInfoSynapse(exptDate,exptIndex);
close(dbConn);