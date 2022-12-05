clear all
%Average Rate of HTR- ALL DRUGS Plotted
treatments = {
% 'saline0p9_vol'
%'Anlg_5_MeO_DET';
%'Anlg_Pyr_T'; 
'Anlg_6_FDET'; 
%'Anlg_5_MeO_MiPT'; 
%'Anlg_4_AcO_DMT'; 
%'Anlg_5_MeO_pyrT';
%'Anlg_5_6_DiMeO_MiPT';
%'DOI_conc'
'psilocybin';
};
treatmentDisplay = treatments;




halfWData = zeros(3:size(treatments,1));
figure();
for iTreatment = 1:size(treatments,1)
    if contains(treatments{iTreatment},'_conc')
        treatmentDisplay{iTreatment} = strrep(treatmentDisplay{iTreatment},'_conc','');    
    end
    if contains(treatments{iTreatment},'Anlg')
        treatmentDisplay{iTreatment} = treatments{iTreatment}(6:end);
    end
    if contains(treatments{iTreatment},'_')
        treatmentDisplay{iTreatment} = strrep(treatmentDisplay{iTreatment},'_','-');
    end
    if contains(treatments{iTreatment},'_vol')
        treatmentDisplay{iTreatment} = strrep(treatmentDisplay{iTreatment},'_vol','');
    end
    treatment = treatments{iTreatment};
    filename = ['M:\PassiveEphys\AnimalData\pdfHTRevents-100-' treatment];
    load(filename);
    meanPdfMin = meanPdf*60;
    injectionCutoff = find(minuteTimeArray>60,1);
    plotCutoff = find(minuteTimeArray>120,1);
    if ~exist('summaryData','var')
        summaryData = zeros(size(treatments,1),plotCutoff);
    end
    summaryData(iTreatment,:) = meanPdfMin(1:plotCutoff);
    [peakMax(iTreatment),indexMax(iTreatment)] = max(meanPdfMin(injectionCutoff:end));
    indexMax(iTreatment) = indexMax(iTreatment)+injectionCutoff;
    thismean(iTreatment) = mean(meanPdfMin(1:injectionCutoff));
    peakBaselineDifference(iTreatment) = peakMax(iTreatment)-thismean(iTreatment);
    
%     normalizedData = normalize(meanPdfMin);
    normalizedData = mat2gray(meanPdfMin);
    % we have a peak, we have a normalized data set.  From the peak find
    % the points forward and back that are at 0.5
    % normalizedData(indexMax(iTreatment));

    halfWData(1,iTreatment) = indexMax(iTreatment)-find(normalizedData(indexMax(iTreatment):-1:injectionCutoff) < .5,1);
    halfWData(2,iTreatment) = indexMax(iTreatment);
    halfWData(3,iTreatment) = find(normalizedData(indexMax(iTreatment):end) < .5,1)+indexMax(iTreatment);
    
    
    
    plot(minuteTimeArray,meanPdfMin,'LineWidth',1);
    hold on 
    
    

    xlabel('Minutes');
    xlim([0,minuteTimeArray(plotCutoff)]);
end
hold on

ylabel('Head Twitch Event Rate (HTR/min)')
title('Average HTR Rate relative to drug');
xl = xline(60,'LineWidth',4);
% xl.LabelVerticalAlignment = 'middle';
% xl.LabelHorizontalAlignment = 'center';




% for iTreatment = 1:size(treatments,1)
    

for iTreatment = 1:size(treatments,1)
    plot(minuteTimeArray(halfWData(1,iTreatment):halfWData(3,iTreatment)),summaryData(iTreatment,halfWData(1,iTreatment):halfWData(3,iTreatment)),'LineWidth',3);
end
scatter(minuteTimeArray(indexMax),peakMax,'rx');

legend(treatmentDisplay,'Interpreter', 'none');