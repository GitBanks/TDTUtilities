function [singleValueForIndex,moveValuesForEachWindow,peakValsForEachWindow] = plotStimAndMovement(exptDate,exptIndex,doPlot)
%Given an *ephys* expt date and index (ID)
%1. fetch magnet data
%2. fetch stim times
%3. return the movement values associated 

% I kinda rewrote this to handle both stim/resp or spon.  Might be better
% to switch to previous movement plotting, but we need to combine them  and
% make them consistant in any program that calls both.

% exptDate = '21d29';
% exptIndex = '002';


if ~exist('doPlot','var')
    doPlot = true;
end
moveValuesForEachWindow = nan;


disp(['pulling movement for ' exptDate '-' exptIndex]);
% clear all
% 
% exptDate = '21630';
% % exptIndex = '003'; % stim/resp curve 
% % exptIndex = '005'; % single stim type
% exptIndex = '009'; % single stim type
% % exptIndex = '013'; % single stim type
tPreStim = 0.02; %sec % required input for existing data fetch function
tPostStim = 0.2; %sec % required input for existing data fetch function
preStimMovementWindow = 2; %seconds; can't be longer than the time till first stim!
postStimMovementWindow = 2;

%1. fetch magnet data
exptID = [exptDate '-' exptIndex];
[magData,magDT] = HTRMagLoadData(exptID);
magTimeArray = 0:magDT:length(magData)/(1/magDT);
magTimeArray = magTimeArray(1:length(magData));
moveData = abs(magData-mean(magData));
magTimeArray = magTimeArray(1:length(moveData));
movementWindowInSamplesPre = round(preStimMovementWindow*(1/magDT));
movementWindowInSamplesPost = round((postStimMovementWindow+.2)*(1/magDT));



% Warning, we've got a bit of a circular dependancy thing going on here:
% plotStimAndMovement (this program) is called by a number of programs, but needs
% '_peakData' data saved to be efficient.  _peakData is saved in programs
% that call this program (again, in an attempt to be efficient).  This else
% statement fixes that, but be aware of circular issue.  Consider pulling
% out the sections that need this movement data from
% getSynapseSingleStimData and getSynapseStimSetData
%2. fetch stim times - try to load existing data set first
outPath = [getPathGlobal('M') 'PassiveEphys\20' exptDate(1:2) '\' exptDate '-' exptIndex '\'];
if isfile([outPath exptDate '-' exptIndex '_peakData.mat'])
    try
        load([outPath exptDate '-' exptIndex '_peakData'],'peakData');
    catch
        error(['Problem loading ' [outPath exptDate '-' exptIndex '_peakData']]);
    end
    stimTimes = peakData.stimTimes;
    peakValsForEachWindow = peakData.pkVals;
    clear peakData
else
%    error('Program now depends on user to run peak selection program');
    disp('Couldn''t find peakData save file.  Consider running it for faster event related data plotting');
    [~,indexOut,isTank] = getIsTank(exptDate,exptIndex);
    try
        [dataTemp,~] = getSynapseSingleStimData(exptDate,indexOut,tPreStim,tPostStim,isTank);
        stimTimes = dataTemp.stimTimes;
    catch
        [~,~,~,stimTimes] = getSynapseStimSetData(exptDate,indexOut,tPreStim,tPostStim,isTank);
    end
end



if exist('stimTimes','var')
    for iStim = 1:length(stimTimes)
        if magTimeArray(end) < stimTimes(iStim)+(postStimMovementWindow+.2)
            movementsPreStim(iStim) = nan;
            movementsPostStim(iStim) = nan;
        else
            magEvent = find(magTimeArray>stimTimes(iStim),1);
            movementsPreStim(iStim) = mean(moveData(magEvent-movementWindowInSamplesPre:magEvent));
            movementsPostStim(iStim) = mean(moveData(magEvent:magEvent+movementWindowInSamplesPost));
        end
    end
    moveValuesForEachWindow = movementsPreStim;
end

if doPlot && exist('stimTimes','var')
    prePostDiff = movementsPostStim-movementsPreStim;
    figure;
    subtightplot(2,1,1)
    scatter(stimTimes/60,prePostDiff);
    hold on
%     scatter(stimTimes/60,movementsPostStim);
    subtightplot(2,1,2)
    plot(magTimeArray/60,moveData);
    hold on
    scatter(stimTimes/60,prePostDiff);
    hold on
%     scatter(stimTimes/60,movementsPostStim);
end

if doPlot && ~exist('stimTimes','var')
    figure;
    subtightplot(2,1,2)
    plot(magTimeArray/60,moveData);
end

singleValueForIndex = mean(magTimeArray);
