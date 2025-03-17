function plotSpectraAndRawFigure

tname = 'M:\PassiveEphys\mouseEEG\FigureSWAExamples.xlsx';

opts = detectImportOptions(tname);
opts.VariableTypes{3} = 'char';
opts.VariableTypes{4} = 'duration'; %force this to accept the occasional character in our lab date system
opts.VariableTypes{5} = 'duration'; 
workingTable = readtable(tname,opts);


figure;
thisColumn = 0;
for i = 1:size(workingTable,1)
    animalName = workingTable(i,:).AnimalID{:};
    exptDate = workingTable(i,:).exptDate{:};
    reportPlot = false;
    textNotes = '';
    rangeStartPre = seconds(workingTable(i,:).timePre);
    rangeStartPost = seconds(workingTable(i,:).timePost);
    plotNow = false;
    S = plotSpectraAndRaw(animalName,exptDate,reportPlot,textNotes,rangeStartPre,rangeStartPost,plotNow);





    hourSet = [1,4];
    rawDisplayDuration = 4; % seconds
    legLabels = {'Baseline','Peak effect'};
%     QAFig = figure('Units','Normalized','Position',[0 0 0.7 0.7]);
    figRows = 5;
    figColumns = 6;
    channel = 1;

    
    
    % plot pre and post across the top
    subplot(figRows,figColumns,1+thisColumn);
    plot(S.timeArrayC,S.ctrlHourArray(channel,:));
    xlim([rangeStartPre rangeStartPre+rawDisplayDuration]);
    ylim([S.lowerB,S.upperB]);
    title([legLabels{1} ' sample'],'FontSize',10);
    ylabel('Volts');
    
    subplot(figRows,figColumns,1+thisColumn+figColumns);
    plot(S.timeArrayM,S.manipHourArray(channel,:));
    xlim([rangeStartPost rangeStartPost+rawDisplayDuration]);
    ylim([S.lowerB,S.upperB]);
    title([legLabels{2} ' sample'],'FontSize',10);
    xlabel('seconds');
    ylabel('Volts');

    % this should be taken from a save file!  not hard coded here.  it's only
    % here for convenience.  We should be saving this in the file we load above
    %!!!!! TODO!!!
    oddColumnArray = [13,25];
    freqLabels = [1 2 3 4 5 6 7 8 10 12 14 18 22 26 30 40 50 60 70 80 90 100 110 120];
    subplot(figRows,figColumns,oddColumnArray+i-1);
%     for iHour = 1:size(S.dataSet,2)
    for iHour = hourSet
        loglog(freqLabels,S.dataSet(iHour).avgSpectra(:,channel)); 
        hold on
    end
    ylim([S.getYMin*1.1,S.getYMax*1.1]);
    %title(['Channel ' num2str(channel)],'FontSize',10);
    xlabel('Freq');
    legend(legLabels,'Location','northeast','FontSize',10);
    ylabel('Power (mV^2)')
   
    treatmentText = '';
    treatments = getTreatmentInfo(animalName,exptDate);
    for ii = 1:size(treatments.pars,1)
        treatmentText = [treatmentText treatments.pars{ii,1}(1:3) '-'];
    end
    treatmentText = treatmentText(1:end-1);
    
    
    mainPlotTitle = [animalName '-' exptDate ' ' treatmentText];
%     annotation('textbox', [0.2, 0.98, 0, 0], 'string', mainPlotTitle,'FontSize',12);
    title(mainPlotTitle);
    drawnow

    thisColumn = thisColumn+1;


end

%     % save the files
%     fileName = [savePath saveFileName];
%     saveas(QAFig,[fileName '.fig']);
%     saveas(QAFig,[fileName '.jpg']);




