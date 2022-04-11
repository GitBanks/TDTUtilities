function [operationList] = getExperimentsByAnimalAndDate(animalName,exptDate,findExptType)
% Given: an animal name, date, and optional search term
% Return: an n by 2 cell array - 'date-index' and 'experiment description'
% are the two columns
% animalName = 'DREADD07';
% exptDate = '18907';
% animalName = 'EEG190';
% exptDate = '22331';
% findExptType = 'Spon';
% Calls: [outputList] = getExperimentsByAnimal(animalName,findExptType);
% (and just sorts / selects by day)
if nargin <1
   error('You need an animal name and date'); 
end
if nargin <2
   error('This funtion needs a date'); 
end
if nargin <3
   findExptType = '';
end
[outputList] = getExperimentsByAnimal(animalName,findExptType);
listIndex = 1;
operationList = [];
for iDays = 1:size(outputList,1)
    if ~isempty(outputList{iDays,1})
        if ~isempty(strfind(outputList{iDays,1}(1:5),exptDate))
            operationList{listIndex,1} = outputList{iDays,1};
            operationList{listIndex,2} = outputList{iDays,2};
            listIndex = listIndex+1;
        end
    end
end

