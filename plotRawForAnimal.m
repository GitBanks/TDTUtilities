function plotRawForAnimal(animalName)
% 
% animalName = 'EEG11';
% animalName = 'LFP18';
% animalName = 'Opto-01';
animalName = 'EEG29';

exptList = getExperimentsByAnimal(animalName);



fileRoot = ['M:\PassiveEphys\20' exptList{end-2,1}(1:2) '\' exptList{end-2,1} '\' ];

try
    filename = [exptList{end-2,1} '_EEGdata0.mat']; %updated to try catch form ZS 1/17/2019
    load([fileRoot filename])

catch
    filename = [exptList{end-2,1} '_data0.mat'];
    load([fileRoot filename])

end
%dir(fileRoot)



if ndims(ephysData) > 2 % old brainware data
    a = squeeze(ephysData(:,:,2));
else % synapse data assuming 24414 sample rate
    a = ephysData(:,1:24414*20);
end
nChannels = size(a,1);


figH = figure('name',animalName);

a = double(a);
for iChan = 1:nChannels/4 %ZS 1/17/2019
    subtightplot(nChannels/4,1,iChan); %nChannels -> nChannels/4 to just display EEG ZS 1/17/2019
    plot(a(iChan,:)/24576) %/24576
%     ylim([-0.05,0.05]) 
%     set(gca,'XTickLabel',[],'YTickLabel',[],'XTick',[],'YTick',[]); ZS 1/17/2019
%     if iChan == nChannels
%         %xlabel(stimLabels(iStim));
%     end
end

saveLoc = ['C:\Users\Matthew Banks.Helios\Desktop\temp\rawDataProof-' animalName ];
% saveas(figH,[saveLoc '.png']); ZS 1/17/2019
% savefig(figH,saveLoc); ZS 1/17/2019
% close all ZS 1/17/2019
% TODO 11/28/18
% add animal name in plot
% save to a temp folder for review




