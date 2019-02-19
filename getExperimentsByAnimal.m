function [outputList] = getExperimentsByAnimal(animalName,findExptType,ignoreCheck)
% Test params
%animalName = 'DREADD06';
%findExptType = 'CNO';
%animalName = 'EEG53';
%findExptType = 'CNO';

if nargin <1
   error('At least provide an animal name'); 
end
if nargin <2
   findExptType = '';
end
if nargin <3
   ignoreCheck = true; % this will check to see if we should skip description that say 'ignore'
end

% check if version is newer than 2017a. 
fetchAdj = fetchAdjust; %added fetchAdj zs 2/14/2019

dbConn = dbConnect();

animalID = fetch(dbConn,['select animalID from animals where animalName=''' animalName ''''],fetchAdj{:}); 
if isempty(animalID)
    error('Animal name not found! Check spelling.')
end

exptList = fetch(dbConn,['SELECT exptID FROM masterexpt WHERE animalID =''' num2str(animalID{1,1}) ''''],fetchAdj{:}); %added {1,1} instead of {1} to animalID ZS 18d20


listIncrement = 1;
for iExpt = 1:size(exptList,1) %ZS 2/14/2018
    workingList{iExpt,1} = fetch(dbConn,['SELECT exptDate FROM masterexpt WHERE exptID =''' num2str(exptList{iExpt}) ''''],fetchAdj{:}); 
    workingList{iExpt,2} = fetch(dbConn,['SELECT exptIndex FROM masterexpt WHERE exptID =''' num2str(exptList{iExpt}) ''''],fetchAdj{:}); 
    workingList{iExpt,2} = workingList{iExpt,2}{1};
    workingList{iExpt,3} = fetch(dbConn,['SELECT notebookDesc FROM masterexpt WHERE exptID =''' num2str(exptList{iExpt}) ''''],fetchAdj{:});
    if ~isempty(strfind(workingList{iExpt,3}{1},findExptType)) || isempty(findExptType)
        indexN = num2str(workingList{iExpt,2});
        if length(indexN) == 1
            indexN = ['0' indexN];
        end
        if length(indexN) == 2
            indexN = ['0' indexN];
        end
        outputList{listIncrement,1} = [formatDateFive(workingList{iExpt,1}{1}) '-' indexN];
        outputList{listIncrement,2} = workingList{iExpt,3};
        listIncrement = listIncrement+1;
    end
end
if ~exist('outputList','var')
    outputList ={'',''};
    warning('2nd parameter is case sensitive (exclude search to see full list)');
end


iList = 1;
% if description says to ignore
while ignoreCheck  
    if ~isempty(strfind(outputList{iList,2}{:},'Ignore')) ||...
            ~isempty(strfind(outputList{iList,2}{:},'ignore'))
        outputList(iList,:) = [];
    end
    iList = iList+1;
    if iList > size(outputList,1)
        ignoreCheck = false;
    end
end


close(dbConn);



