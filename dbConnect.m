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
% javaaddpath('\\SERVER1\Data\DataBanks\mysql-connector-java-5.1.14-bin.jar'); %edited JK 16331 for more robust access over networks
% javaaddpath('\\144.92.237.180\Users\Matt Banks\Documents\Code\TDTUtilities\mysql-connector-java-5.1.14-bin.jar'); % 21512 - Z drive is out
javaaddpath('\\144.92.237.180\Users\zsultan\Documents\Code\TDTUtilities\mysql-connector-java-5.1.14-bin.jar');
%javaaddpath('C:\Program Files (x86)\MySQL\Connector J 8.0\mysql-connector-java-8.0.29.jar');

warning on all


% Database Server
%host = '144.92.237.181:3306'; %former 'Z'
% host = '144.92.237.186:3306'; %Helmholtz
host = [getPathGlobal('SQL') ':3306']; %Dionysus % this doesn't
%host = '127.0.0.1:3306';
%host = '144.92.237.186'; 
%host = '144.92.237.180'; % try this for this computer 
% host = 'localhost'; % this works

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
    warning('Did not connect to database! whatever you''re doing will probably now crash.');
    dbConn = [];
    success = 0;
end

end

