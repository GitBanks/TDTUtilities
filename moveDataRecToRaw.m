function moveDataRecToRaw(dirStrRecData,dirStrRawData)
% just move all named recorded files to our secure raw data server, with a
% bit of verification and cleanup

if exist(dirStrRecData,'dir') == 7
    recDataDir = dir(dirStrRecData);
else
    display('recording folder can not be found.  Check connection to remote computer, and existence of folder');
    return;
end

if ~exist(dirStrRawData,'dir')
    mkdir(dirStrRawData);
end
for iFile = 1:length(recDataDir)
    if ~recDataDir(iFile).isdir
        fileSource = [dirStrRecData recDataDir(iFile).name];
        fileDest = [dirStrRawData recDataDir(iFile).name];
        if recDataDir(iFile).bytes > 0
            copyfile(fileSource,fileDest);
        else
            warning([recDataDir(iFile).name ' is size 0!']);
            copyfile(fileSource,fileDest);
        end
        tempCheckD = dir(fileDest);
        tempCheckS = dir(fileSource);
        if tempCheckS.bytes == tempCheckD.bytes
            delete(fileSource); %maybe we don't want to delete? add toggle?
        end
    end
end

% only if the folder is empty, remove it so it's not counted in fileMaint
s = dir(dirStrRecData);
name = {s.name};
isdir = [s.isdir] & ~strcmp(name,'.') & ~strcmp(name,'..');
subfolder = fullfile(path, name(isdir));
if sum([s(~isdir).bytes cellfun(@dirsize, subfolder)]) == 0
    [~,msg] = rmdir(dirStrRecData);
    disp([msg ' in ' dirStrRecData]);
end


