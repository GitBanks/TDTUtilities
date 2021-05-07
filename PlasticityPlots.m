%function plasticityPlots(exptDate,exptIndex)


% this is for the 0.1 Hz plasticity expts (with LTP and LTD between).
% this version has discrete sections that can (and should) get pulled out
% for readability and modularity (plotPlasticityAmplitudePeaks() is already
% an alternative version we might prefer, e.g.)


%this is updated to include the new stim variables as of 04/28/21
clear all


% % % % =========  load data in this block  ========= % % % %
% Load in the data and the appropriate variables - taken from evokedStimAveragesMCStimBatchFile
tPreStim = 0.2;
tPostStim = 0.5;
%timeSpans = 4.9*60; %time in seconds (min*60) to group responses into

indexLabels = {'Baseline','LTP','LTD'}; % these correspond to each stimset we load below

exptDate = '21428';
exptIndex = '009';
%evokedData = struct();
%[stimSet(1),dTRec] = getPlasticityData(exptDate,exptIndex,tPreStim,tPostStim);
[evokedData(1),dTRec] = getSynapseSingleStimData(exptDate,exptIndex,tPreStim,tPostStim);

exptDate = '21428';
exptIndex = '013';
%[stimSet(2),dTRec] = getPlasticityData(exptDate,exptIndex,tPreStim,tPostStim);
[evokedData(2),dTRec] = getSynapseSingleStimData(exptDate,exptIndex,tPreStim,tPostStim);

exptDate = '21428';
exptIndex = '015';
%[stimSet(3),dTRec] = getPlasticityData(exptDate,exptIndex,tPreStim,tPostStim);
[evokedData(3),dTRec] = getSynapseSingleStimData(exptDate,exptIndex,tPreStim,tPostStim);

% % % % ============ plot raw data overlay ============= % % % %
% Raw subtracted traces
%dTRec = stimSet.dT;

plotTimeArray = -tPreStim:dTRec:tPostStim;
figure()
for iSet = 1:size(evokedData,2)
    subtightplot(3,1,iSet);
    try
        plot(plotTimeArray,squeeze(evokedData(iSet).sub(1,:,:)),'k','LineWidth',2);
    catch
        plot(plotTimeArray,squeeze(evokedData(iSet).sub(1,:,1:end-1)),'k','LineWidth',2);
    end
    hold on
%         try
%         plot(plotTimeArray,squeeze(mean(stimSet(iSet).sub(1,:,:),2)),'k','LineWidth',2)
%         catch
%         plot(plotTimeArray,squeeze(mean(stimSet(iSet).sub(1,:,1:end-1),2)),'k','LineWidth',2)
%         end
    ylim([-2e-4,2e-4]);
end

% % % % ============ plot peak amplitude time series and get rise time and slope(MIN) ============= % % % %

%finding peak amplitude
%iSet = 2;
iChan = 1;

plotTimeArray = -tPreStim:dTRec:tPostStim;
beginTimeWindow = .005; %this is start of time window
endTimeWindow = .02; %this is end of time window

figure()
minY = 0;
maxY = 0;
%plotColor = {'or','ob','ok'};
for iSet = 1:size(evokedData,2)
% peak min
searchWindow = plotTimeArray>beginTimeWindow&plotTimeArray<endTimeWindow;
[MinA,Imin] = min(evokedData(iSet).subMean(iChan,searchWindow)); % this finds the lowest point within a range
startIndex = find(plotTimeArray>beginTimeWindow,1,'First'); % this is the beginning of the slope
minPeakIndex = startIndex+(Imin);

avgMinPeaks = mean(evokedData(iSet).subMean(iChan,minPeakIndex+startIndex-4:minPeakIndex+startIndex+4));
minBaseline = mean(evokedData(iSet).subMean(iChan,1:100));

%This will plot out time series of every averaged peak
% figure();
% plot(avgMinPeaks-minBaseline,'o'); %This step corrects for the baseline and also plots

%plot out trace to confirm following rise time calculations
responseTrace = evokedData(iSet).subMean(iChan,searchWindow);
% figure;
% plot(plotTimeArray(searchWindow),responseTrace)
% find rise time - note, might need to shorten search window to include
% relevant peak contrary to this, be sure to exclude any irrelevant peaks
% the function WILL pick up largest peak

%Find slope of the line from start of riseTime to peak
timeWindowOfInterest = plotTimeArray(searchWindow);
responseVar = stepinfo(responseTrace,timeWindowOfInterest,MinA);

slopeStart = find(timeWindowOfInterest>responseVar.PeakTime-responseVar.RiseTime,1,'First');
slopeEnd = find(timeWindowOfInterest==responseVar.PeakTime,1,'First');

%BAD HAX
slopeStart = round(slopeStart/2);


t = 1:length(slopeStart:slopeEnd);
p = polyfit(t,responseTrace(slopeStart:slopeEnd),1);

%This is calculating the slope and the intercept
yfit = p(1)*t+p(2);
% %tiny plot version
% figure();plot(t,responseTrace(slopeStart:slopeEnd)); hold on; plot(t,yfit,'r-.'); 
% annotation('textbox',[.5,.8,.1,.1],'String', ['Slope of the Line = ' num2str(p(1))]);
% larger plot version

subtightplot(3,1,iSet);
plot(timeWindowOfInterest,responseTrace); 
hold on; 
plot(timeWindowOfInterest(slopeStart:slopeEnd),yfit,'r-.'); 
% annotation('textbox',[.5,.8,.1,.1],'String', ['Slope of the Line = ' num2str(p(1))]);
ylabel(['Slope of the Line = ' num2str(p(1)) ]);
title(indexLabels(iSet));

minY = min(minY,min(responseTrace));
maxY = max(maxY,max(responseTrace));

end

minY = minY*1.05;
maxY = maxY*1.05;
for iSet = 1:size(evokedData,2)
    subtightplot(3,1,iSet);
    ylim([minY,maxY]);
end





% % % % ============ plot peak amplitude and get rise time (MAX) ============= % % % %




% Identical to finding peak for min, this is relevant for the longer
% component of LTP
% % peak max
% [MaxA,Imax]=max(stimSet(iSet).subMean(1,plotTimeArray>.005&plotTimeArray<.1));
% 
% maxPeakIndex = startIndex+(Imax)
% 
% %this is peak amp max
% stimSet(iSet).subMean(1,maxPeakIndex);
% 







% % % % ============ plot comparison of baseline, LTP LTD  ============= % % % %
figSub = figure();
nRow = length(evokedData);
nCol = 3;
figure(figSub);
plotTimeArray = -tPreStim:dTRec:tPostStim;
useChannels = [2,4,6];
colLabels = {'Ipsi mPfc','Contra mPFC','Contra vCA1'};
minY = 0;
maxY = 0;
for iRec = 1:nRow
     for iBrainLoc = 1:nCol
         subtightplot(nRow,nCol,iBrainLoc+(nCol*(iRec-1)));
%          subtightplot(nRow,nCol,iBrainLoc+(nCol*(iRec-1)))
         try
            plot(plotTimeArray,evokedData(iRec).subMean(iBrainLoc,1:end));
         catch
            plot(plotTimeArray,evokedData(iRec).subMean(iBrainLoc,1:end-1));
        end
             
         hold on;
         line([0 0], [-1 1],'Color','red','LineStyle','--');
         if iRec ==1
             title(colLabels(iBrainLoc));
         end
         if iBrainLoc ~= 1
             set(gca,'YTickLabel',[],'YTick',[]);
         end
         if iBrainLoc == 1
            ylabel(indexLabels(iRec));
         end    
         
%          if iRow == nRow
%              set(gca,'XTick',[0,0.25],'XTickLabel',{'t=0','t=.25'});
%          else
%              set(gca,'XTickLabel',[],'XTick',[]);
%          end
         
         
         minY = min(minY,min(evokedData(iRec).subMean(iBrainLoc,plotTimeArray>.005&plotTimeArray<.1)));
         maxY = max(maxY,max(evokedData(iRec).subMean(iBrainLoc,plotTimeArray>.005&plotTimeArray<.1)));
         xlim([-0.01,0.05]);
         drawnow;
     end
 end

 minY = minY*1.05;
 maxY = maxY*1.05;
 for iRec = 1:nRow
     for iBrainLoc = 1:nCol
         subtightplot(nRow,nCol,iBrainLoc+(nCol*(iRec-1)))
         ylim([minY,maxY]);
     end
 end
 

  
 
 
 
