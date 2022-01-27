function implantDate = getImplantDate(animalName)

dbConn = dbConnect();


query3 = ['SELECT animalID FROM `animals` WHERE `animalName` = ' ''''  animalName ''''];
animalID = fetchAdjust(dbConn,query3);

try
    implantDate = fetch(dbConn,['SELECT implantDate FROM animals WHERE animalID = '  ''''  num2str(animalID{1,1}) '''']);  
catch
    warning('No implant date retrieved');
    implantDate = '0000-00-00';
end


if isempty(implantDate)
    error('No implant date has been entered.')
end
close(dbConn);