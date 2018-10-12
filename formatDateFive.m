function [ formattedDate ] = formatDateFive(inputClock) 
%formatDateFive Format the date to the pClamp 5 date format
% formattedDate = 'YYmDD';
% For example, "10d06" for December 6th 2010.

% If an argument is passed to this function, use that as the date.
% Note: inputClock will be [year month day hour minute seconds] 
% so inputClock(1) is the year, etc

% Otherwise, call "clock()" to get today's date info(see matlab help) and
% output today's date.

% Note: clock() outputs [year month day hour minute seconds]
% so clock(1) is the year, etc

    if(exist('inputClock'))
        [Year, next] = strtok(inputClock,'-');  
        [Month, next] = strtok(next,'-');  
        [Day] =  strtok(next,'-'); 

    else
        inputClock = datestr(now,26);
        [Year, next] = strtok(inputClock,'/');  
        [Month, next] = strtok(next,'/');  
        [Day] =  strtok(next,'/'); 
%         Month = cellstr(Month);
%         Year = cellstr(Year);
%         Day = cellstr(Day);
    end
    
    switch Month %handle cases where month is represented as a char
        case '10'
            Month = 'o';
        case '11'
            Month = 'n';
        case '12'
            Month = 'd';
        otherwise
                tmp = char(Month); %if not extract single digit date
                Month = tmp(2);
    end

    tmpYR = char(Year);
    formattedDate = strcat(tmpYR(3), tmpYR(4), Month(1), Day);
    formattedDate = char(formattedDate);

end