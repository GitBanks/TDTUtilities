function plotPlasticityDuringQuiescence(animal,subset)

%chose animal
%animal = 'ZZ13'; 

%Define the subset of experiment days to use
%subset = {'21n30'};

%Create a table out of the experiment list which is called from exptPlasticitySet
[~,exptTable] = getExptPlasticitySetByAnimal(animal);


%We now want to make a table that pulls data from indices from the dates we give it
exptSubTable = exptTable(contains(exptTable.DateIndex,subset(:)),:);
exptSubTable = exptSubTable(exptSubTable.preLTP == true | exptSubTable.postLTP == true | exptSubTable.postLTD == true,:);

%These are the descriptions for the indices will be useful during the
%plotting portion
indexStepDescription = {'pre LTP','post LTP','post LTD'};


%quick grab unique dates- we have to do this because there are multiple
%indices in a day and so we need to make each index a unique index so its
%read in
for i=1:size(exptSubTable,1)
    dateList{i} = char(exptSubTable.DateIndex(i));
    dateList{i} = dateList{i}(1:5);
end
uniqueDates = unique(dateList);

%Pull the evoked peak response data from the appropriate script- we will
%just apply to ecdf function in the plot itself
nExpts = size(uniqueDates,1);
nIndex = size(indexStepDescription,2);
ourIndex = 1;
for iExptDate = 1:nExpts 
    for iExptIndex = 1:nIndex
        thisDate = char(exptSubTable.DateIndex(ourIndex));
        thisIndex = thisDate(7:9);
        thisDate = thisDate(1:5);
        [dataOut.date(iExptDate).expt(iExptIndex).data] = getPeakSlopeAvgByDateIndexWPlot(thisDate,thisIndex);
        ourIndex = ourIndex+1;
   end
end



%%% =======================================================
%Plotting Section


figure();
ourIndex = 1;
  for iExptDate = 1:nExpts
    for iExptIndex = 1:nIndex
        disp("loop")
        ecdf(dataOut.date(iExptDate).expt(iExptIndex).data.restingPeaksIPSI(1,:));
        if iExptDate == 1; title(['eCDF of IPSI Peak Evoked Response During Quiesensce']); end
        hold on;
        if iExptDate == nExpts
            ylabel('Probability');
            xlabel('Amplitude of Response');
            legend(indexStepDescription,'Location','southeast'); 
        end
           drawnow;
           ourIndex = ourIndex+1;
    end
  end
  
   