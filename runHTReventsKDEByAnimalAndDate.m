function [yEvents,fullTimeArray,fullMagStream,fullEventTimes,timeSteps] = runHTReventsKDEByAnimalAndDate(animalName,date,treatment,overWrite,gaussLength)

% overWrite = false;
% treatment = 'psilocybin';
% gaussLength = 120;
% animalName = 'ZZ14';
% date = '22117';



rootFolder = ['M:\PassiveEphys\AnimalData\' animalName];
if exist(rootFolder,'dir') ~=7
    mkdir(rootFolder)
end
saveTreatment = treatment;
saveTreatment = strrep(saveTreatment,';','');
saveTreatment = strrep(saveTreatment,' ','');
fileName = [rootFolder '\pdfHTRevents-' num2str(gaussLength) '-' saveTreatment '.mat'];

if ~isfile(fileName) || overWrite
    outputList = getExperimentsByAnimalAndDate(animalName,date);
    %step through each index for that day
    injectionTime = []; % now handled by getTreatmentInfo
    fullTimeArray = [];
    fullMagStream = [];
    fullEventTimes = [];
    timeSteps = zeros(1,size(outputList,1));
    previousIndexTimeElapsed = 0;
    for idx = 1:size(outputList,1)
        try
            [magData,magDT] = HTRMagLoadData(outputList{idx,1});
        catch
            fileMaint(subTable.AnimalName{iList});
        end
        plotEnable = false;
        [htrEventTimes] = HTRMagDetectionHandler(outputList{idx,1},plotEnable);% get HTR times 
        timeArray = 0:magDT:length(magData)*magDT;
        while length(timeArray) > length(magData) %sometimes time is a mystery
            timeArray = timeArray(1:end-1);
        end
        fullTimeArray = cat(2,fullTimeArray,(timeArray+previousIndexTimeElapsed));
        fullMagStream = cat(2,fullMagStream,magData);
        fullEventTimes = cat(2,fullEventTimes,htrEventTimes+previousIndexTimeElapsed);
        previousIndexTimeElapsed = previousIndexTimeElapsed+timeArray(end);
        timeSteps(idx) = previousIndexTimeElapsed;
    end

    % = = downsample here = = 
    fullTimeArray = fullTimeArray(1:10:end);
    fullMagStream = fullMagStream(1:10:end);
    magDT_DS = magDT*10;

    % TODO need to be sure the following calculation is correct
    %             pdEvents = fitdist(fullEventTimes','Kernel','BandWidth',gaussLength);
    %             yEvents = pdf(pdEvents,fullTimeArray);
    % concat all events
    % convolve
    % / nAnimals
    % / by time resolution
    yEvents = zeros(1,size(fullTimeArray,2));
    for iTrial = 1:size(fullEventTimes,2)
        yEvents(find(fullTimeArray>fullEventTimes(iTrial),1,'first')) = 1;
    end


    % numbers are seconds, so 8 minutes wide, with a sigma of
    % gaussLength (seconds)
    gaussFilt = normpdf([-240:magDT_DS:240],1,gaussLength);
    yEvents = conv(yEvents,gaussFilt,'same');


    save(fileName,'yEvents','fullTimeArray','fullMagStream','fullEventTimes','timeSteps');
else
    load(fileName,'yEvents','fullTimeArray','fullMagStream','fullEventTimes','timeSteps');
end









