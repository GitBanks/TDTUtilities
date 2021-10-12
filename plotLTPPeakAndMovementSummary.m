function plotLTPPeakAndMovementSummary(animal,plotPeaks)


% now step through the slopes / peaks for each expt.
% animal = 'ZZ09';
%animal = 'ZZ10'; % warning: the first few expts do not have mag data.  21525 and on work
exptList = getExptPlasticitySetByAnimal(animal);
indexStepDescription = {'pre LTP','post LTP','post LTD'};

if ~exist('plotPeaks','var')
    plotPeaks = false;
end

nExpts = size(exptList,2);
nIndex = size(indexStepDescription,2);
for iExptDate = 1:nExpts
    for iExptIndex = 1:nIndex
        thisDate = exptList(iExptDate).exptDate;
        thisIndex = exptList(iExptDate).exptIndices{iExptIndex};
        [dataOut.date(iExptDate).expt(iExptIndex).data,figH] = getPeakSlopeAvgByDateIndexWPlot(thisDate,thisIndex,plotPeaks);
        if plotPeaks
            figure(figH);
            set(gcf,'Name',[animal ' ' thisDate ' ' indexStepDescription{iExptIndex} ]);
            drawnow;
        end
    end
end

% %pull specific things from structure
% restArray = zeros(nExpts,nIndex,3);
% activeArray = zeros(nExpts,nIndex,3);
% activeArrayIntercept = zeros(nExpts,nIndex,3);
% for iExptDate = 1:nExpts
%     for iExptIndex = 1:nIndex
%         restArray(iExptDate,iExptIndex,:) = dataOut.date(iExptDate).expt(iExptIndex).data.restingAvgPeak(:);
%         activeArray(iExptDate,iExptIndex,:) = dataOut.date(iExptDate).expt(iExptIndex).data.activeSlope(:);
%         activeArrayIntercept(iExptDate,iExptIndex,:) = dataOut.date(iExptDate).expt(iExptIndex).data.activeIntercept(:);
%     end
% end

%pull just pfc
restArray = zeros(nExpts,nIndex);
activeArray = zeros(nExpts,nIndex);
activeArrayIntercept = zeros(nExpts,nIndex);
for iExptDate = 1:nExpts
    for iExptIndex = 1:nIndex
        restArray(iExptDate,iExptIndex,:) = dataOut.date(iExptDate).expt(iExptIndex).data.restingAvgPeak(1);
        activeArray(iExptDate,iExptIndex,:) = dataOut.date(iExptDate).expt(iExptIndex).data.activeSlope(1);
        activeArrayIntercept(iExptDate,iExptIndex,:) = dataOut.date(iExptDate).expt(iExptIndex).data.activeIntercept(1);
    end
end

%plot
thisFig = figure('Name',[animal ' average peaks quiet trials, slope intercept active trials']);
maxYforAll=nan;
minYforAll=nan;
nFeatures = 6;
for iExptDate = 1:nExpts
    rowInc = (iExptDate-1)*nFeatures;
    subplot(nExpts,nFeatures,rowInc+1);
%     for iExptIndex = 1:nIndex
%         plot(squeeze(restArray(iExptDate,:,iExptIndex)));
        plot(squeeze(restArray(iExptDate,:))); % just the pfc
        hold on
        if iExptDate == 1; title(['quiet avg']); end
%         ylim([min(min(min(restArray))),max(max(max(restArray)))]);
        ylim([min(min(restArray)),max(max(restArray))]);
%     end
    treatment = getTreatmentFromIndexName(animal,exptList(iExptDate).exptDate);
    ylabel([exptList(iExptDate).exptDate ' ' treatment(1:10)]);
    drawnow;
    
    subplot(nExpts,nFeatures,rowInc+2);
%     for iExptIndex = 1:nIndex   
%         plot(squeeze(activeArray(iExptDate,:,iExptIndex)));
        plot(squeeze(activeArray(iExptDate,:))); % just the pfc
        hold on
        ylim([min(min(activeArray)),max(max(activeArray))]);
        if iExptDate == 1; title(['active - slope']); end
%     end
    drawnow;
    
    subplot(nExpts,nFeatures,rowInc+3);
%     for iExptIndex = 1:nIndex
%         plot(squeeze(activeArrayIntercept(iExptDate,:,iExptIndex)));
        plot(squeeze(activeArrayIntercept(iExptDate,:)));
        hold on
        ylim([min(min(activeArrayIntercept)),max(max(activeArrayIntercept))]);
        %ylim([min(min(min(activeArrayIntercept))),1.e-4]);
        if iExptDate == 1; title(['active - y-intercept']); end
%     end
    drawnow;

    
    
    
    for iExptIndex = 1:nIndex
        thisDate = exptList(iExptDate).exptDate;
        thisIndex = exptList(iExptDate).exptIndices{iExptIndex};
        [allF(iExptIndex).data,allX(iExptIndex).data,quietF(iExptIndex).data,quietX(iExptIndex).data,activeF(iExptIndex).data,activeX(iExptIndex).data] = getECDFActiveOrQuietByDateIndex(thisDate,thisIndex);
    end
    %figure(thisFig);
    
    for iExptIndex = 1:nIndex
        thisDate = exptList(iExptDate).exptDate;
        thisIndex = exptList(iExptDate).exptIndices{iExptIndex};
%         [allF,allX,quietF,quietX,activeF,activeX] = getECDFActiveOrQuietByDateIndex(thisDate,thisIndex);
        subplot(nExpts,nFeatures,rowInc+4);
        hold on;
        plot(allX(iExptIndex).data,allF(iExptIndex).data);
        if iExptDate == 1; title(['movement eCDF all']); end
        hold on;
        subplot(nExpts,nFeatures,rowInc+5);
        hold on;
        plot(quietX(iExptIndex).data,quietF(iExptIndex).data);
        if iExptDate == 1; title(['movement eCDF quiet']); end
        hold on;
        subplot(nExpts,nFeatures,rowInc+6);
        hold on;
        plot(activeX(iExptIndex).data,activeF(iExptIndex).data);
        if iExptDate == 1; title(['movement eCDF active']); end
        hold on;
        drawnow;
    end
    
%     subplot(nExpts,nFeatures,rowInc+4);
%     for iExptIndex = 1:nIndex
%         thisDate = exptList(iExptDate).exptDate;
%         thisIndex = exptList(iExptDate).exptIndices{iExptIndex};
%         useCDF = true;
%         h = getMovementDataFromHTRByDateIndex(thisDate,thisIndex,useCDF);
%         hold on;
%         if iExptDate == 1; title(['CDF movement']); end
%     end
%     drawnow;
%     
%     subplot(nExpts,nFeatures,rowInc+5);
%     for iExptIndex = 1:nIndex
%         if iExptDate == 1; title(['CDF movement active only']); end
%     end
%     drawnow;
%     
%     
%     subplot(nExpts,nFeatures,rowInc+5);
end



for iExptDate = 1:nExpts
    rowInc = (iExptDate-1)*nFeatures;
    % stupid repeat because we're mixing data presentation
    subplot(nExpts,nFeatures,rowInc+1);
    xticks([1,2,3]);
    xlim([0.9,3.1]);
    xticklabels(indexStepDescription);
%     if iExptDate == nExpts
%         dataLabels = {'ipsi PFC','contra PFC','vCA1'};
%         legend(dataLabels);
%     end
    drawnow;
    
    subplot(nExpts,nFeatures,rowInc+2);
    xticks([1,2,3]);
    xlim([0.95,3.05]);
    xticklabels(indexStepDescription);
%     if iExptDate == nExpts
%         dataLabels = {'ipsi PFC','contra PFC','vCA1'};
%         legend(dataLabels);
%     end
    drawnow;
    
    subplot(nExpts,nFeatures,rowInc+3);
    xticks([1,2,3]);
    xlim([0.95,3.05]);
    xticklabels(indexStepDescription);
%     if iExptDate == nExpts
%         dataLabels = {'ipsi PFC','contra PFC','vCA1'};
%         legend(dataLabels);
%     end
    drawnow;
    
    subplot(nExpts,nFeatures,rowInc+4);
    xlim([0,1.5])
    if iExptDate == nExpts
        legend(indexStepDescription,'Location','southeast');
    end
    subplot(nExpts,nFeatures,rowInc+5);
    xlim([0,1.5])
    subplot(nExpts,nFeatures,rowInc+6);
    xlim([0,1.5])
end




