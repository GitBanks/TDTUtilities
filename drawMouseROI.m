function [roiPix,musPix,musArea,bkgdArea,musLum,bkgdLum] = drawMouseROI(firstFrame,currentFrame)
%it's in the title. Use with final product of videoROI analysis
figure('name',['time = ' num2str(firstFrame.times) 'sec'],'Position',[520,398,461,700]);
subtightplot(3,1,1);
disp('step 1) draw a closed shape around bottom of cage');
[roiPix] = roipoly(currentFrame); % background + mouse ROI selection
disp('background ROI selected!');
bkgd = currentFrame;
bkgd(~roiPix) = nan;
subtightplot(3,1,2);
disp('step 2) draw a closed shape around ANIMAL');
imshow(bkgd);
mus = bkgd; % create mouse image variable before drawing ROI
[musPix] = roipoly(bkgd); % mouse ROI selection
disp('mouse ROI selected!');
subtightplot(3,1,3);
mus(~musPix) = nan; % exclude all non-mouse pixels
bkgd(musPix) = nan; % exclude mouse pixels from background
musArea = sum(musPix,'all'); % area of mouse (number of pixels)
bkgdArea = sum(roiPix-musPix,'all'); % area of background (number of pixels)
musLum = nanmean(mus,'all'); % mean luminance of mouse
bkgdLum = nanmean(bkgd,'all'); % mean luminance of background (no mouse)
imshow(bkgd);