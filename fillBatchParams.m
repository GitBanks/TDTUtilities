function params = fillBatchParams(pars,ephysInfo)

params.ephysInfo = ephysInfo;

for iExpt = 1:length(pars.expt)
    parFields = fieldnames(pars.expt(iExpt));
    for iField = 1:length(parFields)
        params.(pars.expt(iExpt).exptDate).(parFields{iField}) = pars.expt(iExpt).(parFields{iField});
    end
end

