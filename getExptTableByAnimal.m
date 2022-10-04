function [exptTable] = getExptTableByAnimal(animal)

% === test parameters
 %animal = 'ZZ09';

listOfAnimalExpts = getExperimentsByAnimal(animal);
descOfAnimalExpts = listOfAnimalExpts(:,2);
listOfAnimalExpts = listOfAnimalExpts(:,1);

sz = [length(listOfAnimalExpts) 6] + 2;
varTypes = {'string','string','string','logical','logical','logical','logical','logical'};
varNames = {'Animal','DateIndex','Description','spon','stimResp','preLTP','postLTP','postLTD'};
exptTable = table('Size',sz,'VariableTypes',varTypes,'VariableNames',varNames);


for iList = 1:length(listOfAnimalExpts)
    exptTable.Animal(iList) = [animal];
    exptTable.Description(iList) = descOfAnimalExpts{iList}{1};
    date = listOfAnimalExpts{iList}(1:5);
    index = listOfAnimalExpts{iList}(7:9);
    exptTable.DateIndex(iList) = [date '-' index];
    
    pat1 = ["Spon" "spon"];
    if contains(exptTable.Description(iList),pat1);
        exptTable.spon(iList) = true;
    else
        exptTable.spon(iList) = false;
    end
    pat2 = ["stimulus response curve" "Stimulus Response Curve" "stim/resp"]
     if contains(exptTable.Description(iList),pat2);
        exptTable.stimResp(iList) = true;
    else
         exptTable.stimResp(iList) = false;
     end
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
    end
        exptTable.postLTD(iList) = false;
end



tic
exptFound = 1;
operatingListStimResp = exptTable.DateIndex(exptTable.stimResp == true);
operatingListPreLTP = exptTable.DateIndex(exptTable.preLTP == true);
operatingListPostLTP = exptTable.DateIndex(exptTable.postLTP == true);
operatingListPostLTD = exptTable.DateIndex(exptTable.postLTD == true);


for iList = 1:length(operatingListStimResp)    
    dateA = operatingListStimResp{iList}(1:5);
    preLTPflag = contains(operatingListPreLTP,dateA);
    postLTPflag = contains(operatingListPostLTP,dateA);
    postLTDflag = contains(operatingListPostLTD,dateA);
    if sum(postLTPflag) == 1 && sum(postLTDflag) == 1
        timeElapsed = toc;
        disp(['Found plasticity expt on ' dateA ' in ' num2str(timeElapsed) ' sec']);
        exptList(exptFound).exptDate = dateA;
        charA = operatingListStimResp{iList}(7:9);
        charB = operatingListPreLTP(preLTPflag);
        charC = char(operatingListPostLTP(postLTPflag));
        charD = char(operatingListPostLTD(postLTDflag));
        exptList(exptFound).exptIndices = {charA,charB(7:9),charC(7:9),charD(7:9)};  
        treatments = getTreatmentInfo(animal,dateA);
        if ~isempty(treatments.pars)
            exptList(exptFound).desc = treatments.pars{1};
        else
            exptList(exptFound).desc = 'No drug';
        end
        exptFound = exptFound+1;
    end

% 
% for iList = 1:length(operatingListPreLTP)    
%     dateA = operatingListPreLTP{iList}(1:5);
%     postLTPflag = contains(operatingListPostLTP,dateA);
%     postLTDflag = contains(operatingListPostLTD,dateA);
%     if sum(postLTPflag) == 1 && sum(postLTDflag) == 1
%         timeElapsed = toc;
%         disp(['Found plasticity expt on ' dateA ' in ' num2str(timeElapsed) ' sec']);
%         exptList(exptFound).exptDate = dateA;
%         charA = operatingListPreLTP{iList}(7:9);
%         charB = char(operatingListPostLTP(postLTPflag));
%         charC = char(operatingListPostLTD(postLTDflag));
%         exptList(exptFound).exptIndices = {charA,charB(7:9),charC(7:9)};  
%         treatments = getTreatmentInfo(animal,dateA);
%         if ~isempty(treatments.pars)
%             exptList(exptFound).desc = treatments.pars{1};
%         else
%             exptList(exptFound).desc = 'No drug';
%         end
%         exptFound = exptFound+1;
%     end
    
end












