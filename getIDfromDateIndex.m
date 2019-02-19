function [ exptID ] = getIDfromDateIndex( exptDate, exptIndex )

dbConn = dbConnect();
exptDate = houseConvertDateTo_dbForm(exptDate);
indexDbl = str2double(exptIndex);
IDQuerry = ['select exptID from masterexpt where  exptDate= ''' exptDate ''' AND exptIndex= ' num2str(indexDbl) ];
exptIDcell = fetch(dbConn,IDQuerry);
if istable(exptIDcell)
    exptIDcell = table2array(exptIDcell);
end
if iscell(exptIDcell)
    exptIDcell = cell2mat(exptIDcell);
end
if isnumeric(exptIDcell)
    exptID = exptIDcell;
else
    error('check the output of fetch(); this has been a problem.')
end
close(dbConn);
end

