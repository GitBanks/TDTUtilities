function [ stimID ] = dbGetUniqueStimulus(stimPar)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Please note any alterations, and update version information
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% VersionNumber = 1.2
% Date = 20-Feb-2019
%
%
%Updates:
% 20-Feb-2019
% Previous version was not compatible with versions of Matlab >= 2018, since 
% the columns function no longer works the same way, so added  
% isVersionNewerThan statement to test current version of Matlab and use 
% sqlfind instead of columns if version is newer than 2017 (9.4). -ZS
%
% 16-Aug-2011
% Previous version had problem with search such that it did not check all
% columns of database, only those in stimPar, so if stimulus in table had
% value in another column not in stimPar it would return that stimulus even 
% though not identical.  Now searches all columns and makes sure all other
% columns in table are set to null. -MB

%dbGetUniqueStimulus Output the unique stimulus reference ID
%   This function needs to search the stimulus table for a stimulus that
%   matches stimPar. If found, output the associated stimID. If not
%   found, create a new entry in the stimulus table and output the new
%   stimID.
%   Bryan Krause 10-Dec 2010

% Example input:
% stimPar.audfreq = ??;
% stimPar.audfreq_L = ??;

dbConn = dbConnect();

% Look to see if the fields in our structure match columns in the database
tempStimFields = fieldnames(stimPar);
if isVersionNewerThan(9.3) %updated 3/12/19 %added 2/20/2019 ZS
    dbTable = sqlfind(dbConn,'stimuli');
    dbStimFields = dbTable.Columns{strcmp(dbTable.Table,'stimuli')};
else
    dbStimFields = columns(dbConn,[],[],'stimuli');
end

              
%get list of all simulus parameters and look for aliases
%if parameter name does not match its alias create a new
%field with that alias while removing the original field 
newAlias = '';
for iParam = 1:length(tempStimFields)
    parameter = tempStimFields(iParam); %query alias database for alias of parameter
    search = ['select alias from aliases where parameter = ''' parameter{1} ''' '];
    alias = fetchAdjust(dbConn,search);
    if(isempty(alias))
        %if alias is empty the parameter does not exsist in the alias table
        %and currently does not have an alias and should prompt the user
        
        prompt = [ 'Does ' parameter{1} ' have an alias? (Leave blank if no)'];
        newAlias = input(prompt, 's');
        
        if(isempty(newAlias)) %if nothing was entered place parameter name under alias
            insertStimulus = ['insert into aliases (parameter,alias) values (''' ...
            parameter{1}  ''','''   parameter{1} ''')'];
            exec(dbConn,insertStimulus);
            
        else  % give parameter's desired alias and reconfigure field of stimPar 
            insertStimulus = ['insert into aliases (parameter,alias) values (''' ...
            parameter{1}  ''','''  newAlias ''')'];
            exec(dbConn,insertStimulus);
            
            stimPar.(newAlias) = stimPar.(parameter{1});  %set new aliased
                       %field to whatever data the previous entry contained
                       
            stimPar = rmfield(stimPar,parameter{1});  %remove original field 
            
        end
        
    else %else the parameter exsists and may have an alias
        if(~strcmpi(alias, tempStimFields(iParam)) )  % If an alias exsists for the parameter
            stimPar.(alias{1}) = stimPar.(parameter{1});  %set new aliased
                            %field to whatever data the previous entry contained
                            
            stimPar = rmfield(stimPar,parameter{1});  %remove original field 
        end
    end
end 

%Must re-aquire fieldnames to take into account the aliasing that has
%occured to the current list of fieldnames

stimFields = fieldnames(stimPar);


% foundMatch will be zero for any fields that don't have a match
foundMatch = zeros(1,length(stimFields));
%8/16/2011 - MB
%This code was altered slightly so that the fields of dbStimFields that are
%not included in stimFields can be accessed below.
matchFields = zeros(1,length(dbStimFields));
for iField = 1:length(stimFields)
    matchTest = strcmpi(stimFields{iField},dbStimFields);
    if sum(matchTest(:)) >= 1
        foundMatch(iField) = 1;
    end
    matchFields = matchFields | matchTest;
end

% If no new fields, do a search to see if we find an identical stimulus. If
% so, stimUnique = 0 and we return the ID.
stimUnique = 1;
if sum(foundMatch(:)) == length(foundMatch)
    
    getStimMatch = 'select id from stimuli where ';
    for iField = 1:length(stimFields)
        getStimMatch = [getStimMatch stimFields{iField} '=' num2str(stimPar.(stimFields{iField})) ' and '];
    end
%8/16/2011 - MB
%The following four lines were added so that we ensure that stim pars not
%included in stimFields are Null in the stim table.  Note that we are using
%the IS NULL comparison predicate (thank you Wikipedia).
    for iField = 2:length(dbStimFields)
        if ~matchFields(iField)
            getStimMatch = [getStimMatch dbStimFields{iField} ' IS NULL and '];
        end
    end
    getStimMatch = getStimMatch(1:end-5); %remove the last "and"

    fetchStimMatch = fetchAdjust(dbConn,getStimMatch);
    
    % Check for uniqueness
    if ~isempty(fetchStimMatch)
        stimID = fetchStimMatch{1};
        stimUnique = 0;
    end
else
    % If there are any new fields (foundMatch(i)==0) then add that column to
    % the database.
    addField = stimFields(~logical(foundMatch));
    for iField = 1:length(addField)
        addFieldStatement = ['alter table stimuli add ' addField{iField} ' double DEFAULT NULL'];
        exec(dbConn,addFieldStatement);
    end
end


% If our stimulus is unique, make a new entry to the database and return
% the new ID.
if stimUnique==1
    insFieldList = '';
    insDataList = '';
    for iField = 1:length(stimFields)
        insFieldList = [insFieldList stimFields{iField} ','];
        insDataList = [insDataList num2str(stimPar.(stimFields{iField})) ','];
    end
    insFieldList = insFieldList(1:end-1); %remove last comma
    insDataList = insDataList(1:end-1); %remove last comma
    insertStimulus = ['insert into stimuli (' insFieldList ') values (' insDataList ');'];
    exec(dbConn,insertStimulus);
    lastInsert = fetchAdjust(dbConn,'select last_insert_id()');
    stimID = lastInsert{1};
end

close(dbConn);
end
