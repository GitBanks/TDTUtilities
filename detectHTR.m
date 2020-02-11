% code adapted from:
% de la fuente Revenga, M., Shin, J. M., Vohra, H. Z., Hideshima, K. S., 
% Schneck, M., Poklis, J. L., & González-Maeso, J. (2019). Fully automated 
% head-twitch detection system for the study of 5-HT 2A receptor pharmacology 
% in vivo. Scientific reports, 9(1), 1-14.

%% Script for the automated detection of head-twitch events %%

% The scripts run on a variable named 'data' contained in a MATLAB file
% named "data.mat"
fileName = 'M:\PassiveEphys\2019\19n08-003\19n08-003_magnetData.mat';
% load('data.mat') % Load the file, variable should appear in the workspace
load(fileName);
Fs = 1/magDT; % Sampling frequency of the recorded session, i.e. 1000 data points per second.
data = double(magData);

%% Defining processing and detection parameters

% Fractioning
frac = 15; % Fraction (in minutes) for each bin reported. The HTR detection will be devided in fractions of "frac" duration

% Band-pass filter parameters
bpL = 70; % Lower limit of the band-pass filter (Hz)
bpH = 110; % Higher limit of the band-pass filter (Hz)

% HTR detection parameters
nSD = 15; % Number of standard deviations (SD) for threshold (multiplier)
Ttv = 0.075; % Top threshold value (V)
mpd = 200; % Minimum distance between events (ms)
Mpw = 90; % Maximum width of an event (ms)

%% Applying a Butterworth band-pass filter to the raw data

f_high = designfilt('bandpassiir','FilterOrder',20, ...
    'HalfPowerFrequency1',bpL,'HalfPowerFrequency2',bpH, ...
    'SampleRate',Fs); % Butterworth band-pass filter
data_h = filtfilt(f_high,data); % Band-passing the raw data

%% Baseline correction and tranformation to absolute values

Mh = mean(data_h); % Mean of filtered data
data_h = data_h - Mh; % Approaching the baseline to an average of 0
absh = abs(data_h); % Absolute value transformation

%% Setting the threshold

sd = std(data_h); % SD of the band-passed data

if sd * nSD > Ttv % Conditional for setting the value of the threshold
    threshold = Ttv; % Top threshold value for datasets with higher SD
else
    threshold = sd * nSD; % Threshold set to n-fold SD (datasets with lower SD)
end

%% Unconditional detection of local maxima

[pksh,loch] = findpeaks(absh); % Prominence of local maxima stored in "pksh", their time indeces are stored in "loch"

%% Conditional detection of local maxima for identification of HTR events

[pksh2,loch2,wh2] = findpeaks(pksh,loch,'MinPeakHeight',threshold,'MinPeakDist',mpd,'MaxPeakWidth',Mpw); % Prominence, time position and width of local maxima --applied over the previous local maxima detection-- stored if the detection parameters are met. In other words, if a HTR event is detected.
% "pksh2" contains the prominence (V) of each HTR event detected
% "loch2" contains the time (ms) of occurrence of each HTR event detected.
% This are the timestamps used for matching visually identified events or
% piezo sensor annotated maxima
% "wh2" contains the width (ms) of each HTR event detected

%% Reporting HTR detection count

% Total count
totalHTR = length(loch2); % "totalHTR" contains the total count of HTR events in the whole session

% Fractioned count
bins = length(data)/(frac*60*Fs);
[countsxfrac,edgesxfrac] = histcounts(loch2,bins); countsxfrac = countsxfrac'; % "countsxfrac" contains the fractioned count of HTR in fractions of length defined by the value "frac"