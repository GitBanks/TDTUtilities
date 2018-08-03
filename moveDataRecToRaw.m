function moveDataRecToRaw(dirStrRecData,dirStrRawData)
% just move all files to raw data server
recDataDir = dir(dirStrRecData);
if ~exist(dirStrRawData,'dir')
    mkdir(dirStrRawData);
end
for iFile = 1:length(recDataDir)
    if ~recDataDir(iFile).isdir
        fileSource = [dirStrRecData recDataDir(iFile).name];
        fileDest = [dirStrRawData recDataDir(iFile).name];
        if recDataDir(iFile).bytes > 0
            copyfile(fileSource,fileDest);
        end
        tempCheckD = dir(fileDest);
        tempCheckS = dir(fileSource);
        if tempCheckS.bytes == tempCheckD.bytes
            delete(fileSource); %maybe we don't want to delete? add toggle?
        end
    end
end