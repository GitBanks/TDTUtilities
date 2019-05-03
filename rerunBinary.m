function [] = rerunBinary(date,exptIDs)

for iExpt = 1:length(exptIDs)
    close all;
    exptname = [date '-' exptIDs{iExpt}];
    
    prevAnalysis = load(['M:\PassiveEphys\2019\' exptname '\' exptname '-movement.mat']);
    fullROI = prevAnalysis.fullROI;
    roiVidAnalysisBinary(['W:\Data\PassiveEphys\2019\' exptname '\2019_' exptname '_Cam1.avi'],exptname(1:5),exptname(7:9),false,fullROI,true,true);
end