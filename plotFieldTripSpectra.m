function [fileName] = plotFieldTripSpectra(animalList,mouseEphys_out,batchParams)
%Plot spectra from fieldTrip output of mouseDelirium_specAnalysis.m for all treatments/experiments. 

%AnimalList must be a cell array of animal names; savePlots is a toggle to save the figure automatically,
%mouseEphys_out is the fieldtrip output structure; batchParams are user-generated descriptions of expt. - ZS 18n14 

% % test case % %
% animalList = {'EEG57'}; 
% savePlot = 0; (does not save)

if ~exist('mouseEphys_out','var')
    load('W:\Data\PassiveEphys\EEG animal data\mouseEphys_out_psychedelics.mat','mouseEphys_out','batchParams')
end

% if ~exist('savePlots','var')
%     savePlots = 0;
% end

if ~exist('animalList','var')
    error('Please enter animal name(s)')
elseif ~iscell(animalList) %ZS 1/22/2019 want to try using a try catch loop
    animalList = {animalList};
%     warning('this function expects animal name(s) inside a cell');
end

outPath = 'M:\mouseEEG\Power\Spectra\';
addpath('M:\Ziyad\')
colorOrder = colorZ; %updated 1/24/2019
for iAnimal = 1:length(animalList)
    thisName = animalList{iAnimal};
    %updated 1/24/2019 to avoid error due to mismatch in batchParams and
    %ephysData for LFP9... 
    ephysDates = fieldnames(mouseEphys_out.(thisName));
    batchDates = fieldnames(batchParams.(thisName));
    batchDates = batchDates(contains(batchDates,'date'));
    theseDates = intersect(ephysDates,batchDates);
    
    chanLabels = batchParams.(thisName).ephysInfo.chanLabels;
%     maxForPlot = 10^-3.75;
%     minForPlot = 10^-6.8;
    for iDate = 1:length(theseDates)
        thisDate = theseDates{iDate};
        thisTreat = batchParams.(thisName).(thisDate).treatment;
        thisTreat = strrep(thisTreat,'_conc','');
        thisTreat = strrep(thisTreat,'0p9_vol','');
        if size(thisTreat,2) > 1 
%             thisTreat = thisTreat{1};
            if iscell(thisTreat)
                treatStr = sprintf('%s + %s', thisTreat{:});
            else
                treatStr = sprintf('%s + %s', thisTreat);
            end
        else
            if iscell(thisTreat)
                treatStr = thisTreat{:};
            else
                treatStr = thisTreat;
            end
        end
        figureName = ([thisName ' - ' thisDate ' - ' treatStr ' - no parse']);
        figH = figure('Name',figureName,'Position',[680 280 809 698]);
        
        set(gcf,'DefaultAxesColorOrder',colorOrder); %set color order for current figure. These are colors I like - ZS 19124 
        expts = fieldnames(mouseEphys_out.(thisName).(thisDate));
        
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
%                 maxForPlot = max([maxForPlot,max(p)]); %                maxForPlot = 10^-3.5;
%                 minForPlot = min([minForPlot,min(p)]); %                minForPlot = 10^-6.5;
            end
            title([chanLabels{iChan} ' (' num2str(iChan) ')']);
            
            % set axis limits (do this for all subplots)
            xlim([0 100]);
            ylim([10^-7 10^-3]);
            xticks([1 10 100]);
            xticklabels([1 10 100]);
            yticks([10^-7 10^-6 10^-5 10^-4 10^-3]);
            
            box off
            if iChan == 3
                xlabel('Freq');
                ylabel('Power (mV^2)');
                hleg = legend(timeStr);
                hleg.Position = [0.1104 0.1396 0.0939 0.1519]; % warning: legend position is hardcoded!
                title(hleg,'Time re: inj'); 
            end
            
            if iChan ==4 || iChan==1
               xticklabels('');
            end
            if iChan==1 || iChan==2
               yticklabels(''); 
            end
            
            if iChan==1
                % add title superimposed on the subplots (will be sensitive
                % to changes in the figure size or subplot size!)
                sgtitle([thisName ' - ' thisDate ' - ' treatStr],'FontWeight','Bold') 
            end
            
            iCount = iCount+1;
        end        
        
        clear iCount
        
        % ask user if they would like to save
        buttonName = questdlg_timer(10,['Would you like to save figure to ' outPath '?'],...
            'Save Dialogue Box','Yes','No','Yes');
        fileName = [outPath figureName]; %file name output for if uploading to slack
        if strcmp(buttonName,'Yes')
            savefig(gcf,fileName); % save figure as .fg
            print('-painters',fileName,'-r300','-dpng'); % save as .png at 300dpi
        else
            disp([fileName ' was not saved']);
        end
    end
   
end