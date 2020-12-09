function fileName = plotRawDataWholeDay(thisAnimal,thisDate)
% specify the date and index you want to load
% thisDate = '20d01';
% thisAnimal = 'EEG168';

% generate list of experiments and dates using enotebook
exptList = getExperimentsByAnimalAndDate(thisAnimal,thisDate);

% access the enotebook descriptions of 
treatment = exptList{contains(exptList(:,1),thisDate),2};
treatment = treatment{:};
treatment(strfind(treatment,'Pre-Inj')-1:end) = [];

% create the file path string (i.e. where the file is located on W drive)
year = thisDate(1:2);
pathStart = ['M:\PassiveEphys\20' year '\']; % the M drive location of the file

D = struct; % this is where you'll store the 
for ii = 1:length(exptList)
    thisExpt = exptList{ii,1};
    fpath = [pathStart '\' thisExpt];
    dirCheck = dir(fpath);
    n = contains({dirCheck.name},'EEGdata0');
    if sum(n) >0 % if there is a data file found
        load([dirCheck(n).folder  '\' dirCheck(n).name],'ephysData','dT'); % 
        % eventual optional todo: downsample
        D(ii).ephysData = ephysData;
        D(ii).dT = dT;
        
        clear ephysData dT
    else
        m = contains({dirCheck.name},'data0');
        if sum(m) >0 % if there is a data file found
            load([dirCheck(m).folder  '\' dirCheck(m).name],'ephysData','dT'); %
            % eventual optional todo: downsample
            D(ii).ephysData = ephysData;
            D(ii).dT = dT;
            clear ephysData dT
        else 
            error([thisExpt ' data not found on M drive']);
        end
    end
    
end

% check that sample rate is not unique to each index (probably unnecessary
dT = unique([D(:).dT]);
if length(dT) >1
    error('different sample rates detected');
end

% concatenate data
dat = [D(:).ephysData];
[nChans,nPts] = size(dat);
t = 0:dT:(nPts-1)*dT; % create time array
t = t/3600; % convert time array to hours

% TODO: determine when injections were
% inj = getInjectionIndex(thisAnimal,thisDate);
% indices = unique(cellfun(@(x) x(7:9), exptList(:,1), 'UniformOutput',false),'stable');
% for ii = 1:length(inj)
%    beep = inj{ii};
%    injIndx = contains(indices,beep);
%    D(injIndx)
% end

gap = [0.05 0.05];
marg_h = [0.05 0.05];
marg_w = [0.05 0.05];

figName = [thisAnimal ' - ' thisDate ' - ' treatment ' full day EEG'];
f = figure('name',figName,'Units','Normalized','Position',[0 0 1 1]);
for iChan = 1:nChans
    h(iChan) = subtightplot(nChans,1,iChan,gap,marg_h,marg_w); % new subplot for each chan
    plot(t,dat(iChan,:));
    box off
    % TODO: add when injection happened
    xline(1,'k--');
    xline(1.5,'k--');
    warning('hardcoded when injections occured!!');
end
linkaxes(h,'xy');
ylabel('V');
ylim([-2*10^-3 2*10^-3]); % hardcode y limits
xlabel('time (hour)');
sgtitle([thisAnimal ' - ' thisDate ' - ' treatment]);

outPath = 'M:\mouseEEG\Power\Raw Traces\Full Day\'; % specify the output path

% ask user if they would like to save
buttonName = questdlg_timer(10,['Would you like to save figure to ' outPath '?'],...
    'Save Dialogue Box','Yes','No','Yes');
fileName = [outPath figName]; %file name output for if uploading to slack
if strcmp(buttonName,'Yes')
    print('-painters',fileName,'-r300','-dpng'); % save as .png at 300dpi
    close(f);
    disp([fileName ' was saved']);
else
    disp([fileName ' was not saved']);
end
