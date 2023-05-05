function [fileName] = plotRawEEG_AllChans(animalName,sendThisToSlack)
% function to plot/display (representative) EEG traces from experiments to
% aid in evaluation in signal quality. This will be included in
% fileMaint_dual/fileMaint. Note that data will need to be imported from recording computer
% prior to running this script (if not running through fileMaint).

% WORK IN PROGRESS!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

% maybe to start just plot 10 seconds of baseline EEG data/all channels?

% generate list of experiments
[outputList] = getExperimentsByAnimal(animalName,'Spon');

% subtightplot grid separation params
gap = [.025 .025];
marg_h = [.05 .1];
marg_w = [.05 .01];

% chan info (WIP)
% electrodeInfo = getElectrodeLocationFromDateIndex(recForAnimal{1,1}(1:5),recForAnimal{1,1}(7:9));

% get most recent date (? might be an issue... open to suggestions) TBD
% to-do: add a loop for dates
dates = unique(cellfun(@(x) x(1:5), outputList(:,1), 'UniformOutput',false),'stable');

for iDate = 1:length(dates)
    thisDate = dates{iDate};
    % thisDate = outputList{end,1}(1:5);
    year = thisDate(1:2);
    expts = outputList(contains(outputList(:,1),thisDate),1);
    
    treatment = outputList{contains(outputList(:,1),thisDate),2};
    treatment = treatment{:};
    treatment(strfind(treatment,'Pre-Inj')-1:end) = [];
    
    % loop through expts, plot representative signals for each hour
    figName = ['EEG traces = ' animalName ' - ' thisDate ' - ' treatment];
    figure('Units','Normalized','Position',[0 0 1 1]);
    
    % preallocate
    H = nan(size(expts,1),4);
    lower = nan(size(expts,1),4);
    upper = nan(size(expts,1),4);
    
    for ii = 1:length(expts)
        
        thisExpt = expts{ii};
        try
            
            % generate file path string
            dirStr = ['M:\PassiveEphys\20' year '\' thisExpt '\'];
            
            % load date using file path
            dirCheck = dir(dirStr);
            
            if isempty(dirCheck)
                error([dirStr ' not found! check connection to M drive or that data were imported correctly']);
            end
            
            % load
            load([dirStr '\' thisExpt '_EEGData0.mat']);
            load([dirStr  '\' thisExpt '_trial0.mat']);
            
            % build time array
            [nChans,nPts] = size(ephysData);
            t = (0:nPts-1)*(dT); % time array for EEG signal
            t1 = 600; % start time
            t2 = 605; % stop time
            time_logi = find(t>=t1 & t<=t2);
            
            % plot all four channels (rows) at the current column
            for kk = 1:nChans
                H(ii,kk) = subtightplot(length(expts),nChans,nChans*(ii-1)+kk,gap,marg_h,marg_w);
                plot(t(time_logi),ephysData(kk,time_logi));
                box off
                if ii==1 % if first expt, label channels with title
                    title(['Ch' num2str(kk)]);
                end
                if kk==1 % if first chan, label expt
                    ylabel(thisExpt);
                end
                if ii~=length(expts)
                    xticks(t1:t2);
                    xticklabels(''); % remove excess xticklabels to avoid crowding.
                end
                xlim([t1 t2]);
                lower(ii,kk) = prctile(ephysData(kk,time_logi),1); % 1st prctile
                upper(ii,kk) = prctile(ephysData(kk,time_logi),99); % 99th prctile
                
            end
        catch
            warning([thisExpt ' failed']);
        end
    end
    
    % set ylimit to smallest and largest 1st & 99th values (respecively) for
    % all axes at the same time
    set(H(:,:),'YLim',[min(lower,[],'all') max(upper,[],'all')]);
    
    % add a title above all subplots
    sgtitle([animalName ' date' thisDate ' ' treatment],'FontWeight','Bold');
    
    outPath = 'M:\PassiveEphys\mouseEEG\Power\Raw Traces\';
    % ask user if they would like to save
%     buttonName = questdlg_timer(10,['Would you like to save figure to ' outPath '?'],...
%         'Save Dialogue Box','Yes','No','Yes');
    
    fileName = [outPath figName]; %file name output for if uploading to slack

        savefig(gcf,fileName); % save figure as .fg
        print('-painters',fileName,'-r300','-dpng'); % save as .png at 300dpi
        
        % ask user if they would like to save
%         b2name = questdlg_timer(10,['Would you like to upload figure to slack?'],...
%             'Save Dialogue Box','Yes','No','No');
        if sendThisToSlack == true
            sendSlackFig([animalName ' date' thisDate ' ' treatment ' Raw EEG'],[fileName '.png']);
            disp('sent');
        end
    close all
    
    
end

end