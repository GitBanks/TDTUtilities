function [filtData] = filterData_dbVer(data,HP,LP,dT)
% Filter the data with low-pass, high-pass or 60 Hz notch filter.
% Butter determines the coefficients used in a second order filter
% implemented by filtfilt.
% The second parameter of butter is normalized to the Nyquist frequency =
% sampling freq divided by 2.
%
% *** NOTE: We assume dT is in seconds ***
%
% note assumed structure of data:
[nChans,nPts] = size(data);
filtData = zeros(size(data));
fNyquist = 0.5/dT;
if LP>0 && HP>0 %bandpass filter
    if HP <= 1 %run as low pass for LFP and CSD 
        [b, a] = butter(2, LP/fNyquist);
    else %band pass
        [b, a] = butter(1, [HP/fNyquist LP/fNyquist]);
%         [b, a] = butter(2, [HP/fNyquist LP/fNyquist]);% this seems to be a better filter NM
    end
elseif LP<=0 && HP<=0 %notch filter
    [b, a] = butter(1, [59, 61]./fNyquist, 'stop');
elseif LP>0 && HP<=0
    [b, a] = butter(2, LP/fNyquist);
elseif HP>0 && LP<=0
    [b, a] = butter(1, HP/fNyquist,'high');
end

for iChan = 1:nChans  
    %filter operates on first non-singleton dimension of data:
    tempdata(1:nPts) = data(iChan,1:nPts);
    tempdata = double(tempdata);
    tempfilt = filtfilt(b,a,tempdata);
    filtData(iChan,:) = tempfilt(1:nPts);
end
