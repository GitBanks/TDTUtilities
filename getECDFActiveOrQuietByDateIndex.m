function [allF,allX,quietF,quietX,activeF,activeX] = getECDFActiveOrQuietByDateIndex(exptDate,exptIndex)
% Given: Date and Index 
% Do: 
% 1. Get active and quiet trials from
% function(getPeakSlopeAvgByDateIndexWPlot)
% 2. grab movement data
% 3. Put active and quiet trial data into ECDF form 
% 4. return plot handles for active quiet and all sorted trials

% Test Paramters:

% exptDate = '21712'; % these don't seem to work - find out why -
% plotStimAndMovement seems to return different output types (arrays vs
% structures) depending on what type of experiment it it.  we need to
% account for that.
% exptIndex = '003';

exptDate = '21d28';
exptIndex = '006';

% user defined parameters
windowLength = 7; % movement window around stim, in seconds



% need to grab stim times from saved data set
outPath = ['M:\PassiveEphys\20' exptDate(1:2) '\' exptDate '-' exptIndex '\'];
try
    load([outPath exptDate '-' exptIndex '_peakData'],'peakData');
catch
    error(['Problem loading ' [outPath exptDate '-' exptIndex '_peakData']]);
end
stimTimes = peakData.stimTimes;
clear peakData


plotPeaks = 0; %Setting this =0 makes it so the plots dont pop up every time this can be toggled
[dataOut,~] = getPeakSlopeAvgByDateIndexWPlot(exptDate,exptIndex,plotPeaks);

exptID = [exptDate '-' exptIndex];
[magData,magDT] = HTRMagLoadData(exptID); %feeding date and index to function that loads in mag data- returns raw data and diff btwn sample points 
moveData = smooth(abs(magData-mean(magData)),(1/magDT)*4,'sgolay',2); % create our movement values.
magTimeArray = 0:magDT:length(magData)/(1/magDT);
magTimeArray = magTimeArray(1:length(magData));



sampleWindow = round(windowLength*(1/magDT)); %rounding so number is an integer for array below
eventArray = zeros(length(stimTimes)-1,sampleWindow); %Initialize the array- set size and what kind of array it is

for iStim = 1:length(stimTimes)-1
    %create an array of values 7 seconds around each stim
    indexToUse = find(stimTimes(iStim)<magTimeArray,1);
    eventArray(iStim,:) = moveData(indexToUse:indexToUse+sampleWindow-1);
end

quietTrials = eventArray(dataOut.resting(1:end-1),:);
activeTrials = eventArray(dataOut.active(1:end-1),:);


quietTrials = quietTrials(:);
activeTrials = activeTrials(:);
eventArray = eventArray(:);

[quietF,quietX] = ecdf(quietTrials);

[activeF,activeX] = ecdf(activeTrials);


[allF,allX] = ecdf(eventArray);


    
    
%xlim([-0.005,1]);
