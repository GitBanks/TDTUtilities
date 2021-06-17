function sendSlackFig(desc,fpath)

%copied from 'SlackAPI' git repo https://github.com/kbuyukburc/MatlabSlackAPI

% desc = 'howdy!!'; %description e.g. EEG120 caffeine + LPS delta power and movement
% fpath = 'M:\PassiveEphys\AnimalData\ZZ09\Plasticity peaks time series - ZZ09_21617.png'; 

try
    load([mousePaths.W 'API\slackAPIToken'],'token'); % NOTE: token needs to be the Bot User OAuth Access Token.
    api = SlackAPI(token); 
    channel = '#datachecks'; % specify what channel you would like to upload to
    SendMsg(api,channel,desc); % this sends the message
    SendFile(api,channel,fpath); % this sends the file
catch why
    warning(why.message);
end