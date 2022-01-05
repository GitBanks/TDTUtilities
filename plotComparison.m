

animal = 'DREADD07';
listOfAnimalExpts = getExperimentsByAnimal(animal,'Stim');
descOfAnimalExpts = listOfAnimalExpts(:,2);

for i =1:length(listOfAnimalExpts)
    tempDates(i) = {listOfAnimalExpts{i}(1:5)};
end
uniqueDates = unique(tempDates)';



% TODO:
% make sure artifact elimination is happening correctly
% make sure drugs are being loaded in and displayed
% make sure correct channel alignment is happening
% allow selection between stim type? or channel/location?

% use this to grab drug dose
% [nGlobalPars,globalParNames,globalParVals]= getGlobalStimParams(exptDate,exptIndex)




maxY = 0;
figure('position',[100 100 1050 900]);
for jList = 1:length(uniqueDates)
    for iList = 1:length(listOfAnimalExpts)
        exptDate = listOfAnimalExpts{iList,1}(1:5);
        exptIndex = listOfAnimalExpts{iList,1}(7:9);
        ephysDir = [getPathGlobal('M') 'PassiveEphys\' '20' exptDate(1:2) '\' exptDate '-' exptIndex '\'];
        if ~isempty(strfind(uniqueDates{jList},exptDate))
            indexingCalc = 2*(jList-1);
            if ~isempty(strfind(descOfAnimalExpts{iList,1}{:},'1c'))
                subtightplot(length(uniqueDates),2,indexingCalc+1);
                display(['Found ctrl dir: ' ephysDir]);
                fileX = dir([ephysDir '*_Stim2_*']);
                load([ephysDir fileX.name],'MUAPsth');
                maxY = max(maxY,max(max(MUAPsth)));
                plot(MUAPsth(3,:));
                set(gca,'XTick',[],'YTick',[])
                drawnow;
            end
            if ~isempty(strfind(descOfAnimalExpts{iList,1}{:},'3c'))
                % use this to grab drug dose
                [~,ParInfo{jList,1},ParInfo{jList,2}]= getGlobalStimParams(exptDate,exptIndex);
                subtightplot(length(uniqueDates),2,indexingCalc+2);
                display(['Found drug dir: ' ephysDir]);
                fileX = dir([ephysDir '*_Stim2_*']);
                load([ephysDir fileX.name],'MUAPsth');
                maxY = max(maxY,max(max(MUAPsth)));
                plot(MUAPsth(3,:));
                set(gca,'XTick',[],'YTick',[])
                drawnow;
            end
        end
    end
end


maxY = maxY/2;
for jList = 1:length(uniqueDates)
    for j = 1:2
        indexingCalc = 2*(jList-1);
        subtightplot(length(uniqueDates),2,indexingCalc+j);
        ylim([0,maxY]);
        if j == 1
            if ~isempty(ParInfo{jList,1})
                ylabel(removeUnderscore([ParInfo{jList,1}{1,1} ' ' num2str(ParInfo{jList,2}) ]));
            end
        end
        if jList == 1 && j == 1
            title('Pre injection');
        end
        if jList == 1 && j == 2
            title('Post Injection');
        end
    end
end
        
        
        
