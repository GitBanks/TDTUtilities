function tableOut = fetchSpectraFromPipelineByAnimalDate(animalName,exptDate)
% much of this taken from my existing function plotSpectraEEG
% test params
% animalName = 'EEG195'
% exptDate = '22421'
chansToExclude = nan;
folder = [getPathGlobal('pipelineSaves') animalName '\']; % data from the pipeline 
chanEEGRemap = [2,4,3,1]; % direct channels to specific subplots so that channels line up with their physical locations
% the file will be some crazy thing like this:
% 'EEG210_22629-001,22629-003,22629-005,22629-007,22629-009,22629-011 wPLI_dbt'; 
% instead, we'll search for it.
dataFolder = dir(folder);
for iFile = 1:size(dataFolder,1)
    if contains(dataFolder(iFile).name,'specAnalysis') && contains(dataFolder(iFile).name,exptDate) 
        file = dataFolder(iFile).name;
    end
end
if ~exist('file','var')
    error(['Found ' dataFolder(1).folder ' but not the file we''re looking for!']);
end
load([folder file]); %careful! what if there's another file with a similar name?  as written, the code will just load the last one it found, but that's not certainly the correct one...
% load and plot - edit for specific recording type and channels
listOfSegments = fields(out.specAnalysis{1,1});
% grab the labels / values for the frequencies
freqLabels = out.specAnalysis{1,1}.(listOfSegments{1}).freq;
% For EEG, we want to compare anterior electrodes to posterior
%plottingArray = nan(nChans,nChans,size(listOfSegments,1));
nChans = size(out.specAnalysis{1,1}.(listOfSegments{1}).powspctrm,1);
for iSegment = 1:size(listOfSegments,1)
    thisSeg = listOfSegments{iSegment};
    for iChan = 1:nChans
        specdataLog(iChan).data(iSegment,:) = real(log2(out.specAnalysis{1,1}.(thisSeg).powspctrm(iChan,:)));
        % taking the log2 of these is fine for the spectrogram, but the
        % units will get nonsensical without that context.  If we want to
        % look at average spectral power, we need the not log data too.
        specdata(iChan).data(iSegment,:) = real(out.specAnalysis{1,1}.(thisSeg).powspctrm(iChan,:));
    end
end
% also exclude channels here
if ~isnan(chansToExclude)
    for iChan = 1:size(chansToExclude,1)
        specdata(chansToExclude(iChan)).data(:,:) = nan;
        specdataLog(chansToExclude(iChan)).data(:,:) = nan;
    end
end


% out.segmentTimeOfDay{1,1};
for iChan = 1:nChans
    %delta
    bounds(1) = find(freqLabels>=FreqBands.Limits.delta(1),1);
    bounds(2) = find(freqLabels>=FreqBands.Limits.delta(2),1);
    delta(:,iChan) = mean(specdata(iChan).data(:,bounds(1):bounds(2)),2,'omitnan');
    % Theta
    bounds(1) = find(freqLabels>=FreqBands.Limits.theta(1),1);
    bounds(2) = find(freqLabels>=FreqBands.Limits.theta(2),1);
    theta(:,iChan) = mean(specdata(iChan).data(:,bounds(1):bounds(2)),2,'omitnan');
    % Alpha
    bounds(1) = find(freqLabels>=FreqBands.Limits.alpha(1),1);
    bounds(2) = find(freqLabels>=FreqBands.Limits.alpha(2),1);
    alpha(:,iChan) = mean(specdata(iChan).data(:,bounds(1):bounds(2)),2,'omitnan');
    % Beta
    bounds(1) = find(freqLabels>=FreqBands.Limits.beta(1),1);
    bounds(2) = find(freqLabels>=FreqBands.Limits.beta(2),1);
    beta(:,iChan) = mean(specdata(iChan).data(:,bounds(1):bounds(2)),2,'omitnan');
    % Gamma
    bounds(1) = find(freqLabels>=FreqBands.Limits.gamma(1),1);
    bounds(2) = find(freqLabels>=FreqBands.Limits.highGamma(2),1);
    gamma(:,iChan) = mean(specdata(iChan).data(:,bounds(1):bounds(2)),2,'omitnan');
end

totalSegs = size(delta,1);
varTypes = {'duration','double','double','double','double','double'};
varNames = {'segTime','delta','theta','alpha','beta','gamma'};
sz = [totalSegs,length(varNames)];
tableOut = table('Size',sz,'VariableTypes',varTypes,'VariableNames',varNames);
tableOut.segTime = out.segmentTimeOfDay{1,1};
% user can later use this line to get duration:
% tableOut.segTime = tableOut.segTime-tableOut.segTime(1);
tableOut.delta = mean(delta,2,'omitnan');
tableOut.theta = mean(theta,2,'omitnan');
tableOut.alpha = mean(alpha,2,'omitnan');
tableOut.beta = mean(beta,2,'omitnan');
tableOut.gamma = mean(gamma,2,'omitnan');









