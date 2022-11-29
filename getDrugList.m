function list = getDrugList
dbConn = dbConnect();
list = unique(fetchAdjust(dbConn,'SELECT paramfield FROM global_stimparams'));
close(dbConn);