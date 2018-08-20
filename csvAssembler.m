function csvAssembler(date,index,nStimTypes,nTrialsPerStim)
% This creates a randomized sequence in the format accepted by Synapse, of  
% nStimTypes number of stims and nTrialsPerStim number of trials per stim.  
% e.g., with 5 unique stims and 100 presentations of each, it will create a 
% list of these 500, shuffle them, and write them to the expected folder 
% with the name {date}-{index}

%date = '18711';
%index = '000';
%nStimTypes = 5
%nTrialsPerStim = 100

[date,index] = fixDateIndexToFiveForSynapse(date,index);

%taken from the Synapse csv format
textA = 'Seq-1'; %will we have multiple sequences?  change if so.
textB = 'Idx-';
textC = 'Row-';
fileName = ['\\Anesbl2\C\TDT\Synapse\ParFiles\' date '-' index '.seq.csv'];

sequenceCellArray = cell(nStimTypes*nTrialsPerStim+1,2);
trialPattern = createTrialPattern(nStimTypes,nTrialsPerStim);
%sequenceCellArray{1,2} = textA;

fid = fopen(fileName,'w');
fprintf(fid, '%s\n',[',' textA]);


for iTrial = 2:length(trialPattern)+1
    %sequenceCellArray{iTrial,1} = [textB num2str(iTrial-1)];
    %sequenceCellArray{iTrial,2} = [textC num2str(trialPattern(iTrial-1))];
    fprintf(fid, '%s\n', [textB num2str(iTrial-1) ',' textC num2str(trialPattern(iTrial-1))]) ;
end

% fprintf(fid, '%s,',[',' textA]);
% fprintf(fid, '%s\n', sequenceCellArray{2:end,:}) ;
fclose(fid) ;




%xlswrite(fileName,sequenceCellArray);
%writetable(sequenceCellArray,fileName)



