
function saveMagnetDataFiles(dirStrRawData,dirStrRawDataTank,dirStrAnalysis)
if ~exist(dirStrAnalysis,'dir')
    mkdir(dirStrAnalysis);
end
checkForSkip = dir([dirStrAnalysis '*skipMagnet*']);
if ~isempty(checkForSkip)
    return
end
tank = TDTbin2mat(dirStrRawDataTank);
if contains(dirStrRawData,dirStrRawDataTank)
    streamNum = '1';
else
    streamNum = '2';
end
magString = {'mag','SU_'};
for ii=1:2
    if isfield(tank.streams,[magString{ii} streamNum])
        magData = tank.streams.([magString{ii} streamNum]).data; % unfiltered magnet signal
        magDT = 1/tank.streams.([magString{ii} streamNum]).fs; % magnet signal dT
    end
end
if ~exist('magData','var')
    disp('No magnet data found. Will skip this check in the future.')
    noMagnet = ' ';
    save([dirStrAnalysis 'skipMagnet'],'noMagnet');
    return;
end
filename = [dirStrRawData(end-9:end-1) '_magnetData'];
save([dirStrAnalysis filename],'magData','magDT');


