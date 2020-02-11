function [gBatchParams, mouseEphys_out,failedTable] = mouseDelirium_specAnalysis(animalName,runICA,forceReRun)
% Computes the power spectrum (and Lempel-Ziv complexity (WIP) for
% mouse ephys data from delirium project (either EEG or LFP).
% Workflow is
%   (a) get parameters for analysis using the function mouseDelirium_getBatchParamsByAnimal
%   (b) load the recorded data, which must already be converted from TDT to Matlab format and down-sampled, using loadMouseEphysData
%   (c) convert data to FieldTrip compatible format using convertMouseEphysToFTFormat
%   (d) break the continuous recording into segments using ft_redefinetrial
%   (e) downsample the data further to save processing time using ft_resampledata
%   (f) perform a spectral analysis on the data using ft_freqanalysis
%   (g) compute power in specified bands
%
% Example parameters
% animalName = 'EEG55';
% runICA = 0; %will not run ICA for heart rate removal
% forceReRun = 1; %will re-run all available dates

noMovtToggle =0; % WARNING: this is a placeholder until we can analyze the movement data

switch nargin
    case 0
        error('at least select an animal!');
    case 1
        runICA = 0;     %default not to run ICA
        forceReRun = 0; %default to not re-analyze previous dates, just most recent
    case 2
        forceReRun = 0;
end

% generate batchParams
gBatchParams = mouseDelirium_getBatchParamsByAnimal(animalName);

% list of frequency bands in Hz
% bands.lowDelta = [1,4]; %
% bands.deltaExtended = [1,6]; %extended delta range for exploratory analyses
bands.delta = [2,4];
bands.theta = [5,12];
bands.alpha = [13,20];
bands.humanAlpha = [8,13];
bands.beta  = [21,30];
bands.gamma = [31,80];
bands.all = [1,80];
bandNames = fieldnames(bands);

eParams = gBatchParams.(animalName);
eParams.bandInfo = bands;
gBatchParams.(animalName).bandInfo = bands;

tempFields = fieldnames(eParams)';

iDate = 1;
for i = 1:length(tempFields)
    if ~isempty(strfind(tempFields{i},'date'))
        eDates{iDate} = tempFields{i};
        iDate = iDate+1;
    end
end

%If forceReRun is false, then just use the most recent date in batchParams
if ~forceReRun
    eDates = eDates(end);
end

%Downsampled Fs
dsFs = 200; % Hz

%Trial rejection criteria
maxSDCriterion = 0.5;
minSDCriterion = 0.2;
rejectAcrossChannels = 1;

%main analysis section
for iDate = 1:length(eDates)%1:length(eDates)
    thisDate = eDates{iDate};
    disp('------------------------');
    disp(['Animal ' animalName ' - Date: ' thisDate]);
    disp('------------------------');
    nExpts = length(eParams.(thisDate).exptIndex);
    try
        %expts correspond to the TDT recording files, i.e. 000, 001, etc
        for iExpt = 1:nExpts
            
            thisExpt = ['expt' eParams.(thisDate).exptIndex{iExpt}];
            
            % loadedData is matrix of nChan x nSamples
            [loadedData,eParams] = loadMouseEphysData(eParams,thisDate,iExpt);
            
            % Load behav data, divide into segments w/ overlap, calculate mean of each segment
            if noMovtToggle %movement will not be added if this is = 1!!!
                meanMovementPerWindow = nan(10000,1);
            else
                fileNameStub = ['PassiveEphys\20' thisDate(5:6) '\' thisDate(5:end) '-' thisExpt(5:end)...
                    '\' thisDate(5:end) '-' thisExpt(5:end) '-movementBinary.mat']; %WARNING: EDITED ON 5/6/2019
                try
                    load(['W:\Data\' fileNameStub],'finalMovementArray','frameTimeStampsAdj');
                catch
                    try
                        load(['\\MEMORYBANKS\Data\' fileNameStub],'finalMovementArray','frameTimeStampsAdj'); %WARNING: EDITED ON 5/2/2019
                    catch
                        warning(['Can not find ' fileNameStub '. Skipping movement analysis for now']);
                        meanMovementPerWindow = nan(1220,1);
                    end
                end
                
                windowLength = gBatchParams.(animalName).windowLength;
                windowOverlap = gBatchParams.(animalName).windowOverlap;
                
                indexLength = frameTimeStampsAdj(end);
                for iWindow = 1:indexLength
                    if ((iWindow-1)*windowLength)*(1-windowOverlap) + windowLength < indexLength
                        windowTimeLims(iWindow,1) = ((iWindow-1)*windowLength)*(1-windowOverlap);
                        windowTimeLims(iWindow,2) = ((iWindow-1)*windowLength)*(1-windowOverlap) + windowLength;
                    end
                end
                
                for iWindow = 1:size(windowTimeLims,1)
                    timeStampsInWindow = frameTimeStampsAdj(frameTimeStampsAdj <= windowTimeLims(iWindow,2));
                    timeStampsInWindow = timeStampsInWindow(timeStampsInWindow >= windowTimeLims(iWindow,1));
                    if ~isempty(timeStampsInWindow)
                        for iFrame = 1:length(timeStampsInWindow)
                            framesToUse(iFrame) = find(frameTimeStampsAdj == timeStampsInWindow(iFrame));
                        end
                        try %added 4/8/2019 ZS in case video ran too long and framesToUse has frames outside finalMovementArray...
                            meanMovementPerWindow(iWindow,1) = mean(finalMovementArray(framesToUse));
                        catch
                            framesToUse = framesToUse(framesToUse <= finalMovementArray);
                            meanMovementPerWindow(iWindow,1) = mean(finalMovementArray(framesToUse));
                        end
                    else
                        meanMovementPerWindow(iWindow,1) = NaN;
                    end
                    clear timeStampsInWindow framesToUse
                end
            end
            
            % Now convert to FieldTrip format:
            [data_MouseEphys] = convertMouseEphysToFTFormat(loadedData,eParams,thisDate,iExpt);
            
            cfg = [];
            cfg.resamplefs = dsFs;
            cfg.detrend    = 'yes';
            % the following line avoids numeric round off issues in the time axes upon resampling
            %data_MouseEphys.time(1:end) = data_MouseEphys.time(1);
            
            data_MouseEphysDS = ft_resampledata(cfg, data_MouseEphys);
            data_MouseEphysDS.sampleinfo = [1, size(data_MouseEphysDS.trial{1,1},2)];
            clear data_MouseEphys
            
            % Remove heart rate noise using ICA
            if runICA || strcmp(animalName,'EEG18')
                [data_MouseEphysDS] = runICAtoRemoveECG(gBatchParams,data_MouseEphysDS,animalName,thisDate,thisExpt);
            end
            
            tempData = cell2mat(data_MouseEphysDS.trial);
            data_MouseEphysDS.trial{1,1} = ft_preproc_bandstopfilter(tempData, dsFs, [59 61]);
            
            % Segment data into trials of length trialLength with overlap
            cfg         = [];
            cfg.length  = eParams.windowLength;
            cfg.overlap = eParams.windowOverlap;
            data_MouseEphysDS   = ft_redefinetrial(cfg, data_MouseEphysDS);
            eParams.(thisDate).trialInfo(iExpt).trialTimesRedef = ...
                (data_MouseEphysDS.sampleinfo-1)/data_MouseEphysDS.fsample;
            
            nChans = length(gBatchParams.(animalName).ephysInfo.chanNums);
            nWindows = length(data_MouseEphysDS.trial);
            nonRejects_byChan = ones(nChans,nWindows);
            nonRejects_all = ones(1,nWindows);
            for iChan = 1:nChans
                for iWindow = 1:nWindows
                    tempSD(iWindow) = std(data_MouseEphysDS.trial{1,iWindow}(iChan,:));
                    tempMax(iWindow) = max(data_MouseEphysDS.trial{1,iWindow}(iChan,:));
                end
                sortSD = sort(tempSD(:));
                SDCriterion = sortSD(ceil(length(sortSD)*0.95));
                SDCriterion = min(SDCriterion,maxSDCriterion);
                SDCriterion = max(SDCriterion,minSDCriterion);
                nonRejectLogic_1 = tempSD<SDCriterion;
                nonRejects_byChan(iChan,:) = nonRejectLogic_1; %& nonRejectLogic_2;
                disp(['SDcrit = ' num2str(SDCriterion) '; Accepting ' num2str(sum(nonRejects_byChan(iChan,:))) '/' num2str(nWindows) ' trials for chan#' num2str(iChan) '.']);
                nonRejects_all = nonRejects_all & nonRejects_byChan(iChan,:);
            end
            if rejectAcrossChannels
                disp('Rejecting across channels...');
                for iChan = 1:nChans
                    nonRejects_byChan(iChan,:) = nonRejects_all;
                end
                disp(['Cumulative accepted trials = ' num2str(sum(nonRejects_all))]);
            end
            clear tempSD tempMax
            theseTrials = 1:length(nonRejects_all);
            theseTrials = theseTrials(nonRejects_all == 1);
            
            %End of video is cut off or one extra ephys trial than video b/c of resolution, so manually cutting off
            %ephys trials with no associated video]
            if length(theseTrials) > length(meanMovementPerWindow) || sum(theseTrials>length(meanMovementPerWindow)) > 0
                theseTrials = theseTrials(theseTrials <= length(meanMovementPerWindow));
                %Headstage became unplugged during index so manually removing these trials based on sudden spike in power
            elseif strcmp(animalName,'EEG33') && strcmp(thisDate,'date17530') && strcmp(thisExpt,'expt004')
                theseTrials(131:242) = [];
            elseif strcmp(animalName,'EEG34') && strcmp(thisDate,'date17601') && strcmp(thisExpt,'expt004')
                theseTrials(592:790) = [];
            end
            
            % LEMPEL-ZIV COMPLEXITY ANALYSIS
%             [~,Cnorm,~,Cnormrand] = runLZC_withRandom(data_MouseEphysDS.trial);
% %             mouseEphys_out.(animalName).(thisDate).(thisExpt).LZC = C(theseTrials,:);
%             mouseEphys_out.(animalName).(thisDate).(thisExpt).LZc = Cnorm(theseTrials,:);
% %             mouseEphys_out.(animalName).(thisDate).(thisExpt).LZCrand = mean(Crand(theseTrials,:),3);
%             mouseEphys_out.(animalName).(thisDate).(thisExpt).LZc_rand = mean(Cnormrand(theseTrials,:,:),3);
%             mouseEphys_out.(animalName).(thisDate).(thisExpt).LZcn = Cnorm(theseTrials,:)...
%                 ./mean(Cnormrand(theseTrials,:,:),3); %LZcn is the signal LZc divided by the average LZc from 100 surrogate signals
            
            % First compute keeping trials to get band power as time series
            cfg           = [];
            cfg.trials    = theseTrials;
            cfg.method    = 'mtmfft';
            cfg.taper     = 'hanning';
            cfg.output    = 'pow';
            cfg.pad       = ceil(max(cellfun(@numel, data_MouseEphysDS.time)/data_MouseEphysDS.fsample));
            cfg.foi       = 1:80;
            cfg.keeptrials= 'yes';
            tempSpec      = ft_freqanalysis(cfg, data_MouseEphysDS);
            mouseEphys_out.(animalName).(thisDate).(thisExpt).bandPow.cfg = cfg; %store config from band power
            
            for iBand = 1:length(bandNames)
                thisBand = bandNames{iBand};
                fLims = bands.(thisBand);
                mouseEphys_out.(animalName).(thisDate).(thisExpt).bandPow.(thisBand) = ...
                    squeeze(mean(tempSpec.powspctrm(:,:,tempSpec.freq>=fLims(1) & tempSpec.freq<=fLims(2)),3));
            end
            
            % Set params for the spectral calculation
            cfg           = [];
            cfg.trials    = theseTrials;
            cfg.method    = 'mtmfft';
            cfg.output    = 'pow';
            cfg.pad       = ceil(max(cellfun(@numel, data_MouseEphysDS.time)/data_MouseEphysDS.fsample));
            cfg.foi       = 1:80;
            cfg.tapsmofrq = 2;
            cfg.keeptrials= 'no';
            
            mouseEphys_out.(animalName).(thisDate).(thisExpt).spec = ...
                ft_freqanalysis(cfg, data_MouseEphysDS);
            
            mouseEphys_out.(animalName).(thisDate).(thisExpt).activity = ...
                meanMovementPerWindow(theseTrials); %store movement array with only the accepted trials...
            
            mouseEphys_out.(animalName).(thisDate).(thisExpt).trialsKept = theseTrials'; %store theseTrials
            
            mouseEphys_out.(animalName).(thisDate).(thisExpt).windowTimeLims = windowTimeLims(theseTrials,:); %store movement time windows with only accepted trials
            
            clear windowTimeLims indexLength meanMovementPerWindow
            
        end %Loop over expts
        gBatchParams.(animalName).(thisDate).trialInfo = eParams.(thisDate).trialInfo;
    catch why
        keyboard
        failedTable.(thisDate).(thisExpt) = why;
    end
end %Loop over recording dates for this animal

if ~exist('failedTable','var')
    failedTable = [];
end

