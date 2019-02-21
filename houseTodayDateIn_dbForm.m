function [todayDateDB] = houseTodayDateIn_dbForm

currentTime = datestr(now);

switch currentTime(4:6)
    case {'Jan'}
        moStr = '01';
    case {'Feb'}
        moStr = '02';
    case {'Mar'}
        moStr = '03';
    case {'Apr'}
        moStr = '04';
    case {'May'}
        moStr = '05';
    case {'Jun'}
        moStr = '06';    
    case {'Jul'}
        moStr = '07';
    case {'Aug'}
        moStr = '08';
    case {'Sep'}
        moStr = '09';    
    case {'Oct'}
        moStr = '10';
    case {'Nov'}
        moStr = '11';
    case {'Dec'}
        moStr = '12';    
%     otherwise
%         error('The date program Sean wrote was not formatted correctly: houseTodayDateIn_dbForm')
end

todayDateDB = [currentTime(8:11) '-' moStr '-' currentTime(1:2)];


