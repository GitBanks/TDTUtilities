% given a date and index
% return: magDT, magData
%e.g.: '20213-008'
%dateString = '20213-008'
function [magData,magDT] = HTRMagLoadData(dateString)
        
date = dateString(1:5);
idx = dateString(7:end);
dir_stub = 'M:\PassiveEphys\20'; % **WARNING** hardcoded
magName = '_magnetData.mat';
dirname = [dir_stub date(1:2) '\' dateString '\'];
try
    load([dirname dateString magName]); % loads in magDT and magData
catch why
    disp(['Failed to load ' dirname dateString magName])
    animal = getAnimalByDateIndex(date,idx);
    disp(['Check to make sure file exists, and make sure analysis is done for ' animal]);
    disp(why);
    %keyboard;
end




