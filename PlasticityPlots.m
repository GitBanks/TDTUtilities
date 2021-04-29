%function plasticityPlots(exptDate,exptIndex)
%this is updated to include the new stim variables as of 04/28/21
clear all

% Load in the data and the appropriate variables - taken from evokedStimAveragesMCStimBatchFile
tPreStim = 0.2;
tPostStim = 0.5;
%timeSpans = 4.9*60; %time in seconds (min*60) to group responses into

indexLabels = {'Baseline','LTP','LTD'}; % these correspond to each stimset we load below

exptDate = '21428';
exptIndex = '009';
[stimSet(1),dTRec] = getPlasticityData(exptDate,exptIndex,tPreStim,tPostStim);

exptDate = '21428';
exptIndex = '013';
[stimSet(2),dTRec] = getPlasticityData(exptDate,exptIndex,tPreStim,tPostStim);

exptDate = '21428';
exptIndex = '015';
[stimSet(3),dTRec] = getPlasticityData(exptDate,exptIndex,tPreStim,tPostStim);



% Plot
figSub = figure();
nRow = length(stimSet);
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
         subtightplot(nRow,nCol,iBrainLoc+(nCol*(iRec-1)))
         try
         plot(plotTimeArray,stimSet(iRec).subMean(iBrainLoc,1:end));
         catch
         plot(plotTimeArray,stimSet(iRec).subMean(iBrainLoc,1:end-1));
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
         
         
         minY = min(minY,min(stimSet(iRec).subMean(iBrainLoc,plotTimeArray>.005&plotTimeArray<.1)));
         maxY = max(maxY,max(stimSet(iRec).subMean(iBrainLoc,plotTimeArray>.005&plotTimeArray<.1)));
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
 
 % Peak Amplitude
  
 
 
 
