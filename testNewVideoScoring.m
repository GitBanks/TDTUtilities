%1. find correct video names
%2. draw shape where cage/animal was
%3. isolate those pixels in all frames of video
%4. compute frame x frame differences 
%5. smooth/clean difference array
%6. save into output structure and move onto next video


%questions: combine RGB values into one value? Not sure how to handle. 
%what are best practices for optimizing code? When to convert to double?

fileName = 'W:\Data\PassiveEphys\2019\19310-002\2019_19310-002_Cam1.avi';
%  fileName = 'W:\Data\PassiveEphys\2019\19313-001\2019_19313-001_Cam1.avi';

%2. draw shape around where mouse movement can be expected
S = loadVidDrawShape(fileName);

%pre-allocate variables
Y = nan(length(S.mov)-1,1);
Y2 = nan(length(S.mov)-1,1);
Z = nan(length(S.mov)-1,1);
W = nan(length(S.mov)-1,1);
%3. calculate frame x frame differences
disp('calculating frame x frame differences');
tic
iFrame = 1;
while iFrame < length(S.mov)
    X2 = S.mov(iFrame+1).cdata(logical(S.thesePix));
    X1 = S.mov(iFrame).cdata(logical(S.thesePix));
    Y(iFrame) = mean(abs(X2-X1));
    Y2(iFrame) = mean((X2-X1).^2);
    Z(iFrame) = abs(mean(X2)-mean(X1));
    W(iFrame) = std(double(X2-X1));
    iFrame = iFrame+1;
end
toc
%%
figure
h(1) = subplot(2,1,1);
plot(Z);
hold on
plot(Y);
hold on
plot(Y2);
legend('Z','Y','Y2')
title('no filter')
% ylim([0,12])


h(2) = subplot(2,1,2);
plot(smooth(Z));
hold on
plot(smooth(Y));
hold on
plot(smooth(Y2));
hold on
title('smooth')
xlabel('nFrames');
ylabel('mean luminance change');
% ylim([0,12])
legend('Z','Y','Y2')
%'Y (mean(abs(X2-X1)))','Z (abs(mean(X2)-mean(X1)))'


figure
plot(W)
hold on
plot(smooth(W))
legend('W (std(X2-X1))','smooth W')

%%
figure
h(1) = subplot(2,1,1);
plot(Y2);
hold on
plot(Z2);
legend('Y','Z')
title('no filter')
ylim([0,12])
h(2) = subplot(2,1,2);
plot(smooth(Y2));
hold on
plot(smooth(Z2));
title('smooth')
xlabel('nFrames');
ylabel('mean luminance change');
ylim([0,12])
legend('Y (mean(abs(X2-X1)))','Z (abs(mean(X2)-mean(X1)))')


%%

figure('name','hist comparison')
subplot(3,1,1)
hist(log(smooth(Y)))
title('Y')

subplot(3,1,2)
hist(log(smooth(Z)))
title('Y')

load('M:\PassiveEphys\2019\19313-001\19313-001-movementInfoAdjusted','finalMovementArray');
subplot(2,1,2)
hist(log(finalMovementArray))
title('sean')


%%
%     X1prime = double(S.mov(iFrame).cdata(logical(S.thesePix)));
%     X2prime = double(S.mov(iFrame+1).cdata(logical(S.thesePix)));
