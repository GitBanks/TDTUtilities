


animals = {'MC09','MC11','MC12','MC15','MC08','MC10','MC13','MC14'};
treatmentOne = {'PBS','PBS','PBS','PBS','mino','mino','mino','mino'};
treatmentTwo = {'PBS','PBS','PBS','PBS','PBS','PBS','PBS','PBS'};
%treatmentTwo = {'LPS','LPS','LPS','LPS','LPS','LPS','LPS','LPS'};

exptDate = '19311';

for i=1:length(animals)
    disp(['Loading ' animals{i}]);
    [fullDayMovement(i,:),fullDayTimestamps(i,:)] = loadFullDayBehaveMovement(animals{i},exptDate);
end
disp('Finished loading.');
yMax = max(max(fullDayMovement));
fullDayTimestamps = fullDayTimestamps(1,:); % careful! this assumes they're all the same
fullDayTimestamps = fullDayTimestamps/60/60;

figure('Name',['Daily Activity - ' exptDate]);
for i=1:length(animals)
    subtightplot(length(animals),1,i);
    plot(fullDayTimestamps,fullDayMovement(i,:));
    ylabel(animals{i});
    %yticklabels([]);
    ylim([0,yMax]);
    vline(fullDayTimestamps(find(fullDayTimestamps>1,1)),'r',treatmentOne{i});
    vline(fullDayTimestamps(find(fullDayTimestamps>2,1)),'r',treatmentTwo{i});
    xlim([0,fullDayTimestamps(end)])
    xticks([0,0.5,1,1.5,2,2.5,3,3.5,4,4.5,5,5.5]);
    box off
    xticklabels([]);
    if i == length(animals)
        xticklabels({'','hour 1','','hour 2','','hour 3','','hour 4','','hour 5','','hour 6'});
    end
    if i == 1
        title(['Daily Activity - ' exptDate]);
    end
end




