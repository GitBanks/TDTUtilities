function trialPattern = createTrialPattern(nStimTypes,nTrialsPerStim)
% Simple helper function that csvAssembler calls.  Separated this out in 
% case we come up with another desired sequence style (non-randomized? 
% oddball?).

% nTrialsPerStim = 100;
% nStimTypes = 5;
trialPattern = zeros(1,nStimTypes*nTrialsPerStim);
for iTrials = 1:nStimTypes
    trialPattern((iTrials-1)*nTrialsPerStim+1:iTrials*nTrialsPerStim) = ...
        iTrials;
end
rng('shuffle');
trialPattern = trialPattern(randperm(length(trialPattern)));