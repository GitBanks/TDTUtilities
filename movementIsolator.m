function [heatMapMoveIsolated] = movementIsolator(fileName,heatMapMoveIsolated)
% Given: a movement 'grid' file
% return: grid of most active squares
% optionally, reveive both (to compare most active squares to an average, e.g.)
% Then: plot an overlay of the first video frame and highlight these active
% squares
% example parameter:
% fileName = '\\MEMORY BANKS\Data\PassiveEphys\2018\18907-001\2018_18907-001_Cam1-framegrid.mat';
% TODO % would make so much more sense for 'filename' to be a date+index,
% so this program could be loaded from the command line more easily

load(fileName,'frameGrid','firstFrame') % should have 'frameGrid','timeGrid','firstFrame','actualFrameRate','frameTimeStamps');
frameGridSubt = abs(frameGrid(:,:,1:end-1)-frameGrid(:,:,2:end)); % looking for frame by frame changes
for iGrid = 1:size(frameGridSubt,1) % look for activity in specific grid spaces.
    for jGrid = 1:size(frameGridSubt,2)
       heatMapMove(iGrid,jGrid,:) = std(frameGridSubt(iGrid,jGrid,:));
    end
end
% find the squares that are the most active
if ~exist('heatMapMoveIsolated','var')
    heatMapMoveIsolated = heatMapMove>mean(mean(heatMapMove))*1.2;
    % TODO % may want to consider *not* hardcoding this
end
% the following will plot a frame from the video image, and the
% corresponding amount of movement detected over the course of the
% recording
xScaleX = 1:size(firstFrame.frames.cdata,2)/10:size(firstFrame.frames.cdata,2);
yScaleY = 1:size(firstFrame.frames.cdata,1)/10:size(firstFrame.frames.cdata,1);
image(firstFrame.frames.cdata);
hold on;
[~,cont] = contour(heatMapMove,5,'LineWidth',1);
set(cont,'XData',xScaleX);
set(cont,'YData',yScaleY);
%a bit cluttered, but helpful to know which frames are being accepted:
[~,cont] = contour(heatMapMoveIsolated,1,'--r','LineWidth',3);
set(cont,'XData',xScaleX);
set(cont,'YData',yScaleY);



