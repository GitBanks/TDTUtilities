function [dateOut,indexOut,isTank] = getIsTank(date,index)
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
isTank = true; %default should assume the tank is the index


% spare us from effort if it's already the correct directory
% The first thing the program does is look for video in the recording
% directory we gave it.  If "Cam1" is there, it will exit - assured that
% this is the index with the data files.  BUT, if the camera data is not
% there it will look in the previous folder (i.e., the code after this if
% statement)
if ~isempty(dir([dirStrRawData '*_Cam1*']))
    dateOut = date;
    indexOut = index;
    return
end
disp(['Cam1 data not found in ' dirStrRawData '. This recording is not the tank keeper.  Loading previous index for tank.']);

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
        disp(' ');
        disp(['If you''re seeing this message ' date ' and index ' index ' may not be the first in the datafile']);
        disp('Please check which animal was run on the preceeding index and import that data first.');
        disp('It will be the animal associated with this file location: ');
        disp(blockLocation);
        disp('This error happens when there''s nothing in that location ');
        disp('or it''s a bogus location like -1');
        disp('It''s also possible video was not recorded.');
        disp('This program was designed assuming the video files need to be sorted into their respective directories.')
        % ['previous index ' blockLocation ' doesn''t exist - something is wrong.  Was video recorded?  Please check this directory for data.' ]%
        error('^^ PLESE READ THE MESSAGE ABOVE ^^');
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
    error(['at this point something has gone wrong - we can''t find the tank file for ' date '-' index ]);
end


if ~contains(index,indexOut)
    isTank = false;
end


end

    

            













