function fileMaint_Mag(exptDate,Animal1,Animal2)
% exptDate = '21114';
% Animal1 = 'Mag003';
% Animal2 = 'Mag004';

% 
% 
% 


% TODO
% 1. import raw HTR signals 
%    1/14/21 = 21114-000
%    solved: 'Mag' import
%    TODO find video data
%    TODO find magnet stream
% 2. load them into existing HTR analysis


% move files to M:
try
    fileMaint_dual(Animal1,1);
catch
    warning('this doesn''t make it through spec analysis')
end
try
    fileMaint_dual(Animal2,0);
catch
    warning('this doesn''t make it through spec analysis')
end
disp('            *              ');
disp('Now saving the magnet data.');
disp('            *              ');
% magnet data import
saveMagnetDataFiles(exptDate,Animal1,Animal2);
close all

% run HTR analysis




