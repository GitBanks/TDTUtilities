function evokedStimAveragesMCStimBatchFile(exptDate,exptIndex)

%%
% User-defined parameters
if ~exist('exptDate','var') || ~exist('exptIndex','var') || ~exist('chanLabels','var')
%     exptDate = '21517'; 
%     exptIndex = '002';
%     exptDate = '21510';
%     exptIndex = '000';
    exptDate = '21513';
    exptIndex = '000';
%     exptDate = '21513';
%     exptIndex = '001';
%     exptDate = '21515';
%     exptIndex = '002';
end
outPath = ['M:\PassiveEphys\20' exptDate(1:2) '\' exptDate '-' exptIndex '\'];
if ~exist(outPath,'dir')
    mkdir(outPath);
end

relevantROIs = {'PFC','CA1','Hipp'}; % labels in database can be any of these
animalName = getAnimalByDateIndex(exptDate,exptIndex);
electrodeLocs = getElectrodeLocationFromDateIndex(exptDate,exptIndex);
%%%%NOTE: The following assumes that channels are arranged in pairs and
%%%%that the channels are ordered in Synapse as they are in eNotebook
ROILabels = electrodeLocs(contains(electrodeLocs,relevantROIs,'IgnoreCase',true));
ROILabels = unique(ROILabels,'stable');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Set time windows and polarities for peak searching 
pkSearchWin = [5,20;20,50]*1.e-3; %Time window re stim time (sec) to search for peak minimum resp
% pkSearchWin = [10,25]*1.e-3; %Time window re stim time (sec) to search for peak minimum resp
nPks = size(pkSearchWin,1);
%Is i_th pk a peak [set pkSign(i) = +1] or a trough [set pkSign(i) = -1]?
pkSign = ones(nPks,1);
pkSign(1) = +1;
pkSign(2) = -1;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Window for analysis and plotting, relative to stim time
tPreStim = 0.02; %sec
tPostStim = 0.2; %sec
% Start searching for peaks and troughs of responses after this time
artifactEnd = 5.e-3; %sec;
% Average over this window to get estimate of peak value
avgWinTime = 1.e-3; %sec; 
% Time window re stim time to calculate baseline value that is subtracted from peak values
baseWin = [-5,-0.5]*1.e-3; %sec; 

%%
[stimSet,dTRec,stimArray] = getSynapseStimSetData(exptDate,exptIndex,tPreStim,tPostStim);
nStims = length(stimSet);
nROIs = size(stimSet(1).sub,1); %number of regions with recording electrodes
% 
% Find the mean for both the raw data and the subtraction
% Also find min and max for plotting and for analysis purposes
preStimIndex = floor(tPreStim/dTRec);
postStimIndex = ceil(tPostStim/dTRec);
plotMax = -1.e10;
plotMin = 1.e10;
startSearchIndex = ceil(artifactEnd/dTRec); %Start search for plot min and max after artifact
for iStim = 1:nStims
    stimSet(iStim).dataMean = squeeze(mean(stimSet(iStim).data,2));
    stimSet(iStim).subMean = squeeze(mean(stimSet(iStim).sub,2));
    plotMax = max([plotMax,max(stimSet(iStim).subMean(:,preStimIndex+startSearchIndex:end))]);
    plotMin = min([plotMin,min(stimSet(iStim).subMean(:,preStimIndex+startSearchIndex:end))]);
end

%% Plot average traces
ampLabel = [];
for iStim = 1:nStims
    ampLabel{iStim} = [num2str(stimArray(iStim)) '\mu' 'A'];
end
legendLabs = [];
for iPk = 1:nPks
    legendLabs{iPk} = ['Pk ' num2str(iPk)];
end
plotTimeArray = dTRec*(-preStimIndex:postStimIndex);
FigName = ['Stim-Resp plot - ' animalName '_' exptDate '_' exptIndex];
thisFig = figure('Name',FigName);
for iROI = 1:nROIs
    % Plot avg traces
    subplot(2,nROIs,iROI)
    hold on
    for iStim = 1:length(stimSet)
        plot(plotTimeArray,stimSet(iStim).subMean(iROI,:));
    end
    ax = gca;
    ax.XLim = [-tPreStim,tPostStim];
    ax.YLim = [1.05*plotMin,1.05*plotMax];
    ax.XLabel.String = 'time(sec)';
    if iROI == 1
        ax.YLabel.String = 'avg dataSub (V)';
    end
    ax.Title.String = ROILabels{iROI};
    if iROI == nROIs
        legend(ampLabel);
    end
end

%% Estimate peak responses by averaging around the peaks and troughs
avgWinIndex = floor(avgWinTime/dTRec);
baseWinIndex = floor(baseWin/dTRec);
%Start and stop indices of time window re stim time to search for peak minimum resp
pkSearchIndex = ceil(pkSearchWin/dTRec); 
pkVals = zeros(nPks,nStims,nROIs);
for iStim = 1:nStims
    tempMn = stimSet(iStim).subMean;
    for iROI = 1:nROIs
        for iPk = 1:nPks
            i1 = preStimIndex+pkSearchIndex(iPk,1);
            i2 = preStimIndex+pkSearchIndex(iPk,2);
            if pkSign(iPk)>0
                [~, pkIndex] = max(tempMn(iROI,i1:i2));
            else
                [~, pkIndex] = min(tempMn(iROI,i1:i2));
            end
            baseVal = ...
                mean(tempMn(preStimIndex + baseWinIndex(1):preStimIndex + baseWinIndex(2)));
            i1 = preStimIndex+pkSearchIndex(iPk,1)+pkIndex-avgWinIndex;
            i2 = preStimIndex+pkSearchIndex(iPk,1)+pkIndex+avgWinIndex;
            pkVals(iPk,iStim,iROI) = mean(tempMn(iROI,i1:i2)) - baseVal;
        end
    end
end

%% Plot stim-resp curves
figure(thisFigure);
for iROI = 1:nROIs
    subplot(2,nROIs,nROIs+iROI)
    hold on
    for iPk = 1:nPks
        plot(stimArray,pkSign(iPk)*squeeze(pkVals(iPk,:,iROI)),'-o');
    end
    ax = gca;
    ax.XLabel.String = 'Stim intensity (\muA)';
    if iROI == 1
        ax.YLabel.String = 'Pk resp (V)';
    end
    if iROI == nROIs
        legend(legendLabs);
    end
end
saveas(thisFig,[outPath FigName]);

