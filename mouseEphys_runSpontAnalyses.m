function [batchParams, mouseEphys_out] = mouseEphys_runSpontAnalyses(animalName,forceReRun)
% Computes the power spectrum (and Lempel-Ziv complexity for Banks Lab
% mouse ephys data.
% Workflow is
%   (a) get parameters for analysis using the function getBatchParamsByAnimal
%   (b) load the recorded data using loadMouseEphysData
%   (c) apply notch filter, downsample
%   (d) break the continuous recording into segments using ft_redefinetrial
%   (e) downsample the data further to save processing time using ft_resampledata
%   (f) run Lempel-Ziv complexity analysis, using runLZc_withRandom
%   (f) compute power in specified bands also using [TBD]
%   (g) perform a spectral analysis on the data using [TBD]
%   (h) save mouseEphys_out and batchParams to output file

% input parameters:
% animalName as the animal ID character string, e.g., 'EEG170';
% forceReRun is a boolean (true or false) 

ignoreMovement = 0; % set equal to 1 to ignore movement analysis
runICA = 0; % set this to true only if we see heartrate noise

switch nargin
    case 0
        error('at least select an animal!');
    case 1
        forceReRun = 0; % default not to rerun experiments
end

% generate batchParams
batchParams = getBatchParamsByAnimal(animalName);

% list of frequency bands
batchParams.(animalName).bandInfo = mouseEEGFreqBands; % information for band power calculation
bandNames = mouseEEGFreqBands.Names;
eParams = batchParams.(animalName); % why are eParams and batchParams separate?

% get list of experiments and dates
exptList = getExperimentsByAnimal(animalName);
dates = unique(cellfun(@(x) x(1:5), exptList(:,1), 'UniformOutput',false),'stable');

% try loading existing batch params from saved analysis output
try
    fpath = getLocalPath('bandPow');
    tempParams = load(fpath,'batchParams');
catch
    
end

% If forceReRun is false, then just narrow the list of dates that aren't already saved in specFile
iCount = 1;
if ~forceReRun
    for ii = 1:length(dates)
        thisDate = ['date' dates{ii}];
        try
            if ~isfield(tempParams.batchParams.(animalName),thisDate)
                eDates{iCount} = thisDate; % if not a field, populate this
                iCount = iCount+1;
            end
        catch
            eDates{ii} = thisDate;
        end
    end
else
    for ii = 1:length(dates)
        eDates{ii} = ['date' dates{ii}];
    end
end
clear tempParams;

if ~exist('eDates','var')
    error('apparently there are no new dates to run');
end

% Downsampled Fs
dsFs = 200; % Hz

% Trial rejection criteria
maxSDCriterion = 0.5;
minSDCriterion = 0.2;
rejectAcrossChannels = 1;

% trial length and overlap
trialLength = 4; % sec
trialOverlap = 0.25; % pct overlap
eParams.trialLength = trialLength; % epoch duration (sec)
eParams.trialOverlap = trialOverlap; % epoch fractional overlap

% Main analysis section
for iDate = 1:length(eDates)
    thisDate = eDates{iDate};
    disp('------------------------');
    disp(['Animal ' animalName ' - Date: ' thisDate]);
    disp('------------------------');
    nExpts = length(eParams.(thisDate).exptIndex);
    try
        % Expts correspond to the TDT recording files, i.e. 000, 001, etc
        for iExpt = 1:nExpts
            
            thisExpt = ['expt' eParams.(thisDate).exptIndex{iExpt}];
            %% TODO: CALCULATE MOVEMENT SCORE
            % Load video-derived movement, divide into segments w/ overlap, calculate mean of each segment
            if ignoreMovement % movement will not be added if this is = 1!!!
                meanMovementPerWindow = nan(1204,1); % TODO: maybe rethink how the non-movement condition is handled
            else
                try
                    [meanMovementPerWindow,windowTimeLims] = segmentMovementDataForAnalysis(thisDate,thisExpt,trialLength,trialOverlap);
                catch
                    warning('failed to segment movement data, will now ignore movement analysis');
                    ignoreMovement = 1; % set equal to 1 to ignore movement analysis
                    meanMovementPerWindow = [];
                end
            end
            
            %% LOAD RAW DATA
            % loadedData is matrix of nChan x nSamples
            [loadedData,eParams] = loadMouseEphysData(eParams,thisDate,iExpt);
            
            nChans = size(loadedData,1);
            file_dT = eParams.(thisDate).trialInfo.dT; % get dT of the original data
            
            %% APPLY 60HZ NOTCH FILTER
            disp('applying 60Hz notch filter');
            [loadedData_filt] = filterData_dbVer(loadedData,-1,-1,file_dT);
            
            %% DOWNSAMPLE
            [fsorig, fsres] = rat((1/file_dT)/dsFs); % get nearest ratio
            dT = file_dT*(fsorig/fsres); % new dT
            
            % resample each channel separately
            disp(['resampling from ' num2str(1/file_dT)  ' to ' num2str(1/dT) ' Hz']);
            for iChan = 1:nChans
                [loadedData_ds(iChan,:)] = resample(loadedData_filt(iChan,:),fsres,fsorig); % resample data to dsFs
            end
            
            % create time vector for downsampled data
            t_ds = 0:dT:(size(loadedData_ds,2)-1)*dT;
            
            %             % compare freq domain signals
            %             [p,f] = myFFT(loadedData,file_dT);
            %             [p_ds,f_ds] = myFFT(loadedData_ds,dT);
            %             [p_notch,f_notch] = myFFT(loadedData,file_dT);
            
            %             figure;
            %             loglog(f,p);
            %             hold on
            %             loglog(f_notch,p_notch);
            %             loglog(f_ds,p_ds);
            %             legend({'original','notch','notch + downsample'});
            %             ylim([10^-5 10^-2.5]);
            %             xlim([0.5 120]);
            %             ylabel('power');
            %             xlabel('freq (Hz)');
            %             title([thisDate ' ' thisExpt]);
            
            %             % compare time series signals
            %             t = 0:file_dT:(size(loadedData,2)-1)*file_dT;
            
            %             figure;
            %             plot(t,loadedData(1,:));
            %             hold on
            %             plot(t_ds,loadedData_ds(1,:),'.');
            
            %% SEGMENT DATA INTO TRIALS
            
            % to-do: preallocate data
%             nPts = floor(trialLength/dT);
%             nTrials = round((round(max(t_ds)/trialLength))*(1+trialOverlap)); %to-do
%             data_mouseEphys = nan(nChans,nPts,nTrials);
            
            % loop through channels, transform data vector into nChans x nPts x nTrials vector
            % note that partial trials will be ignored
            for iChan = 1:nChans
                [data_mouseEphys(iChan,:,:)] = segmentData(loadedData_ds(iChan,:),dT,trialLength,trialOverlap);
            end
            
            % segment time vector into trials
            [trialTimes] = segmentData(t_ds,dT,trialLength,trialOverlap);  
            
            %% TRIAL REJECTION
           
            nTrials = size(data_mouseEphys,3); % third dimension is number of trials
            opts.nChans = nChans;
            opts.nTrials = nTrials;
            opts.minSDCriterion = minSDCriterion;
            opts.maxSDCriterion = maxSDCriterion;
            opts.rejectAcrossChannels = rejectAcrossChannels;
            [theseTrials] = trialRejection_SD(data_mouseEphys,opts);
            
            %% DBT SPEC ANALYSIS
            
            tic
            parfor iTrial = 1:nTrials
                powSpec{iTrial} = specAnalysis(data_mouseEphys(:,:,iTrial)',dsFs); % change dimension of data_mouseEphys because dbt takes channels in columns
            end
            toc
            
            freqs = cat(3,powSpec.freq{:}); % TODOD
            bandPower = cat(3,powSpec.powspctrm{:}); % concatenate along third dimensions (trials), chans x freqs x trials matrix
            

            disp('calculated power spectrum');
            % TODO: make sure band definitions make sense
            
            % TODO: separate out the different bands in powSpec?
            
            %% TODO: RUN LEMPEL-ZIV COMPLEXITY ANALYSIS
            
            disp('starting Lempel-Ziv Complexity Analysis');
            LZc = nan(nChans,nTrials); % preallocate
            LZcn = nan(nChans,nTrials);
            tic
            for iTrial = 1:nTrials
                [LZc(:,iTrial),LZcn(:,iTrial)] = calculateLZcn(data_mouseEphys(:,:,iTrial));
            end
            toc
            
            mouseEphys_out.(animalName).(thisDate).(thisExpt).LZc = LZc;
            mouseEphys_out.(animalName).(thisDate).(thisExpt).LZcn = LZcn;
            
            %% TODO: INCORPORATE ECOG VERSION OF WPLI ANALYSIS?
            
            
            %%
            if ignoreMovement
                meanMovementPerWindow = nan(size(theseTrials));
            end
            %%
        end % Loop over expts
        batchParams.(animalName).(thisDate).trialInfo = eParams.(thisDate).trialInfo;
    catch why
        warning('Error Message:');
        warning([why.message ' ' why.stack(1).name ' line ' num2str(why.stack(1).line)]);
    end
end % Loop over recording dates for this animal

%% save!
% saveBatchParamsAndEphysOut(batchParams,mouseEphys_out);
end
            
%             % Now convert to FieldTrip format:
%             [data_MouseEphys] = convertMouseEphysToFTFormat(loadedData,eParams,thisDate,iExpt);
%             
%             cfg = [];
%             cfg.resamplefs = dsFs;
%             cfg.detrend    = 'yes';
            
            % the following line avoids numeric round off issues in the time axes upon resampling
%             data_MouseEphys.time(1:end) = data_MouseEphys.time(1); % seems unnecessay - March 2021. This has been uncommented for a while, just re-evaluated             
            
           
%             data_MouseEphysDS = ft_resampledata(cfg, data_MouseEphys);
%             data_MouseEphysDS.sampleinfo = [1, size(data_MouseEphysDS.trial{1,1},2)];
%             clear data_MouseEphys
            
            % Remove heart rate noise using ICA
%             if runICA || strcmp(animalName,'EEG18')
%                 [data_MouseEphysDS] = runICAtoRemoveECG(batchParams,data_MouseEphysDS,animalName,thisDate,thisExpt);
%             end
            
%             tempData = cell2mat(data_MouseEphysDS.trial);
%             data_MouseEphysDS.trial{1,1} = ft_preproc_bandstopfilter(tempData, dsFs, [59 61]);
            
            % Segment data into trials of length trialLength with overlap
%             cfg         = [];
%             cfg.length  = eParams.trialLength;
%             cfg.overlap = eParams.trialOverlap;
%             data_MouseEphysDS   = ft_redefinetrial(cfg, data_MouseEphysDS);
%             eParams.(thisDate).trialInfo(iExpt).trialTimesRedef = ...
%                 (data_MouseEphysDS.sampleinfo-1)/data_MouseEphysDS.fsample;  
            
%             % SPECTRAL ANALYSIS
%             % First compute band power, keeping trials separate to generate a time series
%             cfg           = [];
%             cfg.trials    = theseTrials;
%             cfg.method    = 'mtmfft';
%             cfg.taper     = 'hanning';
%             cfg.output    = 'pow';
%             cfg.pad       = ceil(max(cellfun(@numel, data_MouseEphysDS.time)/data_MouseEphysDS.fsample));
%             cfg.foi       = foi;
%             cfg.keeptrials= 'yes';
%             tempSpec      = ft_freqanalysis(cfg, data_MouseEphysDS);
%             mouseEphys_out.(animalName).(thisDate).(thisExpt).bandPow.cfg = cfg; %store config from band power
%             
%             % Calculate average power in each band
%             for iBand = 1:length(bandNames)
%                 thisBand = bandNames{iBand};
%                 fLims = mouseEEGFreqBands.Limits.(thisBand);
%                 mouseEphys_out.(animalName).(thisDate).(thisExpt).bandPow.(thisBand) = ...
%                     squeeze(mean(tempSpec.powspctrm(:,:,tempSpec.freq>=fLims(1) & tempSpec.freq<=fLims(2)),3));
%             end
%             
%             % Set params for the spectral calculation
%             cfg           = [];
%             cfg.trials    = theseTrials;
%             cfg.method    = 'mtmfft';
%             cfg.output    = 'pow';
%             cfg.pad       = ceil(max(cellfun(@numel, data_MouseEphysDS.time)/data_MouseEphysDS.fsample));
%             cfg.foi       = foi;
%             cfg.tapsmofrq = 2;
%             cfg.keeptrials= 'no';
%             
%             % Calculate average spectral power
%             mouseEphys_out.(animalName).(thisDate).(thisExpt).spec = ...
%                 ft_freqanalysis(cfg, data_MouseEphysDS);
%             
%             mouseEphys_out.(animalName).(thisDate).(thisExpt).activity = ...
%                 meanMovementPerWindow(theseTrials); % store movement array with only the accepted trials...
%             
%             mouseEphys_out.(animalName).(thisDate).(thisExpt).trialsKept = theseTrials'; % store theseTrials
%             
%             mouseEphys_out.(animalName).(thisDate).(thisExpt).windowTimeLims = eParams.(thisDate).trialInfo.trialTimesRedef(theseTrials,:); % store movement time windows with only accepted trials
%             
%             clear windowTimeLims indexLength meanMovementPerWindow