function evokedStimAveragesMCStimBatchFile(exptDate,exptIndex)
tPreStim = 0.2;
tPostStim = 0.5;
% timeSpans = 4.9*60; %time in seconds (min*60) to group responses into

% exptDate = '21303';
% exptIndex = '001';
% exptDate = '21303';
% exptIndex = '012';
% 
% exptDate = '21503';
% exptIndex = '005';

% exptDate = '21503';
% exptIndex = '003';
% exptDate = '21426';
% exptIndex = '010';
%  exptDate = '21311';
%  exptIndex ='009';
% exptDate = '21503';
% exptIndex = '005';

exptDate = '21505';
exptIndex = '004';
exptDate = '21505';
exptIndex = '005';

%  exptDate = '21426';
%  exptIndex = '010';
 %exptDate = '21311';
 %exptIndex ='009';

chanLabels = {'ipsi mPFC','contr mPFC','contra vHipp'};
% load saved trial pattern
saveFileRoot = ['W:\Data\PassiveEphys\20' exptDate(1:2) '\' exptDate '-' exptIndex '\'];
load([saveFileRoot  'stimSet-' exptDate '-' exptIndex],'stimArray','trialPattern');
for iStim = 1:length(stimArray)
    ampLabel{iStim} = [num2str(stimArray(iStim)) '\mu' 'A'];
end

data = TDTbin2mat(saveFileRoot); % TDT loads the raw data
% TODO! % % % % % % % % % % %  4/27/21 note: above is the first choice we need to make - do we really
% want to load in raw data here, or depend on the imported data?

% the 'Snc_' is the new (as of 4/27/21) method of finding stim times.  We still
% want the old method in case we need to look at older data ('else' section)
% if isfield(data.epocs,'stim') % this is the stim presentation info, we are getting this from the epocs
%      streamName = 'stim';
% end
if isfield(data.epocs,'Snc_') % this is the stim presentation info, we are getting this from the epocs
    streamName = 'Snc_'; % this is the synchronization in to the RZ5 - better than 'stim out' time
    stimTimes = data.epocs.(streamName).onset;
else
    % one of the following will be true (otherwise error out)
    if isfield(data.streams,'eS1r')
        streamName = 'eS1r';
    end
    if isfield(data.streams,'eSmr')
        streamName = 'eSmr';
    end
    triggerPulses = data.streams.(streamName).data > 0;
    if ~exist('triggerPulses','var')
        error('problem finding stream or loading data');
    end
    % % % % %  4/27/21 note: below, here, we're still using the old way to get
    % the stim times. 
    % This should find all the pulse times according to Synapse
    tStimArray = [];
    triggerIterator = 1;
    while triggerIterator < length(triggerPulses)
        if triggerPulses(triggerIterator) == true
            tStimArray = [tStimArray triggerIterator];
            triggerIterator = triggerIterator+(5*round(data.streams.(streamName).fs));
           % triggerIterator = triggerIterator+(5*round(data.streams.(streamName).fs));
        end
        triggerIterator = triggerIterator+1;
    end
    dTStim = 1/data.streams.(streamName).fs;
    %dTStim = 1/data.streams.(streamName).fs;
    timeArrayStim = (0:dTStim:length(data.streams.(streamName).data)*dTStim-dTStim);
    %timeArrayStim = (0:dTStim:length(data.streams.(streamName).data)*dTStim-dTStim);
    % % show detected stim times
    % figure();
    % plot(timeArrayStim,data.streams.eS1r.data)
    % hold on
    % plot(timeArrayStim(uniqueTTL),zeros(length(uniqueTTL),1),'*')
    stimTimes = timeArrayStim(tStimArray);
end

%stimTimes = stimTimes+.01; %secret time adjustment for old stim tracking
%system


% data are stored like this:
% data.streams.LFP1.data(4,:)
% data.streams.EEGw.data(4,:)
% 1. step through rec types (data.streams.LFP1,data.streams.EEGw)
dataType = 'LFP1';
dTRec = 1/data.streams.(dataType).fs; % get sample rate and recording times
timeArrayRec = (0:dTRec:length(data.streams.(dataType).data)*dTRec-dTRec);



nChans = size(data.streams.(dataType).data,1);
nROIs = floor(nChans/2); %Assuming twisted pair and local bipolar rereferencing
nStims = length(stimTimes); % we want to know how long the expected stim pattern lasts in case erroneous pulses (at end) are found.
if nStims ~= length(trialPattern)
    disp(['WARNING! Number of stims in Synapse data file = ' num2str(nStims)...
        ' but length of trialPattern = ' num2str(length(trialPattern))]);
    if nStims<length(trialPattern)
        disp('Truncating trialPattern to match nStims...')
        trialPattern = trialPattern(1:nStims);
    else
        disp('Padding trialPattern to match nStims...')
        temp(1:length(trialPattern)-nStims) = trialPattern(end);
        temp = [trialPattern temp];
    end
end
%create the structure: stimSet, with different arrays of channels x trials x dataPoints
% First get indices corresponding to each stimulus
stimIndex = zeros(1,nStims);
for iTrial = 1:nStims
    stimIndex(iTrial) = find(timeArrayRec>stimTimes(iTrial),1,'first');
end
preStimIndex = floor(tPreStim/dTRec);
postStimIndex = ceil(tPostStim/dTRec);
% figure()
% plot(data.streams.(dataType).data(1,:));
% hold on
% plot(stimIndex,4.e-3+zeros(1,length(stimIndex)),'vr');
stimSet = struct();
for iStim = 1:length(stimArray) %Loop over all stim levels. These are indexed as integers 1:nStim
    % First grab all trials on which this stim was presented
    trialLgcl = trialPattern==iStim; % = true only when trialPattern is this stim
    theseStim = stimIndex(trialLgcl);
    for iTrial = 1:length(theseStim)
        iStart = theseStim(iTrial)-preStimIndex;
        iStop = theseStim(iTrial)+postStimIndex;
        for iChan = 1:nChans
            stimSet(iStim).data(iChan,iTrial,:) = data.streams.(dataType).data(iChan,iStart:iStop);
        end
    end
    for iSub = 1:nROIs
        stimSet(iStim).sub(iSub,:,:) = stimSet(iStim).data(iSub*2,:,:) - stimSet(iStim).data(iSub*2-1,:,:);
    end
end

%     for iChannel = 1:nChans
%         trialIterator = 1;
%         for iTrial = 1:nStims %length(stimTimes)-1
%             % look to be sure it's the correct stim type according to the trialPattern       
%             % !!...test this..!!          
%             if isequal(iStim,trialPattern(iTrial))
% 
%                 thisStim = find(timeArrayRec>stimTimes(iTrial),1);
%                 %trialsInSpan(iTrial) = find(spansT>thisStim,1);
%                 stimSet(iStim).data(iChannel,trialIterator,:) = data.streams.(dataType).data(iChannel,thisStim-round(tPreStim*data.streams.(dataType).fs):round(tPostStim*data.streams.(dataType).fs)+thisStim);
%                 if mod(iChannel,2)==0
%                     stimSet(iStim).sub(iChannel/2,trialIterator,:) = stimSet(iStim).data(iChannel,trialIterator,:) - stimSet(iStim).data(iChannel-1,trialIterator,:);
%                 end
%                 trialIterator = trialIterator +1;
%             end
%         end
%     end
% end

%find the mean for both the raw data and the subtraction
plotMax = -1.e10;
plotMin = 1.e10;
minLatency = 3.e-3; %In seconds
for iStim = 1:length(stimSet)
    stimSet(iStim).dataMean = squeeze(mean(stimSet(iStim).data,2));
    stimSet(iStim).subMean = squeeze(mean(stimSet(iStim).sub,2));
    plotMax = max([plotMax,max(stimSet(iStim).subMean(:,preStimIndex+ceil(minLatency/dTRec):end))]);
    plotMin = min([plotMin,min(stimSet(iStim).subMean(:,preStimIndex+ceil(minLatency/dTRec):end))]);
end

plotTimeArray = dTRec*(-preStimIndex:postStimIndex);
figure()
for iROI = 1:nROIs
    subplot(1,nROIs,iROI)
    hold on
    for iStim = 1:length(stimSet)
        plot(plotTimeArray,stimSet(iStim).subMean(iROI,:));
    end
    ax = gca;
    ax.YLim = [1.05*plotMin,1.05*plotMax];
    ax.XLabel.String = 'time(sec)';
    if iROI == 1
        ax.YLabel.String = 'avg dataSub (V)';
    end
    ax.Title.String = chanLabels{iROI};
    if iROI == nROIs
        legend(ampLabel);
    end
end

%figSub = figure();
%nRow = length(stimSet)/2;
%nCol = 3;
%figure(figSub);
%plotTimeArray = -tPreStim:dTRec:tPostStim;
%useChannels = [2,4,6];
%colLabels = {'Contra mPFC','Ipsi mPFC','Contra vCA1'};
%for iRow = 1:nRow
    %for iCol = 1:nCol
        %subtightplot(nRow,nCol,iCol+(nCol*(iRow-1)));
        %subtightplot(nRow,nCol,iCol+(nCol*(iRow-1)))
        %try
        %plot(plotTimeArray,stimSet(iRow).subMean(iCol,1:end),'b');
        %hold on
        %catch
        %plot(plotTimeArray,stimSet(iRow).subMean(iCol,1:end-1),'b');
        %hold on
        %end
        
        %try
        %plot(plotTimeArray,stimSet(nRow+iRow).subMean(iCol,1:end),'r');
        %hold on
        %catch
        %plot(plotTimeArray,stimSet(nRow+iRow).subMean(iCol,1:end-1),'r');
        %hold on
        %end
            
        
        %hold on;
         %line([0 0], [-1 1],'Color','red','LineStyle','--');
         %if iRow ==1
             %title(colLabels(iCol));
         %end
        %if iRow ~= length(stimSet)
            % set(gca,'YTickLabel',[],'YTick',[]);
        % end
        % if iCol == 1
           %  ylabel(['amp' num2str(ampLabel(iRow)) 'uA']);
%             if stimSetData(iCol).setNumber == 1
%                 title(['pre LTP stim. n=' num2str(size(stimSetData(iCol).subData,2))]);
%             else
%                 title(['post LTP stim n=' num2str(size(stimSetData(iCol).subData,2))]);
%             end
        % end    
        % if iRow == nRow
            % set(gca,'XTick',[0,0.25],'XTickLabel',{'t=0','t=.25'});
        % else
             %set(gca,'XTickLabel',[],'XTick',[]);
        % end
        % ylim([-40.0000,40.0000]);
        % xlim([-0.2,0.5]);
         %drawnow;
    % end
 %end
% 
% 
% 
% 
% % 
% % 
%  figSub = figure();
%  nRow = length(stimSet);
%  nCol = 3;
%  figure(figSub);
%  useChannels = [2,4,6];
%  colLabels = {'Contra mPFC','Ipsi mPFC','Contra vCA1'};
%  minY = 0;
%  maxY = 0;
%  for iRow = 1:nRow
%      for iCol = 1:nCol
%          %subtightplot(nRow,nCol,iCol+(nCol*(iRow-1)));
%          subtightplot(nRow,nCol,iCol+(nCol*(iRow-1)))
%          try
%          plot(plotTimeArray,stimSet(iRow).subMean(iCol,1:end));
%          catch
%          plot(plotTimeArray,stimSet(iRow).subMean(iCol,1:end-1));
%         end
%              
%          hold on;
%          line([0 0], [-1 1],'Color','red','LineStyle','--');
%          if iRow ==1
%              title(colLabels(iCol));
%          end
%          if iRow ~= length(stimSet)
%              set(gca,'YTickLabel',[],'YTick',[]);
%          end
% %          if iCol == 1
% %              ylabel([num2str(ampLabel(iRow)) 'uA']);
% % %             if stimSetData(iCol).setNumber == 1
% % %                 title(['pre LTP stim. n=' num2str(size(stimSetData(iCol).subData,2))]);
% %  %             else
% %  %                 title(['post LTP stim n=' num2str(size(stimSetData(iCol).subData,2))]);
% %  %             end
% %          end    
%          
%          minY = min(minY,min(stimSet(iRow).subMean(iCol,plotTimeArray>.002)));
%          maxY = max(maxY,max(stimSet(iRow).subMean(iCol,plotTimeArray>.002)));
%          xlim([-0.01,0.05]);
%          drawnow;
%      end
%  end
%  
%  minY = minY*1.05;
%  maxY = maxY*1.05;
%  for iRow = 1:nRow
%      for iCol = 1:nCol
%          subtightplot(nRow,nCol,iCol+(nCol*(iRow-1)))
%          ylim([minY,maxY]);
%          xlim([-0.01,0.05]);
%          if iRow == nRow
%              set(gca,'XTick',[0,0.025],'XTickLabel',{'t=0','t=.025'});
%          else
%              set(gca,'XTickLabel',[],'XTick',[]);
%          end
%      end
%  end
 
 

% 
% % 2. step through channels (data.streams.EEGw.data(i,:))
% for iChan = 1:size(data.streams.(iType).data,1)
%     % 3. step through stims (unique TTL / stim times)
%     for iTrial = 1:length(stimTimes)-1
%         thisStim = find(timeArrayRec>stimTimes(iTrial),1);
%         if ~isempty(find(spansT>thisStim,1))
%             trialsInSpan(iTrial) = find(spansT>thisStim,1);
%             trialData(iChan,iTrial,:) = data.streams.(iType).data(iChan,thisStim-round(tPreStim*data.streams.(iType).fs):round(tPostStim*data.streams.(iType).fs)+thisStim);
%             if mod(iChan,2)==0
%                 subData(iChan,iTrial,:) = trialData(iChan,iTrial,:) - trialData(iChan-1,iTrial,:);
%             end
%         end
%     end
% end


% %now use trialsInSpan logical to sort time spans into structure, also
% %build span across experiments iExpt
% for jj = 1:length(spansT)
%     stimSetData(sIterator).trialData(:,1:sum(logical(trialsInSpan==jj)),:) = trialData(:,logical(trialsInSpan==jj),:);
%     stimSetData(sIterator).subData(:,1:sum(logical(trialsInSpan==jj)),:) = subData(:,logical(trialsInSpan==jj),:);
%     %might as well do mean calc here too
%     stimSetData(sIterator).trialDataMean = squeeze(mean(trialData(:,logical(trialsInSpan==jj),:),2));
%     stimSetData(sIterator).subDataMean = squeeze(mean(subData(:,logical(trialsInSpan==jj),:),2));
%     stimSetData(sIterator).setNumber = iExpt;
%     sIterator = sIterator+1;
% end


% figSub = figure();
% figure(figSub);
% plotTimeArray = -tPreStim:dTRec:tPostStim;
% useChannels = [2,4];
% iCol = 1;
% iRow = 1;    
% try
% plot(plotTimeArray,stimSetData(1).subDataMean(useChannels(iRow),1:end));
% catch
% plot(plotTimeArray,stimSetData(1).subDataMean(useChannels(iRow),1:end-1));
% end
% 
% hold on;
% try
% plot(plotTimeArray,stimSetData(2).subDataMean(useChannels(iRow),1:end));
% catch
% plot(plotTimeArray,stimSetData(2).subDataMean(useChannels(iRow),1:end-1));
% end
% 
% line([0 0], [-1 1],'Color','red','LineStyle','--');
% if iCol ==1
%     ylabel(rowLabels(iRow));
% else
%     set(gca,'YTickLabel',[],'YTick',[]);
% end
% %title(['pre and post LTP stim']);
% if iRow == nRow
%     set(gca,'XTick',[0,0.25],'XTickLabel',{'t=0','t=.25'});
% else
%     set(gca,'XTickLabel',[],'XTick',[]);
% end
% legend({'pre LTP stim','post LTP stim'});
% ylim([-0.000015,0.0000125]);
% xlim([-0.1,0.4]);
% drawnow;



% figSub = figure();
% nCol = length(stimSetData);
% nRow = size(data.streams.(iType).data,1); % chans
% figure(figSub);
% plotTimeArray = -tPreStim:dTRec:tPostStim;
% 
% 
% for iRow = 1:nRow
%     for iCol = 1:nCol
%         subtightplot(nRow,nCol,iCol+(nCol*(iRow-1)));
%         
%         try
%         plot(plotTimeArray,stimSetData(iCol).subDataMean(iRow,1:end));
%         catch
%         plot(plotTimeArray,stimSetData(iCol).subDataMean(iRow,1:end-1));
%         end
%             
%         hold on;
%         line([0 0], [-1 1],'Color','red','LineStyle','--');
%         if iCol ==1
%             ylabel([iType ' ' num2str(iRow)]);
%         else
%             set(gca,'YTickLabel',[],'YTick',[]);
%         end
%         if iRow == 1
%             if stimSetData(iCol).setNumber == 1
%                 title(['pre LTP stim. n=' num2str(size(stimSetData(iCol).subData,2))]);
%             else
%                 title(['post LTP stim n=' num2str(size(stimSetData(iCol).subData,2))]);
%             end
%         end    
%         if iRow == nRow
%             set(gca,'XTick',[0,0.5],'XTickLabel',{'t=0','t=.5'});
%         else
%             set(gca,'XTickLabel',[],'XTick',[]);
%         end
%         ylim([-0.00002,0.00002]);
%         drawnow;
%     end
% end


% use an if exists here for the step after
% [load('M:\PassiveEphys\2019\19814-300uAtest\19814-300uAtest-movementBinary.mat');]

% just need to run the following movement analysis once
% vidFile1 = 'W:\Data\PassiveEphys\2019\19814-300uAtest\2019_19814-300uAtest_Cam1.avi';
% [roiPix,fullROI] = roiVidAnalysisBinary(vidFile1,'19814','300uAtest')
% 
% vidFile2 = 'W:\Data\PassiveEphys\2019\19814-303uAtest\19814-303uAtest1.mp4';
% roiVidAnalysisBinary(vidFile2,'19814','303uAtest1',fullROI,1);
% 
% vidFile3 = 'W:\Data\PassiveEphys\2019\19814-303uAtest\19814-303uAtest2.mp4';
% roiVidAnalysisBinary(vidFile3,'19814','303uAtest2',fullROI,1);
%
% closer formatting for this script
% fText = [exptDate '-' pulseAmp{iExpt} 'uAtest'];
% vidFile = ['W:\Data\PassiveEphys\' '20' exptDate(1:2) '\' fText '\2019_' fText '_Cam1.avi'];
% [roiPix,fullROI] = roiVidAnalysisBinary(vidFile,exptDate,[pulseAmp{iExpt} 'uAtest\']);



% this was just for combining two movies since the video was too large for
% analysis
% finalMovementArray = cat(1,finalM1,finalM2);
% frameT2temp = frameT2+(frameT1(end)-frameT2(1)+(frameT2(2)-frameT2(1)));
% frameTimeStampsAdj = cat(2,frameT1,frameT2temp);
% filename = 'M:\PassiveEphys\2019\19814-303uAtest\19814-303uAtest-movementBinary.mat';
% save(filename,'frameTimeStampsAdj','finalMovementArray','fullROI','roiPix');


% % now load movement information - systemitize this please
% load('M:\PassiveEphys\2019\19814-300uAtest\19814-300uAtest-movementBinary.mat');
% % load('M:\PassiveEphys\2019\19814-303uAtest1\19814-303uAtest1-movementBinary.mat');
% % load('M:\PassiveEphys\2019\19814-303uAtest2\19814-303uAtest2-movementBinary.mat');
% load('M:\PassiveEphys\2019\19814-303uAtest\19814-303uAtest-movementBinary.mat');
% plot(finalMovementArray)
% figure()
% plot(finalMovementArray)







% for iPlot = 1:size(data.streams.(iType).data,1)
% 
%     chanData = squeeze(squeeze(mean(trialData(iPlot,logical(trialsInSpan==jj),:),2)))';
% 
%     vertPlotLoc = (iType-1)*size(data.streams.(iType).data,1)+iPlot; %iterates through the channel lists for types
%     
%     %subtightplot(nChans,length(pulseAmp),iExpt+((vertPlotLoc-1)*length(pulseAmp)));
%     subtightplot(nChans,8,iExpt+jj-1+((vertPlotLoc-1)*8));
%     %subtightplot(nChans,1,vertPlotLoc);
%     plot(plotTimeArray,chanData(1:end-1));
%     if iExpt ==1
%         ylabel([iType ' ' num2str(iPlot)]);
%     else
%         set(gca,'YTickLabel',[],'YTick',[]);
%     end
%     if vertPlotLoc == nChans
%         set(gca,'XTick',[0,0.5],'XTickLabel',{[altLabel{iExpt}],'t=.5'})
%     else
%         set(gca,'XTickLabel',[],'XTick',[])
%     end
%     ylim([-0.0001,0.0001])
%     drawnow;
%     if drawTrains
%         figure(figAllTrains);
%         for ii = 1:size(trialData,2)
%             subtightplot(4,1,iPlot);
%             plot(plotTimeArray,squeeze(trialData(iPlot,ii,1:end-1)));
%             hold on;
%         end
%     end
%     if ~isempty(strfind(iType,'LFP1')) && mod(iChan,2)==0
%         subChanData(iPlot,:) = squeeze(squeeze(mean(subData(iPlot,:,:),2)));
%         figure(figSub);
%         subtightplot(nChans,length(pulseAmp),iExpt+((vertPlotLoc-1)*length(pulseAmp)));
%         plot(plotTimeArray,subChanData(iPlot,1:end-1));
%         if iExpt ==1
%             ylabel([iType ' ' num2str(iPlot)]);
%         else
%             set(gca,'YTickLabel',[],'YTick',[]);
%         end
%         if vertPlotLoc == nChans/2
%             set(gca,'XTick',[0,0.5],'XTickLabel',{[altLabel{iExpt}],'t=.5'});
%         else
%             set(gca,'XTickLabel',[],'XTick',[]);
%         end
%         ylim([-0.00002,0.00002]);
%         drawnow;
%     end
% end      
% 
% 
% 
% 
%     
%     
%     
% clear plotTimeArray trialData subData
% clear timeArrayRec    
%     
% 
% 
% end