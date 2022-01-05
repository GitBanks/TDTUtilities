


clear all

tPreStim = 0.2;
tPostStim = 0.4;
timeSpans = 7*60; %time in seconds (min*60) to group responses into

% exptDate = '19814';
% %pulseAmp = {'1200','1203'};
% pulseAmp = {'300','303'};
exptDate = '19910';
%pulseAmp = {'1200','1203'};
pulseAmp = {'302','305','306','307'};


%we may need to run video analysis here first.
fText = [exptDate '-' pulseAmp{iExpt} 'uAtest'];
vidFile = [getPathGlobal('W') 'PassiveEphys\' '20' exptDate(1:2) '\' fText '\2019_' fText '_Cam1.avi'];
[roiPix,fullROI] = roiVidAnalysisBinary(vidFile,exptDate,[pulseAmp{iExpt} 'uAtest\']);
load([getPathGlobal('M') 'PassiveEphys\2019\19814-300uAtest\19814-300uAtest-movementBinary.mat']);
[getPathGlobal('M') 'PassiveEphys\' '20' exptDate(1:2) '\' fText '\2019_' fText ]


sIterator = 1;
for iExpt = 1:length(pulseAmp)
    dirStrRawData = [getPathGlobal('W') 'PassiveEphys\' '20' exptDate(1:2) '\' exptDate '-' pulseAmp{iExpt} 'uAtest\']; %input
    data = TDTbin2mat(dirStrRawData);
    
    %searching for pulses
    triggerPulses = find(data.streams.eS1r.data > 0);
    ipi = diff(triggerPulses);
    %uniqueTTL = triggerPulses(1);
    uniqueTTL = triggerPulses(1);
    for iPulse = 1:length(triggerPulses)-1
        if ipi(iPulse) > 5 %found a new TTL pulse
            uniqueTTL = [uniqueTTL triggerPulses(iPulse+1)]; % need +1 because diff lags by 1
        end
    end
    
    
    dTStim = 1/data.streams.eS1r.fs;
    timeArrayStim = (0:dTStim:length(data.streams.eS1r.data)*dTStim-dTStim);
    % % show detected stim times
    % figure();
    % plot(timeArrayStim,data.streams.eS1r.data)
    % hold on
    % plot(timeArrayStim(uniqueTTL),zeros(length(uniqueTTL),1),'*')
    stimTimes = timeArrayStim(uniqueTTL);

    % data are stored like this:
    % data.streams.LFP1.data(4,:)
    % data.streams.EEGw.data(4,:)
    % 1. step through rec types (data.streams.LFP1,data.streams.EEGw)
    iType = 'LFP1';
    nChans = 4;
    

    dTRec = 1/data.streams.(iType).fs; % get sample rate and recording times
    timeArrayRec = (0:dTRec:length(data.streams.(iType).data)*dTRec-dTRec);

    % this finds all the stims within a period defined by timeSpans (initialized
    % at the top) which will be averaged together, or whatever
    more = true; ii=1; timeSpansC = timeSpans; %find increments of time related to timeSpans
    while more
        if ~isempty(find(timeArrayRec>timeSpansC,1))
            spansT(ii) = find(timeArrayRec>timeSpansC,1);
            ii = ii+1;
            timeSpansC = timeSpans+timeSpansC;
        else
            more = false;
        end 
    end

    
    % 2. step through channels (data.streams.EEGw.data(i,:))
    for iChan = 1:size(data.streams.(iType).data,1)
        % 3. step through stims (unique TTL)
        for iTrial = 1:length(uniqueTTL)-1
            thisStim = find(timeArrayRec>stimTimes(iTrial),1);
            if ~isempty(find(spansT>thisStim,1))
                trialsInSpan(iTrial) = find(spansT>thisStim,1);
                trialData(iChan,iTrial,:) = data.streams.(iType).data(iChan,thisStim-round(tPreStim*data.streams.(iType).fs):round(tPostStim*data.streams.(iType).fs)+thisStim);
                if mod(iChan,2)==0
                    subData(iChan,iTrial,:) = trialData(iChan,iTrial,:) - trialData(iChan-1,iTrial,:);
                end
            end
        end
    end
    
    % for each trial characterize the response (maybe ipsi and contra
    % diff?)
    % 1. for each side, what is an appropriate response window?  User
    % select or look in expected range and find min/max?
    % 2. stdev of baseline?
    % 3. peak to trough
%     for iTrial = 1:size(subData,2)
%         
%         
%     end
        
    
    %now use trialsInSpan logical to sort time spans into structure, also
    %build span across experiments iExpt
    for jj = 1:length(spansT)
        importData(sIterator).trialData(:,1:sum(logical(trialsInSpan==jj)),:) = trialData(:,logical(trialsInSpan==jj),:);
        importData(sIterator).subData(:,1:sum(logical(trialsInSpan==jj)),:) = subData(:,logical(trialsInSpan==jj),:);
        %might as well do mean calc here too
        importData(sIterator).trialDataMean = squeeze(mean(trialData(:,logical(trialsInSpan==jj),:),2));
        importData(sIterator).subDataMean = squeeze(mean(subData(:,logical(trialsInSpan==jj),:),2));
        importData(sIterator).setNumber = iExpt;
        sIterator = sIterator+1;
    end
end


















figSub = figure();
nCol = length(importData);
nRow = size(data.streams.(iType).data,1); % chans
figure(figSub);
plotTimeArray = -tPreStim:dTRec:tPostStim;


for iRow = 1:nRow
    for iCol = 1:nCol
        subtightplot(nRow,nCol,iCol+(nCol*(iRow-1)));
        
        try
        plot(plotTimeArray,importData(iCol).subDataMean(iRow,1:end));
        catch
        plot(plotTimeArray,importData(iCol).subDataMean(iRow,1:end-1));
        end
            
        hold on;
        line([0 0], [-1 1],'Color','red','LineStyle','--');
        if iCol ==1
            ylabel([iType ' ' num2str(iRow)]);
        else
            set(gca,'YTickLabel',[],'YTick',[]);
        end
        if iRow == 1
            if importData(iCol).setNumber == 1
                title(['pre LTP stim. n=' num2str(size(importData(iCol).subData,2))]);
            else
                title(['post LTP stim n=' num2str(size(importData(iCol).subData,2))]);
            end
        end    
        if iRow == nRow
            set(gca,'XTick',[0,0.5],'XTickLabel',{'t=0','t=.5'});
        else
            set(gca,'XTickLabel',[],'XTick',[]);
        end
        ylim([-0.00003,0.00005]);
        xlim([-.001,0.1]);
        drawnow;
    end
end



% use an if exists here for the step after
% [load('M:\PassiveEphys\2019\19814-300uAtest\19814-300uAtest-movementBinary.mat');]

% just need to run the following movement analysis once
% vidFile1 = 'W' ':\Data\PassiveEphys\2019\19814-300uAtest\2019_19814-300uAtest_Cam1.avi';
% [roiPix,fullROI] = roiVidAnalysisBinary(vidFile1,'19814','300uAtest')
% 
% vidFile2 = 'W' ':\Data\PassiveEphys\2019\19814-303uAtest\19814-303uAtest1.mp4';
% roiVidAnalysisBinary(vidFile2,'19814','303uAtest1',fullROI,1);
% 
% vidFile3 = 'W' ':\Data\PassiveEphys\2019\19814-303uAtest\19814-303uAtest2.mp4';
% roiVidAnalysisBinary(vidFile3,'19814','303uAtest2',fullROI,1);
%
% closer formatting for this script
% fText = [exptDate '-' pulseAmp{iExpt} 'uAtest'];
% vidFile = ['W' ':\Data\PassiveEphys\' '20' exptDate(1:2) '\' fText '\2019_' fText '_Cam1.avi'];
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