function [livingAnimals,livingAnimalsID] = getLivingAnimals()

dbConn = dbConnect();
livingAnimals = fetch(dbConn,'select animalName from animals where sacDate=''0000-00-00''');
if isempty(livingAnimals)
    error('Animal name not found! Check spelling.')
end

livingAnimalsID = fetch(dbConn,'select animalID from animals where sacDate=''0000-00-00''');
if isempty(livingAnimalsID)
    error('Animal name not found! Check spelling.')
end


%TODO!! change format to cells and ints


