function sendSlackFig(desc,fpath)

%copied from 'SlackAPI' git repo https://github.com/kbuyukburc/MatlabSlackAPI

% desc = ''; %description e.g. EEG120 caffeine + LPS delta power and movement
% fpath = ''; 

% this is the Bot User OAuth Access Token. Will need to update if you make
% changes to the bot.
token = 'xoxb-137382725558-880133487650-xxArWvpn5hk2Q0bxV2pbo1rp';
api = SlackAPI(token); % ?
channel = '#datachecks'; % specify what channel you would like to upload to
SendMsg(api,channel,desc); % this sends the message 
SendFile(api,channel,fpath); % this sends the file