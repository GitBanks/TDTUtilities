function [dataOut,figH] = getPeakSlopeAvgByDateIndexWPlot(exptDate,exptIndex,plotPeaks)
% Given: a date and an index
% optional: plotPeaks boolean - if you want to see the plots or not
% Do: 
% 1. splits trials into high and low movement (active and resting)  
% 2. produces scatterplots for movement against the peak evoked response
% accross the index (blue dots are quiet and orange are active) 
% 3. plots average trials below 
% 4. returns data out structure 


if ~exist('plotPeaks','var')
    plotPeaks = false;
end


dataLabels = {'ipsi PFC','contra PFC','vCA1'};
outlierSTD = 3;

% here are a few stim-resp expts we just ran
% exptDate = '21616';
% exptIndex = '010';
% exptIndex = '018';
% exptIndex = '022';

doMovePlot = false;
% pull needed data
[~,moveValuesForEachWindow,peakValsForEachWindow] = plotStimAndMovement(exptDate,exptIndex,doMovePlot);

% the following were determined in getMovementDataFromHTRByDateIndex(exptDate,exptIndex,useCDF) so I'm not sure if we need to run it, or display it or what 
restingThresh = 0.1;
activeThresh = 0.15;
theseAreResting = moveValuesForEachWindow<restingThresh;
theseAreActive = moveValuesForEachWindow>activeThresh;
% We need to pull the unaveraged trials again (because obviously, we're
% sorting them)
tPreStim = 0.02;
tPostStim = 0.2;
disp(['loading peaks for ' exptDate '-' exptIndex]);
ephysData = getImportedSynapseEvokedData(exptDate,exptIndex,tPreStim,tPostStim);
restingAvgMovement = mean(moveValuesForEachWindow(theseAreResting));
curatedPeakValsForEachWindow = peakValsForEachWindow;
for iROI = 1:3
    upperB = mean(peakValsForEachWindow(iROI,:))+std(peakValsForEachWindow(iROI,:))*outlierSTD;
    lowerB = mean(peakValsForEachWindow(iROI,:))-std(peakValsForEachWindow(iROI,:))*outlierSTD;
    rejectThese = curatedPeakValsForEachWindow(iROI,:)>upperB | curatedPeakValsForEachWindow(iROI,:)<lowerB;
    disp(['removed ' num2str(sum(rejectThese)) ' outliers in ROI: ' dataLabels{iROI} ' using ' num2str(outlierSTD) 'x stDev threshold']);
    curatedPeakValsForEachWindow(iROI,rejectThese) = nan;
    restingAvgPeak(iROI) = mean(curatedPeakValsForEachWindow(iROI,theseAreResting),'omitnan');
    % we need a slight... circumlocution because polyfit doesn't like nans
    tempArrayA = moveValuesForEachWindow(theseAreActive);
    tempArrayB = curatedPeakValsForEachWindow(iROI,theseAreActive);
    tempArrayA(isnan(tempArrayB)) = [];
    tempArrayB(isnan(tempArrayB)) = [];
    p = polyfit(tempArrayA,tempArrayB,1);
    activeYhat(iROI,:) = polyval(p,moveValuesForEachWindow(theseAreActive));
    activeSlope(iROI) = p(1);
    activeIntercept(iROI) = p(2);
    stdYbyROI(iROI) = std(curatedPeakValsForEachWindow(iROI,theseAreResting),'omitnan');
end

if plotPeaks
    outlierMove = mean(mean(stdYbyROI,2))*3;
    disp(['plotting ' exptDate '-' exptIndex]);
    figH = figure();
    maxYforAll=nan;
    minYforAll=nan;
    for iROI = 1:3
        subtightplot(2,3,iROI);
        scatter(moveValuesForEachWindow(theseAreResting),curatedPeakValsForEachWindow(iROI,theseAreResting));
        hold on
        scatter(moveValuesForEachWindow(theseAreActive),curatedPeakValsForEachWindow(iROI,theseAreActive));
        plot(moveValuesForEachWindow(theseAreActive),activeYhat(iROI,:),'r');
        scatter(restingAvgMovement,restingAvgPeak(iROI),100,'r','d','filled');
        subtightplot(2,3,3+iROI);
        plot(squeeze(mean(ephysData.sub(iROI,theseAreResting,:))));
        hold on
        plot(squeeze(mean(ephysData.sub(iROI,theseAreActive,:))));
        drawnow;
        localMax = max(max(curatedPeakValsForEachWindow(iROI,theseAreResting)),max(curatedPeakValsForEachWindow(iROI,theseAreResting)));
        localMin = min(min(curatedPeakValsForEachWindow(iROI,theseAreResting)),min(curatedPeakValsForEachWindow(iROI,theseAreResting)));
        % if this ROI std is not an outlier,  
        if outlierMove > stdYbyROI(iROI) 
            scaleThisPlot(iROI) = true;
            maxYforAll = max(maxYforAll,localMax);
            minYforAll = min(minYforAll,localMin);
        else
            scaleThisPlot(iROI) = false;
        end
    end
    for iROI = 1:3
        subtightplot(2,3,iROI);
        title(dataLabels{iROI});
        %if scaleThisPlot
            ax = gca;
%             ax.YLim = [min(minYbyROI)*1.05,max(maxYbyROI)*1.05];
            ax.YLim = [minYforAll*1.05,maxYforAll*1.05];
        %end
        if iROI == 1
            ylabel('movement vs peak amp');
        else
            yticks([ ]);
        end
        xticks([ ]);
        subtightplot(2,3,3+iROI);
        if iROI == 1
            ylabel('avg traces by activity lvl'); 
        else
            yticks([ ]);
        end
        xticks([ ]);
        drawnow;
    end
else
    figH = [];
end

dataOut.date = exptDate;
dataOut.index = exptIndex;
dataOut.restingAvgMovement = restingAvgMovement;
dataOut.restingAvgPeak = restingAvgPeak;
dataOut.peaks = curatedPeakValsForEachWindow;
dataOut.active = theseAreActive;
dataOut.resting = theseAreResting;
dataOut.activeYhat = activeYhat;
dataOut.activeSlope = activeSlope;
dataOut.activeIntercept = activeIntercept;
disp('Done!');
disp(' ');
end

