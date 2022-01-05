

load('C:\Users\Matthew Banks.Helios\Desktop\mouseEphys_conn_dbt_noParse_20sWin_0p5sTrial - BACKUP 18n21.mat');
% 
% listIndex = 1;
% animalList = fields(batchParams);
% 
% for i=1:length(animalList)
%     datesX = fields(batchParams.(animalList{i}));
%     for j=1:length(datesX)
%         %indexX = fields(batchParams.(animalList{i}).(datesX{j}));
%         if isfield(batchParams.(animalList{i}).(datesX{j}),'exptIndex')
%             for k = 1:length(batchParams.(animalList{i}).(datesX{j}).exptIndex)
%                 exptStr{listIndex,1} = [batchParams.(animalList{i}).(datesX{j}).exptDate(5:9) '-' batchParams.(animalList{i}).(datesX{j}).exptIndex{k}];
%                 listIndex = listIndex+1;
%             end
%         end
%     end
% end

% for Ziyad's structure
listIndex = 1;
animalList = fields(mouseEphys_conn.WPLI);
for i=1:length(animalList)
    datesX = fields(mouseEphys_conn.WPLI.(animalList{i}));
    for j=1:length(datesX)
        indexX = fields(mouseEphys_conn.WPLI.(animalList{i}).(datesX{j}));
        for k = 1:length(indexX)
            exptStr{listIndex,1} = [datesX{j}(5:9) '-' indexX{k}(5:7)];
            listIndex = listIndex+1;
        end
    end
end



fileRoots = {[getPathGlobal('W') 'PassiveEphys\'] [getPathGlobal('M') 'PassiveEphys\']};






for i = 1:length(exptStr)
    fileName = [getPathGlobal('W') 'PassiveEphys\' '20' exptStr{i}(1:2) '\' exptStr{i} '\' exptStr{i} '.avi'];
    if exist(fileName) ~= 2
        fileName = fileName(1:end-4);
        if exist(fileName) ~= 2
            error(['Cannot find the file ' fileName]);
        end
    end
    
    try 
        firstFrame = mmread(fileName,1:500);
    catch
        error(['Found, but could not load ' fileName]);
    end
    frameRate(i) = firstFrame.times(end)/length(firstFrame.times)
    
%     nFrames = length(firstFrame.times(firstFrame.times<1));
%     frameRate(i,1) = firstFrame.rate; %useless
%     frameRate(i,2) = nFrames
end







