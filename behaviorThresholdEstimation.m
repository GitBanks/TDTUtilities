function [threshEst] = behaviorThresholdEstimation(experimentInfo)
% Given: a structure containing arrays of calculated movement score
% Return: a threshold estimate.  Also plot a histogram and request user
% input / evaluation.
% this is the previous way movement or nonmovement were determined.  Some
% analysis still expects movement and nonmovement inputs, so this will
% fulfill that need, and provide a reference comparisons.
estimationHist = cat(2,experimentInfo(1:4).framesRaw);
estimationHist = log(estimationHist);
estimationHist = estimationHist(estimationHist>0);
pdf_gaussmix = @(estimationHist,p,mu1,sig1,mu2,sig2) ...
    p*pdf('Normal',estimationHist,mu1,sig1) + (1-p)*pdf('Normal',estimationHist,mu2,sig2);
%Set initial conditions
start = [.5 prctile(estimationHist,25) 1 prctile(estimationHist,95) 1];
%Set reasonable lower/upper bounds
lb = [0 0 0 0 0];
ub = [1 Inf prctile(estimationHist,99) prctile(estimationHist,99) prctile(estimationHist,99)];
[paramEsts,~] = mle(estimationHist, 'pdf',pdf_gaussmix, 'start',start, ...
    'lower',lb, 'upper',ub);
midpointPeaks = (paramEsts(2)+paramEsts(4))/2;%also move 20% higher than quiet
threshEst = exp(midpointPeaks);
% may only need to do this if no hist divergence, for now, leave it in.
figure();
hold on;
hist(estimationHist,100);
plot(0:.1:10,pdf('Normal',0:.1:10,paramEsts(2),paramEsts(3))*length(estimationHist)*paramEsts(1)/10,'r');
plot(0:.1:10,pdf('Normal',0:.1:10,paramEsts(4),paramEsts(5))*length(estimationHist)*(1-paramEsts(1))/10,'g');
plot((midpointPeaks)*[1 1],[0 max(hist(estimationHist,100))],':k');
choice = questdlg('Is this threshold acceptable?', ...
'Verify threshold','Accept','Let me pick','Accept');
if strcmp(choice,'Let me pick')
    adjustedThresh = midpointPeaks;
    while true
        w = waitforbuttonpress;
        switch w
            case 1 % keyboard
                key = get(gcf,'currentcharacter');
                if key==27 && exist('newThreshToUse','var')
                    adjustedThresh = newThreshToUse.Position(1);

                    break
                end
            case 0 % mouse click
                mousept = get(gca,'currentPoint');
                display(mousept);
                try; delete(newThreshToUse); end
                newThreshToUse = text(mousept(1,1),mousept(1,2),'x');
                plot((newThreshToUse.Position(1))*[1 1],[0 max(hist(estimationHist,100))],':k');
        end
    end
    display(['Changing thresh from estimated ' num2str(threshEst) ' to ' num2str(exp(adjustedThresh))]);
    threshEst = exp(adjustedThresh);
end
close all
% old plotting system
nIndices = length(experimentInfo);
scrsz = get(0,'ScreenSize');
figure('Position',[1 scrsz(4)*0.1 scrsz(3) (scrsz(4)/6*nIndices*0.6)]);
movegui(gcf,'north');
for iPlot = 1:nIndices
    minVal = min([length(experimentInfo(iPlot).frameTimeStamps) length(experimentInfo(iPlot).framesRaw)]);
    xvals = experimentInfo(iPlot).frameTimeStamps(1:minVal);
    subtightplot(nIndices,1,iPlot);
    plot(xvals,experimentInfo(iPlot).framesRaw(1:minVal));
    hold on;
    plot([xvals(1) xvals(end)],[threshEst,threshEst],'--r');
    hold on;
    ylabel(['Index ' num2str(iPlot)]);
    set(gca,'XTick',[],'YTick',[]);
%             ylim([0,threshEst*5]);
%             ylim([0,0.02]);
    ylim([0,7000]);
    xlim([0,xvals(end)]);
    drawnow;
end
