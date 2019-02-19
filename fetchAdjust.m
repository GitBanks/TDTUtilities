function fetchAdj = fetchAdjust

% check if version is newer than 2017a. (2017a = 9.2)
% If so, the output of fetch will be a table, not cell! 
if isVersionNewerThan(9.2)
    disp('detected matlab version is newer than 2017a - adjusting fetch');
    fetchAdj = {'DataReturnFormat','cellarray'};
else
    fetchAdj = {};
end