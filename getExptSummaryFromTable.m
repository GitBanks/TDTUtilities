function dataStruct = getExptSummaryFromTable(tname,showMove)
% movementDataStruct = getMoveExptSummaryFromTable(tname)
% GIVEN: a table containing animal names (string pointing to xlsx file.
% Looks for animalName column)
% RETURN a structure containing:
% Animal name = (Animal)
% expt date = (Date)
% structure of treatments = (treatments)
% time array in datetime format = (fullTimeArrayTOD)
% structure of drug injections in datetime format = (drugTOD)
% sample rate (in change-in-time between samples) = (dt) default is ~1 sec
% movement stream = (fullMoveStream)
% time array = (fullTimeArray)
%
% this uses getMoveTimeDrugbyAnimalDate so look at that function for some
% formatting clues and future plans.
% TODO: I ran into syntax/formatting issue trying to get this into a table
% similar to the ecog pipeline.  I left some of that table code commented out
% with an intention to tweak this to use in the pipeline.  In any case it
% just needs a few more lines to get there.
% TODO:  I'd like to make the table input a switch instead of a string, so we can
% easily reference experimental sets like: Fluvoxamine, ZZ animals,
% Psychedelics, upcoming EEG set, etc.  We can refer to paths with
% [p] = getPathGlobal(str) maybe?


% Matt reminded me of previous instructions as follows:
% The behavioral data is for different doses of fluvoxamine, correct? 
% How easy/hard would it be for you put all that movement data into a 
% Matlab data structure so I can play with it? I would need the time vector 
% for each expt, with time relative to injection(s) (unless they are all 
% the same or you can put them all on the same time axis, in which case I 
% just need one vector). Probably a good idea to downsample, e.g. compute 
% 4-sec windows.
% resolving this with what I did yesterday, I can reuse much of the code, 
% but I should instead create a standalone time vector (instead of leaving
% it to him to compute), and adjust it based on time of injection
% test variables:
% tname = 'M:\PassiveEphys\mouseEEG\FLVXGroupInfo.xlsx';
% showMove = false

% check for variables - input parameters
if ~exist("showMove","var")
    showMove = false;
end
%1. load this table
workingTable = readtable(tname);
% 
% %T = T(1:end-2,:);
% workingTable = table;
% workingTable.animalList = T.animalName;
% workingTable.Dates = T.Dates;
% workingTable.chansToExclude = T.chansToExclude;


for iExpt = 1:size(workingTable,1)
    thisAnimal = workingTable.animalName{iExpt};
    if iscell(workingTable.Dates)
        thisDate = workingTable.Dates{iExpt}; %if you've created a new table and are getting an error here, the data in the xls file needs to be text
    end
    if isnumeric(workingTable.Dates)
        thisDate = num2str(workingTable.Dates(iExpt));
    end
    disp([thisAnimal ' ' thisDate]);
    %2. get list of indices
    % workingList = getExperimentsByAnimal(thisAnimal);
    % workingList = getExperimentsByAnimalAndDate(thisAnimal,thisDate);

    % you could add a dataStruct(iExpt).group = workingTable.group for a
    % manually entered grouping - it would make
    % collectSpectraDataFromExptList easier



    dataStruct(iExpt).Animal = thisAnimal;
    dataStruct(iExpt).Date = thisDate;
    dataStruct(iExpt).ChansToExclude = workingTable.chansToExclude(iExpt);
    if showMove
        [S] = getMoveTimeDrugbyAnimalDate(thisAnimal,thisDate);
        dataStruct(iExpt).treatments = S.treatments;
        dataStruct(iExpt).fullTimeArrayTOD = S.fullTimeArrayTOD;
        dataStruct(iExpt).drugTOD = S.drugTOD;
        dataStruct(iExpt).dt = S.dt;
        dataStruct(iExpt).fullMoveStream = S.fullMoveStream;
        dataStruct(iExpt).fullTimeArray = S.fullTimeArray;
    end
end








% old work below

% I wanted to use a table, but some of the array into cell formatting kept
% complaining (I could not figure out syntax).  I'm going to leave this
% here, because it may be nice to tweek 
% sz = [size(T,1) 5];
% varTypes = {'string','string','double','cell','cell'};
% varNames = {'Animal','Date','dt','fullMoveStream','fullTimeArray'};
% % sz = [size(T,1) 8];
% % varTypes = {'string','string','double','cell','cell','struct','cell','struct'};
% % varNames = {'Animal','Date','dt','fullMoveStream','fullTimeArray','treatments','fullTimeArrayTOD','drugTOD'};
% movementData = table('Size',sz,'VariableTypes',varTypes,'VariableNames',varNames);