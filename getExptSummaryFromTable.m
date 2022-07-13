function dataStruct = getExptSummaryFromTable(tname)
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




%1. list of animals
% tname = 'M:\mouseEEG\FLVXGroupInfo.xlsx'; % potentially make this a function with switches we can call from wherever
T = readtable(tname);

T = T(1:end-2,:);
animalList = T.animalName;
animalList = unique(animalList);
dirstr1 = 'M:\PassiveEphys\20';

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

trueIndex = 1;
for i = 24:size(animalList,1)
    thisAnimal = animalList{i};
    %2. get list of indices
    workingList = getExperimentsByAnimal(thisAnimal);
    % are there unique dates?  
    for ii = 1:size(workingList,1)
        justDates(ii) = {workingList{ii,1}(1:5)};
    end
    uniqueDates = unique(justDates);
    for ii = 1:size(uniqueDates,2)
        thisDate = uniqueDates{ii};
        [S] = getMoveTimeDrugbyAnimalDate(thisAnimal,thisDate);
%         movementData(trueIndex,"Animal") = {thisAnimal};
%         movementData(trueIndex,"Date") = thisDate;
%         movementData(trueIndex,"dt") = {S.dt};
%         movementData(trueIndex,"fullMoveStream") = {S.fullMoveStream};
%         movementData(trueIndex,"fullTimeArray") = {S.fullTimeArray'};

        movementDataStruct(trueIndex).Animal = thisAnimal;
        movementDataStruct(trueIndex).Date = thisDate;
        movementDataStruct(trueIndex).treatments = S.treatments;
        movementDataStruct(trueIndex).fullTimeArrayTOD = S.fullTimeArrayTOD;
        movementDataStruct(trueIndex).drugTOD = S.drugTOD;
        movementDataStruct(trueIndex).dt = S.dt;
        movementDataStruct(trueIndex).fullMoveStream = S.fullMoveStream;
        movementDataStruct(trueIndex).fullTimeArray = S.fullTimeArray;

        trueIndex = trueIndex+1;


    end
    clear uniqueDates workingList justDates
end















