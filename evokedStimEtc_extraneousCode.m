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
% vidFile1 = 'W' ':\Data\PassiveEphys\2019\19814-300uAtest\2019_19814-300uAtest_Cam1.avi';
% [roiPix,fullROI] = roiVidAnalysisBinary(vidFile1,'19814','300uAtest')
% 
% vidFile2 = 'W' ':\Data\PassiveEphys\2019\19814-303uAtest\19814-303uAtest1.mp4';
% roiVidAnalysisBinary(vidFile2,'19814','303uAtest1',fullROI,1);
% 
% vidFile3 = 'W' ' :\Data\PassiveEphys\2019\19814-303uAtest\19814-303uAtest2.mp4';
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

%     for iChannel = 1:nChans
%         trialIterator = 1;
%         for iTrial = 1:nTrials %length(stimTimes)-1
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
