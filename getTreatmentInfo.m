function treatments = getTreatmentInfo(animalName,date)
% rework of getInjectionIndex - this will return a whole structure of info
% given a valid animal and date: return a structure containing 
% the global stim params, their values, and a logical array of the first 
% index a manipulation was done.  Will error out if stim params are invalid.
% animalName = 'EEG180';
% date = '21225';
% animalName = 'ZZ10';
% date = '21616';
exptList = getExperimentsByAnimalAndDate(animalName,date);
% 2. step through each and verify drug info (global param)
for ii = 1:size(exptList,1)
    index = exptList{ii,1}(7:9);
    [~,parNames,parVals] = getGlobalStimParams(date,index);
    drugData(ii,1) = {parNames};
    drugData(ii,2) = {parVals};
end
try
treatments.pars = [drugData{:,1}];
treatments.vals = [drugData{:,2}];
catch
    error(['Drug data seems incorrect for ' animalName ' on ' date]);
end
% find column elements that differ from previous column
treatments.injIndex = false(size(treatments.vals)); % logical array for whether next element differs from subsequent element
for jj = 1:size(treatments.vals,1) % loop though number of treatments (first dimension)
    for ii = 2:size(treatments.vals,2) % loop through number of indices (second dimension)
        treatments.injIndex(jj,ii) = treatments.vals(jj,ii) ~= treatments.vals(jj,ii-1);
    end
    if sum(treatments.injIndex(jj,:)) ~= 1
        disp('WARNING! injection data seems incomplete - no inj time detected!');
    end
end
%TODO: add check for treatments.pars to be sure of consistancy: error('injection data has been entered incorrectly');


end

