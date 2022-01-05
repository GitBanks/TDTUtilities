% single-use type script to add in new fields to existing batch params - 20o16
% adapted to do the same for WPLI data 20o21

% load data
if ~exist('params','var')
    [ephysData,params] = loadEphysData('wpli');
end

% get metadata table
animalTable = readtable([getPathGlobal('W') 'PassiveEphys\EEG animal data\Mouse Master Log Psychedelics Project.xlsx']);

% get list of animals
animalList = unique(animalTable.animalName);

% hacky change from datetime format to our house 5-digit date
for ii = 1:size(animalTable.DrugDate,1)
    tempSet{ii,1} = formatDateFive(datestr(animalTable.DrugDate(ii,1),'yyyy-mm-dd'));
end
animalTable.DrugDate = tempSet;

iCount = 1;

for ii = 1:length(animalList)
    thisAnimal = animalList{ii};
    
    % get list of dates entered for this animal
    dates = animalTable.DrugDate(strcmp(animalTable.animalName,thisAnimal));
    
    for jj = 1:length(dates)
       thisDate = dates{jj};
       
       try
        
        indexList = params.(thisAnimal).(['date' thisDate]).exptIndex;
        
        params.(thisAnimal).(['date' thisDate]).indexPostInj = getInjectionIndex(thisAnimal,thisDate);
        
        % loop thru each index, get duration and time of day
        indexDur = cell(length(indexList),1); timeOfDay = cell(length(indexList),1);
        for iIndex = 1:length(indexList)
            thisIndex = indexList{iIndex};
            [indexDur{iIndex},timeOfDay{iIndex}] = getTimeAndDurationFromIndex(thisDate,thisIndex);
        end
        params.(thisAnimal).(['date' thisDate]).indexDur = indexDur;
        params.(thisAnimal).(['date' thisDate]).timeOfDay = timeOfDay;
        catch why
            warning([thisAnimal ' ' thisDate ' error'])
            warning(why.message);
            
            failed{iCount,1} = [thisAnimal ' ' thisDate ' error'];
            failed{iCount,2} = why.message;
            iCount = iCount+1;
       end
    end
    
end

% TODO: add safe saving feature
mouseEphys_conn = ephysData; 
clear ephysData
batchParams = params; 
clear params
save([getPathGlobal('W') 'PassiveEphys\EEG animal data\mouseEphys_conn_dbt_noParse_20sWin_0p5sTrial_psychedelics.mat','mouseEphys_conn','batchParams']);

    

   
    
    