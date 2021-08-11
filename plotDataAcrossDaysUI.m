function plotDataAcrossDaysUI(animalName)

% animalName = 'EEG53';
dbConn = dbConnect();
S.Preselects = unique(fetchAdjust(dbConn,'SELECT paramfield FROM global_stimparams')); 
S.animalName = animalName;
S.fh = figure('units','pixels',...
    'position',[100 100 400 700],...
    'menubar','none',...
    'numbertitle','off',...
    'name','Create plots',...
    'resize','off');
uicontrol('style','text',...
    'units','pix',...
    'position',[10 650 80 30],...
    'string',S.animalName); 
% S.pp = uicontrol('style','pop',...
%     'unit','pix',...
%     'position',[535 650 120 30],...
%     'string',S.Preselects);
uicontrol('style','text',...
    'units','pix',...
    'position',[10 600 150 40],...
    'fontweight','bold',...
    'string','list of expts');
S = listOfDates(S);
uiwait(S.fh);
close(dbConn);

function [S] = listOfDates(varargin)
%setupExptToBeRun sets up experiment for the day based on selection from
%list, then button press
[S] = varargin{1}; % !can't call this as a callback!
S.existingList = getExperimentsByAnimal(S.animalName);
for i = 1:size(S.existingList,1)
    justDates(i,1) = {S.existingList{i,1}(1:5)};
    description(i,1) = S.existingList{i,2};
end
[S.justDates,ia,ic] = unique(justDates);
description = description(ia);
for i = 1:size(S.justDates,1)
    S.uniqueExptDates{i,:} = [S.justDates{i} ': ' description{i}(1:10) '; n=' num2str(sum(ic==i))];
end
S.ls = uicontrol('style','list',...
    'units','pix',...
    'max',20,'min',1,...
    'position',[10 10 290 610],...
    'string', S.uniqueExptDates,...
    'fontsize',10);
S.pb = uicontrol('style','push',...
    'units','pix',...
    'posit',[100 650 80 30],... % we want to overwrite last button (to avoid repeating/changing a list) was% 'posit',[405 650 120 30],
    'string', 'Plot Peaks',...
    'fontsize',10,...
    'callback',{@plotPeaksNow,S});
S.pc = uicontrol('style','push',...
    'units','pix',...
    'posit',[180 650 80 30],... % we want to overwrite last button (to avoid repeating/changing a list) was% 'posit',[405 650 120 30],
    'string', 'Rerun Day',...
    'fontsize',10,...
    'callback',{@rerunPeak,S});
S.pd = uicontrol('style','push',...
    'units','pix',...
    'posit',[260 650 80 30],... % we want to overwrite last button (to avoid repeating/changing a list) was% 'posit',[405 650 120 30],
    'string', 'Plot Day',...
    'fontsize',10,...
    'callback',{@plotSingleDay,S});


function [S] = plotPeaksNow(varargin)
[S] = varargin{3};
S.userDateSelection = get(S.ls,'Value');
subset = S.justDates(S.userDateSelection);
stimRespPeakAnalysisAcrossDaysplotH = stimRespPeakAnalysisAcrossDays(S.animalName,subset);


function [S] = rerunPeak(varargin)
[S] = varargin{3};
S.userDateSelection = get(S.ls,'Value');
workingList = getExperimentsByAnimalAndDate(S.animalName,S.justDates{S.userDateSelection},'stim/resp');
for iList = 1:size(workingList,1)
    evokedStimResp_userInput(workingList{iList,1}(1:5),workingList{iList,1}(7:9));
end

function [S] = plotSingleDay(varargin)
[S] = varargin{3};
S.userDateSelection = get(S.ls,'Value');
sendToSlack = false; 
plotCalculatedPeaks = false; 
plotLog = false; 
workingList = getExperimentsByAnimalAndDate(S.animalName,S.justDates{S.userDateSelection},'stim/resp');
for iList = 1:size(workingList,1)
    plotStimRespByDateIndex(workingList{iList,1}(1:5),workingList{iList,1}(7:9),sendToSlack,plotCalculatedPeaks,plotLog);
end



% M:\PassiveEphys\AnimalData\ZZ10\PeakRespOverTime





% function [S] = addGlobal(varargin)
% [S] = varargin{3};
% S.userDateSelection = get(S.ls,'Value');
% display(['Loading ' S.uniqueExptDates{S.userDateSelection}])
% S.exptByDateList = getExperimentsByAnimalAndDate(S.animalName,S.uniqueExptDates{S.userDateSelection});
% S.indexRange = 1:size(S.exptByDateList,1);
% [S] = updateDisplayList(S);
% 
% 
% S.ep = uicontrol('style','edit',...
%     'unit','pix',...
%     'position',[655 650 120 30],...
%     'string','0');
% S.pb = uicontrol('style','push',...
%     'units','pix',...
%     'posit',[430 650 100 30],... % we want to overwrite last button (to avoid repeating/changing a list) was% 'posit',[405 650 120 30],
%     'string', 'Add This',...
%     'fontsize',10,...
%     'callback',{@addParam,S});
% 
% % S.lsX = uicontrol('style','list',...
% %     'units','pix',...
% %     'position',[460 10 200 610],...
% %     'string', S.listDisplayDetails,...
% %     'fontsize',10);
% 
% function [S] = addParam(varargin)
% [S] = varargin{3};
% userIndexSelection = get(S.lsX,'Value');
% stimParamSelection = get(S.pp,'Value');
% stimValSelection = num2str(get(S.ep,'String'));
% for iList = 1:length(userIndexSelection)
%     newDisplayVal = [S.uniqueExptDates{S.userDateSelection} ' . ' S.exptIndex{userIndexSelection(iList)} ' . ' S.Preselects{stimParamSelection} ' . ' stimValSelection];
%     display(newDisplayVal);
%     setGlobalStimParams(S.uniqueExptDates{S.userDateSelection},S.exptIndex{userIndexSelection(iList)},S.Preselects{stimParamSelection},stimValSelection);
% end
% S.indexRange = userIndexSelection;
% [S] = updateDisplayList(S);
% S.ep = uicontrol('style','edit',...
%     'unit','pix',...
%     'position',[655 650 120 30],...
%     'string','0');
% S.pb = uicontrol('style','push',...
%     'units','pix',...
%     'posit',[430 650 100 30],... % we want to overwrite last button (to avoid repeating/changing a list) was% 'posit',[405 650 120 30],
%     'string', 'Add This',...
%     'fontsize',10,...
%     'callback',{@addParam,S});
% 
% 
% 
% 
% function [S] = updateDisplayList(varargin)
% [S] = varargin{1};
% for i = S.indexRange % if called from addParam, should just be one value.
%     S.exptDesc(i) = S.exptByDateList{i,2};
%     S.exptIndex{i,:} = S.exptByDateList{i,1}(7:9);
%     
%     [nGlobalPars,globalParNames,globalParVals] = getGlobalStimParams(S.uniqueExptDates{S.userDateSelection},S.exptIndex{i}); 
%     
%     
%     S.nGlobalPars{i,:} = nGlobalPars;
%     if isnumeric(S.nGlobalPars{i,:})
%         S.nGlobalPars{i,:} = num2str(S.nGlobalPars{i,:});
%     end
%     parStr = '';
%     for iPars = 1:nGlobalPars
%         if iscell(globalParNames{iPars})
%             S.globalParNames{iPars,i} = S.globalParNames{iPars,i}{1,1};
%         else
%             S.globalParNames{iPars,i} = globalParNames{iPars};
%         end
%         if isnumeric(globalParVals)
%             S.globalParVals{iPars,i} = num2str(globalParVals(iPars));
%         else
%             S.globalParVals{iPars,i} = globalParVals(iPars);
%         end
%         parStr = [parStr ' . ' S.globalParNames{iPars,i} ' . ' S.globalParVals{iPars,i}];
%     end
%     S.listDisplayDetails{i,:} = [S.exptIndex{i} ' . ' S.exptDesc{i} ' . ' S.nGlobalPars{i,:} parStr];
%     display(['loading ' S.exptIndex{i}])
% end
% S.lsX = uicontrol('style','list',...
%     'units','pix',...
%     'max',20,'min',1,...
%     'position',[301 10 470 610],...
%     'string', S.listDisplayDetails,...
%     'fontsize',10);
% 
% 




