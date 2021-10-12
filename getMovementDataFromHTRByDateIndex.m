function h = getMovementDataFromHTRByDateIndex(exptDate,exptIndex,useCDF)
% this is actually more of a plotting function - 


% exptDate = '21712';
% exptIndex = '003';
if ~exist('useCDF','var')
    useCDF = false;
end
exptID = [exptDate '-' exptIndex];
[magData,magDT] = HTRMagLoadData(exptID);
%magTimeArray = 0:magDT:length(magData)/(1/magDT);
%magTimeArray = magTimeArray(1:length(magData));
moveData = smooth(abs(magData-mean(magData)),(1/magDT)*4,'sgolay',2);
%magTimeArray = magTimeArray(1:length(moveData));
if useCDF
    [f,x] = ecdf(moveData);
    h = plot(x,f);
else
    h = histogram(moveData,100);
end
%xlim([-0.005,1]);





% 
% % according to the ecdf
% % movement values below .1 should be 'resting state'
% % movement values above .15 should be 'active state'
% % let's keep a small margin to keep them distinct
% restingThresh = 0.05;
% activeThresh = 0.15;
% % a = find(moveData(moveData < restingThresh));
% % b = find(moveData(moveData > activeThresh));
% % plot(find(moveData > activeThresh))
% 
% a = nan(size(moveData));
% b = nan(size(moveData));
% a(moveData < restingThresh) = moveData(moveData < restingThresh);
% b(moveData > activeThresh) = moveData(moveData > activeThresh);
% figure();
% plot(a);
% hold on
% plot(b);
% 
% 
% 
% 
% 
% x = nan(size(moveData));
% y = nan(size(moveData));
% x(moveData > activeThresh) = magTimeArray(moveData < restingThresh);
% y(moveData > activeThresh) = moveData(moveData < restingThresh);
% figure;
% %plot(magTimeArray,moveData)
% hold on
% plot(x,y);
% x = nan(size(moveData));
% y = nan(size(moveData));
% x(moveData > activeThresh) = magTimeArray(moveData > activeThresh);
% y(moveData > activeThresh) = moveData(moveData > activeThresh);
% plot(x,y);
% 
% 
% 
% figure;
% plot(moveData)
% hold on
% plot(moveData(a));
% plot(moveData(b));
% hold on
% plot(magTimeArray(b),moveData(b));
