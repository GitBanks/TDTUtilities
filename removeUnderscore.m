function [outText] = removeUnderscore(inText)


if ~isempty(strfind(inText,'_'))
    outText = [inText(1:strfind(inText,'_')-1) inText(strfind(inText,'_')+1:end)];
end

