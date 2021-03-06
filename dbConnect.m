function [ dbConn, success ] = dbConnect( )
%dbDatabanksConnect Connects to the database
%   dbConn contains the pointer to the database connection
%   Return variable success == 1 on success, 0 on failure.
%   Please follow me with "close(dbConn);" thank you


% TROUBLESHOOTING INSTALLATION STEP!!!!
% Set this to the path to your MySQL Connector/J JAR

%WARNINGS DISABLED ONLY TO PREVENT CLUTTERING OF THE COMMAND PROMPT 
%NOT A FIX
warning off all

% javaaddpath('Z:\DataBanks\mysql-connector-java-5.1.14-bin.jar'); %old
javaaddpath('\\SERVER1\Data\DataBanks\mysql-connector-java-5.1.14-bin.jar'); %edited JK 16331 for more robust access over networks

warning on all


% Database Server
host = '144.92.237.181:3306';
%host = 'localhost';

% Database Username/Password
user = 'databanks';
password = 'Selt7672';

% Database Name
dbName = 'databanks';

% JDBC Parameters
jdbcString = sprintf('jdbc:mysql://%s/%s', host, dbName);
jdbcDriver = 'com.mysql.jdbc.Driver';



% Create the database connection object
try
    dbConn = database(dbName, user, password, jdbcDriver, jdbcString);
    if ismember('isopen',methods(dbConn))
        success = isopen(dbConn);
    else
        success = isconnection(dbConn); %For backwards compatibility
    end
catch
    dbConn = [];
    success = 0;
end

end

