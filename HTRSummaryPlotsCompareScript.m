

% this script assumes
% HTRSummaryPlots(treatment,selection,acceptedPermutations) 
% has been run for the treatment listed, and that some amount of care has 
% been made to be sure the hours match and are reasonable to include.

treatment = {
'Anlg_6_FDET'; 
'saline0p9_vol'; 
'psilocybin'; 
'DMT';
'Anlg_5_MeO_DET';
'Anlg_Pyr_T'; 
'Anlg_5_MeO_MiPT'; 
'Anlg_4_AcO_DMT'; 
'Anlg_5_MeO_pyrT';
'Anlg_5_6_DiMeO_MiPT';
}; % needs to be in format of database

treatmentLegend = {
'6F-DET'; 
'Saline'; 
'Psilocybin';
'DMT';
'5-MeO-DET';
'Pyr-T'; 
'5-MeO-MiPT'; 
'4-AcO-DMT'; 
'5-MeO-pyrT';
'5-6-DiMeO-MiPT';
}; 
binSize = 5;  %in minutes
nTreatments = size(treatment,1);


acceptedPermutations = [1,2];
for iTreatment = 1:size(treatment,1)
    fileString = [getPathGlobal('animalSaves') 'HTRsummary\HTRsummary-' treatment{iTreatment} '.mat'];
    load(fileString,"animalData","hourData");
    % we plot single indeces first
    figure();
    nHours = size(acceptedPermutations,2);
    plotIndex = 1;
    
    clear meanHist
    maxHistY = 0;
    maxMeanY = 0;
    fullCenters = [];
    fullSmoothedMean = [];
    fullErr = [];
    for iHour = 1:size(hourData,2)
        if ~isempty(hourData(iHour).events)
            hourData(iHour).events = sort(hourData(iHour).events); % units = seconds
            binSizeMin = binSize*60;
            timeArray = (0:animalData(1).data.timeDT(1):hourData(iHour).maxLength*animalData(1).data.timeDT(1));
            edges = timeArray(1):binSizeMin:timeArray(end);
            centers = edges+(binSizeMin/2);
            centers = centers(1:end-1);
            Y = discretize(hourData(iHour).events,edges);
            subtightplot(2,nHours,plotIndex);
            nBins = length(edges)-1;
            histogram(Y,nBins);
            %ylim([0,24]);
            if iHour ~=1; yticklabels([]); end
            timeSteps = [ 15 30 45 ];
            xticks(timeSteps/binSize); % 2 min
            xticklabels({'15' '30' '45' });
            nMice = hourData(iHour).nMice;
            if iHour == 1
                ylabel('Cumulative HTR');
                title(['Pre inj  n=' num2str(nMice)]);
            else
                title(['Hour ' num2str(iHour) '  n=' num2str(nMice)]);
            end
            counts = hist(Y,nBins);
            maxHistY = max(maxHistY,max(counts));
            meanHist(plotIndex,:) = counts/nMice;
            subtightplot(2,nHours,plotIndex+nHours);
            smoothedMean = smooth(counts/nMice);
            maxMeanY = max(maxMeanY,max(smoothedMean));
            for iError = 1:size(counts,2)
%                 err(iError) = std(smoothedMean)/(sqrt(counts(iError)));
                err(iError) = std(smoothedMean)/(sqrt(nMice));
            end
            plot(centers/60,smoothedMean,'ro');
            errorbar(centers/60,smoothedMean,err,'r-o');
            if iHour == 1
                centers = centers-centers(end);
            end
            fullCenters = [fullCenters centers];
            fullSmoothedMean = cat(1,fullSmoothedMean,smoothedMean);
            fullErr = [fullErr err];
            xlim([edges(1)/60,edges(end)/60]);
            if iHour ~=1; yticklabels([]); end
            if iHour == 1
                ylabel('smoothed average of HTR')
            end
            plotIndex = plotIndex+1;
        end
    end
    % A little loop to rescale plots after a max has been found above.
    plotIndex = 1;
    for iHour = 1:size(hourData,2)
        if ~isempty(hourData(iHour).events)
        subtightplot(2,nHours,plotIndex);
        ylim([0,maxHistY*1.2]);
        subtightplot(2,nHours,plotIndex+nHours);
        ylim([0,maxMeanY*1.05]);
        plotIndex = plotIndex+1;
        end
    end
    S(iTreatment).fullCenters = fullCenters;
    S(iTreatment).fullSmoothedMean = fullSmoothedMean;
    S(iTreatment).fullErr = fullErr;
end



% summary figure with all drugs listed in treatment array
figure
%symbolArray = {'b-o','c-d','r-s','k-o','b-o','c-d','r-s','k-o','b-o','c-d','r-s','k-o','b-o','c-d','r-s','k-o','b-o','c-d','r-s','k-o','b-o','c-d','r-s','k-o'};
for iTreatment = 1:size(treatment,1)
    centers = S(iTreatment).fullCenters;
    smoothedMean = S(iTreatment).fullSmoothedMean;
    err = S(iTreatment).fullErr;
    %plot(centers/60,smoothedMean,symbolArray{iTreatment});
    errorbar(centers/60,smoothedMean,err)%,symbolArray{iTreatment});
    hold on

end
legend(treatmentLegend{1:nTreatments,:},'interpreter','none');
xlim([-60,60]);
ylim([0,4]);
ylabel('average HTR rate');
xlabel('minutes');


for iTreatment = 1:size(treatment,1)
    postDrugChange(iTreatment) = S(iTreatment).fullSmoothedMean(13)-S(iTreatment).fullSmoothedMean(8);
    postDrugChangeError(iTreatment) = postDrugChange(iTreatment)/(sqrt(nMice));
end



[sortedPostDrugChange,indexPostDrugSorted] = sort(postDrugChange);

figure
bar(postDrugChange);
xticklabels(treatmentLegend);


figure
b = bar(sortedPostDrugChange);
xtips1 = b(1).XEndPoints;
ytips1 = b(1).YEndPoints;
labels1 = string(round(b(1).YData,1));
text(xtips1,ytips1,labels1,'HorizontalAlignment','center',...
    'VerticalAlignment','bottom')
xticklabels(treatmentLegend(indexPostDrugSorted));




