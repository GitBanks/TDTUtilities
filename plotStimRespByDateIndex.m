function thisFigure = plotStimRespByDateIndex(exptDate,exptIndex,sendToSlack,plotCalculatedPeaks,plotLog)

if ~exist('sendToSlack','var')
    sendToSlack = false;
end
if ~exist('plotCalculatedPeaks','var')
    plotCalculatedPeaks = false;
end
if ~exist('plotLog','var')
    plotLog = false;
end

outPath = ['M:\PassiveEphys\20' exptDate(1:2) '\' exptDate '-' exptIndex '\'];
try
    load([outPath exptDate '-' exptIndex '_peakData'],'peakData','plotTimeArray','avgTraces');
catch
    error(['Problem loading ' [outPath exptDate '-' exptIndex '_peakData']]);
end

if ~exist('avgTraces','var')
    disp(['couldn''t load ' [outPath exptDate '-' exptIndex '_peakData'] ' let''s try re-running the peak selection' ]);
    evokedStimResp_userInput(exptDate,exptIndex);
    clear peakData plotTimeArray avgTraces
    load([outPath exptDate '-' exptIndex '_peakData'],'peakData','plotTimeArray','avgTraces');
end

animalName = getAnimalByDateIndex(exptDate,exptIndex);
outPath2 = ['M:\PassiveEphys\AnimalData\' animalName '\'];
FigName = ['Stim-Resp plot - ' animalName '_' exptDate '_' exptIndex];
thisFigure = figure('Name',FigName);
nROIs = size(peakData.ROILabels,1);
% plotting begins
for iROI = 1:nROIs
    % Plot avg traces
    subPlt(iROI) = subplot(2,nROIs,iROI);
    hold on
    for iStim = 1:length(avgTraces)
        plot(plotTimeArray,avgTraces(iStim).stimSet(iROI,:));
    end
    for iUI = 1:length(peakData.pkSearchData(iROI).tPk)
        plot(peakData.pkSearchData(iROI).tPk(iUI),peakData.pkSearchData(iROI).yPk(iUI),'+r','MarkerSize',12);
        if plotCalculatedPeaks
            for iStim = 1:length(avgTraces)
                plot(peakData.pkVals(iROI).peakTimeCalc(iUI,iStim),peakData.pkVals(iROI).data(iUI,iStim),'+b','MarkerSize',8);
            end
        end
    end
    ax = gca;
    ax.XLim = [plotTimeArray(1),plotTimeArray(end)];
    ax.YLim = [1.05*peakData.plotMin(iROI),1.05*peakData.plotMax(iROI)];
    ax.XLabel.String = 'time(sec)';
    if iROI == 1
        ax.YLabel.String = 'avg dataSub (V)';
    end
    ax.Title.String = peakData.ROILabels{iROI};
    if iROI == nROIs
        %legend(ampLabel,'FontSize',6,'Location','NorthEast');
        %legend('boxoff');
    end
end

for ii = 1:size(avgTraces,2)
    stimArrayNumeric(ii) = avgTraces(ii).stimArrayNumeric;
end

hold off
for iROI = 1:nROIs
    subplot(2,nROIs,nROIs+iROI)
    legendLabs = [];
    nPks = size(peakData.pkVals(iROI).data,1);
    for iPk = 1:nPks
        legendLabs{iPk} = ['Pk ' num2str(iPk)];
    end
    for iPk = 1:nPks
        if plotLog
            semilogx(stimArrayNumeric,peakData.pkSearchData(iROI).pkSign(iPk)*peakData.pkVals(iROI).data(iPk,:),'-o');
        else
            plot(stimArrayNumeric,peakData.pkSearchData(iROI).pkSign(iPk)*peakData.pkVals(iROI).data(iPk,:),'-o');
        end
        hold on
    end
    ax = gca;
    ax.XLabel.String = 'Stim intensity (\muA)';
    if iROI == 1
        ax.YLabel.String = 'Pk resp (V)';
    end
    legend(legendLabs,'FontSize',6,'Location','NorthWest');
    legend('boxoff');
end
%saveas(thisFigure,[outPath FigName]);
saveas(thisFigure,[outPath2 FigName]);


fileName = [outPath2 FigName];
print(thisFigure,'-painters',fileName,'-r300','-dpng');
if sendToSlack
    try
        desc = [FigName ' Mk2'];
        sendSlackFig(desc,[fileName '.png']);
    catch
        disp(['failed to upload ' fileName ' to Slack']);
    end
end
% These are data we load (saved in another program)
% peakData = struct;
% peakData.pkSearchData = pkSearchData; % user selected Time of peak re stim time
% peakData.ROILabels = ROILabels; %corresponding labels
% peakData.stimArrayNumeric = stimArrayNumeric;
% peakData.pkVals = pkVals; % Response magnitude 
% peakData.stimTimes = stimTimes; % Time of stim relative to start of file
% for iStim = 1:length(stimSet)
%     avgTraces(iStim).stimSet = stimSet(iStim).subMean;
%     avgTraces(iStim).stimArrayNumeric = stimArrayNumeric(iStim);
%     avgTraces(iStim).ampLabel = ampLabel{iStim};
% end
% tLim = [-tPreStim,tPostStim];
% save([outPath exptDate '-' exptIndex '_peakData'],'peakData','plotTimeArray','avgTraces');
% 
% clear all
% load([outPath exptDate '-' exptIndex '_peakData']);

