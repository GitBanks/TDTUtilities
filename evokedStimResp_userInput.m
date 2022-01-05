function evokedStimResp_userInput(exptDate,exptIndex)

%%
% User-defined parameters

if ~exist('exptDate','var') || ~exist('exptIndex','var')
%     exptDate = '21601'; 
%     exptIndex = '009';
    exptDate = '21d21'; 
    exptIndex = '008';
    
%     exptIndex = '008'; noTank = false;
%	exptIndex = '004'; noTank = false;
%     exptIndex = '005'; noTank = true;
%     exptIndex = '006'; noTank = false;
%    exptIndex = '007'; noTank = true;
%     exptDate = '21520'; 
%     exptIndex = '005';
%     exptDate = '21510';
%     exptIndex = '000';
%     exptDate = '21513';
%     exptIndex = '000';
%     exptDate = '21513';
%     exptIndex = '001';
%     exptDate = '21515';
%     exptIndex = '002';
end
relevantROIs = {'PFC','CA1','Hipp'}; % labels in database can be any of these
% Window for analysis and plotting, relative to stim time
tPreStim = 0.02; %sec
tPostStim = 0.2; %sec
% Start searching for peaks and troughs of responses after this time
artifactDur = 2.e-3; %sec;
% Average over this window to get estimate of peak value
avgWinTime = 1.e-3; %sec; 
% Time window re stim time to calculate baseline value that is subtracted from peak values
baseWin = [-5,-0.5]*1.e-3; %sec; 
%hardcoded location - not ideal, but this works for now
fileString = [exptDate '-' exptIndex];
outPath = [getPathGlobal('M') 'PassiveEphys\20' exptDate(1:2) '\' fileString '\'];

animal = getAnimalByDateIndex(exptDate,exptIndex);
outPath2 = [getPathGlobal('M') 'PassiveEphys\AnimalData\' animal '\'];
if ~exist(outPath2,'dir')
    mkdir(outPath2);
end



%% load data
% will repeat this for the dual recordings to load in the parallel set

[~,indexOut,isTank] = getIsTank(exptDate,exptIndex);
[stimSet,dTRec,stimArray,stimTimes] = getSynapseStimSetData(exptDate,indexOut,tPreStim,tPostStim,isTank);




%% commands to process some of these parameters
if ~exist(outPath,'dir')
    mkdir(outPath);
end
animalName = getAnimalByDateIndex(exptDate,exptIndex);
electrodeLocs = getElectrodeLocationFromDateIndex(exptDate,exptIndex);
%%%%NOTE: The following assumes that channels are arranged in pairs and
%%%%that the channels are ordered in Synapse as they are in eNotebook
ROILabels = electrodeLocs(contains(electrodeLocs,relevantROIs,'IgnoreCase',true));
ROILabels = unique(ROILabels,'stable');
nStims = length(stimSet);
nROIs = size(stimSet(1).sub,1); %number of regions with recording electrodes
preStimIndex = floor(tPreStim/dTRec);
postStimIndex = ceil(tPostStim/dTRec);

% 
%% Ugly kludge alert!
% Need to account for delay between stim times as saved by Synapse and stim
% times as they appear in data. Do this by averaging across stimuli and
% finding first peak after t=0 (i.e. after what Synapse thinks is the stim
% time).
pkThresh = 5.e-6;
tempData = zeros(size(stimSet(1).subMean));
for iStim = 1:nStims
    tempData = tempData+stimSet(iStim).subMean/nStims;
end
% figure()
saveIndex = zeros(1,nROIs);
for iROI = 1:nROIs
%     subplot(1,nROIs,iROI);
%     plot(abs(tempData(iROI,:)));
%     [tempPks,tempIndex] = findpeaks(abs(tempData(iROI,preStimIndex:end)),'Threshold',pkThresh);
%     if isempty(tempIndex)
%         tempIndex(1) = 0;
%         tempPks(1) = 0;
%     end
%     saveIndex(iROI) = tempIndex(1);
%     hold on
%     plot(tempIndex(1)+preStimIndex,tempPks(1),'+');
    [~,tempIndex] = findpeaks(abs(tempData(iROI,preStimIndex:end)),'Threshold',pkThresh);
    if isempty(tempIndex)
        tempIndex(1) = 0;
    end
    saveIndex(iROI) = tempIndex(1);
end
if sum(saveIndex) == 0
    actualStimIndex = preStimIndex;
else
    indexAdjust = floor(mean(saveIndex(saveIndex>0)));
    actualStimIndex = preStimIndex + indexAdjust;
end
%% Compute means and find min/max for plotting
startSearchIndex = actualStimIndex+ceil(artifactDur/dTRec); %Start search for plot min and max after artifact
stimSet(iStim).dataMean = squeeze(mean(stimSet(iStim).data,2));
stimSet(iStim).subMean = squeeze(mean(stimSet(iStim).sub,2));
for iROI = 1:nROIs
    plotMax(iROI) = -1.e10;
    plotMin(iROI) = 1.e10;
    for iStim = 1:nStims
        plotMax(iROI) = max([plotMax(iROI),prctile(stimSet(iStim).subMean(iROI,startSearchIndex:end),99)]);
        plotMin(iROI) = min([plotMin(iROI),prctile(stimSet(iStim).subMean(iROI,startSearchIndex:end),1)]);
    end
end
%%
% try loading previously saved data
if isfile([outPath2 animal '_peakDataOverTime.mat'])
    load([outPath2 animal '_peakDataOverTime'],'peakDataOverTime');
    structureList = fields(peakDataOverTime);
    p = struct;
    for iROI = 1:nROIs
        tPkList = [];
        yPkList = [];
        for iii = 1:length(structureList)
            tPkList = vertcat(tPkList,peakDataOverTime.(structureList{iii}).peakData.pkSearchData(iROI).tPk);
            yPkList = vertcat(yPkList,peakDataOverTime.(structureList{iii}).peakData.pkSearchData(iROI).yPk);
        end
        p(iROI).tPkList = tPkList;
        p(iROI).yPkList = yPkList;
    end
end




%% Plot average traces
ampLabel = [];
for iStim = 1:nStims
    if iscell(stimArray)
        %TODO use '-' as a delimiter to get each sides correct amplitude -
        %use 'remain'
        [token,remain] = strtok(stimArray{iStim},'-');
        ampLabel{iStim} = [token '\mu' 'A'];
    else 
        ampLabel{iStim} = [num2str(stimArray(iStim)) '\mu' 'A'];
    end
end
plotTimeArray = dTRec*(-preStimIndex:postStimIndex);
FigName = ['Stim-Resp plot - ' animalName '_' exptDate '_' exptIndex];
thisFigure = figure('Name',FigName);
for iROI = 1:nROIs
    % Plot avg traces
    subPlt(iROI) = subplot(1,nROIs,iROI);
    hold on
    for iStim = 1:length(stimSet)
        plot(plotTimeArray,stimSet(iStim).subMean(iROI,:));
    end
    if exist('tPkList','var')
        plot(p(iROI).tPkList,p(iROI).yPkList,'*b','MarkerSize',8);
    end
    ax = gca;
    ax.XLim = [-tPreStim,tPostStim];
    ax.YLim = [1.05*plotMin(iROI),1.05*plotMax(iROI)];
    ax.XLabel.String = 'time(sec)';
    if iROI == 1
        ax.YLabel.String = 'avg dataSub (V)';
    end
    ax.Title.String = ROILabels{iROI};
    if iROI == nROIs
        legend(ampLabel,'FontSize',6,'Location','NorthEast');
        legend('boxoff');
    end
end

% do we want to load in peaks from other experiments here?



%% Have user click on peaks in each subplot to inform peak search windows
msgFig = msgbox({'Click once in each subplot to indicate approximate location of peaks.';...
    'Proceed from left to right. Hit enter to end for each ROI.'});
uiwait(msgFig);
figure(thisFigure);
opts.Default = 'Yes'; % Can just hit enter to proceed
opts.Interpreter = 'Tex'; % Apparently it is necessary to set this option
if exist('pkSearchData','var')
    clear pkSearchData;
end
for iROI = 1:nROIs
    subplot(subPlt(iROI));
    proceed = 0;
    while ~proceed
        [temp_tPk,temp_yPk] = ginput; % Get click input
        hand = plot(temp_tPk,temp_yPk,'+r','MarkerSize',12);
        answer = questdlg(['Accept pk(s) for ' ROILabels{iROI} ' ?'], ...
        [ROILabels{iROI} 'peak estimate'], ...
        'Yes','No',opts);
        % Handle response
        switch answer
            case 'Yes'
                pkSearchData(iROI).tPk = temp_tPk;
                pkSearchData(iROI).pkSign = sign(temp_yPk);
                pkSearchData(iROI).yPk = temp_yPk;
                proceed = 1;
            case 'No'
                delete(hand); % Removes erroneous peak marker
                proceed = 0;
        end
    end
end
close(thisFigure);
%% Estimate peak responses by averaging around the peaks and troughs
avgWinIndex = floor(avgWinTime/dTRec);
baseWinIndex = floor(baseWin/dTRec);
pkVals = struct();
for iROI = 1:nROIs
    pkVals(iROI).data = zeros(length(pkSearchData(iROI).tPk),nStims);
    for iPk = 1:length(pkSearchData(iROI).tPk)
        %Start and stop indices of time window re stim time to search for peak minimum resp
        this_tPk = pkSearchData(iROI).tPk(iPk);
        pkSearchIndices = ceil([this_tPk - this_tPk/2,this_tPk + this_tPk/2]/dTRec);
        tempIndA = actualStimIndex+pkSearchIndices;
        tempIndA(2) = min(tempIndA(2),length(stimSet(iStim).subMean(iROI,:)));  
        pkSign = pkSearchData(iROI).pkSign(iPk);
        for iStim = 1:nStims
            tempMn = stimSet(iStim).subMean(iROI,:);
            if pkSign>0
                [~, pkIndex] = max(tempMn(tempIndA(1):tempIndA(2)));
            else
                [~, pkIndex] = min(tempMn(tempIndA(1):tempIndA(2)));
            end
            baseVal = mean(tempMn(preStimIndex + baseWinIndex(1):preStimIndex + baseWinIndex(2))); % this is the baseline pre stim 
            tempIndB(1) = actualStimIndex+pkSearchIndices(1)+pkIndex-avgWinIndex;
            tempIndB(2) = actualStimIndex+pkSearchIndices(1)+pkIndex+avgWinIndex;
            pkVals(iROI).data(iPk,iStim) = mean(tempMn(tempIndB(1):tempIndB(2))) - baseVal;
            pkVals(iROI).peakTimeCalc(iPk,iStim) = (pkIndex+tempIndA(1))*dTRec-tPreStim;
            pkVals(iROI).baseVal(iPk,iStim) = baseVal;
        end
    end
end


%% 
% set up a few more labels and configurations for the plot

ampLabel = [];
for iStim = 1:nStims
    if iscell(stimArray)
        %TODO use '-' as a delimiter to get each sides correct amplitude -
        %use 'remain'
        [token,remain] = strtok(stimArray{iStim},'-');
        
        ampLabel{iStim} = [token '\mu' 'A'];
        stimArrayNumeric(iStim) = str2num(token);
    else 
        ampLabel{iStim} = [num2str(stimArray(iStim)) '\mu' 'A'];
        stimArrayNumeric(iStim) = stimArray(iStim);
    end
end
plotTimeArray = dTRec*(-preStimIndex:postStimIndex);


%%
% we will save 
% Time of peak re stim time
% Response magnitude (pk, inner product)
% Time of stim relative to start of file
peakData = struct;
peakData.pkSearchData = pkSearchData; % user selected Time of peak re stim time
peakData.ROILabels = ROILabels; %corresponding labels
peakData.stimArrayNumeric = stimArrayNumeric;
peakData.pkVals = pkVals; % Response magnitude 
peakData.stimTimes = stimTimes; % Time of stim relative to start of file
peakData.plotMin = plotMin;
peakData.plotMax = plotMax;
    
for iStim = 1:length(stimSet)
    avgTraces(iStim).stimSet = stimSet(iStim).subMean;
    avgTraces(iStim).stimArrayNumeric = stimArrayNumeric(iStim);
    avgTraces(iStim).ampLabel = ampLabel{iStim};

end
save([outPath fileString '_peakData'],'peakData','plotTimeArray','avgTraces');


% also save long term data
% 
if ~exist('peakDataOverTime','var')
    peakDataOverTime = struct;
end
peakDataOverTime.(['expt' strrep(fileString,'-','')]).peakData = peakData;
save([outPath2 animal '_peakDataOverTime'],'peakDataOverTime');





%% 
% plotting now contained here (so we can call it from other programs)
sendToSlack = true;
plotCalculatedPeaks = false;
plotStimRespByDateIndex(exptDate,exptIndex,sendToSlack,plotCalculatedPeaks)

% %
% % plotting
% FigName = ['Stim-Resp plot - ' animalName '_' exptDate '_' exptIndex];
% thisFigure = figure('Name',FigName);
% for iROI = 1:nROIs
%     % Plot avg traces
%     subPlt(iROI) = subplot(2,nROIs,iROI);
%     hold on
%     for iStim = 1:length(stimSet)
%         plot(plotTimeArray,stimSet(iStim).subMean(iROI,:));
%     end
%     for iUI = 1:length(pkSearchData(iROI).tPk)
%         plot(pkSearchData(iROI).tPk(iUI),pkSearchData(iROI).yPk(iUI),'+r','MarkerSize',12);
%         for iStim = 1:length(stimSet)
%             plot(pkSearchData(iROI).peakTimeCalc(iUI,iStim),pkVals(iROI).data(iUI,iStim),'+b','MarkerSize',8);
%         end
%     end
%     ax = gca;
%     ax.XLim = [-tPreStim,tPostStim];
%     ax.YLim = [1.05*plotMin(iROI),1.05*plotMax(iROI)];
%     ax.XLabel.String = 'time(sec)';
%     if iROI == 1
%         ax.YLabel.String = 'avg dataSub (V)';
%     end
%     ax.Title.String = peakData.ROILabels{iROI};
%     if iROI == nROIs
%         %legend(ampLabel,'FontSize',6,'Location','NorthEast');
%         %legend('boxoff');
%     end
% end
% 
% for iROI = 1:nROIs
%     subplot(2,nROIs,nROIs+iROI)
%     hold on
%     legendLabs = [];
%     nPks = size(pkVals(iROI).data,1);
%     for iPk = 1:nPks
%         legendLabs{iPk} = ['Pk ' num2str(iPk)];
%     end
%     for iPk = 1:nPks
%         plot(stimArrayNumeric,pkSearchData(iROI).pkSign(iPk)*pkVals(iROI).data(iPk,:),'-o');
%     end
%     ax = gca;
%     ax.XLabel.String = 'Stim intensity (\muA)';
%     if iROI == 1
%         ax.YLabel.String = 'Pk resp (V)';
%     end
%     legend(legendLabs,'FontSize',6,'Location','NorthWest');
%     legend('boxoff');
% end
% saveas(thisFigure,[outPath FigName]);
% saveas(thisFigure,[outPath2 FigName]);
% 
% fileName = ['M:\PassiveEphys\AnimalData\' animal '\' FigName];
% print('-painters',fileName,'-r300','-dpng');
% try
%     desc = [FigName '  @Zarmeen Zahid'];
%     sendSlackFig(desc,[fileName '.png']);
% catch
%     disp(['failed to upload ' fileName ' to Slack']);
% end

