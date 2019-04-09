
animal = 'EEG74';
exptDate = '19405';

listOfExpts = getExperimentsByAnimal(animal); %grab relevant experiments & construct file name array
rootDir = ['W:\Data\PassiveEphys\20' exptDate(1:2) '\']; %root directory to load videos. Should only be W for all animals
[fileNameList,exptDesc] = findVideoFiles(listOfExpts,exptDate,rootDir); %grab list of video file names

disp('starting movement calculation.');
pixROI = [];

figure();
for iFile = 1:length(fileNameList)
    tic
    fileName = fileNameList{iFile};
    [finalMovementArray,timeGrid,pixROI] = videoROIMakerAll_test(fileName,pixROI);
    toc   
    subplot(length(fileNameList),1,iFile)
    plot(finalMovementArray);
    title(fileName(end-8:end));
end
