function plotPlasticityDuringQuiescence(animal,subset)


%Run this from ephysAnalysisScript so we can get the peakData save file
%this is the user selction of the peaks - make sure to clear all after
%Run this to decide the peaks and the peak amps
exptDate = '22111';
exptIndices = {'002','005','007'};
description = '';
plotPlasticityAmplitudePeaks(exptDate,exptIndices,description)


%chose animal
animal = 'ZZ14'; 

%Define the subset of experiment days to use
subset = {'22104'}; 

%Create a table out of the experiment list which is called from exptPlasticitySet
[~,exptTable] = getExptPlasticitySetByAnimal(animal);


%We now want to make a table that pulls data from indices from the dates we give it
exptSubTable = exptTable(contains(exptTable.DateIndex,subset(:)),:);
exptSubTable = exptSubTable(exptSubTable.preLTP == true | exptSubTable.postLTP == true | exptSubTable.postLTD == true,:);

%These are the descriptions for the indices will be useful during the
%plotting portion- you will need to write out ALL the indices regardless of
%whether you will plot them or not bc this is how we determine size of nIndex

indexStepDescription = {'Baseline','post LTP'};


%quick grab unique dates- we have to do this because there are multiple
%indices in a day and so we need to make each index a unique index so its
%read in
for i=1:size(exptSubTable,1)
    dateList{i} = char(exptSubTable.DateIndex(i));
    dateList{i} = dateList{i}(1:5);
end
uniqueDates = unique(dateList);


%%% ==========================================================================
%Pulling data and plotting for evokoed peak responses during
%quiescense

% 1) Pull the evoked peak response data from the getPeakSlopeAvgByDate script- we will
% just apply to ecdf function in the plot itself
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

% What is the threshold?

threshold = (dataOut.date.expt(1).data.threshold);

% 2) Plotting Peak IPSI evoked response 

figure();
subplot(2,3,[1,3]);
ourIndex = 1;
  for iExptDate = 1:nExpts
    for iExptIndex = 1:nIndex
        disp("loop")
        ecdf(dataOut.date(iExptDate).expt(iExptIndex).data.restingPeaksIPSI(1,:));
        if iExptDate == 1; title(['eCDF of IPSI Peak Evoked Response During Quiesensce' animal subset ]); end
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
  
% 2) Plotting Peak vCA1 evoked Response
figure();
subplot(2,3,[1,3]);
ourIndex = 1;
  for iExptDate = 1:nExpts
    for iExptIndex = 1:nIndex
        disp("loop")
        ecdf(dataOut.date(iExptDate).expt(iExptIndex).data.restingPeaksVCA1(1,:));
        if iExptDate == 1; title(['eCDF of IPSI Peak Evoked Response During Quiesensce' animal subset ]); end
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
    
%%% =======================================================
%Plotting a histogram of all movement values 

% 1) Make Histograms - be sure to adjust the index to plot out correct
% index if more than 1 LTP protocol was run in a day

subplot(2,3,4);
  for iExptDate = 1:nExpts
    for iExptIndex = 1
        edges = linspace(0, 1.5, 101);  
        x = dataOut.date(iExptDate).expt(iExptIndex).data.totalMovementValues(1,:);
        %[N,edges,bin]=histcounts(x);
        %x = dataOut.date(iExptDate).expt(iExptIndex).data.restingValues(1,:)
        histogram(x, 'BinEdges', edges);
        grid on;
        title(['Movement Distribution During ' indexStepDescription{1}]);
        ylabel('Frequency');
        xlabel('Amplitude of Movement');
        xticks(0:.2:1.5);
        xlim([0,1.5]);
        xline(threshold)
        ylim([0,275]);
        drawnow;
    end
  end

subplot(2,3,5);
  for iExptDate = 1:nExpts
    for iExptIndex = 2
        edges = linspace(0, 1.5, 101);
        x = dataOut.date(iExptDate).expt(iExptIndex).data.totalMovementValues(1,:);
        %[N,edges,bin]=histcounts(x);
        %x = dataOut.date(iExptDate).expt(iExptIndex).data.restingValues(1,:), 'FaceColor', '#D95319'
        histogram(x, 'BinEdges', edges, 'FaceColor', '#D95319');
        grid on;
        title(['Movement Distribution ' indexStepDescription{2}]);
        ylabel('Frequency');
        xlabel('Amplitude of Movement');
        xticks(0:.2:1.5);
        xlim([0,1.5]);
        xline(threshold)
        ylim([0,275]);
        drawnow;
    end
  end

  
subplot(2,3,6);
  for iExptDate = 1:nExpts
    for iExptIndex = 3
        edges = linspace(0, 1.5, 101);
        x = dataOut.date(iExptDate).expt(iExptIndex).data.totalMovementValues(1,:);
        %[N,edges,bin]=histcounts(x);
        %x = dataOut.date(iExptDate).expt(iExptIndex).data.restingValues(1,:)
        histogram(x, 'BinEdges', edges,'FaceColor', '#EDB120');
        grid on;
        title(['Movement Distribution 'indexStepDescription{3}]);
        ylabel('Frequency');
        xlabel('Amplitude of Movement');
        xticks(0:.2:1.5);
        xlim([0,1.5]);
        xline(threshold)
        ylim([0,275]);
        drawnow;
    end
  end
  
  
%   subplot(2,4,8);
%   for iExptDate = 1:nExpts
%     for iExptIndex = 4
%         edges = linspace(0, 1.5, 101);  
%         x = dataOut.date(iExptDate).expt(iExptIndex).data.totalMovementValues(1,:);
%         %[N,edges,bin]=histcounts(x);
%         %x = dataOut.date(iExptDate).expt(iExptIndex).data.restingValues(1,:)
%         histogram(x, 'BinEdges', edges, 'FaceColor', '#7E2F8E');
%         grid on;
%         title(['Movement Distribution During LTP2']);
%         ylabel('Frequency');
%         xlabel('Amplitude of Movement');
%         xticks(0:.2:1.5);
%         xlim([0,1.5]);
%         xline(threshold)
%         ylim([0,275]);
%         drawnow;
%     end
%   end

  
%   subplot(2,5,10);
%   for iExptDate = 1:nExpts
%     for iExptIndex = 6
%         edges = linspace(0, 1.5, 101);  
%         x = dataOut.date(iExptDate).expt(iExptIndex).data.totalMovementValues(1,:);
%         %[N,edges,bin]=histcounts(x);
%         %x = dataOut.date(iExptDate).expt(iExptIndex).data.restingValues(1,:)
%         histogram(x, 'BinEdges', edges);
%         grid on;
%         title(['Movement Distribution During Baseline']);
%         ylabel('Frequency');
%         xlabel('Amplitude of Movement');
%         xticks(0:.2:1.5);
%         xlim([0,1.5]);
%         xline(threshold)
%         ylim([0,275]);
%         drawnow;
%     end
%   end


  
 
  end
  
   