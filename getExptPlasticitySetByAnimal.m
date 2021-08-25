function exptList = getExptPlasticitySetByAnimal(animal)

% === test parameters
% animal = 'ZZ10';

listOfAnimalExpts = getExperimentsByAnimal(animal);
descOfAnimalExpts = listOfAnimalExpts(:,2);
listOfAnimalExpts = listOfAnimalExpts(:,1);

sz = [length(listOfAnimalExpts) 5];
varTypes = {'string','string','logical','logical','logical'};
varNames = {'DateIndex','Description','preLTP','postLTP','postLTD'};
exptTable = table('Size',sz,'VariableTypes',varTypes,'VariableNames',varNames);

for iList = 1:length(listOfAnimalExpts)
    exptTable.Description(iList) = descOfAnimalExpts{iList}{1};
    date = listOfAnimalExpts{iList}(1:5);
    index = listOfAnimalExpts{iList}(7:9);
    exptTable.DateIndex(iList) = [date '-' index];
    if contains(exptTable.Description(iList),'pre LTP/LTD')
        exptTable.preLTP(iList) = true;
    else
        exptTable.preLTP(iList) = false;
    end
    if contains(exptTable.Description(iList),'Post LTP / stim')
        exptTable.postLTP(iList) = true;
    else
        exptTable.postLTP(iList) = false;
    end
    if contains(exptTable.Description(iList),'Post LTD / stim')
        exptTable.postLTD(iList) = true;
    else
        exptTable.postLTD(iList) = false;
    end
end
tic
exptFound = 1;
operatingListPreLTP = exptTable.DateIndex(exptTable.preLTP == true);
operatingListPostLTP = exptTable.DateIndex(exptTable.postLTP == true);
operatingListPostLTD = exptTable.DateIndex(exptTable.postLTD == true);
for iList = 1:length(operatingListPreLTP)    
    dateA = operatingListPreLTP{iList}(1:5);
    postLTPflag = contains(operatingListPostLTP,dateA);
    postLTDflag = contains(operatingListPostLTD,dateA);
    if sum(postLTPflag) == 1 && sum(postLTDflag) == 1
        timeElapsed = toc;
        disp(['Found plasticity expt on ' dateA ' in ' num2str(timeElapsed) ' sec']);
        exptList(exptFound).exptDate = dateA;
        charA = operatingListPreLTP{iList}(7:9);
        charB = char(operatingListPostLTP(postLTPflag));
        charC = char(operatingListPostLTD(postLTDflag));
        exptList(exptFound).exptIndices = {charA,charB(7:9),charC(7:9)};  
        treatments = getTreatmentInfo(animal,dateA);
        if ~isempty(treatments.pars)
            exptList(exptFound).desc = treatments.pars{1};
        else
            exptList(exptFound).desc = 'No drug';
        end
        exptFound = exptFound+1;
    end
end





% animal = 'ZZ10';
% exptList = getExptPlasticitySetByAnimal(animal);
% for iExpt = 1:size(exptList,2)
%     plotPlasticityAmplitudePeaks(exptList(iExpt).exptDate,exptList(iExpt).exptIndices,exptList(iExpt).desc);
% end










