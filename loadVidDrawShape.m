function S = loadVidDrawShape(fileName)
% fileName = 'W:\Data\PassiveEphys\2019\19315-005\2019_19315-005_Cam1.avi';

S = struct;
S.fileName = fileName;
S.v = VideoReader(S.fileName);

vidHeight = S.v.Height;
vidWidth = S.v.Width;

disp('Loading video.  This may take a while for larger videos.'); %took ~70 seconds for an hour of video on Gilgamesh
iFrames = 1;
tic
while hasFrame(S.v)
    S.mov(iFrames).cdata = rgb2gray(readFrame(S.v));
    iFrames=iFrames+1;
end
toc

disp('Video loading complete.');
secondFrame = S.mov(2).cdata;

%draw polygon around mouse area 
figure
[BW] = roipoly(secondFrame);                         
hold on
imshow(BW,[]);
[R,C] = size(BW);

for i = 1:R
   for j =  1:C
       if BW(i,j) == 1
           S.thesePix(i,j) = secondFrame(i,j);
       else
           S.thesePix(i,j) = 0;
       end
   end
end

% S.output = logical(S.output);
end


