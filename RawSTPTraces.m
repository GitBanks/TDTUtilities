SalineBaseline = readmatrix("M:\Ziyad\Slice\Hippocampal LTP\Data\SalineBaselineRaw0-5-210520006")
SalinePostTBS = readmatrix("M:\Ziyad\Slice\Hippocampal LTP\Data\SalinePostTBSRaw0-5-21052009") 
DOIBaseline = readmatrix("M:\Ziyad\Slice\Hippocampal LTP\Data\DOIBaselineRaw0-5-210429004.csv")
DOIPostTBS = readmatrix("M:\Ziyad\Slice\Hippocampal LTP\Data\DOIPostTBSRaw0-5-210429007")
KetBaseline = readmatrix("M:\Ziyad\Slice\Hippocampal LTP\Data\KetamineBaselineRaw0-5-210428004")
KetPostTBS = readmatrix("M:\Ziyad\Slice\Hippocampal LTP\Data\KetaminePostTBS0-5-210428007")

yL = [-3 .5]; % ylim
xL = [10 35]; %lim

%DOI Raw Traces
figure()
plot(DOIBaseline(:,1), DOIBaseline(:,2),'linewidth',1.5)
hold on
plot(DOIBaseline(:,1), DOIPostTBS(:,2),'linewidth',1.5)
ylim(yL); % mV
xlim(xL); % ms

hold on;
plot([25 30],[-2,-2],'-k','LineWidth',1); %x scale
text(27,-2.1,'5ms');
plot([25 30],[-2,-2],'-k','LineWidth',1); %y scale
text(23.5,-1.75,'0.5mV');
axis off % turn off axes
legend('Baseline','60min post TBS40','box','off','location','north');

%Saline Raw Traces
figure()
plot(SalineBaseline(:,1), SalineBaseline(:,2),'linewidth',1.5)
hold on
plot(SalineBaseline(:,1), SalinePostTBS(:,2),'linewidth',1.5)
ylim(yL); % mV
xlim(xL); % ms

hold on;
plot([25 30],[-2,-2],'-k','LineWidth',1); %x scale
text(27,-2.1,'5ms');
plot([25 30],[-2,-2],'-k','LineWidth',1); %y scale
text(23.5,-1.75,'0.5mV');
axis off % turn off axes
legend('Baseline','60min post TBS40','box','off','location','north');

%Ketamine Raw Traces
figure()
plot(KetBaseline(:,1), KetBaseline(:,2),'linewidth',1.5)
hold on
plot(KetBaseline(:,1), KetPostTBS(:,2),'linewidth',1.5)
ylim(yL); % mV
xlim(xL); % ms

hold on;
plot([25 30],[-2,-2],'-k','LineWidth',1); %x scale
text(27,-2.1,'5ms');
plot([25 30],[-2,-2],'-k','LineWidth',1); %y scale
text(23.5,-1.75,'0.5mV');
axis off % turn off axes
legend('Baseline','60min post TBS40','box','off','location','north');
