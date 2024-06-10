function animalOut = getBandPrePostRatioFromFit(animalName,exptDate,windowPre,windowPost)
if ~exist("windowPre","var") || ~exist("windowPost","var")
    windowPre = [duration(0,00,00),duration(1,00,00)];
    windowPost = [duration(2,30,00),duration(3,30,00)];
end
% load the movement info from the gaussian fit program
moveDataPath = [getPathGlobal('animalSaves') animalName '\'];
moveDataFileName = ['MoveFit_' animalName '_' exptDate '.csv'];
tableOutPath = fullfile(moveDataPath, moveDataFileName);
moveTable = readtable(tableOutPath);
% load the spectra data
tableOut = fetchSpectraFromPipelineByAnimalDate(animalName,exptDate);
% tableOut.segTime = tableOut.segTime-tableOut.segTime(1);
% find the index for pre and post
moveTable.ctrl = moveTable.winTime>windowPre(1) & moveTable.winTime<windowPre(2);
moveTable.postInj = moveTable.winTime>windowPost(1) & moveTable.winTime<windowPost(2);
% then use the "accepted" windows for each window and output the
% post/pre ratio
logicalCtrl = moveTable.ctrl & moveTable.acceptedGaussFit;
logicalpostInj = moveTable.postInj & moveTable.acceptedGaussFit;
animalOut.delta = mean(tableOut.delta(logicalpostInj),'omitnan')/mean(tableOut.delta(logicalCtrl),'omitnan');
animalOut.theta = mean(tableOut.theta(logicalpostInj),'omitnan')/mean(tableOut.theta(logicalCtrl),'omitnan');
animalOut.alpha = mean(tableOut.alpha(logicalpostInj),'omitnan')/mean(tableOut.alpha(logicalCtrl),'omitnan');
animalOut.beta = mean(tableOut.beta(logicalpostInj),'omitnan')/mean(tableOut.beta(logicalCtrl),'omitnan');
animalOut.gamma = mean(tableOut.gamma(logicalpostInj),'omitnan')/mean(tableOut.gamma(logicalCtrl),'omitnan');
animalOut.animalName = animalName;
animalOut.exptDate = exptDate;