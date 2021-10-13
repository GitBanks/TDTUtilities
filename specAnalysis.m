function [output] = specAnalysis(data,fs,options,mask)
%specAnalysis Compute spectral power using dbt
%   data: samples x chans
dbtPath = what('TDTUtilities/+ephysutils/kovach');
c = onCleanup(@() rmpath(dbtPath.path));
try
    addpath(dbtPath.path);
catch why
    error('need to call specAnalysis from code dir');
end
powSpec = [];
freqs = [];
FreqBands = mouseEEGFreqBands;
for iBand = 1:length(FreqBands.Names)
    thisBand = FreqBands.Names{iBand};
    bw = FreqBands.Widths.(thisBand);
    freqRange = FreqBands.Limits.(thisBand);
    
    bandTFR = dbt(data,fs,bw,'offset',freqRange(1),'lowpass',freqRange(2)-bw);
    
    if nargin>3 && ~isempty(mask) % use noise rejection
        useBins = ecogutils.logicByBin(mask,size(bandTFR.blrep,1));
        bandTFR.blrep = bandTFR.blrep(useBins,:,:);
    end
    tempPower = squeeze(mean(gather(bandTFR.blrep).*conj(gather(bandTFR.blrep)),1))';
    powSpec = [powSpec tempPower];
    freqs = [freqs bandTFR.frequency];
end

[freqs, uIndex] = unique(freqs);
powSpec = powSpec(:,uIndex);
output = struct('powspctrm',powSpec,'freq',freqs);

end

