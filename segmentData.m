function [segmentedData] = segmentData(signal,dT,nSec,prctOverlap)
% transform input signal into sample points x n trials matrix with overlap

% nSec = 4; % duration of trial in seconds
% prctOverlap = 0.25; % percent overlap between trials

nPts = round(nSec/dT); % number of points in each trial
nPtsOverlap = round((nSec*prctOverlap)/dT); % number of points in overlap

[segmentedData,~] = buffer(signal,nPts,nPtsOverlap,'nodelay'); % segment 1D time vector into nPts x nTrials matrix with nPtsOverlap overlap,
% where nTrials is m = floor((L-n)/(n-p))+1 when opt = 'nodelay'

% second output is partial frame data, which should be ignored...

end