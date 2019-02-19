function [nGlobalPars,globalParNames,globalParVals]= getGlobalStimParams(exptDate,exptIndex)
% test params
% exptDate = '14520'
% exptIndex = '003'

% check if version is newer than 2017a. 
fetchAdj = fetchAdjust; %added fetchAdj ZS 2/14/2019

% turn this into a function??
dbConn = dbConnect(); %handle this better?  close db at end?
masterResult = fetch(dbConn,['select exptID from masterexpt where exptDate=''' houseConvertDateTo_dbForm(exptDate) ''' and exptIndex=' num2str(str2num(exptIndex))],fetchAdj{:});
exptID = masterResult{1,1};
%Query db for global parameters, i.e. parameters whose values do not change
%over the course of the expt but are entered manually into the enotebook.
%Examples are [iso] and LED ampl.
paramResult = fetch(dbConn,['select paramfield,paramvalue from global_stimparams where exptID=' num2str(exptID)],fetchAdj{:});
if(~isempty(paramResult))
    nGlobalPars = size(paramResult,1);
    globalParNames = paramResult(:,1);
    globalParVals = cell2mat(paramResult(:,2));   
else
    nGlobalPars = 0; % No global parameters exsist for this experiment 
    globalParNames = paramResult;
    globalParVals = cell2mat(paramResult); 
end 
close(dbConn);
