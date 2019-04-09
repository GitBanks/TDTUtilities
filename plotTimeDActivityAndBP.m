function [] = plotTimeDActivityAndBP(animalName,band,saveP)
% DESCRIPTION:
%   Creates the famed 'Grady' plots, showing a time series of power and movement for a
%   given animal and band. Most relevant to us is the delta band. 

% HISTORY: 
%   3/21/19 I inherited this script from Liz & Sean and am now making my own
%   edits. My previous copy was not saved due to a git mistake - Ziyad Sultan
%   Switched from cubic method to pchip based on matlab warnings. Add
%   saving feature. Adjust xticklabels to represent hours. 

%   8/8/18 - I (Liz) have made some changes to the original Grady plot. First,
%   I have accounted for time between indices by adding the appropriate number of NaNs to
%   tempExptActivity and tempExpt bandpower. Second, I have normalized to
%   total power since that's what our current analysis is focused on, and
%   smoothed because it looks nicer. Finally, I have changed some of the axis
%   units/labels to be more informative. Either you're welcome or I'm
%   sorry. - Liz Jaeckel

%   example call:
%   animalName = 'EEG29';
%   band = 'delta';

%   TO-DO: 1) fix scaling of axes 2) add subplots for each channel 

switch nargin
    case 0
        error('At least enter an animal name');
    case 1
        band = 'delta';
        saveP = 0;
        disp('note: plot will not be saved');
    case 2
        saveP = 0;
        disp('note: plot will not be saved');
end

if ~exist('mouseEphys_out','var')
    disp('loading mouseEphys_out structure')
    load('\\144.92.218.131\Data\Data\PassiveEphys\EEG animal data\mouseEphys_out_noParse.mat');
    disp('mouseEphys_out loaded')
end

chan = 1; % only set to do one chan for now!!!

ephysDates = fields(mouseEphys_out.(animalName));
batchDates = fields(batchParams.(animalName));
dates = intersect(batchDates,ephysDates);
chanLabels = batchParams.(animalName).ephysInfo.chanLabels;

disp('extracting band power and activity');
for iDate = 1:length(dates)
    expts = fields(mouseEphys_out.(animalName).(dates{iDate}));
    tempExptBandpower = [];
    tempExptActivity = [];
    for iExpt = 1:length(expts)
        trialsKeptThisExpt = mouseEphys_out.(animalName).(dates{iDate}).(expts{iExpt}).trialsKept;
        ephysDataThisExpt = zeros(1,size(batchParams.(animalName).(dates{iDate}).trialInfo(iExpt).trialTimesRedef,1));
        movementDataThisExpt = zeros(1,size(batchParams.(animalName).(dates{iDate}).trialInfo(iExpt).trialTimesRedef,1));
        for iWindow = 1:length(ephysDataThisExpt)
            if ismember(iWindow,trialsKeptThisExpt)
                ephysDataThisExpt(iWindow) = mouseEphys_out.(animalName).(dates{iDate}).(expts{iExpt}).bandPow.(band)(trialsKeptThisExpt == iWindow,chan)/...
                    mouseEphys_out.(animalName).(dates{iDate}).(expts{iExpt}).bandPow.all(trialsKeptThisExpt == iWindow,chan);
                movementDataThisExpt(iWindow) = mouseEphys_out.(animalName).(dates{iDate}).(expts{iExpt}).activity(trialsKeptThisExpt == iWindow);
            else
                ephysDataThisExpt(iWindow) = NaN;
                movementDataThisExpt(iWindow) = NaN;
            end
        end
        ephysDataThisExpt(isnan(ephysDataThisExpt)) = interp1(find(~isnan(ephysDataThisExpt)), ...
        ephysDataThisExpt(~isnan(ephysDataThisExpt)), find(isnan(ephysDataThisExpt)),'pchip');
        ephysDataThisExpt = smooth(ephysDataThisExpt)';
        movementDataThisExpt(isnan(movementDataThisExpt)) = interp1(find(~isnan(movementDataThisExpt)), ...
        movementDataThisExpt(~isnan(movementDataThisExpt)), find(isnan(movementDataThisExpt)),'pchip');
        tempExptBandpower = [tempExptBandpower ephysDataThisExpt];
        tempExptActivity = [tempExptActivity movementDataThisExpt];
        if iExpt ~=length(expts)
            nWindowsBetweenIndices = round((batchParams.(animalName).(dates{iDate}).trialInfo(iExpt+1).trialTimes(1) - ...
                (batchParams.(animalName).(dates{iDate}).trialInfo(iExpt).trialTimes(end) + 20))/batchParams.(animalName).windowLength*...
                (1-batchParams.(animalName).windowOverlap));
            tempExptBandpower = [tempExptBandpower NaN(1,nWindowsBetweenIndices)];
            tempExptActivity = [tempExptActivity NaN(1,nWindowsBetweenIndices)];
        end
        tempIndexPop(iExpt) = length(tempExptBandpower);
        tempTimeSincePoke(iExpt) = round((batchParams.(animalName).(dates{iDate}).trialInfo(iExpt).trialTimes(1) - batchParams.(animalName).(dates{iDate}).trialInfo(2).trialTimes(1))/60,1);
        tempTimeReInj(iExpt) = batchParams.(animalName).(dates{iDate}).timeReInj(iExpt);
        if iExpt == length(expts)
           tempTimeSincePoke(iExpt + 1) = round((batchParams.(animalName).(dates{iDate}).trialInfo(iExpt).trialTimes(end) - batchParams.(animalName).(dates{iDate}).trialInfo(2).trialTimes(1))/60,1);
        end
    end
    timeRelation(iDate).Bandpower = tempExptBandpower;
    timeRelation(iDate).Activity = tempExptActivity/4;  %added div by 4 19321
    timeRelation(iDate).timeSincePoke = tempTimeSincePoke;
    timeRelation(iDate).timeReInj = tempTimeReInj;
    timeRelation(iDate).indexPop = tempIndexPop;
    yMaxCalc(iDate) = max(timeRelation(iDate).Bandpower);
    bpMn(iDate) = nanmean(timeRelation(iDate).Bandpower);
    activeMn(iDate) = nanmean(timeRelation(iDate).Activity);
    clear tempExptBandpower tempExptActivity tempIndexPop tempTimeReInj
end
yMaxCalc = max(yMaxCalc)/5;
bpMn = nanmean(bpMn);           %band power mean
activeMn = nanmean(activeMn);   %active power mean

% determine offset for movement to allow plotting on same scale
offset = 10^(log10(bpMn))*2;
scaleFactor = activeMn/bpMn*6;%/2

disp('plotting band power and activity');
datesStr = sprintf('%s, ', dates{:});
figureName = ['Time Series Activity and ' band ' power - ' animalName ' - ' chanLabels{chan} ' - ' datesStr(1:end-2)];
figure('Name',figureName,'Renderer', 'painters', 'Position', [-2 624 1680 340]);
for iPlot = 1:length(timeRelation)
    subtightplot(length(timeRelation),1,iPlot);
    plot(timeRelation(iPlot).Bandpower);
    hold on
    plot((timeRelation(iPlot).Activity)/scaleFactor+offset);
    try 
        if size(batchParams.(animalName).(dates{iPlot}).treatment,2) > 1
            treatments = batchParams.(animalName).(dates{iPlot}).treatment;
        end
        for iTreat = 1:size(treatments,2)
            thisTreat = treatments{iTreat};
            thisTreat = strrep(thisTreat,'_',' ');
            vline(timeRelation(iPlot).indexPop(iTreat),'k--',thisTreat);
        end
    catch
        thisTreat = batchParams.(animalName).(dates{iPlot}).treatment;
        vline(timeRelation.indexPop(2),'k--',thisTreat);
    end
    xlim([-20,length(timeRelation(iPlot).Activity)+20])
    ylim([0,yMaxCalc*10]);
    if iPlot == 1; title([animalName ' ' band ' ' chanLabels{chan}]); end
    set(gca,'XTick',[0 timeRelation(iPlot).indexPop(1:length(timeRelation(iPlot).indexPop))],'YTick',[])
    set(gca,'XTickLabel',[timeRelation(iPlot).timeReInj 4])
    ylabel(dates{iPlot});
%     ylabel(batchParams.(animalName).(dates{iPlot}).treatment);
    if iPlot == length(timeRelation)
       xlabel('Time re: inj (hr)');
       legend([band ' power'],'activity','Location','NorthEast');
    end
end
clear timeRelation

%save plot here:
if saveP 
    disp('saving figure');
    outPath = 'M:\mouseEEG\Power vs activity\';
    savePlot(outPath,figureName)
end


% OLD SHIT:
%     plot(timeRelation(iPlot).indexPop,0,'k*');
%     xlim([0,length(timeRelation(length(timeRelation)).Activity)]);
%what the fuck is this??
% for iDate = 1:2 
%     timeRelation(iDate).Activity = timeRelation(iDate).Activity/4;
% end
%     set(gca,'xticklabel',timeRelation(iPlot).timeSincePoke);
%timeRelation(iDate).div = tempExptBandpower./tempExptActivity; %what is this???


