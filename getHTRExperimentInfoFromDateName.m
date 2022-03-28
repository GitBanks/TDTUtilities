function timeStruct = getHTRExperimentInfoFromDateName(thisDate,thisName,oldFormatOverride)

%thisDate = '21318'
%thisName = 'EEG181'

%thisDate = '21910'
%thisName = 'ZZ09'

if ~exist('oldFormatOverride','var')
    oldFormatOverride = false;
end


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
    timeStruct.desc(iFile) = notebookDescText;
    
    if oldFormatOverride == false 
        textIndex = strfind(notebookDescText,'a Spon');
        hourOfRecording = str2num(notebookDescText{:}(textIndex{1}-2:textIndex{1}-1)); 
        if isempty(hourOfRecording)
            error('only ''spontaneous hour''  recording is supported');
        end
    else
        hourOfRecording = iFile;
    end
    
    timeStruct.hourOfRecording(iFile) = hourOfRecording;
    fileLocation = ['M:\PassiveEphys\20' exptID(1:2) '\'  exptID '\' ];
    [~,timeStruct.timeOfDay{iFile}] = getTimeAndDurationFromIndex(exptID(1:5),exptID(7:9));
    % - load in time domain length 
    load([fileLocation exptID '_magnetData.mat']);
    timeStruct.timeLength(iFile) = length(magData);
    timeStruct.timeDT(iFile) = magDT;
    clear magData magDT
    % - load in HTRevents
    try
        load([fileLocation exptID '-HTRevents.mat'],'htrEventTimes');
    catch
        [~] = HTRMagDetectionHandler(exptID,true);
        load([fileLocation exptID '-HTRevents.mat'],'htrEventTimes');
    end
    % - arrange into cleanedEventTimes
   
    timeStruct.eventArray(iFile).events =htrEventTimes(:);
    
    clear htrEventTimes
end







end