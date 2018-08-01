function trialPattern = createTrialPattern(nStimTypes,nTrialsPerStim)
% nTrialsPerStim = 100;
% nStimTypes = 5;
trialPattern = zeros(1,nStimTypes*nTrialsPerStim);
for iTrials = 1:nStimTypes
    trialPattern((iTrials-1)*nTrialsPerStim+1:iTrials*nTrialsPerStim) = ...
        iTrials;
end

trialPattern = trialPattern(randperm(length(trialPattern)));