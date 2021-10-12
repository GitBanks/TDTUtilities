function [fname] = plotNewBandPowerTimeSeries_byDate(animalName,params,ephysData,subset)
% plot power time series of newly created animal (for use in fileMaint)
% * animalName is the identifier for animal of interest (e.g. 'EEG118')
% * gBatchParams is newly created batch params for animal (also works for the
%   master batchParams)
% * gMouseEphys_out is the newly created band power structure for animal
%   (this also works for the master ephys structure though too)
% will plot the individual channel band power values - both the absolute values (millivolt^2)
% and normalized ('nmlz') power which is the absolute power in band vs total power across all bands
% e.g. for 4 channel EEG there will be four traces

% subset = {
% '21623'
% '21624'
% '21626'};

chansNums = params.(animalName).ephysInfo.chanNums;
chanLabels = params.(animalName).ephysInfo.chanLabels;


if ~exist('subset','var')
    dates = fieldnames(ephysData.(animalName));
else
    for ii = 1:size(subset,1)
        dates{ii} = ['date' subset{ii,:}];
    end
end

bands = mouseEEGFreqBands.Names;
outPath = 'M:\mouseEEG\Power\Individual Time Series\';

% dimensions for subtightplots
gap = [.05 .025];
marg_h = [.1 .1];
marg_w = [];


for idate = 1:length(dates)
    thisDate = dates{idate}(5:end);
    tempList = getExperimentsByAnimalAndDate(animalName,thisDate,'Spon');
    expts{idate} = ['expt' tempList{1,1}(7:9)];
end


% preallocate your data variables so matlab doesn't yell at you
pows = nan(length(dates),length(chansNums),length(bands));
err = nan(length(dates),length(chansNums),length(bands));
indexOfExpts = 1;
for idate = 1:length(dates)
    thisDate = dates{idate};
    %expts = fieldnames(ephysData.(animalName).(thisDate)); % % % % ---->
    %see the line where we do thisexpt = expts{idate}; for why we're not
    %looping through the expts for the day
    indexLabel = getTreatmentFromIndexName(animalName,thisDate(5:end));
    % check if it's an injection date by searching for the Inj string
    % NOTE: this assumes we have kept our naming convention consistent
    isInj = contains(indexLabel,'Inj');
    if isInj
        % if it is an injection day, we need to change how we plot the data
        % from this date
        
        % TODO: see if you can separate the hour-by-hour injection data. We
        % used to separate post-injection indices, but now they are
        % combined into one continious recording.
        
    else 
        % if it's not an injection day, do the following  
%         for iexpt = 1:length(expts)
            thisexpt = expts{idate}; % for now, this will be 1:1 with the expt dates.  We need to better filter the experiments we load in from the analysis (which will also require a better analysis, which is why we're not just fixing this now...)
            for iband = 1:length(bands)
                thisband = bands{iband};
                pows(idate,:,iband) = nanmean(ephysData.(animalName).(thisDate).(thisexpt).bandPow.(thisband),1); %average over rows, which should be windows
                err(idate,:,iband) = stderr(ephysData.(animalName).(thisDate).(thisexpt).bandPow.(thisband),1); %standard error over windows
            end
            exptList{indexOfExpts} = [thisDate(5:9) '-' thisexpt(5:7)];
            indexOfExpts = indexOfExpts+1;
%         end
    end
end




animal = animalName;
% =================== consider moving this to a standalone function =======
% This block is to find which of the expts is the injection index
% here's a way to prune further: a subset of experiments from a user input
if exist('subset','var') % if we're working with a subset, we can get some specifics
    % stimRespExptTable = stimRespExptTable(contains(stimRespExptTable.DateIndex,subset),:);
    % check each day for drug/injection information
    disp('Loading drug information for selected experiments.');
    tic;
    for iDay = 1:size(subset,1)
        treats = getTreatmentInfo(animal,subset{iDay});
        if sum(treats.injIndex) == 1 %warning! this assumes 1 drug manipulation
            listQ = getExperimentsByAnimalAndDate(animal,subset{iDay});
            injectionIndex = listQ{treats.injIndex};
            drugInj = treats.pars{treats.injIndex};
        end
        msg = toc;
        disp(['loaded ' subset{iDay} ' with ' num2str(msg) ' seconds elapsed.']);
    end
end
% =========================================================================



% =================== consider moving this to a standalone function =======
% ================== find the datetimes for recordings ====================
% this section uses getTimeAndDurationFromIndex to get the exact datetime
% of the index for the x axis. 
% if there's an injection index, include it here
if exist('injectionIndex','var') % this will run if we didn't already define 
    strExpt = char(injectionIndex);
    thisDate = strExpt(1:5);
    thisIndex = strExpt(7:9);
    dateExpt = houseConvertDateTo_dbForm(thisDate);
    [~,timeOfDay] = getTimeAndDurationFromIndex(thisDate,thisIndex);
    injMoment = datetime([dateExpt ' ' char(timeOfDay)]);
end
for ii = 1:length(exptList)
    strExpt = char(exptList(ii));
    thisDate = strExpt(1:5);
    thisIndex = strExpt(7:9);
    dateExpt = houseConvertDateTo_dbForm(thisDate);
    [~,timeOfDay] = getTimeAndDurationFromIndex(thisDate,thisIndex);
    exptSeq(ii) = datetime([dateExpt ' ' char(timeOfDay)]);
end
% =========================================================================






% we now have the following:
% exptSeq 
% injMoment
% injectionIndex
% drugInj


figName = [animalName ' - spontaneous power time series'];
figure('name',figName,'position',[24 430 1644 417]);
t = 1:length(dates); % get list of index start times in datetime format
for iband = 1:length(bands)
    h(iband) = subtightplot(1,length(bands),iband,gap,marg_h,marg_w); % draw subplot with the dimensions as specified above
    datnms = datenum(exptSeq);
    % draw all channels at once
    errorbar(repmat(datnms',size(chansNums)),squeeze(pows(:,:,iband)),squeeze(err(:,:,iband)));
    % set xticks and xlims
    
    
    
    hold on
    xl = xline(datenum(injMoment),'.',drugInj,'DisplayName',drugInj,'LineWidth',1,'Interpreter', 'none');
    xl.LabelVerticalAlignment = 'middle';
    
    
    
    xlim([datnms(1)-.3 datnms(end)+.3])
    datetick('x', 'yyyy-mm-dd','keepticks','keeplimits');
%     xticklabels(dates)
    xtickangle(68);

    
    
    if iband==1
        % only label first plot
        xlabel('Recording date (yymdd)');
        ylabel('absolute power (mV^2)');
    else
        % remove xticklabels for other subplots
        xticklabels('')
    end

    % only draw legend on last plot
    if iband==length(bands)
        sz = get(gca,'position'); % get axis size before drawing legend
        legend(chanLabels,'location','eastoutside','autoupdate','off');
        set(gca,'position',sz); % set axis size back to original size after drawing legend
    end
    title([bands{iband}],'FontWeight','Normal');
    box off
    axis square
end
sgtitle([animalName ' ' drugInj],'FontWeight','Bold','Interpreter', 'none');



% ask user to save
buttonName = questdlg_timer(10,['Would you like to save figure to ' outPath '?'],...
    'Save Dialogue Box','Yes','No','Yes');
if strcmp(buttonName,'Yes')
    fname = [outPath figName];
    print('-painters',fname,'-r300','-dpng');
end



end