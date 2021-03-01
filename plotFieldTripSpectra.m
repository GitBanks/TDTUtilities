function [fileName] = plotFieldTripSpectra(animalList,mouseEphys_out,batchParams)
% Plot spectra from fieldTrip output of mouseEphys_specAnalysis.m for all treatments/experiments. 

% animalList must be a cell array of animal names; savePlots is a toggle to save the figure automatically,
% mouseEphys_out is the saved output from the spec analysis output structure; batchParams are user-generated descriptions of expt. - ZS 18n14 

% % test case % %
% animalList = {'EEG57'}; 

% if not entered, load the saved data file (warning: hardcoded)
if ~exist('mouseEphys_out','var')
    load('W:\Data\PassiveEphys\EEG animal data\mouseEphys_out_psychedelics.mat','mouseEphys_out','batchParams')
end

if ~exist('animalList','var')
    error('Please enter animal name(s)')
elseif ~iscell(animalList) 
    animalList = {animalList};
end

outPath = 'M:\mouseEEG\Power\Spectra\';
addpath('M:\Ziyad\');
colorOrder = colorZ; % updated 1/24/2019
for iAnimal = 1:length(animalList)
    thisName = animalList{iAnimal};
    
    % get chan info
    chanLabels = batchParams.(thisName).ephysInfo.chanLabels;
    
    % note: these need to be sorted chronologically
    theseDates = fieldnames(mouseEphys_out.(thisName));
%     theseDates = checkDateChronology(ephysDates);  
     
    % loop through each date and save a new figure for each
    for iDate = 1:length(theseDates)
        try
            thisDate = theseDates{iDate};
            % format treatment... TODO: simplify this
            thisTreat = batchParams.(thisName).(thisDate).treatment;
            thisTreat = strrep(thisTreat,'_conc','');
            thisTreat = strrep(thisTreat,'0p9_vol','');
            if size(thisTreat,2) > 1
                treatStr = strjoin(thisTreat,' + ');
            else
                if iscell(thisTreat)
                    treatStr = thisTreat{:};
                else
                    treatStr = thisTreat;
                end
            end
            figureName = ([thisName ' - ' thisDate ' - ' treatStr ' - no parse']);
            figH = figure('Name',figureName,'Position',[680 280 809 698]); % warning: figure size is hardcoded
            
            % set color order for current figure. These are colors I like - ZS 19124
            set(gcf,'DefaultAxesColorOrder',colorOrder);
            expts = fieldnames(mouseEphys_out.(thisName).(thisDate));
            
            % times relative to injection (used to label each trace in the legend)
            timeReInj = batchParams.(thisName).(thisDate).timeReInj;
            for iTime = 1:length(timeReInj)
                timeStr{iTime} = ['hr ' num2str(timeReInj(iTime))];
            end
            
            iCount = 1;
            for iChan = [4 1 3 2] %Plots AL AR PL PR in 2x2 subplots (in that order) - 18n13 ZS
                subH(iChan) = subtightplot(2,2,iCount,[.04 .04],[.1 .12],[.1 .04]);
                
                for iExpt = 1:size(expts,1)
                    thisExpt = expts{iExpt};
                    if ~isempty(mouseEphys_out.(thisName).(thisDate).(thisExpt).spec)
                        f = mouseEphys_out.(thisName).(thisDate).(thisExpt).spec.freq;
                        p = mouseEphys_out.(thisName).(thisDate).(thisExpt).spec.powspctrm(iChan,:);
                        loglog(f,p,'LineWidth',1.5);
                    end
                    hold on
                end
                title([chanLabels{iChan} ' (' num2str(iChan) ')']);
                
                % set axis limits (do this for all subplots)
                xlim([0 100]);
                ylim([10^-7 10^-3]);
                xticks([1 10 100]);
                xticklabels([1 10 100]);
                yticks([10^-7 10^-6 10^-5 10^-4 10^-3]);
                
                box off
                % add labels and legend to channel 3
                if iChan == 3
                    xlabel('Freq');
                    ylabel('Power (mV^2)');
                    hleg = legend(timeStr);
                    hleg.Position = [0.1104 0.1396 0.0939 0.1519]; % warning: legend position is hardcoded!
                    title(hleg,'Time re: inj');
                end
                
                % remove redundant axis labels
                if iChan ==4 || iChan==1
                    xticklabels('');
                end
                if iChan==1 || iChan==2
                    yticklabels('');
                end           
                iCount = iCount+1;
            end
            clear iCount
            
            % add title over all subplots
            sgtitle([thisName ' - ' thisDate ' - ' treatStr],'FontWeight','Bold');
            
            % ask user if they would like to save
            buttonName = questdlg_timer(10,['Would you like to save figure to ' outPath '?'],...
                'Save Dialogue Box','Yes','No','Yes');
            fileName = [outPath figureName]; %file name output for if uploading to slack
            if strcmp(buttonName,'Yes')
                savefig(gcf,fileName); % save figure as .fig
                print('-painters',fileName,'-r300','-dpng'); % save as .png at 300dpi
            else
                disp([fileName ' was not saved']);
            end
        catch 
            warning([thisDate ' spectra failed to plot']);
        end
        close % close new figure once done
    end % dates
end % animals