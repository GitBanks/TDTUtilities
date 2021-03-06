function manuallySetGlobalParamUI(animalName)

% animalName = 'EEG53';


dbConn = dbConnect();
S.Preselects = unique(fetch(dbConn,'SELECT paramfield FROM global_stimparams')); 
S.animalName = animalName;
S.fh = figure('units','pixels',...
    'position',[100 100 1050 700],...
    'menubar','none',...
    'numbertitle','off',...
    'name','Audit experiment parameters',...
    'resize','off');
uicontrol('style','text',...
    'units','pix',...
    'position',[10 650 80 30],...
    'string',S.animalName); 
S.pp = uicontrol('style','pop',...
    'unit','pix',...
    'position',[535 650 120 30],...
    'string',S.Preselects);


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
end
S.uniqueExptDates = unique(justDates);
S.ls = uicontrol('style','list',...
    'units','pix',...
    'position',[10 10 150 610],...
    'string', S.uniqueExptDates,...
    'fontsize',10);
S.pb = uicontrol('style','push',...
    'units','pix',...
    'posit',[100 650 80 30],... % we want to overwrite last button (to avoid repeating/changing a list) was% 'posit',[405 650 120 30],
    'string', 'Show now',...
    'fontsize',10,...
    'callback',{@addGlobal,S});








function [S] = addGlobal(varargin)
[S] = varargin{3};
S.userDateSelection = get(S.ls,'Value');
display(['Loading ' S.uniqueExptDates{S.userDateSelection}])
S.exptByDateList = getExperimentsByAnimalAndDate(S.animalName,S.uniqueExptDates{S.userDateSelection});
S.indexRange = 1:size(S.exptByDateList,1);
[S] = updateDisplayList(S);


S.ep = uicontrol('style','edit',...
    'unit','pix',...
    'position',[655 650 120 30],...
    'string','0');
S.pb = uicontrol('style','push',...
    'units','pix',...
    'posit',[430 650 100 30],... % we want to overwrite last button (to avoid repeating/changing a list) was% 'posit',[405 650 120 30],
    'string', 'Add This',...
    'fontsize',10,...
    'callback',{@addParam,S});

% S.lsX = uicontrol('style','list',...
%     'units','pix',...
%     'position',[460 10 200 610],...
%     'string', S.listDisplayDetails,...
%     'fontsize',10);

function [S] = addParam(varargin)
[S] = varargin{3};
userIndexSelection = get(S.lsX,'Value');
stimParamSelection = get(S.pp,'Value');
stimValSelection = num2str(get(S.ep,'String'));
for iList = 1:length(userIndexSelection)
    newDisplayVal = [S.uniqueExptDates{S.userDateSelection} ' . ' S.exptIndex{userIndexSelection(iList)} ' . ' S.Preselects{stimParamSelection} ' . ' stimValSelection];
    display(newDisplayVal);
    setGlobalStimParams(S.uniqueExptDates{S.userDateSelection},S.exptIndex{userIndexSelection(iList)},S.Preselects{stimParamSelection},stimValSelection);
end
S.indexRange = userIndexSelection;
[S] = updateDisplayList(S);
S.ep = uicontrol('style','edit',...
    'unit','pix',...
    'position',[655 650 120 30],...
    'string','0');
S.pb = uicontrol('style','push',...
    'units','pix',...
    'posit',[430 650 100 30],... % we want to overwrite last button (to avoid repeating/changing a list) was% 'posit',[405 650 120 30],
    'string', 'Add This',...
    'fontsize',10,...
    'callback',{@addParam,S});




function [S] = updateDisplayList(varargin)
[S] = varargin{1};
for i = S.indexRange % if called from addParam, should just be one value.
    S.exptDesc(i) = S.exptByDateList{i,2};
    S.exptIndex{i,:} = S.exptByDateList{i,1}(7:9);
    
    [nGlobalPars,globalParNames,globalParVals] = getGlobalStimParams(S.uniqueExptDates{S.userDateSelection},S.exptIndex{i}); 
    
    
    S.nGlobalPars{i,:} = nGlobalPars;
    if isnumeric(S.nGlobalPars{i,:})
        S.nGlobalPars{i,:} = num2str(S.nGlobalPars{i,:});
    end
    parStr = '';
    for iPars = 1:nGlobalPars
        if iscell(globalParNames{iPars})
            S.globalParNames{iPars,i} = S.globalParNames{iPars,i}{1,1};
        else
            S.globalParNames{iPars,i} = globalParNames{iPars};
        end
        if isnumeric(globalParVals)
            S.globalParVals{iPars,i} = num2str(globalParVals(iPars));
        else
            S.globalParVals{iPars,i} = globalParVals(iPars);
        end
        parStr = [parStr ' . ' S.globalParNames{iPars,i} ' . ' S.globalParVals{iPars,i}];
    end
    S.listDisplayDetails{i,:} = [S.exptIndex{i} ' . ' S.exptDesc{i} ' . ' S.nGlobalPars{i,:} parStr];
    display(['loading ' S.exptIndex{i}])
end
S.lsX = uicontrol('style','list',...
    'units','pix',...
    'max',20,'min',1,...
    'position',[160 10 470 610],...
    'string', S.listDisplayDetails,...
    'fontsize',10);



