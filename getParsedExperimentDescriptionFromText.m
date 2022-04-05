function [preHourText,hourText,postHourText] = getParsedExperimentDescriptionFromText(inputText)
% given a description, return either the stuff before it or which hour it
% was
%inputText = exptDescription

parseText = strfind(inputText,'Pre');
if isempty(parseText)
    parseText = strfind(inputText,'Post');
end
if isempty(parseText)
    warning('getParsedExperimentDescriptionFromText requires input text to contain ''Pre'' or ''Post'' ');
    return
end

preHourText = inputText(1:parseText-2); %
trimmedText = inputText(parseText:end);
[partA,trimmedText] = strtok(trimmedText,' ');
[partB,postHourText] = strtok(trimmedText,' ');
hourText = [partA ' ' partB];
hourText = hourText(1:end-1);

