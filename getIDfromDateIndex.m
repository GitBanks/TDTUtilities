function [ exptID ] = getIDfromDateIndex( exptDate, exptIndex )

dbConn = dbConnect();
exptDate = houseConvertDateTo_dbForm(exptDate);
indexDbl = str2double(exptIndex);
IDQuerry = ['select exptID from masterexpt where  exptDate= ''' exptDate ''' AND exptIndex= ' num2str(indexDbl) ];
exptIDcell = fetch(dbConn,IDQuerry);
exptID = exptIDcell{1};
close(dbConn);
end

