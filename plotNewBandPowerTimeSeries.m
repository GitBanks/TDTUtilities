function [fname] = plotNewBandPowerTimeSeries(animalName,params,ephysData)
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
dates = fieldnames(ephysData.(animalName));
bands = mouseEEGFreqBands.Names;
outPath = 'M:\mouseEEG\Power\Individual Time Series\';

% dimensions for subtightplots
gap = [.05 .025];
marg_h = [.1 .1];
marg_w = [];

for idate = 1:length(dates)
    thisDate = dates{idate};
    try
        expts = fieldnames(ephysData.(animalName).(thisDate));
        
        treatment = getTreatmentFromIndexName(animalName,thisDate(5:end));
        
        figName = [animalName ' - ' thisDate ' - ' treatment ' - power time series'];
        
        figure('name',figName,'position',[93 641 1773 302]);
        pows = nan(length(expts),length(chansNums),length(bands));
        nmlzpows = nan(length(expts),length(chansNums),length(bands));
        err = nan(length(expts),length(chansNums),length(bands));
        nmlzerr = nan(length(expts),length(chansNums),length(bands));
        
        for iexpt = 1:length(expts)
            thisexpt = expts{iexpt};
            for iband = 1:length(bands)
                thisband = bands{iband};
                pows(iexpt,:,iband) = nanmean(ephysData.(animalName).(thisDate).(thisexpt).bandPow.(thisband),1); %average over rows, which should be windows
                
                nmlzpows(iexpt,:,iband) = nanmean(ephysData.(animalName).(thisDate).(thisexpt).bandPow.(thisband)./... %nmlz power
                    ephysData.(animalName).(thisDate).(thisexpt).bandPow.('all'),1);
                
                err(iexpt,:,iband) = stderr(ephysData.(animalName).(thisDate).(thisexpt).bandPow.(thisband),1); %standard error over windows
                
                nmlzerr(iexpt,:,iband) = stderr(ephysData.(animalName).(thisDate).(thisexpt).bandPow.(thisband)./... %error over nmlz power
                    ephysData.(animalName).(thisDate).(thisexpt).bandPow.('all'),1);
            end
        end
        t = [params.(animalName).(thisDate).timeOfDay{:}]; % get list of index start times in datetime format
        t = datenum(t); % convert to datenum format since we can't plot datetime using errorbar
        
        for iband = 1:length(bands)
            h(iband) = subtightplot(1,length(bands),iband,gap,marg_h,marg_w); % draw subplot with the dimensions as specified above
            
            % draw all channels at once
            errorbar(repmat(t',size(chansNums)),squeeze(pows(:,:,iband)),squeeze(err(:,:,iband)));
            
            % set xticks and xlims
            xticks(t);
            xtickangle(90);
            datetick('x',15,'keepticks'); % change x tick labels to have the datetime format
            xLim = datetime(xlim,'ConvertFrom','datenum','Format','HH:mm');
            xlim(datenum([xLim(1)-minutes(30) xLim(2)+minutes(30)]));
            
            if iband==1
                % only label first plot
                xlabel('Time of day (hh:mm)');
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
            
            % determine when injections occurred
            injPostIndex = params.(animalName).(thisDate).indexPostInj;
            exptIndex = params.(animalName).(thisDate).exptIndex;
            inj = find(ismember(exptIndex,injPostIndex));
            treatment_labels = params.(animalName).(thisDate).treatment;
            
            try
                % draw veritcal lines with labels to indicate injection
                for qq = 1:length(inj)
                    lbl = formatTreatmentString(treatment_labels{qq});
                    if iband==1
                        % draw vertical line and label for every value of inj
                        xline(t(inj(qq))-datenum(minutes(5)),'k:',lbl,'FontSize',8,'LabelHorizontalAlignment','center');
                    else
                        % leave out label for other bands so plot is not overwhelming
                        xline(t(inj(qq))-datenum(minutes(5)),'k:');
                    end
                end
            catch
                warning('failed to draw injection vertical lines and labels');
            end
            
        end
        
        
        
        % ask user to save
        sgtitle([animalName ' - ' thisDate ' - ' treatment],'FontWeight','Bold');
        buttonName = questdlg_timer(10,['Would you like to save figure to ' outPath '?'],...
            'Save Dialogue Box','Yes','No','Yes');
        if strcmp(buttonName,'Yes')
            fname = [outPath figName];
            print('-painters',fname,'-r300','-dpng');
        end
    catch
        warning([thisDate ' failed to plot power time series']);
    end
end

end