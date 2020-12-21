% animals = {'EEG142','EEG143'};

% animals = {'EEG150','EEG151'};%first one must be tank file animal
% animals = {'EEG152','EEG153'};
% animals = {'EEG154','EEG155'};
animals = {'EEG156','EEG157'}; 
exptTypeToRun = 'Ketamine';

mags = {'mag1','mag2'};
% mags = {'mag1','mag2'}; %mag1 is 118, mag2 is 119 (check this)
% istank = [1,0];
istank = [1,0];
tankpath = 'W:\Data\PassiveEphys\2020\'; %tank file location

 
% loop through animals
for ianimal = 1:length(animals)
    name = animals{ianimal};
    tnk = istank(ianimal);
    % grab dates/expts
    expts = getExperimentsByAnimal(name,exptTypeToRun);
%     expts(~contains(expts(:,1),'19n08'),:) = [];
    
    if ianimal==1
       tankexpts = expts; 
    end
    
    % loop through expts
    for iexpt = 1:size(expts,1)
        date = expts{iexpt,1}(1:5);
        
%         if strcmp(date,'20221')
%            keyboard; 
%         end
        try
        
        idx = expts{iexpt,1}(7:9);
        
        if ~tnk %if not associated with tank file
            tankIdx = tankexpts{iexpt,1}(7:9);
            tank = TDTbin2mat([tankpath date '-' tankIdx '\']);
        else
            tank = TDTbin2mat([tankpath date '-' idx '\']);
        end
        
        magstream = mags{ianimal}; 
        
        magData = tank.streams.(magstream).data; % unfiltered magnet signal
        magDT = 1/tank.streams.(magstream).fs; % magnet signal dT
        
        % save magnet signal
        filename = [date '-' idx '_magnetData'];
        path = ['M:\PassiveEphys\2020\' date '-' idx '\'];
%         path = ['W:\Data\PassiveEphys\EEG animal data\' animal '\' date '-' index '\'];
        save([path filename],'magData','magDT');
        clear tank magData magDT
        catch why
            warning([date '-' idx ' failed']);
        end
    end
    clear xpts
end %animal loop
% end
