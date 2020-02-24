function [fname] = plotNewBandPowerTimeSeries(animalName,gBatchParams,gMouseEphys_out)
% plot power time series of newly created animal (for use in fileMaint)
% * animalName is the identifier for animal of interest (e.g. 'EEG118')
% * gBatchParams is newly created batch params for animal (also works for the
%   master batchParams)
% * gMouseEphys_out is the newly created band power structure for animal
%   (this also works for the master ephys structure though too)
% will plot the individual channel band power values - both the absolute values (millivolt^2) 
% and normalized ('nmlz') power which is the absolute power in band vs total power across all bands
% e.g. for 4 channel EEG there will be four traces

chansNums = gBatchParams.(animalName).ephysInfo.chanNums;
chanLabels = gBatchParams.(animalName).ephysInfo.chanLabels;
dates = fieldnames(gMouseEphys_out.(animalName));
% bands = fieldnames(gBatchParams.(animalName).bandInfo); 
bands = {'delta','theta','alpha','humanAlpha','beta','gamma','all'};
outPath = 'M:\mouseEEG\Power\Individual Time Series\';
for idate = 1:length(dates)
    thisDate = dates{idate};
    

    expts = fieldnames(gMouseEphys_out.(animalName).(thisDate));
    timeReInj = gBatchParams.(animalName).(thisDate).timeReInj;
    
    treatment = gBatchParams.(animalName).(thisDate).treatment;
    if iscell(treatment)
        treatment = treatment{:};
    end
    
    treatment = formatDrugTreatments(treatment);
    
    figName = [animalName ' - ' thisDate ' - ' treatment ' - power time series'];
    
    figure('name',figName,'position',[93 391 1773 552]); 
    pows = nan(length(expts),length(chansNums),length(bands));
    nmlzpows = nan(length(expts),length(chansNums),length(bands));
    err = nan(length(expts),length(chansNums),length(bands));
    nmlzerr = nan(length(expts),length(chansNums),length(bands));
    
    for iexpt = 1:length(expts)
        thisexpt = expts{iexpt};
        for iband = 1:length(bands)
            thisband = bands{iband};
            pows(iexpt,:,iband) = nanmean(gMouseEphys_out.(animalName).(thisDate).(thisexpt).bandPow.(thisband),1); %average over rows, which should be windows
            
            nmlzpows(iexpt,:,iband) = nanmean(gMouseEphys_out.(animalName).(thisDate).(thisexpt).bandPow.(thisband)./... %nmlz power
                gMouseEphys_out.(animalName).(thisDate).(thisexpt).bandPow.('all'),1);
            
            err(iexpt,:,iband) = stderr(gMouseEphys_out.(animalName).(thisDate).(thisexpt).bandPow.(thisband),1); %standard error over windows
            
            nmlzerr(iexpt,:,iband) = stderr(gMouseEphys_out.(animalName).(thisDate).(thisexpt).bandPow.(thisband)./... %error over nmlz power
                gMouseEphys_out.(animalName).(thisDate).(thisexpt).bandPow.('all'),1);
        end
    end
    
    for iband = 1:length(bands)
        subtightplot(2,length(bands),iband,[.05 .025],[.05 .1],[]); 
        errorbar(repmat(timeReInj',size(chansNums)),squeeze(pows(:,:,iband)),squeeze(err(:,:,iband)));
%         vline(0,'k--')
%         xlim([min(timeReInj)-.25,max(timeReInj)+0.25]);
%         xticks(timeReInj);

        xticks([timeReInj timeReInj(end)+1]-.5);
        xmin = min(timeReInj)-0.5;
        xmax = max(timeReInj)+0.5;
        xlim([xmin xmax]);
        
        if iband==1
            xticklabels([timeReInj timeReInj(end)+1]);
%             xticklabels(timeReInj-0.5)
            xlabel('Time re: inj (h)');
            ylabel('absolute power (mV^2)');
        else
            xticklabels('')
        end
        if iband==length(bands)
             sz = get(gca,'position');
             legend(chanLabels,'location','eastoutside');
             set(gca,'position',sz);
        end
        title(bands{iband},'FontWeight','Normal');
        box off
        axis square
        
        % draw vertical lines when injections occurred
        if iband==1
            timesOfInjs = getInjectionByHour(animalName,thisDate,timeReInj); 
        end
        
        for ii = 1:length(timesOfInjs)
            x = x_to_norm_v2(timesOfInjs(ii)-.5,timesOfInjs(ii)-.5);
            y = y_to_norm_v2(.9*max(ylim),.83*max(ylim));
            annotation('arrow',x,y,'Color','k');
        end
    end
    
    %plot nmlz power
    for iband = 1:length(bands)
        h(iband) = subtightplot(2,length(bands),length(bands)+iband,[.05 .025],[.05 .1],[]); %
        errorbar(repmat(timeReInj',size(chansNums)),squeeze(nmlzpows(:,:,iband)),squeeze(nmlzerr(:,:,iband)));
        
        xticks([timeReInj timeReInj(end)+1]-.5);
        
        xmin = min(timeReInj)-0.5;
        xmax = max(timeReInj)+0.5;
        xlim([xmin xmax]);
        
%         xlim([min(timeReInj)-.25 max(timeReInj)+0.25]);
%         xticks(timeReInj);
        if iband==1
%             xticklabels(timeReInj-0.5)
            xticklabels([timeReInj timeReInj(end)+1]);
            xlabel('Time re: inj (h)');
            ylabel('Nmlz power');
        else
            xticklabels('');
        end
        
        if iband==length(bands)
             sz = get(gca,'position');
             legend(chanLabels,'location','eastoutside');
             set(gca,'position',sz);
        end
%         vline(0,'k--')
        box off
        axis square
        
        % draw vertical lines when injections occurred
        if iband==1
            timesOfInjs = getInjectionByHour(animalName,thisDate,timeReInj); 
        end
        
        for ii = 1:length(timesOfInjs)
            x = x_to_norm_v2(timesOfInjs(ii)-.5,timesOfInjs(ii)-.5);
            y = y_to_norm_v2(.97*max(ylim),.94*max(ylim));
            annotation('arrow',x,y,'Color','k');
        end
        
    end

    sgtitle([animalName ' - ' thisDate ' - ' treatment],'FontWeight','Bold');
    buttonName = questdlg_timer(10,['Would you like to save figure to ' outPath '?'],...
    'Save Dialogue Box','Yes','No','Yes');
    if strcmp(buttonName,'Yes')
        fname = [outPath figName];
        print('-painters',fname,'-r300','-dpng');
    end
end

end