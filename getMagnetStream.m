

%dirStrRawData='W:\Data\PassiveEphys\2019\19o31-000\';
dirStrRawData='W:\Data\PassiveEphys\2019\19n08-002\';

%dirStrRawData='W:\Data\PassiveEphys\2019\19o29-001\';
%dirStrAnalyzedData='M:\PassiveEphys\2019\19o29-001\19o25-001-movementBinary';

% dirStrRawData='W:\Data\PassiveEphys\2019\19o31-magnetTest\';

% dirStrRawData='W:\Data\PassiveEphys\2019\19o25-002\';
% dirStrAnalyzedData='M:\PassiveEphys\2019\19o25-002\19o25-002-movementBinary';
data = TDTbin2mat(dirStrRawData);

% magnetData = data.streams.mag1.data;
% magnetdt = 1/data.streams.mag1.fs;
% magnetfs = data.streams.mag1.fs;
magnetData = data.streams.mag2.data;
magnetdt = 1/data.streams.mag2.fs;
magnetfs = data.streams.mag2.fs;

timeS = zeros(1,length(magnetData));

for iTimes = 2:length(timeS)
   timeS(iTimes) = timeS(iTimes-1)+magnetdt;
end

oneSecWin = find(timeS>1,1);


% 
% a = data.streams.EEG2.data;
% freqRange = [.1,200];
% fNyquist = data.streams.EEG2.fs/2;
% [b_BP, a_BP] = butter(1, [freqRange(1)/fNyquist freqRange(2)/fNyquist]);
% b = filtfilt(b_BP,a_BP,a(1,:));
% 
% figure();plot(a(1,:));hold on;plot(b);
% 
% figure();
% z = periodogram(b(1,:),[],[],data.streams.EEG2.fs);
% loglog(z);
% xlim([0,200]);

% %plot a short window
% timeStart = 15;
% timeEnd = 16;
% %sample window
% sWin = [find(timeS>timeStart,1),find(timeS>timeEnd,1)];
% figure();
% plot(timeS(sWin(1):sWin(2)),magnetData(sWin(1):sWin(2)));






load(dirStrAnalyzedData);


%filter
Fnorm = 130/(magnetfs/2);           % Normalized frequency
df = designfilt('lowpassfir','FilterOrder',70,'CutoffFrequency',Fnorm);
grpdelay(df,2048,magnetfs)   % plot group delay
D = mean(grpdelay(df));
magnetDataX = filter(df,[magnetData'; zeros(D,1)]);
magnetDataX = magnetDataX(D+1:end);
figure();



timeX = duration(minutes(timeS/60),'format','mm:ss');

plot(timeX,magnetData);
hold on
plot(timeX,magnetDataX);



procMagnet = abs(smooth(magnetDataX,round(oneSecWin/2),'sgolay'));
procMagnet = smooth(procMagnet);
procMagnetZ = envelope(procMagnet,oneSecWin*2,'rms');


figure();
plot(frameTimeStampsAdj,finalMovementArray);
hold on
plot(timeX,procMagnetZ*1000);



%HTR stuff

bpFilt = designfilt('bandpassfir','FilterOrder',80, ...
         'CutoffFrequency1',40,'CutoffFrequency2',200, ...
         'SampleRate',magnetfs);
% bpFilt = designfilt('bandpassiir','FilterOrder',200, ...
%          'HalfPowerFrequency1',60,'HalfPowerFrequency2',160, ...
%          'SampleRate',magnetfs);
grpdelay(bpFilt,2048,magnetfs)   % plot group delay
D = mean(grpdelay(bpFilt));
magnetDataHTR = filter(bpFilt,[magnetData'; zeros(D,1)]);
magnetDataHTR = bandstop(magnetDataHTR,[103,106],magnetfs);

magnetDataHTR = magnetDataHTR(D+1:end);


freqRange = [40,200];
fNyquist = magnetfs/2;
[b_BP, a_BP] = butter(1, [freqRange(1)/fNyquist freqRange(2)/fNyquist]);
filtData = filtfilt(b_BP,a_BP,magnetDataHTR);


figure();
plot(timeX,magnetData);
hold on
plot(timeX,filtData);


% %plot a short window
% timeStart = 578;
% timeEnd = 582;
% timeStart = 698;
% timeEnd = 700;
% %sample window
timeStart = 1891;
timeEnd = 1911;

timeStart = 31:30;
timeEnd = 31:40;
sWin = [find(timeS>timeStart,1),find(timeS>timeEnd,1)];
figure();
plot(timeS(sWin(1):sWin(2)),magnetDataHTR(sWin(1):sWin(2)));





figure();
periodogram(filtData,[],[],magnetfs);
xlim([0,.2]);







% % % notes

% [pxx,f]= periodogram(magnetData,[],[],magnetfs);
% figure();
% plot(f,pxx);
% ylim([0,.2e-8]);
% xlim([0,400]);


%xcorr

%magnetData

%find 104.7
% 
% figure();
% spectrogram(magnetData,oneSecWin,[],[],magnetfs);
% xlim([0,.2]);

