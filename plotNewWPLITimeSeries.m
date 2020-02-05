function fname = plotNewWPLITimeSeries(animalName,gBatchParams,gMouseEphys_conn)
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
    dates = fieldnames(gMouseEphys_conn.WPLI.(animalName));
catch
    dates = fieldnames(gMouseEphys_conn.(animalName));
end
bands = {'delta','theta','alpha','beta','gamma'}; 
outPath = 'M:\mouseEEG\WPLI\Individual Time Series\';

for idate = 1:length(dates)
    thisDate = dates{idate};
    

    expts = fieldnames(gMouseEphys_conn.WPLI.(animalName).(thisDate));
    timeReInj = gBatchParams.(animalName).(thisDate).timeReInj;
    treatment = gBatchParams.(animalName).(thisDate).treatment{:};
    treatment = formatDrugTreatments(treatment);
%     dose = gBatchParams.(animalName).(thisdate).dose;
    
    figName = [animalName ' - ' thisDate ' - ' treatment ' - A-P WPLI'];
    figure('name',figName,'position',[449 515 1070 277]); 
    
    plis = nan(length(expts),npairs,length(bands));
    err = nan(length(expts),npairs,length(bands));
    
    for iexpt = 1:length(expts)
        thisexpt = expts{iexpt};
        for iband = 1:length(bands)
            thisband = bands{iband};
            plis(iexpt,:,iband) = nanmean(gMouseEphys_conn.WPLI.(animalName).(thisDate).(thisexpt).(thisband).connVal(:,pairings),1); %average over rows, which should be windows
            err(iexpt,:,iband) = stderr(gMouseEphys_conn.WPLI.(animalName).(thisDate).(thisexpt).(thisband).connVal(:,pairings),1); %standard error over windows
        end
    end
    
    for iband = 1:length(bands)
        h(iband) = subtightplot(1,length(bands),iband,[.01 .01],[.1 .1],[]); %
        errorbar(repmat(timeReInj',size(pairings)),squeeze(plis(:,:,iband)),squeeze(err(:,:,iband)));
        hold on
        axis tight
        
        xticks([timeReInj timeReInj(end)+1]-.5);
        xmin = min(timeReInj)-0.5;
        xmax = max(timeReInj)+0.5;
        xlim([xmin xmax]);
        
%         xlim([min(timeReInj)-.25,max(timeReInj)+0.25]);
%         xticks(timeReInj);
        if iband==1
            xticklabels([timeReInj timeReInj(end)+1]);
%             xticklabels(timeReInj-0.5)
            xlabel('Time re: inj (h)');
            ylabel('WPLI');
        else
            xticklabels('')
            yticklabels('');
        end
        if iband==length(bands)
           sz = get(gca,'position');
           legend({'R-AP','L-AP'},'Location','EastOutside');
           set(gca,'position',sz);
        end
        title(bands{iband},'FontWeight','Normal');
        box off
        axis square
        
        % draw vertical lines when injections occurred
        if iband==1
            timesOfInjs = getInjectionByHour(animalName,thisDate,timeReInj); 
        end
        ylim([0 0.4]);
        % draw arrows to indicate when injections occurred
        for ii = 1:length(timesOfInjs)
            x = x_to_norm_v2(timesOfInjs(ii)-.5,timesOfInjs(ii)-.5);
            y = y_to_norm_v2(min(ylim)+.12,min(ylim)+.075);
            annotation('arrow',x,y);
        end
    end

    linkaxes(h,'xy');
    sgtitle([animalName ' - ' thisDate ' - ' treatment],'FontWeight','Bold');
    
    buttonName = questdlg_timer(10,['Would you like to save figure to ' outPath '?'],...
    'Save Dialogue Box','Yes','No','Yes');
    if strcmp(buttonName,'Yes')
        fname = [outPath figName];
        print('-painters',fname,'-r300','-dpng');
    end
end

end

% % add vertical line to indicate injection
% plot([0 0],[0 max(plis,[],'all')],'k--');
% text(0.1,max(plis,[],'all'),treatment);
% text(0.1,max(plis,[],'all')-.2,num2str(dose));