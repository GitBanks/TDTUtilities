function sendSlackFig(desc,fpath)

%copied from 'SlackAPI' git repo https://github.com/kbuyukburc/MatlabSlackAPI

% desc = ''; %description e.g. EEG120 caffeine + LPS delta power and movement
% fpath = ''; 

token = 'xoxp-137382725558-384646086694-892845663616-f124501856ea317ae805205adeeb4727'; %can be user or bot token (this is Ziyad's)
api = SlackAPI(token); 
channel = '#delirium';
SendMsg(api,channel,desc);
SendFile(api,channel,fpath);