function createArbitraryStimForMCStim(date,index,frequency,nPulses,magnitude,frequency2,nPulses2,magnitude2)
% This creates a randomized sequence in the format accepted by Multi Channel Systems MC_Stimulus II, of  
% stimArray number of stims and nTrialsPerStim number of trials per stim.  
% e.g., with 5 unique stims and 100 presentations of each, it will create a 
% list of these 500, shuffle them, and write them as the appropriate .dat file 
% with the name {date}-{index}
% Calls:
% [date,index] = fixDateIndexToFiveForSynapse(date,index);
% trialPattern = createTrialPattern(nStimTypes,nTrialsPerStim);

%date = '21309';
%index = '001';
%frequency = 250; %Hz
%nPulses = 50
%magnitude = '150';

%TBS protocol
%date = '';
%index = '';
%frequency = 400;
%nPulses = 6;
%magnitude = '80% of maximal response from stim resp';

if ~ischar(magnitude)
    magnitude = num2str(magnitude);
end
if ~ischar(magnitude2)
    magnitude2 = num2str(magnitude2);
end
%nTrialsPerStim = 20;
%stimArray = [50,100,150,200,300,400,500,600];
%must make a stim in MC to correspond with the above stims
%stimArray = [10,50,100,200,300,400,500,600,700,-10,-50,-100,-200,-300,-400,-500,-600,-700];
[date,index] = fixDateIndexToFiveForSynapse(date,index);

%fileName = ['\\Banksrig\c\Users\Ziyad Sultan\Documents\Multi Channel Systems\' date '-' index '.xls']; %BAD BAD BAD HARDCODING
%IMPORTANT: fopen or Windows permissions to Matlab DO NOT like it when you
%try to address this thorough the network.  If we ever run this on a remote
%computer there will be trouble when switching to the format above.
%fileName = ['C:\Users\Ziyad Sultan\Documents\Multi Channel Systems\' date '-' index '.dat']; %can only be run from gilgamesh C drive hardcoded
fileName = ['C:\Users\banksadmin\Documents\Multi Channel Systems\' date '-' index '.dat']; %can only be run from gilgamesh C drive hardcoded
%fileName = ['\\NESSUS\Users\LabRat\Documents\Multi Channel Systems\' date '-' index '.dat']; %BAD BAD BAD HARDCODING
%trialPattern = createTrialPattern(length(stimArray),nTrialsPerStim);

[fid errMsg]= fopen(fileName,'w');
if ~isempty(errMsg)
   error(['Error writing file!! '  errMsg ]) ;
end


% ===this section is for the 'header'===
% fprintf(fid, '%s\n',[',' textA]);
fprintf(fid, '%s\n','Multi Channel Systems MC_Stimulus II');
fprintf(fid, '%s\n','ASCII import Version 1.10');
fprintf(fid, '%s\n','channels: 2');
fprintf(fid, '%s\n','');
fprintf(fid, '%s\n','output mode: current');
fprintf(fid, '%s\n','');
fprintf(fid, '%s\n','format: 4');
fprintf(fid, '%s\n','');
fprintf(fid, '%s\n','channel: 1');
fprintf(fid, '%s\n','');
fprintf(fid, '%s\n','value	time');

% the change in time = (1/frequncy) * (conversion to microseconds) - (duration of stimulus)%
dT = num2str((1/frequency)*1000000-300);

% ===This section is for the sequence===.
%for iTrial = 2:length(trialPattern)+1
fprintf(fid, '%s\n', '0  40');
for ii = 1:nPulses
    fprintf(fid, '%s\n', [magnitude ' 100']);
    fprintf(fid, '%s\n', '0 100');
    fprintf(fid, '%s\n', ['-' magnitude ' 100']);
    fprintf(fid, '%s\n', ['0 ' dT]);
end
fprintf(fid, '%s\n', '0 40');



if exist('frequency2','var')%,nPulses2,magnitude2
    fprintf(fid, '%s\n','');
    fprintf(fid, '%s\n','channel: 2');
    fprintf(fid, '%s\n','');
    fprintf(fid, '%s\n','value	time');
    dT2 = num2str((1/frequency2)*1000000-300);
    fprintf(fid, '%s\n', '0  40');
    for ii = 1:nPulses2
        fprintf(fid, '%s\n', [magnitude2 ' 100']);
        fprintf(fid, '%s\n', '0 100');
        fprintf(fid, '%s\n', ['-' magnitude2 ' 100']);
        fprintf(fid, '%s\n', ['0 ' dT2]);
    end
    fprintf(fid, '%s\n', '0 40');
end

% fileName
% saveFileRoot = ['W:\Data\PassiveEphys\20' date(1:2) '\' date '-' index '\'];
% if ~exist(saveFileRoot,'dir')
%     mkdir(saveFileRoot);
%     disp(['making dir: ' saveFileRoot]);
% end
% save([saveFileRoot  'stimSet-' date '-' index],'stimArray','trialPattern');

% HERE TODO also save the pattern so we can sort the stims / analyze these data

fclose(fid) ;
