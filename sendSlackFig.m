function sendSlackFig(desc,fpath)

%copied from 'SlackAPI' git repo https://github.com/kbuyukburc/MatlabSlackAPI

% desc = ''; %description e.g. EEG120 caffeine + LPS delta power and movement
% fpath = ''; 

try
    load('Z:\API\slackAPIToken','token'); % NOTE: token needs to be the Bot User OAuth Access Token.
    api = SlackAPI(token); 
    channel = '#datachecks'; % specify what channel you would like to upload to
    SendMsg(api,channel,desc); % this sends the message
    SendFile(api,channel,fpath); % this sends the file
catch why
    warning(why.message);
end