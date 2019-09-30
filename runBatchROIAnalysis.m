function runBatchROIAnalysis(animal,rerun)
% animal = 'EEG74';

if nargin < 2
   rerun = 0; 
end
query = 'Spon';
listOfExpts = getExperimentsByAnimal(animal,query);
if isempty(listOfExpts{1})
   warning(['No experiments found for ' animal ' under ' query '. Trying again with no query']);
   listOfExpts = getExperimentsByAnimal(animal);
end

dates = unique(cellfun(@(x) x(1:5), listOfExpts(:,1), 'UniformOutput',false),'stable'); 

if ~rerun
   dates = dates(end); %use most recent experiment... 
end

animalNum = getAnimalNumber(animalName);

for ii = 1:length(dates)
    date = dates{ii};
    list = getExperimentsByAnimalAndDate(animal,date,query);
    fullROI = [];
    for qq = 1:size(list,1)
        indices{qq} = list{qq,1}(7:9);
    end
    for jj = 1:length(indices)
        index = indices{jj};
        if animalNum > 51 % assumes animal name has a number associated with it (and follows the EEG animal order). New system videos started with EEG52
            vidFileName = ['W:\Data\PassiveEphys\20' date(1:2) '\' date '-' index '\20' date(1:2) '_' date '-' index '_Cam*.avi'];
        else
            vidFileName = ['W:\Data\PassiveEphys\20' date(1:2) '\' date '-' index '\' date '-' index ];
%             vidFileName = ['W:\Data\PassiveEphys\20' date(1:2) '\' date '-' index '\' date '-' index '-converted.mp4']; %ONLY FOR EEG43 and 47
        end
        dirCheck = dir(vidFileName);
        if ~isempty(dirCheck)
%             if size(dirCheck,1) > 1 
%                 vidFileName = [dirCheck.folder '\' dirCheck(1).name];
%             else
                vidFileName = [dirCheck(1).folder '\' dirCheck(1).name];
%             end
            
            [~,fullROI] = roiVidAnalysisBinary(vidFileName,date,index,fullROI,false);
        else 
            disp([vidFileName ' not found']);
        end
    end
end
