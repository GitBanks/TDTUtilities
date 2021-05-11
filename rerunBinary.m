function failed = rerunBinary(animal,date,exptIDs)

animalNum = getAnimalNumber(animal);

iCount = 1;
failed = {''};
for iExpt = 1:length(exptIDs)
    close all;
    exptname = [date '-' exptIDs{iExpt}];
    index = exptIDs{iExpt};
    
    if animalNum > 51 % New system videos started with EEG52
        vidFileName = ['W:\Data\PassiveEphys\20' date(1:2) '\' date '-' index '\20' date(1:2) '_' date '-' index '_Cam1.avi'];
        % vidFileName = ['W:\Data\PassiveEphys\20' date(1:2) '\' date '-' index '\20' date(1:2) '_' date '-' index '_Cam2.avi'];
    else
        vidFileName = ['W:\Data\PassiveEphys\20' date(1:2) '\' date '-' index '\' date '-' index ];
        % vidFileName = ['W:\Data\PassiveEphys\20' date(1:2) '\' date '-' index '\' date '-' index '-converted.mp4']; %ONLY FOR EEG43 and 47
    end
    
    try
        % check for saved movement analysis
        movtFile = ['M:\PassiveEphys\20' date(1:2) '\' exptname '\' exptname '-movementBinary.mat'];
        dirCheck = dir(movtFile);
        
        if ~isempty(dirCheck)
            % if there is a saved movement file, load it, and use the previous ROI
            disp('using saved ROI');
            prevAnalysis = load(['M:\PassiveEphys\20' date(1:2) '\' exptname '\' exptname '-movementBinary.mat'],'fullROI');
            fullROI = prevAnalysis.fullROI;
            useOldROI = true;
        else
            % if there is NOT a saved movement file, toggle fullROI and useOldROI off
            disp('no saved ROI found');
            fullROI = [];
            useOldROI = false;
        end
        
        % run roiVidAnalysis
        roiVidAnalysisBinary(vidFileName,date,index,fullROI,useOldROI);
    catch why
        failed.which{iCount,:} = [date '-' index];
        failed.why{iCount,:} = why;
        iCount = iCount+1;
    end
end