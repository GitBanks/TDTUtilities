function [] = rerunBinary(animal,date,exptIDs)

for iExpt = 1:length(exptIDs)
    close all;
    exptname = [date '-' exptIDs{iExpt}];
    index = exptIDs{iExpt};
    
    prevAnalysis = load(['M:\PassiveEphys\20' date(1:2) '\' exptname '\' exptname '-movementBinary.mat']);
    fullROI = prevAnalysis.fullROI;
    
    if str2double(animal(end-1:end)) > 51 %assumes animal name has a number associated with it (and follows the EEG animal order). New system videos started with EEG52
        vidFileName = ['W:\Data\PassiveEphys\20' date(1:2) '\' date '-' index '\20' date(1:2) '_' date '-' index '_Cam1.avi'];
    else
        vidFileName = ['W:\Data\PassiveEphys\20' date(1:2) '\' date '-' index '\' date '-' index ];
    end
    roiVidAnalysisBinary(vidFileName,date,index,false,fullROI,true,true);
end