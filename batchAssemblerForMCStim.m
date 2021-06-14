function batchAssemblerForMCStim(date,index)
% This creates a randomized sequence in the format accepted by Multi Channel Systems MC_Stimulus II, of  
% stimArray number of stims and nTrialsPerStim number of trials per stim.  
% e.g., with 5 unique stims and 100 presentations of each, it will create a 
% list of these 500, shuffle them, and write them as the appropriate .dat file 
% with the name {date}-{index}
% Calls:
% [date,index] = fixDateIndexToFiveForSynapse(date,index);
% trialPattern = createTrialPattern(nStimTypes,nTrialsPerStim);

%date = '21601';
%index = '002';
nTrialsPerStim = 30;
stimArray = [200,300,400,500,600,700];
%stimArray =  {'200-200','300-300','400-400','500-500','600-600'};
%stimArray =  {'300-300'};

%must make a stim in MC to correspond with the above stims
%stimArray = [10,50,100,200,300,400,500,600,700,-10,-50,-100,-200,-300,-400,-500,-600,-700];
[date,index] = fixDateIndexToFiveForSynapse(date,index);

%fileName = ['\\Banksrig\c\Users\Ziyad Sultan\Documents\Multi Channel Systems\' date '-' index '.xls']; %BAD BAD BAD HARDCODING
%IMPORTANT: fopen or Windows permissions to Matlab DO NOT like it when you
%try to address this thorough the network.  If we ever run this on a remote
%computer there will be trouble when switching to the format above.
fileName = ['C:\Users\Ziyad Sultan\Documents\Multi Channel Systems\' date '-' index '.stb'];
%fileName = ['\\NESSUS\Users\LabRat\Documents\Multi Channel Systems\' date '-' index '.stb']; %BAD BAD BAD HARDCODING
trialPattern = createTrialPattern(length(stimArray),nTrialsPerStim);

[fid errMsg]= fopen(fileName,'w');
if ~isempty(errMsg)
   error(['Error writing file!! '  errMsg ]) ;
end

fprintf(fid, '%s\n',['Multi Channel Systems MCS MC_Stimulus']);
fprintf(fid, '%s\n',['Batch Control File']);
fprintf(fid, '%s\n',['Version 1.00']);

for iTrial = 1:length(trialPattern)
    fprintf(fid, '%s\n', ['C:\Users\Ziyad Sultan\Documents\Multi Channel Systems\SINGLEpulseRange\' num2str(stimArray(trialPattern(iTrial))) '.stm']);
    %fprintf(fid, '%s\n', ['C:\Users\Ziyad Sultan\Documents\Multi Channel Systems\DUALpulseRange\' stimArray{trialPattern(iTrial)} '.stm']);

end

saveFileRoot = ['W:\Data\PassiveEphys\20' date(1:2) '\' date '-' index '\'];
if ~exist(saveFileRoot,'dir')
    mkdir(saveFileRoot);
    disp(['making dir: ' saveFileRoot]);
end
save([saveFileRoot  'stimSet-' date '-' index],'stimArray','trialPattern');

% HERE TODO also save the pattern so we can sort the stims / analyze these data

fclose(fid) ;
