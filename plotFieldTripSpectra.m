function plotFieldTripSpectra(animalList,savePlots,mouseEphys_out,batchParams)
%Plot spectra from fieldTrip output of mouseDelirium_specAnalysis.m for all treatments/experiments. 

%AnimalList must be a cell array of animal names; savePlots is a toggle to save the figure automatically,
%mouseEphys_out is the fieldtrip output structure; batchParams are user-generated descriptions of expt. - ZS 18n14 

% % test case % %
% animalList = {'EEG57'}; 
% savePlot = 0; (does not save)

if ~exist('mouseEphys_out','var')
    load('W:\Data\PassiveEphys\EEG animal data\mouseEphys_out_noParse_nu.mat','mouseEphys_out','batchParams')
end

if ~exist('savePlots','var')
    savePlots = 0;
end

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
    maxForPlot = 10^-3.5;
    minForPlot = 10^-7;
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
        figH = figure('Name',figureName);
        
        set(gcf,'DefaultAxesColorOrder',colorOrder); %set color order for current figure. These are colors I like - ZS 19124 
        expts = fieldnames(mouseEphys_out.(thisName).(thisDate));
        iCount = 1;
        for iChan = [4 1 3 2] %Plots AL AR PL PR in 2x2 subplots (in that order) - 18n13 ZS 
            subH(iChan) = subtightplot(2,2,iCount,[.04 .04],[.1 .04],[.1 .04]);
            
            timeReInj = batchParams.(thisName).(thisDate).timeReInj;
            for iTime = 1:length(timeReInj)
                timeStr{iTime} = ['hr ' num2str(timeReInj(iTime))];
            end
            
            for iExpt = 1:size(expts,1)
                thisExpt = expts{iExpt};
                if ~isempty(mouseEphys_out.(thisName).(thisDate).(thisExpt).spec)
                    f = mouseEphys_out.(thisName).(thisDate).(thisExpt).spec.freq;
                    p = mouseEphys_out.(thisName).(thisDate).(thisExpt).spec.powspctrm(iChan,:);
                    loglog(f,p,'LineWidth',1.5);
                end
                hold on
                maxForPlot = max([maxForPlot,max(p)]); %                maxForPlot = 10^-3.5;
                minForPlot = min([minForPlot,min(p)]); %                minForPlot = 10^-6.5;
            end
            title(chanLabels{iChan});
            xlim([1 100]);
            %ylim([minForPlot maxForPlot]);
            s = gca;
            s.XTick = [1 10 100];
            s.XTickLabel = {1 10 100};
%             axis square
            box off
            if iChan == 3
                xlabel('Freq');
                ylabel('Power (mV^2)');
                hleg = legend(timeStr,'Location','Best');
                title(hleg,'Time re: inj (LPS)');   
            end
            iCount = iCount+1;
        end        
        
        %rescale plots here
        iCount = 1;
        for iChan = [4 1 3 2] 
            subH(iChan) = subtightplot(2,2,iCount,[.04 .04],[.1 .04],[.1 .04]);
            axis tight
            if iChan ==4 || iChan==1
               xticklabels('');
            end
            if iChan==1 || iChan==2
               yticklabels(''); 
            end
            iCount = iCount+1;
        end        
        linkaxes(subH(:),'xy');
        clear iCount
        
        if savePlots
%             if ~exist([outDataPath thisName '\'],'dir')
%                 mkdir([outDataPath thisName '\']);
%             end
            savePlot(outPath,figureName); %updated 1/24/2019. savePlot is in M:\Ziyad
            close all
        else 
            disp([outPath figureName ' was not saved']);
        end
    end
   
end