%This script is to pull the single trial data into one excell sheet
clear all
exptTable = readtable('C:\Users\Grady\Documents\Zarmeen Data\PeakMax\PsilTableSingleTrial.csv');

nExpt = size(exptTable,1);

for iList = 1:nExpt
    exptDate = exptTable.DateIndex(iList);
    exptDateChar = char(exptDate);
    exptDate = exptDateChar(1:5);
    exptIndex = exptDateChar(7:9);
    animal = char(exptTable.Animal(iList));
    outPath2 = [getPathGlobal('M') 'PassiveEphys\20' char(exptDate(1:2)) '\' char(exptTable.DateIndex(iList)) '\'];
if ~exist(outPath2,'dir')
    mkdir(outPath2);
end
    load([outPath2 char(exptTable.DateIndex(iList)) '_singleTrialPeakData'],'singleTrialPeakData')
    data(iList).Animal = exptTable.Animal(iList);
    data(iList).dateIndex = exptTable.DateIndex(iList);
    data(iList).Drug = exptTable.Description{iList};
    data(iList).StimIntensity =  singleTrialPeakData.stimArrayNumeric;
    data(iList).TrialData = singleTrialPeakData.pkVals.data;
end

%You have to manually go through the recordings now
iList = 2610987654321;
size(data(iList).TrialData ,2);

varTypes = {'string','string','string','double','double','double','double','double','double','double','double','double','double','double','double','double','double','double','double','double','double','double','double','double','double','double','double','double','double','double','double','double','double','double'};
varNames = {'Animal','Drug','DateIndex','StimIntensity','Trial1','Trial2','Trial3','Trial4','Trial5','Trial6','Trial7','Trial8','Trial9','Trial10','Trial11','Trial12','Trial13','Trial14','Trial15','Trial16','Trial17','Trial18','Trial19','Trial20','Trial21','Trial22','Trial23','Trial24','Trial25','Trial26','Trial27','Trial28','Trial29','Trial30'};
nROI = 1;
sz = [size(data(iList).TrialData ,1) length(varNames)];
singleTrialPeakTable = table('Size',sz,'VariableTypes',varTypes,'VariableNames',varNames);


for iList = iList;
    singleTrialPeakTable.Animal(1:(length(data(iList).StimIntensity))) = data(iList).Animal;
    singleTrialPeakTable.Drug(1:(length(data(iList).StimIntensity))) = data(iList).Drug;
    singleTrialPeakTable.DateIndex(1:(length(data(iList).StimIntensity))) = data(iList).dateIndex;
    singleTrialPeakTable.StimIntensity(1:(length(data(iList).StimIntensity))) = data(iList).StimIntensity;
    singleTrialPeakTable.Trial1(1:size(data(iList).TrialData ,1)) = data(iList).TrialData(:,1);
    singleTrialPeakTable.Trial2(1:size(data(iList).TrialData ,1)) = data(iList).TrialData(:,2);
    singleTrialPeakTable.Trial3(1:size(data(iList).TrialData ,1)) = data(iList).TrialData(:,3);
    singleTrialPeakTable.Trial4(1:size(data(iList).TrialData ,1)) = data(iList).TrialData(:,4);
    singleTrialPeakTable.Trial5(1:size(data(iList).TrialData ,1)) = data(iList).TrialData(:,5);
%     singleTrialPeakTable.Trial6(1:size(data(iList).TrialData ,1)) = data(iList).TrialData(:,6);
%     singleTrialPeakTable.Trial7(1:size(data(iList).TrialData ,1)) = data(iList).TrialData(:,7);
%     singleTrialPeakTable.Trial8(1:size(data(iList).TrialData ,1)) = data(iList).TrialData(:,8);
%     singleTrialPeakTable.Trial9(1:size(data(iList).TrialData ,1)) = data(iList).TrialData(:,9);
%     singleTrialPeakTable.Trial10(1:size(data(iList).TrialData ,1)) = data(iList).TrialData(:,10);
%     singleTrialPeakTable.Trial11(1:size(data(iList).TrialData ,1)) = data(iList).TrialData(:,11);
%     singleTrialPeakTable.Trial12(1:size(data(iList).TrialData ,1)) = data(iList).TrialData(:,12);
%     singleTrialPeakTable.Trial13(1:size(data(iList).TrialData ,1)) = data(iList).TrialData(:,13);
%     singleTrialPeakTable.Trial14(1:size(data(iList).TrialData ,1)) = data(iList).TrialData(:,14);
%     singleTrialPeakTable.Trial15(1:size(data(iList).TrialData ,1)) = data(iList).TrialData(:,15);
%     singleTrialPeakTable.Trial16(1:size(data(iList).TrialData ,1)) = data(iList).TrialData(:,16);
%     singleTrialPeakTable.Trial17(1:size(data(iList).TrialData ,1)) = data(iList).TrialData(:,17);
%     singleTrialPeakTable.Trial18(1:size(data(iList).TrialData ,1)) = data(iList).TrialData(:,18);
%     singleTrialPeakTable.Trial19(1:size(data(iList).TrialData ,1)) = data(iList).TrialData(:,19);
%     singleTrialPeakTable.Trial20(1:size(data(iList).TrialData ,1)) = data(iList).TrialData(:,20);
%     singleTrialPeakTable.Trial21(1:size(data(iList).TrialData ,1)) = data(iList).TrialData(:,21);
%     singleTrialPeakTable.Trial22(1:size(data(iList).TrialData ,1)) = data(iList).TrialData(:,22);
%     singleTrialPeakTable.Trial23(1:size(data(iList).TrialData ,1)) = data(iList).TrialData(:,23);
%     singleTrialPeakTable.Trial24(1:size(data(iList).TrialData ,1)) = data(iList).TrialData(:,24);
%     singleTrialPeakTable.Trial25(1:size(data(iList).TrialData ,1)) = data(iList).TrialData(:,25);
% %     singleTrialPeakTable.Trial26(1:size(data(iList).TrialData ,1)) = data(iList).TrialData(:,26);
% %     singleTrialPeakTable.Trial27(1:size(data(iList).TrialData ,1)) = data(iList).TrialData(:,27);
% %     singleTrialPeakTable.Trial28(1:size(data(iList).TrialData ,1)) = data(iList).TrialData(:,28);
% %     singleTrialPeakTable.Trial29(1:size(data(iList).TrialData ,1)) = data(iList).TrialData(:,29);
% %     singleTrialPeakTable.Trial30(1:size(data(iList).TrialData ,1)) = data(iList).TrialData(:,30);
 end

descrip = char(exptTable.DateIndex(iList));
outPath = ['C:\Users\Grady\Documents\Zarmeen Data\SingleTrialPeakMax'];
tableOutPath = fullfile(outPath, [descrip '.csv'])
writetable(singleTrialPeakTable, tableOutPath)

