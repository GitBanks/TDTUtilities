function [t,data] = loadEPSPSlopes(workbookFile,sheetName)
% function [t,data] = loadEPSPSlopes(workbookFile,sheetName,isPre)
% load normalized fEPSP slope data 
% t is time array
% data is the normalized EPSP slope
dataLines = [29, 338];
% if isPre
%      dataLines = [29, 118]; % should be consistent across files
% else
%      dataLines = [159,338]; % rows in post TBS
% end

t = importfile3(workbookFile, sheetName, dataLines, "L"); % times
data = importfile3(workbookFile, sheetName, dataLines, "N"); % slopes

end