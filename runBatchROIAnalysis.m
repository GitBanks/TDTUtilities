function runBatchROIAnalysis(animal,rerun)
% a function to run the ROI-based movement analysis on all experiments for a given 
% animal. Second parameter 'rerun' is a boolean to say whether
% you want to re-analyze all videos for this animal (usually no!). 
% NOTE: the movement analysis roiVidAnalysisBinary is
% pretty computationally taxing. Should only be run on computers with >
% 32gb RAM (e.g. HELMMHOLTZ, THOR)!!!!!!!!!!!

% example inputs: 
% animal = 'EEG74'; rerun = 0;

if nargin < 2
   rerun = 0; % default
end
query = 'Spon';
listOfExpts = getExperimentsByAnimal(animal,query);
if isempty(listOfExpts{1})
   warning(['No experiments found for ' animal ' under ' query '. Trying again with no query']);
   listOfExpts = getExperimentsByAnimal(animal);
end

% for each experiment, check if there is:
% 1) an associated movementBinary.mat file 
% 2) AND a finalMovementArray variable

pathToCheck = 'M:\PassiveEphys\20'; % path stub 
alreadyAnalyzed = zeros(length(listOfExpts),1); % preallocate logical
for ii = 1:size(listOfExpts,1)
    % dirname is the directory where the movementBinary file is located
    dirname = [pathToCheck listOfExpts{ii}(1:2) '\' listOfExpts{ii} '\' ...
        listOfExpts{ii} '-movementBinary' '.mat'];
    dirCheck = dir(dirname); % check directory
    if ~isempty(dirCheck)
        varCheck = who('-file',dirname);
        if any(contains(varCheck,'finalMovementArray'))
            disp([listOfExpts{ii} ' finalMovementArray already exits']);
            alreadyAnalyzed(ii) = 1;
        else
            alreadyAnalyzed(ii) = 0; % if finalMovementArray doesn't exist (e.g. if only the ROI was saved, etc)
        end
    else
        alreadyAnalyzed(ii) = 0; % if directory doesn't exist
    end
end

% exclude experiments that were determined to have already been analyzed, using alreadyAnalyzed
if ~rerun
    listOfExpts(logical(alreadyAnalyzed),:) = [];
end

% check if there are any experiments remaining, then proceed
if ~isempty(listOfExpts)
    dates = unique(cellfun(@(x) x(1:5), listOfExpts(:,1), 'UniformOutput',false),'stable');
    
    animalNum = getAnimalNumber(animal); %utility to find the animal ID number (e.g. 116 in EEG116)
    
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
                % vidFileName = ['W:\Data\PassiveEphys\20' date(1:2) '\' date '-' index '\' date '-' index '-converted.mp4']; %ONLY FOR EEG43 and 47
            end
            dirCheck = dir(vidFileName);
            if ~isempty(dirCheck)
                vidFileName = [dirCheck(1).folder '\' dirCheck(1).name];
                [~,fullROI] = roiVidAnalysisBinary(vidFileName,date,index,fullROI,false); % run the movement analysis
            else
                disp([vidFileName ' not found']);
            end
        end
    end
else
    disp(['No videos remain to be analyzed for ' animal]);
end
end