function [fname] = plotNewBandPowerTimeSeries_byDate(animalName,params,ephysData,dateRange)
% plot power time series of newly created animal (for use in fileMaint)
% * animalName is the identifier for animal of interest (e.g. 'EEG118')
% * gBatchParams is newly created batch params for animal (also works for the
%   master batchParams)
% * gMouseEphys_out is the newly created band power structure for animal
%   (this also works for the master ephys structure though too)
% will plot the individual channel band power values - both the absolute values (millivolt^2)
% and normalized ('nmlz') power which is the absolute power in band vs total power across all bands
% e.g. for 4 channel EEG there will be four traces

chansNums = params.(animalName).ephysInfo.chanNums;
chanLabels = params.(animalName).ephysInfo.chanLabels;


if ~exist('dateRange','var')
    dates = fieldnames(ephysData.(animalName));
else
    for ii = 1:size(dateRange,1)
        dates{ii} = ['date' dateRange{ii,:}];
    end
end

bands = mouseEEGFreqBands.Names;
outPath = 'M:\mouseEEG\Power\Individual Time Series\';

% dimensions for subtightplots
gap = [.05 .025];
marg_h = [.1 .1];
marg_w = [];

figName = [animalName ' - spontaneous power time series'];

figure('name',figName,'position',[24 430 1644 417]);

% preallocate your data variables so matlab doesn't yell at you
pows = nan(length(dates),length(chansNums),length(bands));
err = nan(length(dates),length(chansNums),length(bands));

for idate = 1:length(dates)
    thisDate = dates{idate};
    
    expts = fieldnames(ephysData.(animalName).(thisDate));
    
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
        
        for iexpt = 1:length(expts)
            thisexpt = expts{iexpt};
            for iband = 1:length(bands)
                thisband = bands{iband};
                pows(idate,:,iband) = nanmean(ephysData.(animalName).(thisDate).(thisexpt).bandPow.(thisband),1); %average over rows, which should be windows
                err(idate,:,iband) = stderr(ephysData.(animalName).(thisDate).(thisexpt).bandPow.(thisband),1); %standard error over windows
            end
        end
        
    end
  
end

t = 1:length(dates); % get list of index start times in datetime format

for iband = 1:length(bands)
    h(iband) = subtightplot(1,length(bands),iband,gap,marg_h,marg_w); % draw subplot with the dimensions as specified above

    % draw all channels at once
    errorbar(repmat(t',size(chansNums)),squeeze(pows(:,:,iband)),squeeze(err(:,:,iband)));

    % set xticks and xlims
    xticks(t);
    xticklabels(dates)
    xtickangle(90);

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
    title(bands{iband},'FontWeight','Normal');
    box off
    axis square

end


% ask user to save
sgtitle(animalName,'FontWeight','Bold');
buttonName = questdlg_timer(10,['Would you like to save figure to ' outPath '?'],...
    'Save Dialogue Box','Yes','No','Yes');
if strcmp(buttonName,'Yes')
    fname = [outPath figName];
    print('-painters',fname,'-r300','-dpng');
end


end