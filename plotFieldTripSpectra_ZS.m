function plotFieldTripSpectra_ZS(animalList,savePlots,mouseEphys_out,batchParams)
%Plot spectra from fieldTrip output of mouseDelirium_specAnalysis.m for all treatments/experiments. 

%AnimalList must be a cell array of animal names; savePlots is a toggle to save the figure automatically,
%mouseEphys_out is the fieldtrip output structure; batchParams are user-generated descriptions of expt. - ZS 18n14 

% animalList = {'EEG55'}; test case

if ~exist('mouseEphys_out','var')
    load('W:\Data\PassiveEphys\EEG animal data\mouseEphys_out_noParse.mat')
end

if ~exist('savePlots','var')
    savePlots = 0;
end

if ~exist('animalList','var')
    error('Please enter animal name(s)')
elseif ~iscell(animalList)
    error('Please store animal name(s) inside a cell');
end

outDataPath = 'M:\mouseEEG\FieldTripVideoScoring';

for iAnimal = 1:length(animalList)
    thisName = animalList{iAnimal};
    dates = fieldnames(mouseEphys_out.(thisName));
    chanLabels = batchParams.(thisName).ephysInfo.chanLabels;
    maxForPlot = 0;
    minForPlot = 10^-11;
    for iDate = 1:length(dates)
        thisDate = dates{iDate};
        thisTreat = batchParams.(thisName).(thisDate).treatment;
        figureName = ([thisName ' - ' thisDate ' - ' thisTreat ' - no parse']);
        figure('Name',figureName);
        colOrd = colorcube;
        set(gcf,'DefaultAxesColorOrder',colOrd([12 10 15:3:27],:)); %set color order for current figure. These are colors I like - ZS 18n14 
        expts = fieldnames(mouseEphys_out.(thisName).(thisDate));
        iCount = 1;
        for iChan = [4 1 3 2] %Plots AL AR PL PR in 2x2 subplots (in that order) - 18n13 ZS 
            subtightplot(2,2,iCount,[.02 .02]);
            for iExpt = 1:length(fieldnames(mouseEphys_out.(thisName).(thisDate)))
                thisExpt = expts{iExpt};
                if ~isempty(mouseEphys_out.(thisName).(thisDate).(thisExpt).spec)
                    f = mouseEphys_out.(thisName).(thisDate).(thisExpt).spec.freq;
                    p = mouseEphys_out.(thisName).(thisDate).(thisExpt).spec.powspctrm(iChan,:);
                    loglog(f,p,'LineWidth',1.5);
                end
                hold on
                maxForPlot = max([maxForPlot,p]);
                minForPlot = min([minForPlot,p]);
                
            end
            title(chanLabels{iChan});
            xlim([1 100]);
            ylim([minForPlot-.15*minForPlot maxForPlot+.15*maxForPlot]);
            s = gca;
            s.XTick = [1 10 100];
            s.XTickLabel = {1 10 100};
%             axis square
            box off
            if iChan == 3
               xlabel('Freq');
               ylabel('Power');  
               legend(expts,'location','best');
            end
            iCount = iCount+1;
        end        
        clear iCount
       
        if savePlots
            if ~exist([outDataPath '\' thisName '\'],'dir')
                mkdir([outDataPath '\' thisName '\']);
            end
            savefig(gcf,[outDataPath '\' thisName '\' figureName]);
            print([outDataPath '\' thisName '\' figureName],'-dpng')
            disp([thisName '\' figureName ' was saved']);
        else 
            disp([figureName ' was not saved']);
        end
    end
   
end


% animalList = {'EEG52','EEG53','EEG54','EEG55','EEG57'};
% 
% load('W:\Data\PassiveEphys\EEG animal data\mouseEphys_out_noParse.mat')
% 
% plotFieldTripSpectra_ZS(animalList,1,mouseEphys_out,batchParams);