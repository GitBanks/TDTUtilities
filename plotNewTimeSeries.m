function plotNewBandPowerTimeSeries(animalName,gBatchParams,gMouseEphys_out)
% plot power time series of newly created animal (for use in fileMaint)

chansNums = gBatchParams.(animalName).ephysInfo.chanNums;
chanLabels = gBatchParams.(animalName).ephysInfo.chanLabels;
dates = fieldnames(gMouseEphys_out.(animalName));
bands = {'delta','theta','alpha','beta','gamma'}; 

for idate = 1:length(dates)
    thisdate = dates{idate};
    
    figure; 
    expts = fieldnames(gMouseEphys_out.(animalName).(thisdate));
    timeReInj = gBatchParams.(animalName).(thisdate).timeReInj;
    
    pows = nan(length(expts),length(chansNums),length(bands));
    nmlzpows = nan(length(expts),length(chansNums),length(bands));
    err = nan(length(expts),length(chansNums),length(bands));
    nmlzerr = nan(length(expts),length(chansNums),length(bands));
    
    for iexpt = 1:length(expts)
        thisexpt = expts{iexpt};
        for iband = 1:length(bands)
            thisband = bands{iband};
            pows(iexpt,:,iband) = nanmean(gMouseEphys_out.(animalName).(thisdate).(thisexpt).bandPow.(thisband),1); %average over rows, which should be windows
            
            nmlzpows(iexpt,:,iband) = nanmean(gMouseEphys_out.(animalName).(thisdate).(thisexpt).bandPow.(thisband)./... %nmlz power
                gMouseEphys_out.(animalName).(thisdate).(thisexpt).bandPow.('all'),1);
            
            err(iexpt,:,iband) = stderr(gMouseEphys_out.(animalName).(thisdate).(thisexpt).bandPow.(thisband),1); %standard error over windows
            
            nmlzerr(iexpt,:,iband) = stderr(gMouseEphys_out.(animalName).(thisdate).(thisexpt).bandPow.(thisband)./... %error over nmlz power
                gMouseEphys_out.(animalName).(thisdate).(thisexpt).bandPow.('all'),1);
        end
    end
    
    for iband = 1:length(bands)
        subtightplot(2,length(bands),iband,[.05 .025],[.05 .1],[]); %
        errorbar(repmat(timeReInj',size(chansNums)),squeeze(pows(:,:,iband)),squeeze(err(:,:,iband)));
        vline(0,'k--')
        xlim([min(timeReInj)-.25,max(timeReInj)+0.25]);
        if iband==1
           xlabel('Time re: inj (h)'); 
           ylabel('absolute power (mV^2)');
           legend(chanLabels)
        else
            xticklabels('')
        end
        title(bands{iband});
    end
    
    %plot nmlz power
    for iband = 1:length(bands)
        h(iband) = subtightplot(2,length(bands),length(bands)+iband,[.05 .025],[.05 .1],[]); %
        errorbar(repmat(timeReInj',size(chansNums)),squeeze(nmlzpows(:,:,iband)),squeeze(nmlzerr(:,:,iband)));
        xlim([min(timeReInj)-.25 max(timeReInj)+0.25]);
        if iband==1
           xlabel('Time re: inj (h)'); 
           ylabel('Nmlz power');
        end
        vline(0,'k--')
    end

    sgtitle([animalName ' ' thisdate]);
end


end