function [S] = getMoveTimeDrugbyAnimalDate(animalName,exptDate)
% [S] = getMoveTimeDrugbyAnimalDate(animalName,exptDate)   
% given: an animalname and a date of its experiment
% return a structure containing:
% 1. a movement array
% 2. a corresponding time array
% 3. the injection time(s)
% 4. drug(s) injected
% 5. sample rate
% 6. drug injected in datetime format
% 7. time array in datetime format
% other notes
% default is to downsample into 1 second windows.  This version doesn't parameterize that.
% both drug manipulation structures describe what drug and when it was given in different ways because I tapped into existing function for one, and simplified the other.  This, obviously, could be improved.
% Time array 'zero' is not adjusted to be relative to injection time to offer flexibility for which injection we want to be t=0.  use treatments.indexOfTimeArray(drugIndex) for the regular time array and drug(drugIndex).time for the datetime version, to pick and adjust t=0.

% test / debug params
% animalName = 'EEG206';
% exptDate = '22622';
% animalName = 'EEG187';
% exptDate = '22222';

disp(['Loading info for: ' exptDate]);
workingList = getExperimentsByAnimalAndDate(animalName,exptDate);
treatments = getTreatmentInfo(animalName,exptDate);

downsampleFactor = round(1/3.2768e-04); %typical for movement data.  This will give us 1 second samples

fullTimeArray = [];
fullMoveStream = [];
fullTimeArrayTOD = [];
previousIndexTimeElapsed = 0;
drugIndex = 1;
for ii = 1:size(workingList,1)
    disp(['Loading data for: ' workingList{ii,1}]);
    thisDate = workingList{ii,1}(1:5);
    thisIndex = workingList{ii,1}(7:9);
    [indexDur,timeOfDay] = getTimeAndDurationFromIndex(thisDate,thisIndex);
    [magData,magDT] = HTRMagLoadData(workingList{ii,1});
    timeArray = 0:magDT:length(magData)*magDT;
    while length(timeArray) > length(magData) %sometimes time is a mystery - this is in case the sample points are one longer than what we calculated by dT
        timeArray = timeArray(1:end-1);
    end
    timeArray = downsample(timeArray,downsampleFactor);
    magData = smooth(abs(magData-mean(magData)),(1/magDT)*4,'sgolay',2);
    magData = downsample(magData,downsampleFactor);
    timeArrayTOD = (timeOfDay : seconds(1) : timeOfDay+indexDur);
    % quick grab and calculate the actual injection time
    if sum(treatments.injIndex(:,ii)) > 0
        for jj = 1:size(treatments.injIndex(:,ii),1)
            if treatments.injIndex(jj,ii)
                drug(drugIndex).what = treatments.pars{jj,ii};
                drug(drugIndex).amount = treatments.vals(jj,ii);
                drug(drugIndex).time = timeArrayTOD(1)-seconds(45);
                treatments.indexOfTimeArray(drugIndex) = length(fullMoveStream);
                drugIndex = drugIndex+1;
            end
        end
    end
    fullTimeArray = cat(2,fullTimeArray,(timeArray+previousIndexTimeElapsed));
    fullTimeArrayTOD = cat(2,fullTimeArrayTOD,timeArrayTOD);
    fullMoveStream = cat(1,fullMoveStream,magData);
    previousIndexTimeElapsed = fullTimeArray(end);
end
% fix any issues with datetime losing accuracy
while length(fullTimeArrayTOD) > length(fullMoveStream) %sometimes time is a mystery - this is in case the sample points are one longer than what we calculated by dT
    fullTimeArrayTOD = fullTimeArrayTOD(1:end-1);
end
%updated dt
dt = downsampleFactor*magDT;
% figure
% plot(fullTimeArray,fullMagStream)
% figure
% plot(fullTimeArrayTOD,fullMagStream)
S.dt = dt;
S.fullTimeArray = fullTimeArray;
S.fullTimeArrayTOD = fullTimeArrayTOD;
S.fullMoveStream = fullMoveStream;
S.treatments = treatments;
S.drugTOD = drug;


