function [electrodeLocation] = getElectrodeLocationFromDateIndex(exptDate,exptIndex)
% return the channel map DESCRIPTIONS (DON'T confuse with channel ordering
% function getChannelMap()) as a cell array (18 cells long), with a 
% specific cell describing, e.g., 'EEG R front' or 'LFP L V2'.  Array will
% be 18 long: 16 channels (in 1:16 order) and Ground and Reference location
% as 17 and 18
if iscell(exptDate)
    exptDate = exptDate{1};
end
if iscell(exptIndex)
    exptIndex = exptIndex{1};
end

dbConn = dbConnect(); %handle this better?  close db at end?
exptID = getIDfromDateIndex(exptDate,exptIndex);
%SQLdetail_ephys = fetch(dbConn,['SELECT * FROM detail_ephys WHERE exptID= ' num2str(exptID) ]);
animalID = fetchAdjust(dbConn,['SELECT animalID FROM masterexpt WHERE exptID= ' num2str(exptID) ]); 

animalID = animalID{1};

%TODO handle case where animal has more than one probe

probeRequestText = fetchAdjust(dbConn,['SELECT * FROM probe WHERE animalID='  num2str(animalID) ]);
if isempty(probeRequestText)
    error('enter probe information please')
end
channelDesc = probeRequestText{3};
delimPoints = strfind(channelDesc, ','); % can't use splitstr() because some ',' might be empty (tied to ground)
delimPoints = [0 delimPoints length(channelDesc)+1];
for iDelim = 1:length(delimPoints)-1 % -1 because we added an extra point above
    electrodeLocation{iDelim,:} = channelDesc(delimPoints(iDelim)+1:delimPoints(iDelim+1)-1);
end

close(dbConn);



