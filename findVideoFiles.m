function [fileNameList,exptDesc] = findVideoFiles(listOfExpts,exptDate,rootDir)

listIndex = 1; %set iterant (?) to 1, only increases when a video file is successfully found
disp('finding video files');
tic
for iExpt = 1:size(listOfExpts,1)
    if isempty(listOfExpts{iExpt,1})
        error('This step is only set to run on spon experiments for now.')
    end
    if ~isempty(strfind(listOfExpts{iExpt,1}(1:5),exptDate))
        operationList{listIndex} = listOfExpts{iExpt,1};
        vidFile = dir([rootDir operationList{listIndex} '\*.avi*']);
        try %the following section *should* be good for Synapse.
            if isempty(vidFile)
                error(['No video found for' operationList{listIndex}  '. Check that path is OK.']);
            else
                fileNameList{listIndex} = [rootDir operationList{listIndex} '\' vidFile.name];
                exptDesc{listIndex} = listOfExpts{iExpt,2};
                listIndex = listIndex+1;
            end
        catch %for old system WIP TODO: find how old system data were named.
            vidFile = dir([rootDir operationList{listIndex} '\' operationList{listIndex}]); %'*.'
            if isempty(vidFile)
                warning(['No video found for ' operationList{listIndex}  '. Check that path is OK.']);
            else
                fileNameList{listIndex} = [rootDir operationList{listIndex} '\' vidFile.name];
                exptDesc{listIndex} = listOfExpts{iExpt,2};
                listIndex = listIndex+1;
            end
        end
    end
end
toc