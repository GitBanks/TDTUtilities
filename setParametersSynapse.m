% setParametersSynapse

% STUB, WIP, for adding 'stim params' from synapse.



% test params
animalName = 'DREADD07';
exptDate = '18907';

[operationList] = getExperimentsByAnimalAndDate(animalName,exptDate);

dbConn = dbConnect();

operationList{1,1}(1:5)
exptDate_dbForm = houseConvertDateTo_dbForm(operationList{1,1}(1:5));
exptIndex_dbForm = str2num(operationList{1,1}(7:9));

masterResult = fetch(dbConn,['select exptID,animalID from masterexpt where exptDate=''' exptDate_dbForm ''' and exptIndex=' num2str(exptIndex_dbForm)]);
exptID = masterResult{1,1};
animalID = masterResult{1,2};

% NEXT!!!: need to add exptID to global_stimparams for drug dose





% examples
paramResult = fetch(dbConn,['select paramfield,paramvalue from global_stimparams where exptID=' num2str(exptID)]);
if(~isempty(paramResult))
    nGlobalPars = size(paramResult,1);
    globalParNames = paramResult(:,1);
    globalParVals = cell2mat(paramResult(:,2));   
else
    nGlobalPars = 0; % No global parameters exsist for this experiment 
end 





ewr = 'SELECT `led_right_ampl` FROM  `databanks`.`global_stimfields`'
FROM  `databanks`.`global_stimfields`
textQ = 'SELECT * FROM databanks.global_stimfields';
globalStimfieldsList = fetch(dbConn,ewr);


textW = 'INSERT INTO `databanks`.`stimuli_units` (`parameter`, `units`) VALUES (''LPS_conc'', ''mg/kg'')';






lastEntryID = fetch(dbConn,'SELECT MAX(exptID) FROM masterexpt');

hardware = 'TDT'; %this is always a TDT specific program.
grandExpt = 'PassiveEphys'; %this is another assumption
animalID = fetch(dbConn,['SELECT animalID FROM animals WHERE animalName=''' animalName '''']);
exptDate = fetch(dbConn,['SELECT exptDate FROM masterexpt WHERE exptID=' num2str(lastEntryID{1})]);
exptIndex = fetch(dbConn,['SELECT exptIndex FROM masterexpt WHERE exptID=' num2str(lastEntryID{1})]);
experimenterID = fetch(dbConn,['SELECT experimenterID FROM masterexpt WHERE exptID= ''' num2str(lastEntryID{1}) '''']);


    lastEntryID = fetch(dbConn,'SELECT MAX(exptID) FROM masterexpt');
    exptDate = fetch(dbConn,['SELECT exptDate FROM masterexpt WHERE exptID=' num2str(lastEntryID{1})]);
    exptIndex = fetch(dbConn,['SELECT exptIndex FROM masterexpt WHERE exptID=' num2str(lastEntryID{1})]);
    synapseImportingPathway(exptDate,exptIndex,S.recordingComputer,S.recordingComputerSubfolder);



    
    


