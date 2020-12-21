function sortedDates = checkDateChronology(theseDates)
% given a cell array of dates in the Banks Lab 5-digit format, this code
% will check for  

% remove "date" from these strings (usually we label structure fields dateYYmDD)
datos = strrep(theseDates,'date',''); % remove 'date' from the string, yielding YYmDD

% get unique months
ms = unique(cellfun(@(x) x(3), datos, 'UniformOutput',false)); 

% check how many different months there are, and if there is more than one
% month in the october - december range
if length(ms) > 1 && sum(contains(ms,{'d','n','o'}))>1
    % if there is more than one month with characters, check the chronological ordering
    for ii = 1:length(ms)
        m = ms{ii};
        ds{ii,1} = flip(sort(datos(contains(datos,m))));
    end
else
    
end

% liberate each row from the individual cells, merge together (??) FUCK
ds = vertcat(ds{:});
ds = flip(ds);
sortedDates = strcat('date',ds); % remove 'date' from the string, yielding YYmDD

% cellfun(@(x) x(3), datos, 'UniformOutput',false)
% cellfun(@(x) x(4:5), datos, 'UniformOutput',false)
% sort(ms,'ascend');
% ds = unique(cellfun(@(x) x(4:5), datos, 'UniformOutput',false),'stable');