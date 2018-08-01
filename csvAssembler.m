function csvAssembler(date,index,nStimTypes,nTrialsPerStim)
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



