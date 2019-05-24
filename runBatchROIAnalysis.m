function runBatchROIAnalysis(animal)
% animal = 'EEG74';
% animal = 'EEG68';

query = 'Spon';
listOfExpts = getExperimentsByAnimal(animal,query);
if isempty(listOfExpts{1})
   warning(['No experiments found for ' animal ' under ' query '. Trying again with no query']);
   listOfExpts = getExperimentsByAnimal(animal);
end

for k = 1:length(listOfExpts) 
    a(k) = {listOfExpts{k}(1:5)};
end
dates = unique(a)';
% dates = dates(end-2:end); %for EEG68 and 69... 


for ii = 1:length(dates)
    date = dates{ii};
    list = getExperimentsByAnimalAndDate(animal,date);
    fullROI = [];
    for qq = 1:length(list)
        indices{qq} = list{qq,1}(7:9);
    end
    for jj = 1:length(indices)
        index = indices{jj};
%         vidFileName = ['W:\Data\PassiveEphys\20' date(1:2) '\' date '-' index '\2019_' date '-' index '_Cam1.avi'];
        vidFileName = ['W:\Data\PassiveEphys\20' date(1:2) '\' date '-' index '\' date '-' index ];
        [~,fullROI] = roiVidAnalysisBinary(vidFileName,date,index,false,fullROI,true);
    end
end

%         subplot(length(fileNameList),1,iFile)
%         plot(finalMovementArray);
%         title(fileName(end-8:end));
