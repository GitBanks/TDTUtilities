function [roiPix,fullROI] = drawMouseROI(currentFrame,currentTime,fullROI,useOldROI)
% it's in the title. Draw ROI around video image (presumably where mouse is able to move!)
% Use with final product of videoROI analysis

figure('name',['time = ' num2str(currentTime) 'sec']);%,'Position',[520,100,461,700]);
disp('INPUT REQUIRED: draw a closed shape around cage');

if nargin<4
    useOldROI = false;
end

h = imshow(currentFrame);
title('Draw a closed shape around cage');
if ~exist('fullROI','var') || isempty(fullROI)
    [fullROI] = drawassisted(h);
else
    disp('using existing ROI')
    title('using existing ROI');
    
    [newfullROI] = drawassisted(h,'Position',fullROI.Position,'Waypoints',fullROI.Waypoints);
    if ~useOldROI
        customWait(newfullROI);
    end
    
    if ~exist('newfullROI','var')
        [fullROI] = drawassisted(h);
        
    else
        fullROI = newfullROI;
    end
end

roiPix = createMask(fullROI);
disp('background ROI selected!');
bkgd = currentFrame;
bkgd(~roiPix) = nan;

figure
imshow(bkgd);
title('areas in black to be excluded from analysis');

% save(['M:\PassiveEphys\20' date(1:2) '\' date '-' index '\' date '-' index '-movementBinary.mat'],'finalMovementArray','frameTimeStampsAdj','roiPix','fullROI','avg_FR');

end

function pos = customWait(hROI)

% Listen for mouse clicks on the ROI
l = addlistener(hROI,'ROIClicked',@clickCallback);

% Block program execution
uiwait;

% Remove listener
delete(l);

% Return the current position
pos = hROI.Position;

end


function clickCallback(~,evt)

if strcmp(evt.SelectionType,'double')
    uiresume;
end

end