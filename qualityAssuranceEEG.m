function qualityAssuranceEEG(animalName,exptDate,reportPlot,textNotes)

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



% Question: do we want to store this by animal, or by project?
% here's by animal:
% savePath = [getPathGlobal('animalSaves') animalName '\']
% here's project:

savePath = '\\144.92.237.185\Data\PassiveEphys\AnimalData\combined\QA\'; %change this for saving 
saveFileName = [animalName '-' exptDate '-QA'];

if ~exist('textNotes','var')
    textNotes = '';
end

% find the correct files and set a few variables
findExptType = 'Spon';
[operationList] = getExperimentsByAnimalAndDate(animalName,exptDate,findExptType);
year = exptDate(1:2);
rangeStart = 600;
rangeEnd = 605;
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
    time_logi = find(t>=rangeStart & t<=rangeEnd);
    if i == ctrlHour
        ctrlHourArray = ephysData(:,time_logi);
        timeArray = t(time_logi);
    end
    if i == manipHour
        manipHourArray = ephysData(:,time_logi);
    end
    fullExptChannel = [fullExptChannel ephysData(fullChannel,:)];
end
% downsample
fullExptChannel = fullExptChannel(1:10:end);
fullTimeArray = (0:size(fullExptChannel,2)-1)*(dT*10)/60;

lowerB = prctile(fullExptChannel,1)*2; % 1st prctile
upperB = prctile(fullExptChannel,99)*2; % 99th prctile


% pull the spectra data from the saved run

saveFolder = 'M:\PassiveEphys\AnimalData\combined\'; % EEG animals bandpower location
% saveFolder = 'M:\Zarmeen\Data\spectra\'; % ZZ animal bandpower location 
load([saveFolder animalName '_' exptDate '_bandpowerSet.mat'],"dataSet");
getYMax = nan;
getYMin = nan;
for iHour = 1:size(dataSet,2)
    getYMax = max(max(max(dataSet(iHour).avgSpectra)),getYMax);
    getYMin = max(min(min(dataSet(iHour).avgSpectra)),getYMin);
end


% start plotting

% more conventions
legLabels = {'Pre inj 1','Pre inj 2','Post inj 1','Post inj 2','Post inj 3','Post inj 4'};

QAFig = figure('Units','Normalized','Position',[0 0 0.7 0.7]);
figRows = 5;
figColumns = 6;

% plot full day across the top
subplot(figRows,figColumns,1:figColumns);
secondsOfDataErased = sum(isnan(fullExptChannel))/(1/dT)*10;

plot(fullTimeArray,fullExptChannel);
%  ylim([lowerB*3,upperB*3]);  % don't force this scale!  we need to blank
%  out the extreme noise events!!!!!!!!
xlim([0,fullTimeArray(end)]);
%xlabel('minutes');
ylabel('Volts');
title(['Full REC (minutes); Channel ' num2str(fullChannel) '; ' num2str(secondsOfDataErased) ' seconds of NaN; ' textNotes],'FontSize',10)

%ctrl and manip plot loop
startCtrlPlotColumn = 11;
for iPlot = 1:4
    thisSub = startCtrlPlotColumn+(iPlot-1)*figColumns;
    subplot(figRows,figColumns,thisSub);
    plot(timeArray,ctrlHourArray(iPlot,:));
    xlim([rangeStart rangeEnd]);
    ylim([lowerB,upperB]);
    if iPlot == 1
%         title(['Hour: ' num2str(ctrlHour)],'FontSize',10)
        title([legLabels{ctrlHour} ' sample'],'FontSize',10);
    end
    if iPlot == 4
        xlabel('seconds');
        ylabel('Volts');
    end


    subplot(figRows,figColumns,thisSub+1);
    plot(timeArray,manipHourArray(iPlot,:));
    xlim([rangeStart rangeEnd]);
    ylim([lowerB,upperB]);
    if iPlot == 1
%         title(['Hour: ' num2str(manipHour)],'FontSize',10)
        title([legLabels{manipHour} ' sample'],'FontSize',10);
    end

end

% this should be taken from a save file!  not hard coded here.  it's only
% here for convenience.  We should be saving this in the file we load above
%!!!!! TODO!!!
freqLabels = [1 2 3 4 5 6 7 8 10 12 14 18 22 26 30 40 50 60 70 80 90 100 110 120];

% this is the weird pattern we'll need to address multiple subplots to
% create the correct shape (square) for the avg spectra 
subplotRange = [7 8 13 14; 9 10 15 16; 19 20 25 26; 21 22 27 28];

% a convention we've been using for a while
channelRemapping = [4 1 3 2]; %going to change with different number of electrodes ????????

% need to track the subplots and channels distinctly and carefully!  ii vs
% iChan via channelRemapping
for ii = 1:nChans
    iChan = channelRemapping(ii);
    subplot(figRows,figColumns,subplotRange(ii,:));
    for iHour = 1:size(dataSet,2)
        loglog(freqLabels,dataSet(iHour).avgSpectra(:,iChan)); 
        hold on
    end
    ylim([getYMin*1.1,getYMax*1.1]);
    title(['Channel ' num2str(iChan)],'FontSize',10);
end

for iChan = 1:nChans
    subplot(figRows,figColumns,subplotRange(iChan,:));
    if iChan == 1
        set(gca,'xticklabel',{[]});
    end
    if iChan == 2
        set(gca,'xticklabel',{[]});
        set(gca,'yticklabel',{[]});
    end
    if iChan == 3
        xlabel('Freq');
        legend(legLabels,'Location','southwest','FontSize',6);
        ylabel('Power (mV^2)')
    end
    if iChan == 4
        set(gca,'yticklabel',{[]});
    end
end

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

print('-painters',fileName,'-r300','-dpng');
if reportPlot
    try
        sendSlackFig(mainPlotTitle,[fileName '.png']);
    catch
        disp(['failed to upload ' fileName ' to Slack']);
    end
end

close all




