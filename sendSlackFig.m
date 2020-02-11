function sendSlackFig(desc,fpath)

%copied from 'SlackAPI' git repo https://github.com/kbuyukburc/MatlabSlackAPI

% desc = ''; %description e.g. EEG120 caffeine + LPS delta power and movement
% fpath = ''; 

token = '';
api = SlackAPI(token); 
channel = '#delirium';
SendMsg(api,channel,desc);
SendFile(api,channel,fpath);