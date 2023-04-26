function summaryData = plotSpectraLFP(animalName,exptDate,chansToExclude)

% chansToExclude = nan
 
% problem animals  
% 
% exptDate = '22831'
% animalName = 'ZZ20'

% % no movement data animal
% % animalName = 'ZZ06' 
% % exptDate = '21520' 
% % exptDate = '21608'
% % chansToExclude = nan
% 
% % no pre injection recording (4-aco treatment) 
% % animalName = 'ZZ06';
% % exptDat = '21512'
% % chansToExclude = nan;

% noise problems 
% animalName = 'ZZ09' 
% exptDate = '21623'
% animalName = 'ZZ14' 
% exptDate = '22120'
% animalName = 'ZZ14' 
% exptDate = '22120'

% animalName = 'ZZ14' 
% exptDate = '22120'
% animalName = 'ZZ19'
% exptDate = '22705'
% animalName = 'ZZ09';
% exptDate = '21623';
% animalName = 'ZZ10';
% exptDate = '21726';

% chansToExclude = nan

% problem days:
% animalName = 'ZZ09';
% exptDate = '21804';
% animalName = 'ZZ10';
% exptDate = '21804';
% chansToExclude = nan


% this is just for Zarmeen's data
saveFolder = 'M:\Zarmeen\data\spectra\';

if iscell(chansToExclude)
    chansToExclude = chansToExclude{:};
end
if ischar(chansToExclude)
    chansToExclude = str2num(chansToExclude);
end

% save some specific data for Matt
summaryData = struct;



% legLabels = {'Ch1','Ch2','Ch3','Ch4','Ch5','Ch6'};
% legLabels = {'Pre inj','Post inj 1','Post inj 2','Post inj 3','Post inj 4','Post inj 5','Post inj 6','Post inj 7'};
% plotTitleLabels = {'R Anterior','R Posterior','L Posterior','L Anterior'};
% no, do better.  load this from database!
% we're also going to run into trouble if this isn't the EEG.  What we need
% to do is reference the mapping files we make for each animal, then base
% which subplots to make on that...


folder = ['M:\PassiveEphys\AnimalData\initial\' animalName '\']; % data from the pipeline 
chanEEGRemap = [1,2,3,4,5,6]; % direct channels to specific subplots so that channels line up with their physical locations
% the file will be some crazy thing like this:
% 'EEG210_22629-001,22629-003,22629-005,22629-007,22629-009,22629-011 wPLI_dbt'; 
% instead, we'll search for it.
dataFolder = dir(folder);
for iFile = 1:size(dataFolder,1)
    if contains(dataFolder(iFile).name,'specAnalysis') && contains(dataFolder(iFile).name,exptDate) 
        file = dataFolder(iFile).name;
    end
end
if ~exist('file','var')
    error(['Found ' dataFolder(1).folder ' but not the file we''re looking for!']);
end

load([folder file]); %careful! what if there's another file with a similar name?  as written, the code will just load the last one it found, but that's not certainly the correct one...

% load and plot - edit for specific recording type and channels
listOfSegments = fields(out.specAnalysis{1,1});
% grab the labels / values for the frequencies
freqLabels = out.specAnalysis{1,1}.(listOfSegments{1}).freq;
% For EEG, we want to compare anterior electrodes to posterior
%plottingArray = nan(nChans,nChans,size(listOfSegments,1));
nChans = size(out.specAnalysis{1,1}.(listOfSegments{1}).powspctrm,1);
for iSegment = 1:size(listOfSegments,1)
    thisSeg = listOfSegments{iSegment};
    for iChan = 1:nChans
        specdataLog(iChan).data(iSegment,:) = log2(out.specAnalysis{1,1}.(thisSeg).powspctrm(iChan,:));
        % taking the log2 of these is fine for the spectrogram, but the
        % units will get nonsensical without that context.  If we want to
        % look at average spectral power, we need the not log data too.
        specdata(iChan).data(iSegment,:) = out.specAnalysis{1,1}.(thisSeg).powspctrm(iChan,:);
    end
end
% also exclude channels here
if ~isnan(chansToExclude)
    for iChan = 1:size(chansToExclude,1)
        specdata(chansToExclude(iChan)).data(:,:) = nan;
        specdataLog(chansToExclude(iChan)).data(:,:) = nan;
    end
end



for iChan = 1:nChans
    specdataLog(iChan).data = specdataLog(iChan).data';
    specdata(iChan).data = specdata(iChan).data';
end

windowTimes = out.segmentTimeOfDay{1,1};
[exptDate_dbForm] = houseConvertDateTo_dbForm(exptDate);
windowTimes = datetime(exptDate_dbForm,'TimeZone','local')+windowTimes;
[moveTimeDrugStruct] = getMoveTimeDrugbyAnimalDate(animalName,exptDate);
moveTimes = moveTimeDrugStruct.fullTimeArrayTOD;
moveArray = moveTimeDrugStruct.fullMoveStream;
TheseDrugs = moveTimeDrugStruct.drugTOD;

% times of day for indecies are found under the animal's metaData.blockTime
% try pulling all the blocks from metadata based on today's date (i.e.,
% exptDate)
% metadata location
rootFileLocation = 'M:\PassiveEphys\AnimalData\';
metaDataLocation = [rootFileLocation animalName '\metaData.mat'];
load(metaDataLocation);
newTable = metaData(contains(metaData.block,exptDate),:);
nextTimeArray = newTable.blockTime; % these will be our new breaks against this array:

for iBreak = 1:size(nextTimeArray,1)
    avgSpectraBreakIndex(iBreak) = find(windowTimes>=nextTimeArray(iBreak),1);
    movementBreakIndex(iBreak) = find(moveTimes>=nextTimeArray(iBreak),1);
end
adjTimes = windowTimes-TheseDrugs(end).time;
adjMoveTimes = moveTimes-TheseDrugs(end).time;


% 
% 
% windowTimes
% -TheseDrugs(end).time % we still need this to adjust everything relative to injection
% % we still want to create these:
% avgSpectraBreakIndex
% movementBreakIndex

% ZARMEEN EDITS TODO
% OK, finding the breaks for Zarmeen's set doesn;t work cleanly, but we can
% jump to the spectrograms (last plot) below for now.  The next step is to
% fix the break points and use them for the other two (first two) plots
% we can keep the for iDrugInj = 1:size(TheseDrugs,2) loop to adjust the
% firt times, but it's a little weird.  needs an overhaul.
%
% % t = 0 should be injection;  
% % WARNING!  this assumes that the last injection is the one to ref as t=0
% 
% try
%     adjTimes = windowTimes-TheseDrugs(end).time;
%     adjMoveTimes = moveTimes-TheseDrugs(end).time;
%     % we will need to break apart the avgSpectra based on drug injection times,
%     % then hour lengths after 2nd injection, so grab these times here, too
%     for iDrugInj = 1:size(TheseDrugs,2)
%         TheseDrugs(iDrugInj).adjTime = TheseDrugs(iDrugInj).time-TheseDrugs(end).time;
%         avgSpectraBreakIndex(iDrugInj) = find(adjTimes>TheseDrugs(iDrugInj).adjTime,1);
%         movementBreakIndex(iDrugInj) = find(adjMoveTimes>TheseDrugs(iDrugInj).adjTime,1);
%     end
% catch
%     error('Not set to handle no injection yet!!!!!')
% %     disp('HEY!!!! there was no drug information for this day.  I wrote this assuming a drug was given.');
% %     disp('I assume you don;t want it to crash here, so I''m seeting t=0 to be the start of REC' );
% %     pause(2);
% %     adjTimes = windowTimes;
% %     adjMoveTimes = moveTimes;
% %     avgSpectraBreakIndex(1) = 1;
% %     movementBreakIndex(1) = 1;
% end
% 2/24/23: we need to figure out if and why the first few indecies are
% getting merged.... this stupid 'breakpoint' thing strikes again...

% 2/10/23 I think the above is workng ???? pls test
% % find breakpoints
% moreTime = true;
% nextTime = 1;
% while moreTime
%     avgSpectraBreakIndex(nextTime) = find(windowTimes>=nextTimeArray(nextTime),1);
%     movementBreakIndex(nextTime) = find(moveTimes>=nextTimeArray(nextTime),1);
%     nextTime = nextTime+1;
%     if windowTimes(end) < nextTime
%         moreTime = false;
%     end
% end



% ZARMEEN EDITS TODO
% need to totally rethink this for Zarmeen's data - it assumes the channels
% counts AND hours are set up as EEG
% we REALLY want this corrected:   dataSet(iHour).avgSpectra(:,iChan)
% so step through the iHour based on index instead of the goofy hours
% established above.

% combine front and rear for bandpower analysis
% warning!  hardcoded channels for now!!!  fix this via database!!!!
% I don;t like the way I wrote this, but if either of a front/rear pair is
% naned out, just make the final 'combined' data to good channel.  I don't
% know if anything needs to be done otherwise (like error / scaling thing)
% if any(any(isnan(specdata(1).data))) || any(any(isnan(specdata(4).data)))
%     if any(any(isnan(specdata(1).data))) 
%         combSpecdata(1).data = specdata(4).data;
%     else
%         combSpecdata(1).data = specdata(1).data;
%     end
% else
%     combSpecdata(1).data = (specdata(1).data+specdata(4).data)/2;
% end
% if any(any(isnan(specdata(2).data))) || any(any(isnan(specdata(3).data)))
%     if any(any(isnan(specdata(2).data)))
%         combSpecdata(2).data = specdata(3).data;
%     else
%         combSpecdata(2).data = specdata(2).data;
%     end
% else
%     combSpecdata(2).data = (specdata(2).data+specdata(3).data)/2;
% end

% avgSpectraBreakIndex = [1 avgSpectraBreakIndex];
% movementBreakIndex = [1 movementBreakIndex];






nChans = size(specdata,2);
for iHour = 1:size(avgSpectraBreakIndex,2)-1
    iStart = avgSpectraBreakIndex(iHour);
    iStop = avgSpectraBreakIndex(iHour+1)-1;
    for iChan = 1:nChans % for average spectra
        dataSet(iHour).avgSpectra(:,iChan) = mean(specdata(iChan).data(:,iStart:iStop),2,'omitnan');
    end
    dataSet(iHour).movement = moveArray(movementBreakIndex(iHour):movementBreakIndex(iHour+1)-1);
    dataSet(iHour).movementTimes = adjMoveTimes(movementBreakIndex(iHour):movementBreakIndex(iHour+1)-1);
    dataSet(iHour).time = adjTimes(iStart:iStop);
    for iChan = 1:nChans % bandpower only uses front and rear. this should be done better, but...
        % also break spectra into bands like the undergrad homework assignment:
        % will be much better to break this out into a function so we're
        % not repeating ourselves, but this will work for now.
        % Delta
        bounds(1) = find(freqLabels>=FreqBands.Limits.delta(1),1);
        bounds(2) = find(freqLabels>=FreqBands.Limits.delta(2),1);
%         dataSet(iHour).delta(:,iChan) = specdata(iChan).data(bounds(1):bounds(2),iStart:iStop);
        dataSet(iHour).avgDelta(:,iChan) = mean(specdata(iChan).data(bounds(1):bounds(2),iStart:iStop));
        % Theta
        bounds(1) = find(freqLabels>=FreqBands.Limits.theta(1),1);
        bounds(2) = find(freqLabels>=FreqBands.Limits.theta(2),1);
%         dataSet(iHour).theta(:,iChan) = specdata(iChan).data(bounds(1):bounds(2),iStart:iStop);
        dataSet(iHour).avgTheta(:,iChan) = mean(specdata(iChan).data(bounds(1):bounds(2),iStart:iStop));
        % Alpha
        bounds(1) = find(freqLabels>=FreqBands.Limits.alpha(1),1);
        bounds(2) = find(freqLabels>=FreqBands.Limits.alpha(2),1);
%         dataSet(iHour).alpha(:,iChan) = specdata(iChan).data(bounds(1):bounds(2),iStart:iStop);
        dataSet(iHour).avgAlpha(:,iChan) = mean(specdata(iChan).data(bounds(1):bounds(2),iStart:iStop));
        % Beta
        bounds(1) = find(freqLabels>=FreqBands.Limits.beta(1),1);
        bounds(2) = find(freqLabels>=FreqBands.Limits.beta(2),1);
%         dataSet(iHour).beta(:,iChan) = specdata(iChan).data(bounds(1):bounds(2),iStart:iStop);
        dataSet(iHour).avgBeta(:,iChan) = mean(specdata(iChan).data(bounds(1):bounds(2),iStart:iStop));
        % Gamma
        bounds(1) = find(freqLabels>=FreqBands.Limits.gamma(1),1);
        bounds(2) = find(freqLabels>=FreqBands.Limits.highGamma(2),1);
%         dataSet(iHour).gamma(:,iChan) = specdata(iChan).data(bounds(1):bounds(2),iStart:iStop);
        dataSet(iHour).avgGamma(:,iChan) = mean(specdata(iChan).data(bounds(1):bounds(2),iStart:iStop));
    end
end




% ZARMEEN EDITS TODO
% we don;t care about pre-post hours, but maybe Z wants something else
% saved?

% controlHour = 1;
% postDrugManipHour = 4;

% % this is really ugly hardcoding.  FIX THIS!
summaryData.pre.move = mean(dataSet(1).movement);
summaryData.post.move = mean(dataSet(4).movement);
summaryData.pre.avgDelta = dataSet(1).avgDelta;
summaryData.pre.avgTheta = dataSet(1).avgTheta;
summaryData.pre.avgAlpha = dataSet(1).avgAlpha;
summaryData.pre.avgBeta = dataSet(1).avgBeta;
summaryData.pre.avgGamma = dataSet(1).avgGamma;
summaryData.post.avgDelta = dataSet(4).avgDelta;
summaryData.post.avgTheta = dataSet(4).avgTheta;
summaryData.post.avgAlpha = dataSet(4).avgAlpha;
summaryData.post.avgBeta = dataSet(4).avgBeta;
summaryData.post.avgGamma = dataSet(4).avgGamma;
summaryData.TheseDrugs = TheseDrugs;
% 
% 
% 
save([saveFolder animalName '_' exptDate '_bandpowerSet.mat'],"dataSet");


% end of 2/10/23


% ZARMEEN EDITS TODO
% this will work once the dataSet loop is corrected to count index

%  ======= Plotting bandpower =============================================

if size(TheseDrugs,2) > 1
    titletext = [animalName ' Bandpower over time for ' exptDate ' ' TheseDrugs(1).what ' & ' TheseDrugs(2).what];
    savetext = [TheseDrugs(1).what '_' TheseDrugs(2).what];
else
    titletext = [animalName ' Bandpower over time for ' exptDate ' ' TheseDrugs(1).what];
    savetext = TheseDrugs(1).what;
end

bandPower = figure('Name',titletext); 

% add this for animals without movement data 
if contains(animalName, 'ZZ06')
    subplotrows = 5;
else
    subplotrows = 6;
end

% hardcoded ylimits 

for iHour = 1:size(dataSet,2)
    subtightplot(subplotrows,1,1);
    title(titletext);
    plot(dataSet(iHour).time,dataSet(iHour).avgDelta(:,1),"Color",'r');
    hold on
    if nChans > 2 
        plot(dataSet(iHour).time,dataSet(iHour).avgDelta(:,3),"Color",'b');
    end
    ylim ([0 8e-7]);
    ylabel('delta power');

    subtightplot(subplotrows,1,2);
    plot(dataSet(iHour).time,dataSet(iHour).avgTheta(:,1),"Color",'r');
    hold on
    if nChans > 2
        plot(dataSet(iHour).time,dataSet(iHour).avgTheta(:,3),"Color",'b');
    end
    ylim ([0 4e-7]);
    ylabel('theta power');

    subtightplot(subplotrows,1,3);
    plot(dataSet(iHour).time,dataSet(iHour).avgAlpha(:,1),"Color",'r');
    hold on
    if nChans > 2
        plot(dataSet(iHour).time,dataSet(iHour).avgAlpha(:,3),"Color",'b');
    end
    ylim ([0 1.5e-7]);
    ylabel('alpha power');

    subtightplot(subplotrows,1,4);
    plot(dataSet(iHour).time,dataSet(iHour).avgBeta(:,1),"Color",'r');
    hold on
    if nChans > 2
        plot(dataSet(iHour).time,dataSet(iHour).avgBeta(:,3),"Color",'b');
    end
    ylim ([0 2.5e-8]);
    ylabel('beta power')

    subtightplot(subplotrows,1,5);
    plot(dataSet(iHour).time,dataSet(iHour).avgGamma(:,1),"Color",'r');
    hold on
    if nChans > 2
        plot(dataSet(iHour).time,dataSet(iHour).avgGamma(:,3),"Color",'b');
    end
    ylabel('gamma power');
    ylim([0,1e-8])
%     ylim([0,4.5e-9])


%    checks if there's movement data and will plot accordingly 
    if ~contains(animalName,'ZZ06')
        subtightplot(subplotrows,1,6);
        plot(dataSet(iHour).movementTimes, dataSet(iHour).movement,"Color",'b');
        hold on
        ylabel('Movement');
        ylim([0,max(moveArray)*1.2]);
        xlim([dataSet(1).movementTimes(1),dataSet(end).movementTimes(end)]);
    end

    subtightplot(6,1,6);
    plot(dataSet(iHour).movementTimes, dataSet(iHour).movement,"Color",'b');
    hold on
    ylabel('Movement');
    ylim([0,max(moveArray)*1.2]);
    xlim([dataSet(1).movementTimes(1),dataSet(end).movementTimes(end)]);
end
subtightplot(6,1,5);
legend({'Front','Rear'});
for i = 1:5
    subtightplot(6,1,i);
    xlim([dataSet(1).time(1),dataSet(end).time(end)]);
end

% legend

allAnimalExpt = getExperimentsByAnimal(animalName);
ElectrodeLocationDate = allAnimalExpt{1}(1:5);
ElectrodeLocationIndex = allAnimalExpt{1}(7:9);
[electrodeLocation,map,~] = getElectrodeLocationFromDateIndex(ElectrodeLocationDate,ElectrodeLocationIndex);


electrodeLocationplot = find(~rem(map,2)==0);
legendinfo = [];

if ~exist([saveFolder 'bandpower\'],"dir")
    mkdir([saveFolder 'bandpower\']);
end
saveas(bandPower,[saveFolder 'bandpower\' animalName '-' exptDate '-' savetext '.fig']);
saveas(bandPower,[saveFolder 'bandpower\' animalName '-' exptDate '-' savetext '.jpg']);


%  ======= Plotting smoothed bandpower a la Ziyad's paper =================

titletext = [animalName ' Bandpower over time for ' exptDate ' ' TheseDrugs(1).what];
savetext = TheseDrugs(1).what;
bandPowerSmoothed = figure('Name',titletext); 
for iHour = 1:size(dataSet,2)

    subtightplot(3,1,1);
    title(titletext);
    plot(dataSet(iHour).time,dataSet(iHour).avgDelta(:,1),"Color",'r');
    hold on
    plot(dataSet(iHour).time,dataSet(iHour).avgDelta(:,3),"Color",'b');
    ylabel('delta power');

    subtightplot(3,1,2);
    plot(dataSet(iHour).time,smooth(dataSet(iHour).avgDelta(:,1),30),"Color",'r');
    hold on
    plot(dataSet(iHour).time,smooth(dataSet(iHour).avgDelta(:,3),30),"Color",'b');
    ylabel(' smoothed delta power');

    subtightplot(3,1,3);
    plot(adjMoveTimes, moveArray);
    ylabel('Movement');
    ylim([0,max(moveArray)*1.2]);
    xlim([adjMoveTimes(1),adjMoveTimes(end)]);
end
subtightplot(3,1,3);
legend({'Front','Rear'});
for i = 1:2
    subtightplot(3,1,i);
    xlim([adjTimes(1),adjTimes(end)]);
end
















for iPlot = 1:length(electrodeLocationplot)       
    legendinfo{iPlot} = electrodeLocation{map(electrodeLocationplot(iPlot))};
end


if nChans > 2
    subtightplot(subplotrows,1,5);
    legend(legendinfo{1:2})
else 
    subtightplot (subplotrows,1,5);
    legend(legendinfo{1})
end

for i = 1:5
    subtightplot(subplotrows,1,i);
    xlim([dataSet(1).time(1),dataSet(end).time(end)]);
end

% saving below
% 
% if ~exist([saveFolder 'bandpower\'],"dir")
%     mkdir([saveFolder 'bandpower\']);
% end
% 
% 
% if ~exist([saveFolder 'bandpower\' animalName],"dir")
%     mkdir([saveFolder 'bandpower\' animalName]);
% end
% 
% 
% saveas(bandPower,[saveFolder 'bandpower\' animalName '\' animalName '-' exptDate '-' savetext '.fig']);
% saveas(bandPower,[saveFolder 'bandpower\' animalName '\' animalName '-' exptDate '-' savetext '.jpg']);

% saving by drug !!! HARDCODED !!!

if ~exist([saveFolder 'bandpower\'],"dir")
    mkdir([saveFolder 'bandpower\']);
end
% 
% ------------4aco-------------
% if ~exist([saveFolder 'bandpower\4-AcO-DMT' ],"dir")
%     mkdir([saveFolder 'bandpower\4-AcO-DMT' ]);
% end
% 
% saveas(bandPower,[saveFolder 'bandpower\4-AcO-DMT\' animalName '-' exptDate '-' savetext '.fig']);
% saveas(bandPower,[saveFolder 'bandpower\4-AcO-DMT\' animalName '-' exptDate '-' savetext '.jpg']);
% 
% 
% ---------6fdet-------------
if ~exist([saveFolder 'bandpower\6-FDET' ],"dir")
    mkdir([saveFolder 'bandpower\6-FDET' ]);
end

saveas(bandPower,[saveFolder 'bandpower\6-FDET\' animalName '-' exptDate '-' savetext '.fig']);
saveas(bandPower,[saveFolder 'bandpower\6-FDET\' animalName '-' exptDate '-' savetext '.jpg']);

% 
% ----------saline------------
% if ~exist([saveFolder 'bandpower\Saline' ],"dir")
%     mkdir([saveFolder 'bandpower\Saline' ]);
% end
% 
% saveas(bandPower,[saveFolder 'bandpower\Saline\' animalName '-' exptDate '-' savetext '.fig']);
% saveas(bandPower,[saveFolder 'bandpower\Saline\' animalName '-' exptDate '-' savetext '.jpg']);

% ---------psilocybin------------
% if ~exist([saveFolder 'bandpower\Psilocybin' ],"dir")
%     mkdir([saveFolder 'bandpower\Psilocybin' ]);
% end
% 
% saveas(bandPower,[saveFolder 'bandpower\Psilocybin\' animalName '-' exptDate '-' savetext '.fig']);
% saveas(bandPower,[saveFolder 'bandpower\Psilocybin\' animalName '-' exptDate '-' savetext '.jpg']);




% ===== Plotting smoothed Delta bandpower =======================================
% 
% titletext = [animalName ' Delta Bandpower over time for ' exptDate ' ' TheseDrugs(1).what];
% savetext = TheseDrugs(1).what;
% bandPowerSmoothed = figure('Name',titletext); 
% 
% 
% % checks if there's movement data and will plot accordingly 
% if contains(animalName,'ZZ06')
%     subplotrows = 2;
% else
%     subplotrows = 3;
% end
% 
% 
% for iHour = 1:size(dataSet,2)
% 
%     subtightplot(subplotrows,1,1);
%     title(titletext);
%     
%     
%     plot(dataSet(iHour).time,dataSet(iHour).avgDelta(:,1),"Color",'r');
%     hold on
%     if nChans > 2 
%         plot(dataSet(iHour).time,dataSet(iHour).avgDelta(:,3),"Color",'b');
%     end
%     hold on 
%     ylabel('delta power');
% 
%     subtightplot(subplotrows,1,2);
%     plot(dataSet(iHour).time,smooth(dataSet(iHour).avgDelta(:,1),30),"Color",'r');
%     hold on
%     if nChans >2 
%         plot(dataSet(iHour).time,smooth(dataSet(iHour).avgDelta(:,3),30),"Color",'b');
%     end
%     hold on 
%     ylabel(' smoothed delta power');
% 
% %   checks if there's movement data and will plot accordingly 
%     if ~contains(animalName,'ZZ06')
%         subtightplot(subplotrows,1,3);
%         plot(dataSet(iHour).movementTimes, dataSet(iHour).movement,"Color",'b');
%         hold on
%         ylabel('Movement');
%         ylim([0,max(moveArray)*1.2]);
%         xlim([dataSet(1).movementTimes(1),dataSet(end).movementTimes(end)]);
%     end
% end
% 
% 
% % legend info and adding to plots 
% allAnimalExpt = getExperimentsByAnimal(animalName);
% ElectrodeLocationDate = allAnimalExpt{1}(1:5);
% ElectrodeLocationIndex = allAnimalExpt{1}(7:9);
% [electrodeLocation,map,~] = getElectrodeLocationFromDateIndex(ElectrodeLocationDate,ElectrodeLocationIndex);
% 
% electrodeLocationplot = find(~rem(map,2)==0);
% legendinfo = [];
% 
% 
% for iPlot = 1:length(electrodeLocationplot)       
%     legendinfo{iPlot} = electrodeLocation{map(electrodeLocationplot(iPlot))};
% end
% 
% if nChans > 2
%     subtightplot(subplotrows,1,2);
%     legend(legendinfo{1:2})
% else 
%     subtightplot (subplotrows,1,2);
%     legend(legendinfo{1})
% end
% 
% 
% 
% for i = 1:2
%     subtightplot(subplotrows,1,i);
%     xlim([dataSet(1).time(1),dataSet(end).time(end)]);
% end
% 
% % saving below 
% 
% if ~exist([saveFolder 'smthDeltabandpower\'],"dir")
%     mkdir([saveFolder 'smthDeltabandpower\']);
% end
% 
% 
% if ~exist([saveFolder 'smthDeltabandpower\' animalName],"dir")
%     mkdir([saveFolder 'smthDeltabandpower\' animalName]);
% end
% 
% saveas(bandPowerSmoothed,[saveFolder 'smthDeltabandpower\' animalName '\' animalName '-' exptDate '-' savetext '.fig']);
% saveas(bandPowerSmoothed,[saveFolder 'smthDeltabandpower\' animalName '\' animalName '-' exptDate '-' savetext '.jpg']);


% Average Spec and Spectrogram ( Commented out ) 

% 
% % ZARMEEN EDITS TODO
% % this will work once the dataSet loop is corrected to count index
% % ======= Plotting average spectral power =================================
% if size(TheseDrugs,2) > 1
%     titletext = [animalName ' average spectral power for ' exptDate ' ' TheseDrugs(1).what ' & ' TheseDrugs(2).what];
%     savetext = [TheseDrugs(1).what '_' TheseDrugs(2).what];
% else
%     titletext = [animalName ' average spectral power for ' exptDate ' ' TheseDrugs(1).what];
%     savetext = TheseDrugs(1).what;
% end
% 
% getYMax = nan;
% getYMin = nan;
% for iHour = 1:size(dataSet,2)
%     getYMax = max(max(max(dataSet(iHour).avgSpectra)),getYMax);
%     getYMin = max(min(min(dataSet(iHour).avgSpectra)),getYMin);
% end
% 
% avgspectra = figure('Name',titletext); 
% for iChan = 1:nChans
%     subplot(3,2,chanEEGRemap(iChan));
% %     subtightplot(2,2,chanEEGRemap(iChan),[0.04,0.01]);
%     for iHour = 1:size(dataSet,2)
%         loglog(freqLabels,dataSet(iHour).avgSpectra(:,iChan)); 
%         hold on
%     end
%     
%     %ylabel('Power (mV^2)');  % this is wrong... stop showing the wrong thing...
%     
%     ylim([getYMin*1.1,getYMax*1.1]);
%     % title(['Ch' num2str(iChan) ' ' plotTitleLabels{iChan}],'Interpreter', 'none');  
% end
% 
% 
% % for iChan = 1:nChans
% % %     subtightplot(2,2,iChan,[0.04,0.01]);
% %     subplot(3,2,iChan);
% % 
% %     if iChan == 1
% %         set(gca,'xticklabel',{[]});
% %     end
% %     if iChan == 2
% %         set(gca,'xticklabel',{[]});
% %         set(gca,'yticklabel',{[]});
% %     end
% %     if iChan == 3
% %         xlabel('Freq');
% %         % legend(legLabels,'Location','southwest','FontSize',5);
% %         ylabel('Power (mV^2)')
% %     end
% %     if iChan == 4
% %         set(gca,'yticklabel',{[]});
% %     end
% % end
% sgtitle([animalName '-' exptDate '-' savetext],'Interpreter', 'none');
% 
% if ~exist([saveFolder 'avgspectra\'],"dir")
%     mkdir([saveFolder 'avgspectra\']);
% end
% saveas(avgspectra,[saveFolder 'avgspectra\' animalName '-' exptDate '-' savetext '.fig']);
% saveas(avgspectra,[saveFolder 'avgspectra\' animalName '-' exptDate '-' savetext '.jpg']);
% 
% 
% 
% 
% 
% 
% % ======= Plotting spectrogram and movement ===============================
% 
% if size(TheseDrugs,2) > 1
%     titletext = [animalName ' spectrogram and movement for ' exptDate ' ' TheseDrugs(1).what ' & ' TheseDrugs(2).what];
%     savetext = [TheseDrugs(1).what '_' TheseDrugs(2).what];
% else
%     titletext = [animalName ' spectrogram and movement for ' exptDate ' ' TheseDrugs(1).what];
%     savetext = TheseDrugs(1).what;
% end
% 
% spectrogramFig = figure('Name',titletext);
% for iChan = 1:nChans
%     subtightplot(nChans+1,1,iChan);
%     colormap('jet')
%     pcolor(adjTimes,log2(freqLabels),specdataLog(iChan).data)
%     shading flat
%     axis xy; %colorbar('east');
%     if iChan == nChans; colorbar('east'); end
%     ylim([log2(freqLabels(1)) log2(freqLabels(end))]);
%     set(gca,'fontsize',10);
%     set(gca,'ytick',log2([2 4 8 16 30 50]),'yticklabel',string([2 4 8 16 30 50]));
%     ylabel('Hz');
%     xlabel('time');
% end
% % Movement here (loaded previously)
% subtightplot(nChans+1,1,nChans+1);
% plot(adjMoveTimes, moveArray);
% ylabel('Movement');
% xlim([adjMoveTimes(1),adjMoveTimes(end)]);
% ylim([0,max(moveArray)*1.2]);
% % indicate where manipulations took place.
% % loop through drug injections here
% for iDrugInj = 1:size(TheseDrugs,2)
%     thisDrugTime = TheseDrugs(iDrugInj).adjTime;
%     thisDrugName = [TheseDrugs(iDrugInj).what ' ' num2str(TheseDrugs(iDrugInj).amount)];
%     xline(thisDrugTime,'-',thisDrugName);
% end
% sgtitle([animalName '-' exptDate '-' savetext],'Interpreter', 'none');
% 
% if ~exist([saveFolder 'spectrogram\'],"dir")
%     mkdir([saveFolder 'spectrogram\']);
% end
% saveas(spectrogramFig,[saveFolder 'spectrogram\' animalName '-' exptDate '-' savetext '.fig']);
% saveas(spectrogramFig,[saveFolder 'spectrogram\' animalName '-' exptDate '-' savetext '.jpg']);
% 
% 
% 
% 




% Movement related code 














% %%% ================= Movement from pipeline example ====================
% fileList = out.block;
% listToUse = strsplit(fileList,',');
% 
% % we also need metadata - change animal name
% metadataPath = ['M:\PassiveEphys\AnimalData\' animalName '\metadata.mat'];
% load(metadataPath);
% 
% %Pick out the times for the movement events
% theseTimes = metaData(contains(metaData.block,listToUse),:).blockTime;
% 
% conditionsList = strsplit(out.conditions,',');
% for i = 1:length(listToUse)
%     thisExptIndex = char(listToUse(i));
%     [magData,magDT] = HTRMagLoadData(thisExptIndex);
%     dataToPlot = smooth(abs(magData-mean(magData)),(1/magDT)*4,'sgolay',2);
%     tempText = strrep(thisExptIndex,'-','_');
%     loadedData.(['blk' tempText]) = dataToPlot;
%     
%     
%     segTime = out.analysisOptions(1,1).segTime;
%     splitTime = out.analysisOptions(1,1).splitTime;
%     fs = 1/magDT;
%     
%     conditions{i} = char(conditionsList(i));
%     blockTime.(['blk' tempText]) = theseTimes(i);
% end
% 
% [loadedData,segmentTimeData] = patientAnalysis.segmentData(loadedData,blockTime,conditions,1/fs,splitTime,segTime);
% 
% actionList = fields(loadedData);
% for i = 1:size(fields(loadedData),1)
%     %thisTime = metaData(contains(actionList(i),segmentTimeData)).blockTime;
%     time(i) = getfield(segmentTimeData,actionList{i});
%     meanMove(i) = mean(getfield(loadedData,actionList{i}));
% end
% 
% 
% % =======================Plot The Movement=====================
% subplot(2,1,2)
% plot(windowTimes, meanMove);
% title('Movement Across Time')
% %xline(line,'-','Psilocybin')

% ======================= previous way of plotting  =====================
% subtightplot(5,1,1);
% imagesc(Ch1);
% yticks(1:24);
% yticklabels(fliplr(freqLabels));
% ylabel('Chan1');
% 
% subtightplot(5,1,2);
% imagesc(Ch2);
% yticks(1:24);
% yticklabels(fliplr(freqLabels));
% ylabel('Chan2');
% 
% subtightplot(5,1,3);
% imagesc(Ch3);
% yticks(1:24);
% yticklabels(fliplr(freqLabels));
% ylabel('Chan3');
% 
% subtightplot(5,1,4);
% imagesc(Ch4);
% yticks(1:24);
% yticklabels(fliplr(freqLabels));
% ylabel('Chan4');