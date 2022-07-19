%% Plot PSM corrected and uncorrected Band Power

folder = ['M:PassiveEphys\mouseLFP\MatlabCSV\']
file = 'ZZ1422117saline0p9_vol'
PSMTable = readtable([folder file]);

folder = ['M:\PassiveEphys\mouseLFP\Power vs Activity\Tables\'];
file = 'deltaPSM_matchedMovement_ZZ1422117saline0p9_voltest';
PSMCorrTable = readtable([folder file]);

windowTimes = PSMTable.winTime
windowGaps = diff(windowTimes);
largeWindowGapLocations = find(windowGaps>median(windowGaps));
tempWindowTimes = windowTimes;
for ii = 1:size(largeWindowGapLocations,1)
    gapTimeLength = windowGaps(largeWindowGapLocations(ii));
    gapIndex = largeWindowGapLocations(ii); % this will be the last element befor the discontinuity
    tempWindowTimes(gapIndex+1:end) = tempWindowTimes(gapIndex+1:end) - gapTimeLength;
end
newArray = PSMTable.winTime(largeWindowGapLocations(1)+1);

PSMTimeArray = PSMTable.winTime - newArray;
PSMCorrTimeArray = PSMCorrTable.winTime - newArray;

treatLine = PSMTimeArray(largeWindowGapLocations(1)+1);

%Plot all together
animalName = 'ZZ14';
thisDrug = 'Saline';
thisDate = '22117';

figure()
subplot(3,1,1)
plot(PSMCorrTimeArray,PSMCorrTable.delta)
title([animalName,' ',thisDate,' ',thisDrug,'',' PSM delta Band Power'])
xline(treatLine,'-',['',thisDrug,''])

subplot(3,1,2)
plot(PSMTimeArray,PSMTable.delta)
title([animalName,' ',thisDate,' ',thisDrug,'',' unmatched delta Band Power'])
xline(treatLine,'-',['',thisDrug,''])

subplot(3,1,3)
plot(PSMTimeArray,PSMTable.meanMovement)
title([animalName,' ',thisDate,' ',thisDrug,' ', 'Movement'])
xline(treatLine,'-',['',thisDrug,''])



%If we want to plot w no gaps
% windowTimes = newSegTimes
% out.segmentTimeOfDay{1,1};
% windowGaps = diff(windowTimes);
% largeWindowGapLocations = find(windowGaps>median(windowGaps));
% tempWindowTimes = windowTimes;
% for ii = 1:size(largeWindowGapLocations,1)
%     gapTimeLength = windowGaps(largeWindowGapLocations(ii));
%     gapIndex = largeWindowGapLocations(ii); % this will be the last element befor the discontinuity
%     tempWindowTimes(gapIndex+1:end) = tempWindowTimes(gapIndex+1:end) - gapTimeLength;
% end
% newWindowTimes = tempWindowTimes(:) - tempWindowTimes(1);
% line = newWindowTimes(largeWindowGapLocations(1));
% endVal = newWindowTimes(end)
% newwindowTimes = cellfun(@(x) x - 11:34:27 , windowTimes, 'un', 0)





