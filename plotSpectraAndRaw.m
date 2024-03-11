function S = plotSpectraAndRaw(animalName,exptDate,reportPlot,textNotes,rangeStartPre,rangeStartPost,plotNow)

% given an animal name and experiment date,
% plot raw traces and spectra then send it to Slack, for closer examination

% test params
% animalName = 'EEG243';
% exptDate = '23214';
% reportPlot = false;

% animalName = 'EEG248';
% exptDate = '23221';
% reportPlot = true;

% saline day - 1 electrode
% animalName = 'ZZ19';
% exptDate = '22623'; 
% reportPlot = false;

% saline day - 3 electrodes
% animalName = 'ZZ14';
% exptDate = '22117'; 
% reportPlot = false;


channel = 1;


% Question: do we want to store this by animal, or by project?
% here's by animal:
% savePath = [getPathGlobal('animalSaves') animalName '\']
% here's project:

% savePath = '\\144.92.237.185\Data\PassiveEphys\AnimalData\combined\QA\'; %change this for saving 
savePath = '\\144.92.237.185\Data\PassiveEphys\AnimalData\DOI\QA\'; %change this for saving 
saveFileName = [animalName '-' exptDate '-spectraAndRaw'];

if ~exist('textNotes','var')
    textNotes = '';
end

if ~exist('reportPlot','var')
    reportPlot = false;
end

if ~exist('rangeStartPre','var')
    rangeStartPre = 600;
end
rangeEndPre = rangeStartPre+5;

if ~exist('rangeStartPost','var')
    rangeStartPost = 600;
end
rangeEndPost = rangeStartPost+5;

if ~exist('plotNow','var')
    plotNow = true;
end






% find the correct files and set a few variables
findExptType = 'Spon';
[operationList] = getExperimentsByAnimalAndDate(animalName,exptDate,findExptType);
year = exptDate(1:2);
ctrlHour = 1;
manipHour = 4;
fullChannel = 1; % show this channel in the 'full day' plot


% this part loads in raw data
fullExptChannel = [];
for i=1:size(operationList,1)
    dirStr = [getPathGlobal('importedData') '20' year '\' operationList{i,1} '\'];
    load([dirStr '\' operationList{i,1} '_EEGData0.mat']);
%     load([dirStr '\' operationList{i,1} '_Data0.mat']);
    [nChans,nPts] = size(ephysData);
    t = (0:nPts-1)*(dT); 
    
    if i == ctrlHour
        time_logi = find(t>=rangeStartPre & t<=rangeEndPre+240);
        ctrlHourArray = ephysData(:,time_logi);
        timeArrayC = t(time_logi);
    end
    
    if i == manipHour
        time_logi = find(t>=rangeStartPost & t<=rangeEndPost+240);
        manipHourArray = ephysData(:,time_logi);
        timeArrayM = t(time_logi);
    end
    fullExptChannel = [fullExptChannel ephysData(fullChannel,:)];
end
% downsample
fullExptChannel = fullExptChannel(1:10:end);
fullTimeArray = (0:size(fullExptChannel,2)-1)*(dT*10)/60;

lowerB = prctile(fullExptChannel,1)*2; % 1st prctile
upperB = prctile(fullExptChannel,99)*2; % 99th prctile


% pull the spectra data from the saved run

% saveFolder = 'M:\Zarmeen\Data\spectra\'; % ZZ animal bandpower location 
try
    saveFolder = 'M:\PassiveEphys\AnimalData\DOI\'; % EEG animals bandpower location
    load([saveFolder animalName '_' exptDate '_bandpowerSet.mat'],"dataSet");
catch
    saveFolder = 'M:\PassiveEphys\AnimalData\combined\'; % EEG animals bandpower location
    load([saveFolder animalName '_' exptDate '_bandpowerSet.mat'],"dataSet");
end

getYMax = nan;
getYMin = nan;
for iHour = 1:size(dataSet,2)
    getYMax = max(max(max(dataSet(iHour).avgSpectra)),getYMax);
    getYMin = max(min(min(dataSet(iHour).avgSpectra)),getYMin);
end

S.ctrlHourArray = ctrlHourArray;
S.manipHourArray = manipHourArray;
S.timeArrayC = timeArrayC;
S.timeArrayM = timeArrayM;
S.dataSet = dataSet;
S.getYMax = getYMax; 
S.getYMin = getYMin;
S.lowerB = lowerB;
S.upperB = upperB;





if plotNow
    % start plotting
    
    % more conventions
    legLabels = {'Pre inj 1','Pre inj 2','Post inj 1','Post inj 2','Post inj 3','Post inj 4'};
    
    QAFig = figure('Units','Normalized','Position',[0 0 0.7 0.7]);
    figRows = 7;
    figColumns = 6;
    
    % plot pre and post across the top
    subplot(figRows,figColumns,1:3);
    plot(timeArrayC,ctrlHourArray(channel,:));
    xlim([rangeStartPre rangeEndPre]);
    ylim([lowerB,upperB]);
    title([legLabels{ctrlHour} ' sample'],'FontSize',10);
    xlabel('seconds');
    ylabel('Volts');
    
    subplot(figRows,figColumns,4:6);
    plot(timeArrayM,manipHourArray(channel,:));
    xlim([rangeStartPost rangeEndPost]);
    ylim([lowerB,upperB]);
    title([legLabels{manipHour} ' sample'],'FontSize',10);
    
    % this should be taken from a save file!  not hard coded here.  it's only
    % here for convenience.  We should be saving this in the file we load above
    %!!!!! TODO!!!
    freqLabels = [1 2 3 4 5 6 7 8 10 12 14 18 22 26 30 40 50 60 70 80 90 100 110 120];
    subplot(figRows,figColumns,7:42);
    for iHour = 1:size(dataSet,2)
        loglog(freqLabels,dataSet(iHour).avgSpectra(:,channel)); 
        hold on
    end
    ylim([getYMin*1.1,getYMax*1.1]);
    title(['Channel ' num2str(channel)],'FontSize',10);
    xlabel('Freq');
    legend(legLabels,'Location','northeast','FontSize',10);
    ylabel('Power (mV^2)')
   
    treatmentText = '';
    treatments = getTreatmentInfo(animalName,exptDate);
    for i = 1:size(treatments.pars,1)
        treatmentText = [treatmentText treatments.pars{i,1}(1:3) '-'];
    end
    treatmentText = treatmentText(1:end-1);
    
    mainPlotTitle = [animalName '-' exptDate '-' treatmentText];
    annotation('textbox', [0.2, 0.98, 0, 0], 'string', mainPlotTitle,'FontSize',12);
    
    % save the files
    fileName = [savePath saveFileName];
    saveas(QAFig,[fileName '.fig']);
    saveas(QAFig,[fileName '.jpg']);
    
    % print('-painters',fileName,'-r300','-dpng');
    % if reportPlot
    %     try
    %         sendSlackFig(mainPlotTitle,[fileName '.png']);
    %     catch
    %         disp(['failed to upload ' fileName ' to Slack']);
    %     end
    % end


end

