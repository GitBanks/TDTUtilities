function [gBatchParams, mouseEphys_out] = mouseDelirium_specAnalysis_Synapse(animalName,runICA,forceReRun)
%
% Computes the power spectrum for 
% mouse ephys data from delirium project (either EEG or LFP). Workflow is 
%
%   (a) get parameters for analysis using the function
%   mouse_deliriumGetBatchParams
%   (b) loads the recorded data, which must already be converted from TDT 
%   to Matlab format and down-sampled, using loadMouseEphysData
%   (c) convert data to FieldTrip compatible format using 
%   convertMouseEphysToFTFormat
%   (d) break the continuous recording into segments using ft_redefinetrial
%   (e) downsample the data further to save processing time using 
%   ft_resampledata
%   (f) parse data according to behavioral state
%   (g) perform a spectral analysis on the data using ft_freqanalysis
%   (h) compute power in specified bands
%
% General parameters
% Analysis type 0: mean activity in each trial
% Test case: animalName = 'EEG55';
% synapsePathing;
 
noMovtToggle =0; % WARNING: this is a temporary fix until we can analyze the movement data from Synapse.
outPath = '\\144.92.218.131\Data\Data\PassiveEphys\EEG animal data\';
outFileName = 'mouseEphys_out_noParse_Synapse.mat';
disp(['Data will be saved to `' outPath '`']);

switch nargin
    case 0 
        error('at least select an animal!');
    case 1
        runICA = 0;     %default not to run ICA 
        forceReRun = 0; %default to not re-analyze previous dates, just most recent
    case 2
        forceReRun = 0;    
end

%generate batchParams
gBatchParams = mouseDelirium_getBatchParamsByAnimal(animalName); 

bands.delta = [2,4];
bands.theta = [5,12];
bands.alpha = [13,20];
bands.humanAlpha = [8,13];
bands.beta  = [21,30];
bands.gamma = [31,80];
bands.all = [2,80];
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
% if forceReRun is false, then just use the most recent date in
% batchParams.
if ~forceReRun
    eDates = eDates(end);
end

%Downsampled Fs
dsFs = 200; % Hz

%Trial rejection
maxSDCriterion = 0.5;  %Check this... 18n14 ZS
minSDCriterion = 0.2;
rejectAcrossChannels = 1; 

%main analysis section
for iDate = 1:length(eDates)%1:length(eDates)
    thisDate = eDates{iDate};
    disp('------------------------');
    disp(['Animal ' animalName ' - Date: ' thisDate]);
    disp('------------------------');
    nExpts = length(eParams.(thisDate).exptIndex);
   
    %expts correspond to the TDT recording files, i.e. 000, 001, etc
    for iExpt = 1:nExpts
        thisExpt = ['expt' eParams.(thisDate).exptIndex{iExpt}];
        
        % loadedData is matrix of nChan x nSamples
        [loadedData,eParams] = loadMouseEphysData(eParams,thisDate,iExpt); 
        
        % Load behav data, divide into segments w/ overlap, calculate mean of each segment
        if noMovtToggle %WARNING: movement will not be added if this is = 1!!!
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
                    error(['Can not find ' fileNameStub])
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
        
        data_MouseEphysDS = ft_resampledata(cfg, data_MouseEphys);     %%%% Returning an error in 2018a - ZS
        data_MouseEphysDS.sampleinfo = [1, size(data_MouseEphysDS.trial{1,1},2)];
        clear data_MouseEphys
        
        %Remove heart rate noise using ICA - WIP!!! 18n26
        if runICA
            [data_MouseEphysDS] = runICAtoRemoveECG(gBatchParams,data_MouseEphysDS,animalName,thisDate,thisExpt);
        end

        tempData = cell2mat(data_MouseEphysDS.trial);
        data_MouseEphysDS.trial{1,1} = ft_preproc_bandstopfilter(tempData, dsFs, [59 61]);

        % segment data into trials of length trialLength with overlap
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

        %First compute keeping trials to get band power as time series
        cfg           = [];
        cfg.trials    = theseTrials;
        cfg.method    = 'mtmfft';
        cfg.taper     = 'hanning';
        cfg.output    = 'pow';
        cfg.pad       = ceil(max(cellfun(@numel, data_MouseEphysDS.time)/data_MouseEphysDS.fsample));
        cfg.foi       = 1:80;
        cfg.keeptrials= 'yes';
        tempSpec      = ft_freqanalysis(cfg, data_MouseEphysDS);

        for iBand = 1:length(bandNames)
            thisBand = bandNames{iBand};
            fLims = bands.(thisBand);
            mouseEphys_out.(animalName).(thisDate).(thisExpt).bandPow.(thisBand) = ...
                squeeze(mean(tempSpec.powspctrm(:,:,tempSpec.freq>=fLims(1) & tempSpec.freq<=fLims(2)),3));
        end
        
        %added 10/15/2019... debugging WIP. If number of ephys windows is
        %somehow longer than number of movement windows
        if find(theseTrials > length(meanMovementPerWindow))
            warning('trial index exceeds number of movement windows...');
            theseTrials  = theseTrials(theseTrials <= length(meanMovementPerWindow));
        end
        
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
                meanMovementPerWindow(theseTrials);
        
        mouseEphys_out.(animalName).(thisDate).(thisExpt).trialsKept = theseTrials;
                
        clear windowTimeLims indexLength meanMovementPerWindow
    end %Loop over expts
    gBatchParams.(animalName).(thisDate).trialInfo = eParams.(thisDate).trialInfo;
end %Loop over recording dates for this animal



