
% test params
animalName = 'DREADD07';
exptDate = '18907';

exptList = getExperimentsByAnimalAndDate(animalName,exptDate);

dbConn = dbConnect();
globalParamsAvailable = unique(fetch(dbConn,['SELECT paramfield FROM global_stimparams'])); 
rememberLastChoices = true;


lastChoice = '0';
for iIndex = 1:length(exptList)
    exptIndex = exptList{iIndex,1}(7:9);
    drugGuess = strsplit(exptList{iIndex,2}{:},' ');
    % first look for drugs in the description
    matchbuilder = 1;
    matches = {'',''};
    for iParams = 1:length(globalParamsAvailable)
        for jParams = 1:length(drugGuess)
            if strfind(globalParamsAvailable{iParams},drugGuess{jParams})
                matches{matchbuilder,1} = drugGuess{jParams};
                matches{matchbuilder,2} = globalParamsAvailable{iParams};
                matchbuilder = matchbuilder+1;
            end
        end
    end
    % second, look to see if they're in the global stim params
    [nGlobalPars,globalParNames,globalParVals]= getGlobalStimParams(exptDate,exptIndex);
    needToSetDay = 'N';
    for iParams = 1:size(matches,1)
        if isempty(globalParNames)
            globalParNames = {''};
        end
        if ~isempty(strfind(globalParNames{1},matches{iParams,2}))
            display(['notebook has ' globalParNames{1} ' recorded with a value of ' num2str(globalParVals) ' which matches notebook description.'])
        else
            if ~exist('remembered','var')
                display(['Global parameter not found! We think it should be ' matches{1,2}])
                needToSetDay = input('Should we set up this day''s global parameters? [Y]','s');
                if isempty(needToSetDay)
                    needToSetDay = 'Y';
                end
                if needToSetDay == 'Y'
                    globalParNames = matches(1,2);
                end
                if rememberLastChoices
                    remembered = true;
                    globalParNames = matches(1,2);
                    needToSetDay = 'Y';
                end
            end
        end
    end
    % if we discover we need to set the day (needToSetDay == 'Y'), do so
    if needToSetDay == 'Y'      
        if ~isempty(strfind(drugGuess{2},'Pre-Inj'))
%             globalParValsToEnter = input('Should we set this pre-injection parameter val to zero? enter value to override: ','s');
%             if isempty(globalParValsToEnter)
%                 globalParValsToEnter = 0;
%             end
            prompt = {'pre-injection parameter val:'};
            defaultans = {'0'};
            globalParValsToEnter = inputdlg(prompt,'Input',1,defaultans);
        end
        if ~isempty(strfind(drugGuess{2},'Post-Inj'))
            prompt = {'post-injection parameter val:'};
            defaultans = {lastChoice};
            globalParValsToEnter = inputdlg(prompt,'Input',1,defaultans);
            %globalParValsToEnter = input('What should we set this post-injection parameter val to? ');
            lastChoice = globalParValsToEnter;
        end
        globalParValsToEnter = globalParValsToEnter{1};
        
        
        setGlobalStimParams(exptDate,exptIndex,globalParNames,globalParValsToEnter);
    end
end



