function plotAllBehaveAnimalsInDay(exptDate,sheet,treatmentTwo)


% exptDate = '19423';
% treatmentTwo = 'PBS';
% sheet = 'piroxicam'; %(name of the drug treatment, basically)
T = readtable('M:\mouseEEG\movement\behaviorExptDrugList.xlsx','Sheet',sheet);
animals = T.animal;
drugs = T.drug;


for i=1:length(animals)
    disp(['Loading ' animals{i}]);
    [fullDayMovement(i,:),fullDayTimestamps(i,:)] = loadFullDayBehaveMovement(animals{i},exptDate);
end

disp('Finished loading.');
yMax = max(max(fullDayMovement));
fullDayTimestamps = fullDayTimestamps(1,:); % careful! this assumes they're all the same
fullDayTimestamps = fullDayTimestamps/60/60;

figureName = ['Daily Activity - ' exptDate ' - ' sheet ' - '  treatmentTwo];
figure('Name',figureName,'Position',[60 80 1511 868]);
for i=1:length(animals)
    subtightplot(length(animals),1,i);
    plot(fullDayTimestamps,fullDayMovement(i,:));
    ylabel(animals{i});
    %yticklabels([]);
    ylim([0,yMax]);
    vline(fullDayTimestamps(find(fullDayTimestamps>1,1)),'r',drugs{i});
    vline(fullDayTimestamps(find(fullDayTimestamps>2,1)),'r',treatmentTwo);
    xlim([0,fullDayTimestamps(end)])
    xticks([0,0.5,1,1.5,2,2.5,3,3.5,4,4.5,5,5.5]);
    box off
    xticklabels([]);
    if i == length(animals)
        xticklabels({'','hour 1','','hour 2','','hour 3','','hour 4','','hour 5','','hour 6'});
    end
    if i == 1
        title(figureName);
    end
end

outPath = 'M:\mouseEEG\movement\behavioral experiments\';
savePlot(outPath,figureName);


% treatmentOne = {'L-655,708';'PBS+DMSO';'L-655,708';'PBS+DMSO';'PBS+DMSO';'L-655,708';'PBS+DMSO';'L-655,708'}; %{'PBS','PBS','PBS','PBS','mino','mino','mino','mino'};
% treatmentTwo = {'PBS','PBS','PBS','PBS','PBS','PBS','PBS','PBS'};
% treatmentTwo = {'LPS','LPS','LPS','LPS','LPS','LPS','LPS','LPS'};

% animals = {'MC04';'MC07';'MC16';'MC18';'MC20';'MC21';'MC22';'MC23'}; %{'MC04';'MC07';'MC16';'MC18';'MC20';'MC21';'MC22';'MC23'}; %{'MC09','MC11','MC12','MC15','MC08','MC10','MC13','MC14'};

