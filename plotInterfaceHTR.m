function plotInterfaceHTR
% this is a cute interface for selecting different conditions from a
% curated list.  From that list the user can select a drug to add to a
% comparison table.  User can also toggle if they want to reload the drug
% condition.  This is just written for HTR.
% default configurations
S.thisFile = getPathGlobal('banksLocalHTRData');
S.binSize = 5;
S.nPlots = 1;
edges = round(-60:S.binSize:60);
S.allCenters = edges+(S.binSize/2);
S.allCenters = S.allCenters(1:end-1);
S.allCounts = nan(10,size(S.allCenters,2));
S.fhPlot = figure('units','pixels',...
    'position',[200 200 1200 500]);
S.fhControls = figure('units','pixels',...
    'position',[100 100 350 100],...
    'menubar','none',...
    'numbertitle','off',...
    'name','Experiment Day Setup',...
    'resize','off');  
% S.thisFile = getPathGlobal('banksLocalHTRData');
opts = detectImportOptions(S.thisFile);
% opts = setvartype(opts, "RecordingID", 'string');
S.workingTable = readtable(S.thisFile,opts);
S.Preselects = unique(S.workingTable.exptGroupName);
[S] = refreshControls(S);
uiwait(S.fhControls);  % everything set up now. wait for button pushes or exit.
% END OF PROGRAM %



function [S] = plotNow(varargin)
S = varargin{3};
% grab values from the interface
groupName = S.Preselects{get(S.bGroupSelect,'Value')};
groupSet = S.workingTable(contains(S.workingTable.exptGroupName,groupName),:);
groupSet = groupSet(~isnan(groupSet.exptGroup),:);
groupID = groupSet.exptGroup(1);
rerun = get(S.bRerun,'Value'); % implement this later?
displayEachAnimal = get(S.bDispEach,'Value');
displaySummary = false;
[avgCenters,avgCounts,avgSTD] = getPlotHTRBinnedAvgByGroup(groupID,S.thisFile,displayEachAnimal,S.binSize,displaySummary);
[~,placeHere] = intersect(S.allCenters,avgCenters);
% now calculate standard error
nMice = size(groupSet,1);
err = avgSTD/sqrt(nMice);
% need to track error for distinct sets, too
S.allCounts(S.nPlots,placeHere) = avgCounts;
S.allErr(S.nPlots,placeHere) = err;
S.ErrCenters(S.nPlots,placeHere) = avgCenters;
disp(['Running: ' groupName]);
fullLegendText = [groupName ' nMice=' num2str(nMice)];
S.allTreatments{S.nPlots} = fullLegendText;
currentCenters = S.ErrCenters(1:S.nPlots,:);
% currentCenters currently doesn't match the bar plot splits (as we add
% more data, the error stays in the center)
% let's try to make some offsets
stepSize = S.binSize;
offsetVal = stepSize/S.nPlots*.8


currentPlot = S.allCounts(1:S.nPlots,:);
currentErr = S.allErr(1:S.nPlots,:);

figure(S.fhPlot);
bar(S.allCenters,currentPlot);

% need to fix the offset vals above to get the error bars to align
% correctly
% hold on
% er = errorbar(currentCenters,currentPlot,currentErr);
% er.Color = [0 0 0];                            
% er.LineStyle = 'none';
% hold off

% title([treatment ' n=' num2str(size(S,2))]);
xlabel('min (5 min bins)');
ylabel('Average HTR');
legend(S.allTreatments);
S.nPlots = S.nPlots+1;
[S] = refreshControls(S);


function [S] = refreshControls(varargin)
S = varargin{1};
figure(S.fhControls);
% this creates a pulldown list from the unique entries in workingTable
S.bGroupSelect = uicontrol('style','pop',...
    'unit','pix',...
    'position',[10 50 120 30],...
    'string',S.Preselects); 
S.bRerun = uicontrol('style','radiobutton',...
    'unit','pix',...
    'position',[140 50 55 30],...
    'string','rerun'); 
S.bDispEach = uicontrol('style','radiobutton',...
    'unit','pix',...
    'position',[140 14 80 30],...
    'string','see each animal'); 
S.bPlotNow = uicontrol('style','push',...
    'unit','pix',...
    'position',[200 50 120 30],...
    'string','add to plot',... 
    'callback',{@plotNow,S});


