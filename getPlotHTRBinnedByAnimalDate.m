function [allCenters,allCounts,allHtrEventTimes] = getPlotHTRBinnedByAnimalDate(animalName,exptDate,binSize,displayFigure,nHours)

% new code for plotting HTR!!!!
% Zarmeen, Mallory, Sean!
% given an animal name and date
% 1. create list of indices based on animal name and date
% 2. load in data
% 3. return the events and bin centers so we can pool data

% % test params
% animalName = 'ZZ24';
% exptDate = '23208';

if ~exist("displayFigure","var")
    displayFigure = 0;
end

if ~exist("binSize","var")
    binSize = 5; % minutes -make this a parameter?
end

if ~exist("nHours","var")
    nHours = 2;
end

exptList = getExperimentsByAnimalAndDate(animalName,exptDate,'Spon');

% this is a guess that there's only one ctrl!   not advisable!  please change ASAP!!!
% this is a guess that there's only one ctrl!   not advisable!  please change ASAP!!!
exptList = exptList(1:nHours,:); % this is a guess that there's only one ctrl!   not advisable!  please change ASAP!!!
% this is a guess that there's only one ctrl!   not advisable!  please change ASAP!!!
% this is a guess that there's only one ctrl!   not advisable!  please change ASAP!!!

if displayFigure
    figure;
end

allCenters = [];
allCounts = [];
allHtrEventTimes = [];

for iFile = 1:nHours
    fileNameBase = [getPathGlobal('importedData') '20' exptDate(1:2) '\' exptList{iFile} '\' exptList{iFile}];
    fileNameHTR = [fileNameBase '-HTRevents.mat'];
    fileNameMagData = [fileNameBase '_magnetData'];
    load(fileNameMagData)
    load(fileNameHTR);
    % == here we need to get the time array, and why not also get movement
    % all we need is the time from this array
    downsampleFactor = 10;
    magData = magData(1:downsampleFactor:end);
    magDT = magDT*downsampleFactor;
    timeArrayMag = 0:magDT:(length(magData)-1)*magDT;
    magData = abs(magData-mean(magData));
    magData = magData-mean(magData);
    magData(magData<0) = 0;
    magData = smooth(magData);
    % == here we do the HTR work
    if iFile == 1 % this works, but we need to be really careful about if this is a pre inj 
        recLength = timeArrayMag(end);
        timeArrayMag = timeArrayMag - recLength;
        htrEventTimes = htrEventTimes - recLength;
    end
    minuteSummaryEvents = htrEventTimes/60;
    minuteTimeArray = timeArrayMag/60;
    edges = round(minuteTimeArray(1):binSize:minuteTimeArray(end));
    centers = edges+(binSize/2);

    centers = centers(1:end-1);
    if iFile > 1
        if allCenters(end) > 0 % if we're running more than one hour after t=0
            centers = centers+(allCenters(end)+binSize/2);
        end
    end

    Y = discretize(minuteSummaryEvents,edges);
    Y(isnan(Y)) = []; % if they're outside of bounds, they're likely erroneous due to being too early or too late. TODO - maybe handle these differently?
    [C,~,ic] = unique(Y);
    a_counts = accumarray(ic,1)';
    nBins = length(edges)-1;    
    counts = zeros(1,nBins);
    counts(C) = a_counts;
    allCenters = [allCenters centers];
    allCounts = [allCounts counts];
    allHtrEventTimes = [allHtrEventTimes htrEventTimes];
end

if displayFigure
    bar(allCenters,allCounts);
    xlabel('Time, Mins');
    ylabel('events');
    title([animalName ' ' exptDate]); % TODO add a drug?
    hold on
    xline(0,'r','LineWidth',3)
    drawnow;
end



