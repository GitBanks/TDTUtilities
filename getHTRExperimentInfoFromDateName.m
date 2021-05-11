function timeStruct = getHTRExperimentInfoFromDateName(thisDate,thisName)

%thisDate = '21318'
%thisName = 'EEG181'

timeStruct = struct();
%timeStruct.TimeArray(1) = 0;
timeStruct.animalName = thisName;
timeStruct.eventArray(1).events = 0;
outputList = getExperimentsByAnimalAndDate(thisName,thisDate);
treatments = getTreatmentInfo(thisName,thisDate);
timeStruct.injIndex = treatments.injIndex;
for iFile = 1:size(outputList,1)
    exptID = outputList{iFile,1};
    dbConn = dbConnect();
    [DBexptID] = getIDfromDateIndex(exptID(1:5),exptID(7:9));
    notebookDescText = fetchAdjust(dbConn,['SELECT notebookDesc FROM masterexpt WHERE exptID=' num2str(DBexptID)]);
    close(dbConn);
    textIndex = strfind(notebookDescText,'a Spon');
    hourOfRecording = str2num(notebookDescText{:}(textIndex{1}-2:textIndex{1}-1)); 
    timeStruct.desc(iFile) = notebookDescText;
    timeStruct.hourOfRecording(iFile) = hourOfRecording;
    fileLocation = ['M:\PassiveEphys\20' exptID(1:2) '\'  exptID '\' ];
    [~,timeStruct.timeOfDay{iFile}] = getTimeAndDurationFromIndex(exptID(1:5),exptID(7:9));
    % - load in time domain length 
    load([fileLocation exptID '_magnetData.mat']);
    timeStruct.timeLength(iFile) = length(magData);
    timeStruct.timeDT(iFile) = magDT;
    clear magData magDT
    % - load in HTRevents
    load([fileLocation exptID '-HTRevents.mat'],'htrEventTimes');
    % - arrange into cleanedEventTimes
   
    timeStruct.eventArray(iFile).events =htrEventTimes(:);
    
    clear htrEventTimes
end







end