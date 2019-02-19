function [gBatchParams, gMouseEphys_conn] = mouseDelirium_WPLI_dbt_Synapse(animalName,runICA)
%
% Computes the debiased weighted phase-lag index (Vinvk et al 2011) for 
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
%   (f) perform a time-frequency analysis on the data using ft_freqanalysis
%   (g) using the spectral coefficients from (f), compute the debiased WPLI
%   using ft_connectivityanalysis. The WPLI takes a value in [0, 1] that can be interpreted as evidence for a
%   consistent phase relationship between the signals.
%
%   References:
%     [1] Vinck M, Oostenveld R, van Wingerden M, Battaglia F, Pennartz CM. An
%     improved index of phase-synchronization for electrophysiological data in
%     the presence of volume-conduction, noise and sample-size bias.
%     Neuroimage. 2011 Apr 15;55(4):1548-65.

% General parameters
% Analysis type 0: mean activity in each trial
% animalName = 'EEG52';

%add in relevant paths... 
synapsePathing;

if ~exist('animalName','var')
    error('At least select an animal');
end
if ~exist('runICA','var')
     runICA = 0;
end

% outFileName = 'mouseEphys_conn_dbt_noParse_20sWin_0p5sTrial.mat';     
outPath = '\\144.92.218.131\Data\Data\PassiveEphys\EEG animal data\';

% disp(['Data will be saved to `' outPath '`']);
gBatchParams = mouseDelirium_getBatchParamsByAnimal(animalName);
eParams = gBatchParams.(animalName);

trial_l = 0.5; %length of trial that windows are divided into: sec

windowLength = 20;
windowOverlap = 0.25;

%Downsampled Fs
dsFs = 200; % Hz
tinyCriterion = 0.02; %Ignore values of WPLI that are less than this value

%Trial rejection
maxSDCriterion = 0.5;
minSDCriterion = 0.2;
rejectAcrossChannels = 1;

nChans = length(eParams.ephysInfo.chanNums); % !TODO! % do we want to get nChans from the number of channels entered in DB instead?

% Main analysis loop: divide into trials, no behavior parsing
chanCmb = zeros(nChans*(nChans-1)/2,2);
iCount = 0;
for iChan = 1:nChans-1
    for jChan = iChan+1:nChans
        iCount = iCount+1;
        chanCmb(iCount,1) = iChan;
        chanCmb(iCount,2) = jChan;
    end
end
nChanCmbs = size(chanCmb,1);

thisName = animalName;

eParams.windowLength = windowLength;
eParams.windowOverlap = windowOverlap;
tempFields = fieldnames(eParams)';
 
%Check the version before using field names to generate list of recording dates

%WARNING: This section still crashes in 2015. 
ver = version;
if str2double(ver(end-3:end-2)) < 16 
    eDates = tempFields(strfind(tempFields,'date')); %for matlab versions <2016
else
    eDates = tempFields(contains(tempFields,'date')); %Only use for >2016b
end

if ~exist([outPath thisName],'file')
    error(['No ephys data for ' thisName]);
end

for iDate = 1:length(eDates) %ZS UPDATED 1/15/2019
    thisDate = eDates{iDate};       %eDates{end};      
    disp('------------------------');
    disp(['Animal ' thisName ' - Date: ' thisDate]);
    disp('------------------------');
    nExpts = length(eParams.(thisDate).exptIndex); %NOTE: If using for earlier data, eParams needs to be "curated"

    %expts correspond to the TDT recording files, i.e. 000, 001, etc
    for iExpt = 1:nExpts
        tic
        thisExpt = ['expt' eParams.(thisDate).exptIndex{iExpt}];

        % loadedData is matrix of nChan x nSamples
        [loadedData,eParams] = loadMouseEphysData(eParams,thisDate,iExpt);

        %Load behav data, divide into segments w/ overlap,
        %calculate mean of each segment
        fileFound = 0;
        fileNameStub = ['PassiveEphys\20' thisDate(5:6) '\' thisDate(5:end) '-' thisExpt(5:end)...
                    '\' thisDate(5:end) '-' thisExpt(5:end) '-movementInfoAdjusted.mat'];
        try
            load(['W:\Data\' fileNameStub],'finalLEDTimes','finalMovementArray','frameTimeStampsAdj');
            fileFound = 1;
        catch
            try
                load(['M:\' fileNameStub],'finalLEDTimes','finalMovementArray','frameTimeStampsAdj');
                fileFound = 1;
            catch
                warning('No movement data found. Continuing without.');
            end
        end

        if ~fileFound
            meanMovementPerWindow = zeros(10000,1);
            meanMovementPerWindow(:,:) = NaN;
        else
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
                    meanMovementPerWindow(iWindow,1) = mean(finalMovementArray(framesToUse));
                else
                    meanMovementPerWindow(iWindow,1) = NaN;
                end
                clear timeStampsInWindow framesToUse
            end

        end

        for iBand = 1:length(mouseDeliriumFreqBands.Names)
            thisBand = mouseDeliriumFreqBands.Names{iBand};
            gMouseEphys_conn.WPLI.(thisName).(thisDate).(thisExpt).(thisBand).activity = meanMovementPerWindow;
            disp('Movement calculated & added to ephys structure');
        end

        % Now convert to FieldTrip format:
        [data_MouseEphys] = convertMouseEphysToFTFormat(loadedData,eParams,thisDate,iExpt);

        cfg = [];
        cfg.resamplefs = dsFs;
        cfg.detrend    = 'yes';
        cfg.feedback   = 'no';
        cfg.verbose    = 'no';
        % the following line avoids numeric round off issues in the time axes upon resampling
        %data_MouseEphys.time(1:end) = data_MouseEphys.time(1);
        data_MouseEphysDS = ft_resampledata(cfg, data_MouseEphys);
        data_MouseEphysDS.sampleinfo = [1, size(data_MouseEphysDS.trial{1,1},2)];
        clear data_MouseEphys

        %Remove heart rate noise using ICA
        if runICA
            [data_MouseEphysDS,badcomp.thisExpt] = runICAtoRemoveECG(gBatchParams,data_MouseEphysDS,thisName,thisDate,thisExpt);
        end

        tempData = cell2mat(data_MouseEphysDS.trial);
        data_MouseEphysDS.trial{1,1} = ft_preproc_bandstopfilter(tempData, dsFs, [59 61]);

        % segment data into trials of length trialLength with overlap
        cfg         = [];
        cfg.length  = eParams.windowLength;
        cfg.overlap = eParams.windowOverlap;
        cfg.feedback   = 'no';
        cfg.verbose    = 'no';
        data_MouseEphysDS   = ft_redefinetrial(cfg, data_MouseEphysDS);
        eParams.(thisDate).trialInfo(iExpt).trialTimesRedef = ...
            (data_MouseEphysDS.sampleinfo-1)/data_MouseEphysDS.fsample;

    %     nChans = length(batchParams.(thisName).ephysInfo.chanNums);
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
            nonRejects_byChan(iChan,:) = nonRejectLogic_1;
            disp(['SDcrit = ' num2str(SDCriterion) '; Accepting ' num2str(sum(nonRejects_byChan(iChan,:))) '/' num2str(nWindows) ' trials for chan#' num2str(iChan) '.']);
            nonRejects_all = nonRejects_all & nonRejects_byChan(iChan,:);
        end
        if rejectAcrossChannels
            disp('Rejecting across channels...');
            for iChan = 1:nChans
                nonRejects_byChan(iChan,:) = nonRejects_all;
            end
            display(['Cumulative accepted trials = ' num2str(sum(nonRejects_all))]);
        end
        clear tempSD tempMax
        windowsToUse = 1:length(nonRejects_all);
        windowsToUse = windowsToUse(nonRejects_all == 1);

        %End of video is cut off or one extra ephys trial than video b/c of resolution, so manually cutting off
        %ephys trials with no associated video
        if strcmp(thisName,'EEG10') && strcmp(thisDate,'date16506') && strcmp(thisExpt,'expt005') || ...
            strcmp(thisName,'EEG39') && strcmp(thisDate,'date17622') && strcmp(thisExpt,'expt002') || ...
            strcmp(thisName,'EEG47') && strcmp(thisDate,'date18309') && strcmp(thisExpt,'expt004') || ...
            strcmp(thisName,'EEG49') && strcmp(thisDate,'date18328') && strcmp(thisExpt,'expt002')
            windowsToUse = windowsToUse(windowsToUse <= length(meanMovementPerWindow));

        %Headstage became unplugged during index so
        %manually removing these trials based on sudden
        %spike in power

        elseif strcmp(thisName,'EEG33') && strcmp(thisDate,'date17530') && strcmp(thisExpt,'expt004')
            windowsToUse(ismember(windowsToUse,find(eParams.(thisDate).trialInfo(4).trialTimesRedef(:,1)>390 & ...
                eParams.(thisDate).trialInfo(4).trialTimesRedef(:,2)<727))) = [];
    %                         windowsToUse(131:242) = [];
        elseif strcmp(thisName,'EEG34') && strcmp(thisDate,'date17601') && strcmp(thisExpt,'expt004')
            windowsToUse(ismember(windowsToUse,find(eParams.(thisDate).trialInfo(4).trialTimesRedef(:,1)>1773 & ...
                eParams.(thisDate).trialInfo(4).trialTimesRedef(:,2)<2371))) = [];
    %                         windowsToUse(592:790) = [];
        end

        %For each window, divide into trials of length trial_l and calculate wPLI for each segment
        firstWindow = 1;
        for iWindow = 1:nWindows
            if sum(ismember(iWindow,windowsToUse))>0
                thisWindow = iWindow;

                seg_dat = [];
                seg_dat.trial = data_MouseEphysDS.trial(thisWindow);
                seg_dat.time = data_MouseEphysDS.time(thisWindow);
                seg_dat.fsample = data_MouseEphysDS.fsample;
                seg_dat.label = data_MouseEphysDS.label;
                seg_dat.sampleinfo = data_MouseEphysDS.sampleinfo(thisWindow,:);

                cfg         = [];
                cfg.feedback   = 'no';
                cfg.verbose    = 'no';
                cfg.length  = trial_l; %trial length in s
                cfg.overlap = eParams.windowOverlap; %1/4 segment overlap
                seg_dat   = ft_redefinetrial(cfg, seg_dat);
                nTrials = length(seg_dat.trial);

                for iBand = 1:length(mouseDeliriumFreqBands.Names)
                    thisBand = mouseDeliriumFreqBands.Names{iBand};
                    if firstWindow
                        gMouseEphys_conn.WPLI.(thisName).(thisDate).(thisExpt).(thisBand).connVal = NaN(nWindows,nChans*(nChans-1)/2);
                        gMouseEphys_conn.WPLI.(thisName).(thisDate).(thisExpt).(thisBand).connSEM = NaN(nWindows,nChans*(nChans-1)/2);
                    end
                    bw = mouseDeliriumFreqBands.Widths.(thisBand);
                    freqRange = mouseDeliriumFreqBands.Limits.(thisBand);
                    for iTrial = 1:nTrials
                        bandTFR=dbt(seg_dat.trial{iTrial}',seg_dat.fsample,bw,'offset',freqRange(1),'lowpass',freqRange(2)-bw);
                        if iTrial==1
                            [nTimePts,nFreqs,~] = size(bandTFR.blrep);
                            csdDum = zeros(nTrials,nChanCmbs,nFreqs,nTimePts);
                        end
                        csdTemp = bandTFR.blrep(:,:,chanCmb(:,1)).*conj(bandTFR.blrep(:,:,chanCmb(:,2)));
                        csdDum(iTrial,:,:,:) = permute(csdTemp,[3,2,1]);
                    end
                    csdDum = squeeze(mean(csdDum,4));

                    [wpli,sem] = my_wPLI(csdDum);
                    %wPLI is returned as n_ChannCmb x nFreqs. Need to reshape back to
                    %nChanXnChan, and take average across frequency
                    tempWPLI = mean(wpli,2)';
                    tempSEM = mean(sem,2)';
                    gMouseEphys_conn.WPLI.(thisName).(thisDate).(thisExpt).(thisBand).connVal(iWindow,:) = tempWPLI;
                    gMouseEphys_conn.WPLI.(thisName).(thisDate).(thisExpt).(thisBand).connSEM(iWindow,:) = tempSEM;
                end %bands
                firstWindow = 0;
            end   
        end %loop over windows  
    end %Loop over expts

    % Add in new params info to output batchParams structure
    gBatchParams.(animalName).(thisDate).trialInfo = eParams.(thisDate).trialInfo;
    toc
end %loop over dates

% batchParams.(thisName) = eParams;
% save([outPath outFileName],'mouseEphys_conn','batchParams');
% disp('mouseEphys_conn & batchParams saved!');

end
