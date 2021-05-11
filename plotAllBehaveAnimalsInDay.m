function plotAllBehaveAnimalsInDay(exptDate,day,sheet,treatmentTwo)

% example parameters:
% exptDate = '19423';
% day = 1; %e.g. for first day of experiment
% treatmentTwo = 'PBS';
% sheet = 'piroxicam'; %(name of the drug treatment)


T = readtable('M:\mouseEEG\movement\behaviorExptDrugList.xlsx','Sheet',sheet);
animals = T.animal;
drugs = T.drug;

for ii=1:length(animals)
    disp(['Loading ' animals{ii}]);
    [fullDayMovement(ii,:),fullDayTimestamps(ii,:)] = loadFullDayBehaveMovement(animals{ii},exptDate);
end

disp('Finished loading.');
yMax = max(max(fullDayMovement));
fullDayTimestamps = fullDayTimestamps(1,:); % careful! this assumes they're all the same
fullDayTimestamps = fullDayTimestamps/60/60;

figureName = ['Daily Activity - ' exptDate ' - ' sheet ' - '  treatmentTwo];
superTitle = ['Animal Movement - Day ' num2str(day) ' - ' treatmentTwo];
figure('Name',figureName,'Position',[1 41 1600 1083]);

for ii=1:length(animals)
    h(ii) = subtightplot(length(animals),1,ii,[],[.075 .05],[.075 .05]);
    plot(fullDayTimestamps,fullDayMovement(ii,:),'MarkerEdge',[.5 .5 .5]);
    ylim([0,yMax]);
    l = vline(fullDayTimestamps(find(fullDayTimestamps>1,1)),'r',drugs{ii});
    m = vline(fullDayTimestamps(find(fullDayTimestamps>2,1)),'r',treatmentTwo);
    set(m,'LineWidth',2);
    set(l,'LineWidth',2);
    xlim([0,fullDayTimestamps(end)])
    box off
    ax = gca;
    ax.FontSize = 16; 
    ax.LineWidth = 2;
    if ii == length(animals)
    else
       yticklabels([]);
       xticklabels([]);
    end
    if ii == 1
        title(superTitle,'fontsize',20);
    end
    if ii==length(animals)
       xlabel('Time (hr)','fontsize',20); 
    elseif ii==length(animals)-4
       ylabel('\Delta luminance of video (a.u.)','fontsize',20); 
    end

end

% v = findobj('String','minocycline');
% w = findobj('String','PBS');
% r = findobj('String','LPS');
% set(v,'FontSize',14);
% set(w,'FontSize',14);
% set(r,'FontSize',14);

linkaxes(h(:),'xy');
outPath = 'M:\mouseEEG\movement\behavioral experiments\';
savePlot(outPath,figureName);
