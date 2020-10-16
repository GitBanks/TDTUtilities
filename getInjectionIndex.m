function indexPostInj = getInjectionIndex(animalName,exptDate)

% animalName = 'EEG128';
% exptDate = 'date20129';

exptDate = strrep(exptDate,'date','');
[outputList] = getExperimentsByAnimalAndDate(animalName,exptDate,'Spon');
if isempty(outputList)
    [outputList] = getExperimentsByAnimalAndDate(animalName,exptDate);
end

% get list of indices
indices = unique(cellfun(@(x) x(7:9), outputList(:,1), 'UniformOutput',false),'stable');

% 2. step through each and verify drug info (global param)
for ii = 1:length(indices)
    index = indices{ii};
    [~,parNames,parVals] = getGlobalStimParams(exptDate,index);
    drugData(ii,1) = {parNames};
    drugData(ii,2) = {parVals};
end
pars = [drugData{:,1}];
vals = [drugData{:,2}];

% find column elements that differ from previous column
isDiff = false(size(vals)); % logical array for whether next element differs from subsequent element
for jj = 1:size(vals,1) % loop though number of treatments (first dimension)
    for ii = 2:size(vals,2) % loop through number of indices (second dimension)
        isDiff(jj,ii) = vals(jj,ii) ~= vals(jj,ii-1);
    end
    if sum(isDiff(jj,:)) ~= 1
        error('injection data has been entered incorrectly');
    end
end

for ii = 1:size(vals,1) % loop through number of treatments (1st dimension)
     indexPostInj(:,ii) = indices(isDiff(ii,:));
end


end

