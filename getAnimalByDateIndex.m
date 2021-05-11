function animal = getAnimalByDateIndex(exptDate,exptIndex)
% exptDate = '21304';
% exptIndex = '012';
dbConn = dbConnect(); %handle this better?  close db at end?
exptDate = houseConvertDateTo_dbForm(exptDate);
query = ['select animalID from masterexpt where  exptDate= ''' exptDate ''' AND exptIndex= ' num2str(str2double(exptIndex)) ];
result = fetchAdjust(dbConn,query);
query2 = ['SELECT animalName FROM `animals` WHERE `animalID` = ' ''''  num2str(result{:}) ''''];
animal = fetchAdjust(dbConn,query2);
animal = animal{:};
close(dbConn);