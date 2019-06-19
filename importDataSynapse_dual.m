function importDataSynapse_dual(exptDate,exptIndex,blockLocation)
% FOR DUAL RECORDING DUMMY!

% Given: a date and index
% Do: Save data and trial files in the expected formats for subsequent
% exptDate = '18924';
% exptIndex = '000';
% exptDate = '18o05';
% exptIndex = '000';
% exptDate = '18820';
% exptIndex = '000';
% exptDate = '18o19';
% exptIndex = '005';

% dirStrRawData = 'W:\Data\PassiveEphys\2018\18o01-001\'; %input
% TODO / WIP works, but some parameters not handled appropriately (so
% analyze MUA will not work)

% A few considerations:
% CONSIDERATION 1
% 1. Synapse holds data in continuous streams, so to store data as trial
% length snippets is a decision that requires a parameter.  It also
% complicates non trial based recordings: how should we set the
% 'maxFileSize'?  The TDT data stores have features that allow a user to 
% take out specific sections of recordings, so if we find the need to do so
% we should use that.
maxFileSize = 1.e9;
% this is not a great thing to hardcode here...
preStim = 500; % delay in ms.
postStim = 500;

% CONSIDERATION 2
% 2. % These are the recognized stream types so far.  I'm inclined to leave 
% these specific, because if someone adds a feature, we will almost 
% certainly need to code specifics for it.

signalTypes = {'EEG','LFP','SU'};
% TODO don't hardcode any of the following:
dirStrRawData = ['W:\Data\PassiveEphys\' '20' exptDate(1:2) '\' blockLocation '\']; %input
dirStrAnalysis = ['M:\PassiveEphys\20' exptDate(1:2) '\' exptDate '-' exptIndex '\']; %output


% All stim info is now handled in here.  and saved, so there may be no
% reason to pull trialList info out.
display('Updating stim info.')
trialList = updateStimInfoSynapse(blockLocation(1:5),blockLocation(end-2:end)); %DEBUG


% loading ephys data
display('Loading in raw data.  This sometimes takes a while.');

% check block location by comparing the block location vs exptDate & exptIndex
if strcmp([exptDate '-' exptIndex],blockLocation)
    streamToUse = 'NPr1'; % if blockLocation == exptDate-exptIndex, use the FIRST stream (left cage, chans 1-4, Cam1, etc)
else
    streamToUse = 'NPr2'; % if  blockLocation ~= exptDate-exptIndex, use the SECOND stream (right cage, chans 5-8, Cam2, etc)
end


data = TDTbin2mat(dirStrRawData); % this step may take a while depending on how long the recording is.  We can limit the length if necessary,


% data = TDTbin2mat(dirStrRawData,'TYPE',{'epocs'}); consider this format with the limited 'TYPE' could be useful 
display('Loading complete.');

% CONSIDERATION 3
% I have excluded a few things from the Brainware version: much metadata is
% already stored in the 'tank' file in Synapse, or are simply unneeded (the
% channels are already 'mapped', in a mapping set by the Synapse software.


% find which channels are EEG, LFP, etc. from database
% obviously, will only work if this has been entered (will be empty
% otherwise - add check?)
% [channelMap] = getElectrodeLocationFromDateIndex(exptDate,exptIndex);
streamList = fields(data.streams);
streamList(~strcmp(streamList,streamToUse)) = []; % remove the irrelevant stream

% Warning! this approach assumes we're recording strictly with this latest
% paradigm: 8 channels of twisted electrodes, and 4 EEGs.  This greatly
% reduces data storage and computational overhead.  If we implement 16 
% channel electrodes (full sample rates) we need to finish the size limit
% calculator (and load accordingly)

% step through signalTypes and find which match streams
for iSignal = 1:length(signalTypes)
    for iList = 1:length(streamList)
        if ~isempty(strfind(streamList{iList},signalTypes{iSignal})) % only handle the streams we have written to
            tempdT = 1/data.streams.(streamList{iList}).fs;
            %timeseries
            tempTS = zeros(1,length(data.streams.(streamList{iList}).data));
            tempTS(1) = tempdT;
            for iTimes = 2:length(tempTS)
               tempTS(iTimes) = tempTS(iTimes-1)+tempdT;
            end
            nChans = size(data.streams.(streamList{iList}).data,1);
            % need to find the length of trials
            if size(trialList,2)>1
                stimName = fields(data.scalars);
                stimDur = (data.scalars.(stimName{1}).data(3,1)-1)*data.scalars.(stimName{1}).data(4,1);
                sampPreStim = ceil(preStim/tempdT/1000);
                sampStim = ceil(stimDur/tempdT/1000); 
                sampPostStim = ceil(postStim/tempdT/1000);
                display('Finding trial times in stream');
                stimRange = zeros(length(trialList),sampPreStim+sampStim+sampPostStim+1);
                for i = 1:length(trialList)
                    sampStimTime = find(tempTS>trialList(i).trialTime,1);
                    stimRange(i,:) = sampStimTime-sampPreStim:sampStimTime+sampStim+sampPostStim;
                    
                end
                display('Done finding trial times in stream');
            else
                display('Using continuous stream');
                stimRange = zeros(1,length(data.streams.(streamList{iList}).data));
                stimRange(1,:) = 1:length(data.streams.(streamList{iList}).data);
            end
            
            ephysData = zeros(nChans,size(stimRange,2),length(trialList));
            justDataTrialSize_dec = (size(ephysData,2)*size(ephysData,1))+100; % length of each array single trial in bytes
            nTrialsPerFile = floor(2*maxFileSize/justDataTrialSize_dec/nChans);
            if nTrialsPerFile<length(trialList); display('warning! size of ephysData larger than reccommended!'); end; % !!!TODO!!! check size before load, then load as appropriate.

            for iStim = 1:length(trialList)
                % catch cases where the recording ends before trial time is
                % caught up
                endpad = find(length(data.streams.(streamList{iList}).data)<stimRange(iStim,:));
                if length(endpad) > 0
                    ephysData(:,:,iStim) = cat(2,data.streams.(streamList{iList}).data(:,stimRange(iStim,1):end),zeros(nChans,length(endpad)));
                else
                    ephysData(:,:,iStim) = data.streams.(streamList{iList}).data(:,stimRange(iStim,:));
                end
                
                
            end
            
            dT = tempdT; %#ok<NASGU>
            if strcmp(signalTypes{iSignal},'EEG') 
                dataFileName = [dirStrAnalysis exptDate '-' exptIndex '_' signalTypes{iSignal} 'data0']; % 0 is hard coded because EEG data will be small, or should otherwise taken from the data.stream on its own
            end
            if strcmp(signalTypes{iSignal},'LFP') || strcmp(signalTypes{iSignal},'SU')
                dataFileName = [dirStrAnalysis exptDate '-' exptIndex '_' 'data0']; % 0 is hard coded because EEG data will be small, or should otherwise taken from the data.stream on it's own
            end
            save(dataFileName,'ephysData','dT','-v7.3');
            clear ephysData dT stimRange;
        end
    end
end

