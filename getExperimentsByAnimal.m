function [outputList] = getExperimentsByAnimal(animalName,findExptType,ignoreCheck)
% Test params
% animalName = 'DREADD06';
% findExptType = 'CNO';

if nargin <1
   error('At least provide an animal name'); 
end
if nargin <2
   findExptType = '';
end
if nargin <3
   ignoreCheck = true; % this will check to see if we should skip description that say 'ignore'
end

dbConn = dbConnect();

animalID = fetchAdjust(dbConn,['select animalID from animals where animalName=''' animalName '''']); 
if isempty(animalID)
    error('Animal name not found! Check spelling.')
end

exptList = fetchAdjust(dbConn,['SELECT exptID FROM masterexpt WHERE animalID =''' num2str(animalID{1,1}) '''']); %added {1,1} instead of {1} to animalID ZS 18d20


listIncrement = 1;
for iExpt = 1:size(exptList,1) %ZS 2/14/2018
    workingList{iExpt,1} = fetchAdjust(dbConn,['SELECT exptDate FROM masterexpt WHERE exptID =''' num2str(exptList{iExpt,1}) '''']); 
    workingList{iExpt,2} = fetchAdjust(dbConn,['SELECT exptIndex FROM masterexpt WHERE exptID =''' num2str(exptList{iExpt,1}) '''']); 
    workingList{iExpt,2} = workingList{iExpt,2}{1};
    workingList{iExpt,3} = fetchAdjust(dbConn,['SELECT notebookDesc FROM masterexpt WHERE exptID =''' num2str(exptList{iExpt,1}) '''']);
    if ~isempty(strfind(workingList{iExpt,3}{1},findExptType)) || isempty(findExptType) || ~isempty(strfind(workingList{iExpt,3}{1},lower(findExptType)))
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
    outputList ={'',{''}};
    warning('2nd parameter is case sensitive (exclude search to see full list)');
end


iList = 1;

% if description says to ignore
% while ignoreCheck  
%     if ~isempty(strcmp(outputList{iList,2}{:},'Ignore')) ||...
%             ~isempty(strfind(outputList{iList,2}{:},'ignore'))
%         outputList(iList,:) = [];
%     else
%         iList = iList+1;
%     end
%     
%     if iList > size(outputList,1)
%         ignoreCheck = false;
%     end
% end
if ignoreCheck
    exptDesc = cellfun(@(x) x{:}, outputList(:,2), 'un', 0);
    outputList = outputList(~(contains(exptDesc,'ignore') | contains(exptDesc,'Ignore')),:);
    exptDesc = cellfun(@(x) x{:}, outputList(:,2), 'un', 0);
    outputList = outputList(~(contains(exptDesc,'test') | contains(exptDesc,'Test')),:);
end
% cellfun(@isempty,contains(exptDesc,'ignore'))

close(dbConn);



