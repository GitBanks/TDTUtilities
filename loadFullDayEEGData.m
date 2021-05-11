function d = loadFullDayEEGData(animalName,thisDate)

% get list of experiments
exptList = getExperimentsByAnimalAndDate(animalName,thisDate);

% isolate the 3-digit index number only
indx = unique(cellfun(@(x) x(6:end), exptList(:,1), 'UniformOutput',false),'stable');

year = thisDate(1:2);
dirStub = 'M:\PassiveEphys\20';


for ii = 1:length(exptList)
    expt = exptList{ii};
    try
        fpath = [dirStub year '\' expt '\'];
        dirCheck = dir(fpath);
        
        fnames = {dirCheck.name};
        ephysFile = fnames{contains(fnames,'data')};
        
        if isempty(ephysFile) % if none of the files in this path contain the name EEG
            error([expt ' EEGdata filed not found. check import']);
        end
        
        load([fpath ephysFile]);
        [nChans,nPts] = size(ephysData);
        d(ii).expt = expt;
        d(ii).ephysDat = ephysData;
        d(ii).dT = dT;
        d(ii).t = 0:dT:(nPts-1)*dT;
        
    catch
        warning([expt ' failed']);
    end

end