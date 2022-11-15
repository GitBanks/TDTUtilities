function setExptDescription(exptDate,exptIndex,newDescriptionText)
% given a date and index
% Do: change the experiment description 
% exptDate = '22n14'
% exptIndex = '000'
% newDescriptionText = 'changed!'
dbConn = dbConnect();
[ exptID ] = getIDfromDateIndex( exptDate, exptIndex );
addDescription = ['UPDATE masterexpt SET notebookDesc= ''' ...
    newDescriptionText ''' WHERE exptID= '''...
    num2str(exptID) ''''];
exec(dbConn,addDescription);
close(dbConn);

