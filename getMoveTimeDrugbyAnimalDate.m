function [S] = getMoveTimeDrugbyAnimalDate(animalName,exptDate,overwriteMove)
% [S] = getMoveTimeDrugbyAnimalDate(animalName,exptDate)   
% given: an animalname and a date of its experiment
% return a structure containing:
% 1. a movement array
% 2. a corresponding time array
% 3. the injection time(s)
% 4. drug(s) injected
% 5. sample rate of movement samples
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
% animalName = thisAnimal;
% exptDate = thisDate;
% animalName = 'ZZ06';
% exptDate = '21515';
% 
% animalName = 'ZZ22';
% exptDate = '23105';
% exptDate = '22o26';


if ~exist("overwriteMove","var")
    overwriteMove = true;
end



% add an option to save this days movement information
% first check if a movement file exists in the animal folder
movementFileName = [getPathGlobal('animalSaves') animalName '\' exptDate '-moveTreatInfo.mat'];
if overwriteMove || ~isfile(movementFileName)

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
        try
            [magData,magDT] = HTRMagLoadData(workingList{ii,1});
        catch
            % instead of faking plots w a bunch of nans, load in the old
            % movement data, like: M:\PassiveEphys\2019\19621-001\19621-001-movementBinary
            magData = nan(1,3600*3052);
            magDT = 3.2768e-04;
        end
        timeArray = 0:magDT:length(magData)*magDT;
        while length(timeArray) > length(magData) %sometimes time is a mystery - this is in case the sample points are one longer than what we calculated by dT
            timeArray = timeArray(1:end-1);
        end
        timeArray = downsample(timeArray,downsampleFactor);
        magData = downsample(magData,downsampleFactor);
        % magData = smooth(abs(magData-mean(magData)),(1/magDT)*4,'sgolay',2);
        % % this smoothing seems too extreme
        
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
    %     fullMoveStream = cat(1,fullMoveStream,magData);
        fullMoveStream = cat(2,fullMoveStream,magData);
        previousIndexTimeElapsed = fullTimeArray(end);
    end
    % fix any issues with datetime losing accuracy
    while length(fullTimeArrayTOD) > length(fullMoveStream) %sometimes time is a mystery - this is in case the sample points are one longer than what we calculated by dT
        fullTimeArrayTOD = fullTimeArrayTOD(1:end-1);
    end
    %updated dt
    dt = downsampleFactor*magDT;
    
    fullMoveStream = diff(fullMoveStream);
    fullMoveStream = [fullMoveStream fullMoveStream(end)];
    fullMoveStream = abs(fullMoveStream);
    
    
    
    % clean up drug text from database
    for iDrug = 1:size(drug,2)
        if contains(drug(iDrug).what,'_conc')
            drug(iDrug).what = strrep(drug(iDrug).what,'_conc','');    
        end
        if contains(drug(iDrug).what,'Anlg')
            drug(iDrug).what = drug(iDrug).what(6:end);
        end
        if contains(drug(iDrug).what,'_vol')
            drug(iDrug).what = strrep(drug(iDrug).what,'_vol','');
        end
        if contains(drug(iDrug).what,'_')
            drug(iDrug).what = strrep(drug(iDrug).what,'_','-');
        end
        if contains(drug(iDrug).what,'0p9')
            drug(iDrug).what = strrep(drug(iDrug).what,'0p9','');
        end
    end
    
    
    S.dt = dt;
    S.fullTimeArray = fullTimeArray;
    S.fullTimeArrayTOD = fullTimeArrayTOD;
    S.fullMoveStream = fullMoveStream;
    S.treatments = treatments;
    S.drugTOD = drug;



    save(movementFileName,"S");
else
    load(movementFileName)
end





