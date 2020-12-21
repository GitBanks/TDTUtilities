function fname = plotNewWPLITimeSeries(animalName,params,ephysData)
% plot WPLI time series of newly created animal (for use in fileMaint)
% * animalName is the identifier for animal of interest (e.g. 'EEG118')
% * gBatchParams is newly created batch params for animal (also works for the
%   master batchParams)
% * gMouseEphys_conn is the newly created WPLI structure for animal
%   (this also works for the master ephys structure though too)
% will plot the individual anterior-posterior WPLI values, e.g. for 4
% channel EEG should be 2 pairs & 2 lines per subplot

pairings = [1,6]; %warning: hardcoding the anterior-poster channel pairings
npairs = 2; %number of wpli channel pairs
try
    dates = fieldnames(ephysData.(animalName));
catch
    ephysData = ephysData.WPLI;
    dates = fieldnames(ephysData.(animalName));
end
bands = {'delta','theta','alpha','beta','gamma'}; 
outPath = 'M:\mouseEEG\WPLI\Individual Time Series\';

gap = [.01 .025];
marg_h = [.1 .1];
marg_w = [];

for idate = 1:length(dates)
    thisDate = dates{idate};
    
    try
        expts = fieldnames(ephysData.(animalName).(thisDate));
        treatment = getTreatmentFromIndexName(animalName,thisDate(5:end));
        
        figName = [animalName ' - ' thisDate ' - ' treatment ' - A-P WPLI'];
        figure('name',figName,'position',[449 515 1070 277]);
        
        plis = nan(length(expts),npairs,length(bands));
        err = nan(length(expts),npairs,length(bands));
        
        for iexpt = 1:length(expts)
            thisexpt = expts{iexpt};
            for iband = 1:length(bands)
                thisband = bands{iband};
                plis(iexpt,:,iband) = nanmean(ephysData.(animalName).(thisDate).(thisexpt).(thisband).connVal(:,pairings),1); %average over rows, which should be windows
                err(iexpt,:,iband) = stderr(ephysData.(animalName).(thisDate).(thisexpt).(thisband).connVal(:,pairings),1); %standard error over windows
            end
        end
        t = [params.(animalName).(thisDate).timeOfDay{:}]; % get list of index start times in datetime format
        t = datenum(t); % convert to datenum format since we can't plot datetime using errorbar
        
        for iband = 1:length(bands)
            h(iband) = subtightplot(1,length(bands),iband,gap,marg_h,marg_w); %
            errorbar(repmat(t',size(pairings)),squeeze(plis(:,:,iband)),squeeze(err(:,:,iband)));
            hold on
            axis tight
            
            % set xticks and xlims
            xticks(t);
            xtickangle(90);
            datetick('x',15,'keepticks'); % change x tick labels to have the datetime format
            xLim = datetime(xlim,'ConvertFrom','datenum','Format','HH:mm');
            xlim(datenum([xLim(1)-minutes(30) xLim(2)+minutes(30)]));
            
            %         xlim([min(timeReInj)-.25,max(timeReInj)+0.25]);
            %         xticks(timeReInj);
            if iband==1
                % only label first plot
                xlabel('Time of day (hh:mm)');
                ylabel('WPLI');
            else
                xticklabels('')
                %             yticklabels('');
            end
            if iband==length(bands)
                sz = get(gca,'position');
                legend({'R-AP','L-AP'},'Location','EastOutside','AutoUpdate','Off');
                set(gca,'position',sz);
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
        
        %     linkaxes(h,'xy');
        sgtitle([animalName ' - ' thisDate ' - ' treatment],'FontWeight','Bold');
        
        buttonName = questdlg_timer(10,['Would you like to save figure to ' outPath '?'],...
            'Save Dialogue Box','Yes','No','Yes');
        if strcmp(buttonName,'Yes')
            fname = [outPath figName];
            print('-painters',fname,'-r300','-dpng');
        end
    catch
        warning([thisDate ' failed to plot wpli time series']);
    end
end

end

% % add vertical line to indicate injection
% plot([0 0],[0 max(plis,[],'all')],'k--');
% text(0.1,max(plis,[],'all'),treatment);
% text(0.1,max(plis,[],'all')-.2,num2str(dose));