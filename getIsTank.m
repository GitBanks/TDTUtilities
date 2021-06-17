function [dateOut,indexOut] = getIsTank(date,index)
% this will let us know if we need to take the previous index in a dual
% recording prep
% A few assumptions:
% 1. there are only 'dual' recordings (not triple or more).
% 2. there was video taken.

% these are shakey assumptions, but do apply to all our collected data so
% far (if there's a tank file split)
% examples to test:
% date='21105';
% index='000';
% index='001';
%
dirStrRawDataROOT = [mousePaths.W 'PassiveEphys\']; %'W' drive
dirStrRawData = [dirStrRawDataROOT '20' date(1:2) '\' date '-' index '\'];
dirCheck = dir(dirStrRawData);

%spare us from effort if it's already the correct directory
if ~isempty(dir([dirStrRawData '*_Cam1*']))
    dateOut = date;
    indexOut = index;
    return
end

%establish a hypothetical earlier index
tempIndex = str2double(index)-1;
if length(num2str(tempIndex)) < 2
    tempIndex = ['00' num2str(tempIndex)];
else
    tempIndex = ['0' num2str(tempIndex)];
end
blockLocation = [dirStrRawDataROOT '20' date(1:2) '\' date '-' tempIndex '\'];

% first, make sure it exists
if isempty(dirCheck)
    mkdir(dirStrRawData);
    dirCheck = dir(dirStrRawData);
end
% in this case it's only the directory.  We need the video file from
% (hopefully) the tank directory
if size(dirCheck,1)==2 || isempty(dir([dirStrRawData '*_Cam2*']))
    prevIndexDirCheck = dir(blockLocation);
    if isempty(prevIndexDirCheck) % if this is true, we've really derailed somewhere.  stop here.
        error('previous index doesn''t exist - something is wrong');
    end
    %dir([blockLocation '*_Cam*']);
    vidFileDir = dir([blockLocation '*_Cam2*']);
    if isempty(vidFileDir)
        error(['If you''re reading this message, the _Cam2 video file is missing from ' blockLocation])
    end
    vidFileName = vidFileDir.name;
    tank_Cam2_name = [blockLocation vidFileName];
    if isfile(tank_Cam2_name)
        copy_Cam2_name = [dirStrRawData vidFileName];
        copyfile(tank_Cam2_name,copy_Cam2_name); 
        disp([tank_Cam2_name ' copied to ' copy_Cam2_name]);
        tempCheckD = dir(copy_Cam2_name); %fileDest
        tempCheckS = dir(tank_Cam2_name); %fileSource
        if tempCheckS.bytes == tempCheckD.bytes
            delete(tank_Cam2_name); %maybe we don't want to delete? add toggle?
        end
    end
end

if ~isempty(dir([dirStrRawData '*_Cam2*']))
    dateOut = date;
    indexOut = tempIndex;
else
    error('at this point something has gone wrong - we can''t find the tank file');
end


end

    

            













