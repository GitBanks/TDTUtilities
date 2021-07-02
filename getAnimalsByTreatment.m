function [exptTable] = getAnimalsByTreatment(treatment)

%treatment = 'DOI_conc';
dbConn = dbConnect(); %handle this better?  close db at end?
query = ['SELECT * FROM `global_stimparams` WHERE `paramfield` LIKE ' '''' treatment ''''];
masterResult = fetchAdjust(dbConn,query);
exptIDlist = masterResult(:,2);

sz = [length(exptIDlist) 5];
varTypes = {'string','string','string','string','string'};
varNames = {'AnimalName','Date','Index','Druglist','Desc'};
exptTable = table('Size',sz,'VariableTypes',varTypes,'VariableNames',varNames);

for iExptList = 1:length(exptIDlist)
    query2 = ['SELECT exptDate,exptIndex,animalID FROM `masterexpt` WHERE `exptID` = ' '''' num2str(exptIDlist{iExptList}) ''''];
    dateResult(iExptList,:) = fetchAdjust(dbConn,query2);
    query3 = ['SELECT animalName FROM `animals` WHERE `animalID` = ' ''''  num2str(dateResult{iExptList,3}) ''''];
    exptTable.AnimalName(iExptList) = fetchAdjust(dbConn,query3);
    exptTable.Date(iExptList) = formatDateFive(dateResult{iExptList,1});
    exptTable.Index(iExptList) = {num2str(dateResult{iExptList,2})};
    query4 =['select paramfield,paramvalue from global_stimparams where exptID=' num2str(exptIDlist{iExptList})];
    paramResult = fetchAdjust(dbConn,query4);
    drugList = [];
    for iParam = 1:size(paramResult,1)
%         drugList = [drugList paramResult{iParam,1} ' ' num2str(paramResult{iParam,2}) '; '];
        drugList = [drugList paramResult{iParam,1} '; '];
    end
    exptTable.Druglist(iExptList) = drugList;
    query5 = ['SELECT notebookDesc FROM masterexpt WHERE exptID =''' num2str(exptIDlist{iExptList}) ''''];
    exptTable.Desc(iExptList) = fetchAdjust(dbConn,query5);
end

close(dbConn);