%function [htrEventTimes,detectedIndex] = HTRMagFindEventTimes(localVar,windowedVarTimes,plotEnable,magData,magDT,exptID)

function HTRMagFindEventTimes(localVar,windowedVarTimes,plotEnable,magData,magDT,exptID)
%global detectedIndex htrEventTimes
S.localVar = localVar;
S.windowedVarTimes = windowedVarTimes;
S.magData = magData;
S.magDT = magDT;
S.exptID = exptID;

S.fh = figure('units','pixels',...
    'position',[100 100 1050 700],...
    'menubar','none',...
    'numbertitle','off',...
    'name','Manually remove HTR events',...
    'resize','off');
% uicontrol('style','text',...
%     'units','pix',...
%     'position',[10 600 150 40],...
%     'fontweight','bold',...
%     'string','list of expts');



[histCount,~] = hist(S.localVar,100);
%thisMany = sum(histCount(bandpowerHTRThreshold:end));
thisMany = sum(histCount(find(histCount==0,1):end)); % we're looking for rare events in the long tail, so take the first bin that has a zero value. 

thisMany = min(thisMany,30); % don't take too many in case something went wrong
[tempSort,sortedIndex] = sort(S.localVar);
detected = tempSort(end-thisMany:end);
S.detectedIndex = sortedIndex(end-thisMany:end);
detectedTimes = S.windowedVarTimes(S.detectedIndex);
detected(detectedTimes < 1) =[];
detectedTimes(detectedTimes < 1) =[];

magTimeArray = 0:S.magDT:length(S.magData)*S.magDT;
detected(magTimeArray(end-round(1/S.magDT))<detectedTimes)=[];
detectedTimes(magTimeArray(end-round(1/S.magDT))<detectedTimes) =[];
    
% find the corresponding matched HTR raw traces
for indexRaw = 1:length(detected)
    warning('off','all');
%    if length(S.magData)>(detectedTimes(indexRaw)+1)*(1/S.magDT) %in case the detected event window (1 second) is within a second of the end!
        rawTraces = double(S.magData((detectedTimes(indexRaw)-1)*(1/S.magDT):(detectedTimes(indexRaw)+1)*(1/S.magDT)));
        rawTraces = filterData_dbVer(rawTraces,20,200,S.magDT); % bandpass
        warning('on','all');
        detectedRawFig(:,indexRaw) = rawTraces;
        detectedRawTimes(:,indexRaw) = (detectedTimes(indexRaw)-1):S.magDT:(detectedTimes(indexRaw)+1);
        %also find the exact times for matching/plotting
        [~,eventIndex] = max(envelope(rawTraces));
        S.htrEventTimes(indexRaw) = detectedRawTimes(eventIndex,indexRaw);
%    end
end



% === find and eliminate redundant events === 
% % remove the nonunique from the total distribution
S.normalizedBandwindowsForDetectedPlot = S.localVar;
S.normalizedBandwindowsForDetectedPlot(S.detectedIndex) = [];
% done twice, because we now have exact time from envelope calculation
[~,uniqueIndex,~]= unique(round(S.htrEventTimes));
S.htrEventTimes = S.htrEventTimes(uniqueIndex);
S.detectedIndex = S.detectedIndex(uniqueIndex);

S = plotNow(S);

S.pb = uicontrol('style','push',...
    'units','pix',...
    'posit',[430 650 100 30],... % we want to overwrite last button (to avoid repeating/changing a list) was% 'posit',[405 650 120 30],
    'string', 'Remove some',...
    'fontsize',10,...
    'callback',{@deleteFromList,S});
[S.pp] = uicontrol('style','push',...
    'units','pix',...
    'posit',[530 650 100 30],... % we want to overwrite last button (to avoid repeating/changing a list) was% 'posit',[405 650 120 30],
    'string', 'Use these',...
    'fontsize',10,...
    'callback',{@useThisSet,S});


uiwait(S.fh);
close(S.fh)




function [S] = deleteFromList(varargin)
[S] = varargin{3};

S = HTRclicksubplot(S);

S.htrEventTimes(S.removeThese) = [];
S.detectedIndex(S.removeThese) = [];
S = plotNow(S);

S.pb = uicontrol('style','push',...
    'units','pix',...
    'posit',[430 650 100 30],... % we want to overwrite last button (to avoid repeating/changing a list) was% 'posit',[405 650 120 30],
    'string', 'Remove some',...
    'fontsize',10,...
    'callback',{@deleteFromList,S});
[S.pp] = uicontrol('style','push',...
    'units','pix',...
    'posit',[530 650 100 30],... % we want to overwrite last button (to avoid repeating/changing a list) was% 'posit',[405 650 120 30],
    'string', 'Use these',...
    'fontsize',10,...
    'callback',{@useThisSet,S});


function [S,detectedIndex,htrEventTimes] = useThisSet(varargin)
[S] = varargin{3};
detectedIndex = S.detectedIndex;
htrEventTimes = S.htrEventTimes;

saveLocation = ['M:\PassiveEphys\20' S.exptID(1:2) '\'  S.exptID '\' ];
save([saveLocation S.exptID '-HTRevents'],'htrEventTimes','detectedIndex');


uiresume


function [S] = plotNow(varargin)
[S] = varargin{1}; %var 1 when not a callback, 3 when a callback


for indexRaw = 1:length(S.htrEventTimes)
    warning('off','all');
    startOfWindow = (S.htrEventTimes(indexRaw)-1)*(1/S.magDT);
    endOfWindow = (S.htrEventTimes(indexRaw)+1)*(1/S.magDT);
    if endOfWindow <= size(S.magData,2)
        rawTraces = double(S.magData(startOfWindow:endOfWindow));   
        rawTraces = filterData_dbVer(rawTraces,20,200,S.magDT); % bandpass
        detectedRawCenteredFig(:,indexRaw) = rawTraces;
    end
    warning('on','all');
end

%figure('Name',[exptID ' Events above threshold']); %v2
[htrValsHist,~] = sort(S.localVar(S.detectedIndex));
subplot(5,4,17:20);
histPlaces = linspace(min(S.normalizedBandwindowsForDetectedPlot),max(htrValsHist));
%histPlaces = linspace(min(S.normalizedBandwindowsForDetectedPlot),);
histogram(S.normalizedBandwindowsForDetectedPlot,histPlaces);
hold on
histogram(htrValsHist,histPlaces);
xlim([0,max(htrValsHist)]);
ylim([0,10]);
hold off
%figure('Name',[expt ' Centered Events']);
%indexLimit = min(size(detectedRawCenteredFig,2),16);
for indexPlot = 1:16
    subplot(5,4,indexPlot);

    timeX = 0:S.magDT:(length(detectedRawCenteredFig)-1)*S.magDT;
    timeX = timeX-1;

%         [c,lags] = xcorr(detectedRawCenteredFig(:,indexPlot),wavFilt);
%         c = c(length(rawTraces):end);
%         figure(); plot(lags,c);
%         figure(); plot(detectedRawCenteredFig(:,indexPlot));
    if indexPlot <= size(detectedRawCenteredFig,2)
        plot(timeX,detectedRawCenteredFig(:,indexPlot));
    else
        plot(timeX,zeros(size(detectedRawCenteredFig,1),1));
    end
    %title(['variance ' num2str(htrValsHist(indexPlot))]);
    ylim([min(min(detectedRawCenteredFig)),max(max(detectedRawCenteredFig))]);
    xlim([-.5,.5]);
    set(gca,'tag',num2str(indexPlot)); 
end



    


function [S] = HTRclicksubplot(varargin)
[S] = varargin{1};
S.removeThese = [];
while 1 == 1
    w = waitforbuttonpress;
      switch w 
          case 1 % keyboard 
              key = get(gcf,'currentcharacter'); 
              if key==27 % (the Esc key) 
                  try; delete(h); end
                  break
              end
          case 0 % mouse click 
              mousept = get(gca,'currentPoint');
              x = mousept(1,1);
              y = mousept(1,2);
              %try; delete(h); end
              h = text(x,y,['X' get(gca,'tag') 'X'],'vert','middle','horiz','center');
              tempNum = str2num(get(gca,'tag'));
              if ~isempty(tempNum)
                S.removeThese = cat(1,S.removeThese,tempNum);
              end
      end
end 
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
      
        