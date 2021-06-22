function [output] = fetchAdjust(dbConn,inputText)

% check if version is newer than 2017a. (2017a = 9.2)
% If so, the output of fetch will be a table, not cell!

%if isVersionNewerThan(9.4)
    output = fetch(dbConn,inputText,'DataReturnFormat','cellarray');
%else
%    output = fetch(dbConn,inputText);
%end
