
function saveMagnetDataFiles(dirStrRawData,dirStrRawDataTank,dirStrAnalysis)

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
    disp('No magnet data found')
    return;
end
if ~exist(dirStrAnalysis)
    mkdir(dirStrAnalysis)
end
filename = [dirStrRawData(end-9:end-1) '_magnetData'];
save([dirStrAnalysis filename],'magData','magDT');


