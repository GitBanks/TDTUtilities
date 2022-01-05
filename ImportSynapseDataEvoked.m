

clear all
tPreStim = 0.5;
tPostStim = 0.5;

%exptDate = '19625';
%exptDate = '19702';
%exptDate = '19711';
% exptDate = '19801';
% exptDate = '19912';
% exptDate = '19808';


figA = figure();
figSub = figure();
figAllTrains = figure();
%pulseAmp = {'10','40','80','120','160','200','280','360','440','520','600'};
%pulseAmp = {'750','1000'};
%pulseAmp = {'1400'};%,'1002'};
%pulseAmp = {'1001','1002','1003'};
%pulseAmp = {'175','200','225','250'};
%pulseAmp = {'360','440','520','600'};
%pulseAmp = {'800','1001','1200'};
%pulseAmp = {'151','201','251','305','501','600','700','800','1000'};
% pulseAmp = {'800','151','305'};
% exptDate = '19920';
% pulseAmp = {'560','562','563'};
exptDate = '19925';
pulseAmp = {'100','200','500','1000','1500'};

%pulseAmp = {'560','564','561','565','562','566','563','567'};
% pulseAmp = {'300','301','302','303'};
%altLabel = {'pre','train','post'};
altLabel = pulseAmp;
drawTrains = false;


for iExpt = 1:length(pulseAmp)
% pulseAmp = '10';

dirStrRawData = [getPathGlobal('W') 'PassiveEphys\' '20' exptDate(1:2) '\' exptDate '-' pulseAmp{iExpt} 'uAtest\']; %input


%dirStrRawData = [getPathGlobal('W') 'PassiveEphys\' '20' exptDate(1:2) '\' exptDate '-' pulseAmp{iExpt} 'uAStim2test\']; %input

data = TDTbin2mat(dirStrRawData);


%searching for pulses
triggerPulses = find(data.streams.eS1r.data > 0);
ipi = diff(triggerPulses);
%uniqueTTL = triggerPulses(1);
uniqueTTL = triggerPulses(1);
for iPulse = 1:length(triggerPulses)-1
    if ipi(iPulse) > 5 %found a new TTL pulse
        uniqueTTL = [uniqueTTL triggerPulses(iPulse+1)]; % need +1 because diff lags by 1
    end
end
dTStim = 1/data.streams.eS1r.fs;
timeArrayStim = (0:dTStim:length(data.streams.eS1r.data)*dTStim-dTStim);
% % show detected stim times
% figure();
% plot(timeArrayStim,data.streams.eS1r.data)
% hold on
% plot(timeArrayStim(uniqueTTL),zeros(length(uniqueTTL),1),'*')
stimTimes = timeArrayStim(uniqueTTL);

% data are stored like this:
% data.streams.LFP1.data(4,:)
% data.streams.EEGw.data(4,:)
% 1. step through rec types (data.streams.LFP1,data.streams.EEGw)

% uType = {'LFP1','EEGw'};
% nChans = 8;
uType = {'LFP1'};
nChans = 4;
% iSub = 1;

drawnow;
for iType = 1:length(uType)
    dTRec = 1/data.streams.(uType{iType}).fs;
    timeArrayRec = (0:dTRec:length(data.streams.(uType{iType}).data)*dTRec-dTRec);
    % 2. step through channels (data.streams.EEGw.data(i,:))
    for iChan = 1:size(data.streams.(uType{iType}).data,1)
        % 3. step through stims (unique TTL)
        for iTrial = 1:length(uniqueTTL)-1
            thisStim = find(timeArrayRec>stimTimes(iTrial),1);
            
            
            trialData(iChan,iTrial,:) = data.streams.(uType{iType}).data(iChan,thisStim-round(tPreStim*data.streams.(uType{iType}).fs):round(tPostStim*data.streams.(uType{iType}).fs)+thisStim);
            if ~isempty(strfind(uType{iType},'LFP1')) && mod(iChan,2)==0
                subData(iChan,iTrial,:) = trialData(iChan,iTrial,:) - trialData(iChan-1,iTrial,:);
            end
        end

    end
    
    plotTimeArray = -tPreStim:dTRec:tPostStim;
    
    
    
    for iPlot = 1:size(data.streams.(uType{iType}).data,1)
        chanData = squeeze(squeeze(mean(trialData(iPlot,:,:),2)))';
        
        vertPlotLoc = (iType-1)*size(data.streams.(uType{iType}).data,1)+iPlot; %iterates through the channel lists for types
        figure(figA);
        subtightplot(nChans,length(pulseAmp),iExpt+((vertPlotLoc-1)*length(pulseAmp)));
        %subtightplot(nChans,1,vertPlotLoc);
        plot(plotTimeArray,chanData(1:end-1));
        if iExpt ==1
            ylabel([uType{iType} ' ' num2str(iPlot)]);
        else
            set(gca,'YTickLabel',[],'YTick',[]);
        end
        if vertPlotLoc == nChans
            set(gca,'XTick',[0,0.5],'XTickLabel',{[altLabel{iExpt}],'t=.5'})
        else
            set(gca,'XTickLabel',[],'XTick',[])
        end
        ylim([-0.0001,0.0001])
        drawnow;
        if drawTrains
            figure(figAllTrains);
            for ii = 1:size(trialData,2)
                subtightplot(4,1,iPlot);
                plot(plotTimeArray,squeeze(trialData(iPlot,ii,1:end-1)));
                hold on;
            end
        end

        %subData(1,:,:) = []

        if ~isempty(strfind(uType{iType},'LFP1')) && mod(iChan,2)==0
            subChanData(iPlot,:) = squeeze(squeeze(mean(subData(iPlot,:,:),2)));
            figure(figSub);
            subtightplot(nChans,length(pulseAmp),iExpt+((vertPlotLoc-1)*length(pulseAmp)));
            plot(plotTimeArray,subChanData(iPlot,1:end-1));
             if iExpt ==1
                ylabel([uType{iType} ' ' num2str(iPlot)]);
            else
                set(gca,'YTickLabel',[],'YTick',[]);
            end
            if vertPlotLoc == nChans/2
                set(gca,'XTick',[0,0.5],'XTickLabel',{[altLabel{iExpt}],'t=.5'});
            else
                set(gca,'XTickLabel',[],'XTick',[]);
            end
            ylim([-0.00004,0.0001]);
            xlim([-0.05,0.3]);
            drawnow;
        end
    end
    clear plotTimeArray timeArrayRec trialData chanData subData
end

% subtightplot(nChans,length(pulseAmp),1);

%xlabel([pulseAmp{iExpt} ' uA 300 uS biphasic test pulse']);



end


% subChanData(iPlot,:);



% 
% xVal = [151,201,251,305,501,600,700,800,1000];
% yVal = [0,16,24,45,65,70,95,96,91];
% figure;
% scatter(xVal,yVal);
% title('Peak to trough');
% xlabel('Stimulus intensity');
% ylabel(['\muVolts']);





