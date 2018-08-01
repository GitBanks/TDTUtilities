function [date,index] = fixDateIndexToFiveForSynapse(date,index)
%
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


