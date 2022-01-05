function trialList = updateStimInfoSynapse(exptDate,exptIndex)
% GIVEN: data.scalars;
% DO: update database; save trial file
% RETURN: unique list of stims
% I haven't found a good way to store or extract a specific parameter name
% in Synapse (WIP).  The solution for now is to pull expected values from a
% list.  There is a permanent record in each raw data folder about which
% experiment was run (to know the parameters) e.g., 
% [getPathGlobal('W') 'PassiveEphys\2018\18830-020']

% test params
% exptDate = '18o01';
% exptIndex = '001';
% exptDate = '18o01';
% exptIndex = '005';

dbConn = dbConnect();
exptDate_dbForm = houseConvertDateTo_dbForm(exptDate);
masterResult = fetchAdjust(dbConn,['select exptID,animalID,hardware from masterexpt where exptDate=''' exptDate_dbForm ''' and exptIndex=' num2str(str2num(exptIndex))]);
exptID = masterResult{1,1};
ephysResult = fetchAdjust(dbConn,['select sample_freq,filter_highcut,amp_gain,headstage from detail_ephys where exptid=' num2str(exptID)]);
% only load the stim info from the data tank
% % TODO % can't seem to get away from this stupid 'hardcoding'
tankFileLoc = [getPathGlobal('W') 'PassiveEphys\20' exptDate(1:2) '\' exptDate '-' exptIndex '\'];
saveFileLoc = [getPathGlobal('M') 'PassiveEphys\20' exptDate(1:2) '\' exptDate '-' exptIndex '\'];
stimInfo = TDTbin2mat(tankFileLoc,'TYPE',{'scalars'});
% scan the list of stims and get them ready to sort
if isempty(stimInfo) % throw an error, since we couldn;t find these data
    error(['No tank file found at ' tankFileLoc ' or tankfile does not have scalars' ]);
end
if ~isempty(stimInfo.scalars)
    stimName = fields(stimInfo.scalars);
    stimTimes = stimInfo.scalars.(stimName{1}).ts;
    stimData = stimInfo.scalars.(stimName{1}).data;
    nTrials = length(stimTimes);
    nStimParams = 0;
    for iStim = 1:size(stimData,1)
        if length(unique(stimData(iStim,:))) > 1
            nStimParams = nStimParams+1;
            uniqueStim(nStimParams,:) = stimData(iStim,:);
        end
    end
    for iStim = 1:size(uniqueStim,1)
        stimsUnique(iStim).stimVals = unique(uniqueStim(iStim,:));
    end
    % for now let's just name the two single parameters we use, and expand as
    % needed?
    stimIncrement = 1;
    for iStim = 1:length(stimsUnique)
        if isequal(stimsUnique(iStim).stimVals,[50,100,200,333,500])
            stimPars{stimIncrement} = 'LED_surr_period';
            stimIncrement = stimIncrement+1;
        end
        if isequal(stimsUnique(iStim).stimVals,[3,4,6,11,21])
            stimPars{stimIncrement} = 'LED_surr_stimcnt';
            stimIncrement = stimIncrement+1;
        end
    end
    % many existing programs are expecting del and dur tags in the stim 
    % info.  Add that here.  In the future, we should toggle the dur and
    % del based on how we're chopping up the continuous data
    stimPars{stimIncrement} = 'LED_stim_del';
    stimIncrement = stimIncrement+1;
    nStimParams = nStimParams+1;
    uniqueStim(nStimParams,:) = 500;
    stimPars{stimIncrement} = 'LED_train_dur';
    nStimParams = nStimParams+1;
    uniqueStim(nStimParams,:) = 1000;
    % % !!! TODO !!! % The above is not at all the correct way to do that
    % the following from Synapse API will help pull parameter names
    % gizmo_names = syn.getGizmoNames()
    % for i = 1:numel(gizmo_names)
    % gizmo = gizmo_names{i}
    % params = syn.getParameterNames(gizmo);
    % end
else % if there is no 'scalar' field, it's a spontaneous recording.  set that up here.
    nTrials = 1;
    nStimParams = 1;
    uniqueStim(nStimParams,:) = 1;
    stimPars{1} = 'no_stim';
    %stimsUnique(1).stimVals = 1;
    stimTimes = 0;
end
% Separate function to fetch global stim parameters (drug dose, light intensity, etc.)
[nGlobalPars,globalParNames,globalParVals] = getGlobalStimParams(exptDate,exptIndex);
% following borrowed from previos import: a fine way to do it, and will
% help keep at least some things consistant.
tempVals = zeros(nTrials,nStimParams+2+nGlobalPars);
for iTrial = 1:nTrials
    tempVals(iTrial,1) = iTrial;
    tempVals(iTrial,2:nStimParams+1) = uniqueStim(1:nStimParams,iTrial)';
    %tempVals(iTrial,2:nStimParams+1) = tempData(1,iTrial).stim.values(1:nStimParams);
    %secondsInDay = (tempData(1,iTrial).timestamp - floor(tempData(1,iTrial).timestamp))*24*60*60;
    tempVals(iTrial,nStimParams+2+nGlobalPars) = stimTimes(iTrial);
end
sortedVals = sortrows(tempVals,2:nStimParams+1);
iIndx=1;
newStimIndx(1) = iIndx;
for iTrial = 2:nTrials
    if sum(sortedVals(iTrial,2:nStimParams+1)==sortedVals(iTrial-1,2:nStimParams+1))~=nStimParams
        %Then stimulus parameters have changed
        iIndx=iIndx+1;
        newStimIndx(iIndx) = iTrial;
    end
end
nDistinctStim = size(newStimIndx,2);
newStimIndx(nDistinctStim+1) = nTrials+1;
trialList(1:nTrials) = struct('uniqueStimID',0,'dataFile','','origTrialNum',0,'trialTime',0);
for iTrial = 1:nTrials
    trialList(iTrial).gain = 1.e3; % This puts the units in millivolts! Important to know!!
    %trialList(iTrial).gain = ephysResult{1,3};
    trialList(iTrial).offset = 0;
    % behavioral functionality disabled
end
%Remove all parameters in the exptstims under the current
%experiment number and clear current stimInfo
deleteStimExpt = ['delete from exptstims where exptID =' num2str(exptID) ];
exec(dbConn,deleteStimExpt);
for iStim = 1:nDistinctStim
    stimValues(iStim).Val(1:nStimParams) = sortedVals(newStimIndx(iStim),2:nStimParams+1);
    nTrialsThisStim = newStimIndx(iStim+1)-newStimIndx(iStim);
    stimValues(iStim).Trials(1:nTrialsThisStim) = sortedVals(newStimIndx(iStim):newStimIndx(iStim+1)-1,1);
    stimValues(iStim).trialTimes(1:nTrialsThisStim) = ...
        sortedVals(newStimIndx(iStim):newStimIndx(iStim+1)-1,nStimParams+2+nGlobalPars);
    stimValues(iStim).Par = stimPars;
    %The following code dynamically creates fields in the stimPars
    %structure that have field names determined by the variable
    %names in stimValues.  Note the use of the ".()" notation.
    for iPar = 1:nStimParams
        parName = char(stimValues(1,iStim).Par{iPar});
        parName = strrep(parName,'[',''); %Handles odd case where parameter name contains []s
        parName = strrep(parName,']','');
        parName = strrep(parName,'(',''); %Handles odd case where parameter name contains ()s
        parName = strrep(parName,')','');
        parName = genvarname(parName); %Removes spaces and any other invalid chars 
        stimPar(iStim).(parName) = stimValues(1,iStim).Val(iPar);
    end
    if(nGlobalPars > 0)
        for iPar = 1:nGlobalPars
            stimPar(iStim).(char(globalParNames{iPar})) = globalParVals(iPar);
        end
    end
    [stimID] = dbGetUniqueStimulus(stimPar(iStim)); 
    %update exptstims adding the experiment ID and the stimulus
    %ID to the table 
    insertStimExpt = ['insert into exptstims (exptID,stimID) values (' ...
         num2str(exptID)  ','  num2str(stimID) ')'];
     exec(dbConn,insertStimExpt);
    %First column of sortedVals is trial numbers.  Figure out
    %which trials in original data structure (i.e. tempVals)
    %correspond to this iStim.  Note that data are not sorted
    %according to stim vals in saved data strucures trialList and ephysData. 
    trialIndx = ismember(tempVals(:,1),stimValues(iStim).Trials);
    [trialList(logical(trialIndx)).uniqueStimID] = deal(stimID);
    [trialList(logical(trialIndx)).dataFile] = deal(tankFileLoc);
    trial_cell = num2cell(stimValues(iStim).Trials);
    [trialList(logical(trialIndx)).origTrialNum] = deal(trial_cell{:});                    
    trialTime_cell = num2cell(stimValues(iStim).trialTimes);
    [trialList(logical(trialIndx)).trialTime] = deal(trialTime_cell{:});                    
end
% save
trialFileName = [saveFileLoc exptDate '-' exptIndex '_' 'trial0'];
if ~exist(saveFileLoc,'dir')
    mkdir(saveFileLoc)
end
save(trialFileName,'trialList');

close(dbConn);