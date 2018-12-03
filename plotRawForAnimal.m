function plotRawForAnimal(animalName)
% 
% animalName = 'EEG11';
% animalName = 'LFP18';
% animalName = 'Opto-01';

exptList = getExperimentsByAnimal(animalName);



fileRoot = ['M:\PassiveEphys\20' exptList{end-2,1}(1:2) '\' exptList{end-2,1} '\' ];

filename = [exptList{end-2,1} '_data0.mat'];

%dir(fileRoot)

load([fileRoot filename])


if ndims(ephysData) > 2 % old brainware data
    a = squeeze(ephysData(:,:,2));
else % synapse data assuming 24414 sample rate
    a = ephysData(:,1:24414*20);
end
nChannels = size(a,1);


figH = figure('name',animalName);

for iChan = 1:nChannels
    subtightplot(nChannels,1,iChan);
    plot(a(iChan,:))
    %ylim([-0.05,0.05])
    set(gca,'XTickLabel',[],'YTickLabel',[],'XTick',[],'YTick',[]);
%     if iChan == nChannels
%         %xlabel(stimLabels(iStim));
%     end
end

saveLoc = ['C:\Users\Matthew Banks.Helios\Desktop\temp\rawDataProof-' animalName ];
saveas(figH,[saveLoc '.png']);
savefig(figH,saveLoc);
close all
% TODO 11/28/18
% add animal name in plot
% save to a temp folder for review




