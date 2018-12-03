
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

for i = 1:length(animalList)


    plotRawForAnimal(animalList{i})

end
