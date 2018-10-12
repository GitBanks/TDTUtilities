function [outText] = removeUnderscore(inText)
% I don't remember exactly, but an underscore pissed me off one day.  I
% think field names can't be underscores, so this is useful for feeding in
% animal names from DB to be stored as matlab field names.

if ~isempty(strfind(inText,'_'))
    outText = [inText(1:strfind(inText,'_')-1) inText(strfind(inText,'_')+1:end)];
end

