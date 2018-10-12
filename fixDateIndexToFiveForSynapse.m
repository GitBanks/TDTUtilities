function [date,index] = fixDateIndexToFiveForSynapse(date,index)
% returns [date,index] in string format appropriate for our save format 
% e.g., '18926' '001' even if handed the number 2 as index or 18/9/26 as
% date
% calls: [ formattedDate ] = formatDateFive(inputClock)

if iscell(date)
    date = date{1};
end
if length(date) > 5
    date = formatDateFive(date);
end

if iscell(index)
    index = index{1};
end
if isnumeric(index)
    index = num2str(index);
end
while length(index)<3
    index = ['0' index];
end


