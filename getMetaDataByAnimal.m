function [metaData] = getMetaDataByAnimal(animalName,overWrite)
% This function will pull metadata associated with a particular animal
%test param
% animalName = 'ZZ10'
% animalName = 'ZZ14'

% Note:  ** are critical, so will error if not found
% block**
% conditions**
% electrodeSheet
% dataPrefix
% dateTime
% startMin
% stopMin
% timePostOp
% patientID** - animalName
% refTime
% blockTime
% ECoGchannels**
% electrodeRev


% add a saving feature so we don't need to rerun existing stuff.
if ~exist('overWrite','var')
    overWrite = true;
end
rootFolder = ['M:\PassiveEphys\AnimalData\' animalName];
if exist(rootFolder,'dir') ~=7
    mkdir(rootFolder)
end
fileName = [rootFolder '\metaData.mat'];


if ~isfile(fileName) || overWrite




listOfAnimalExpts = getExperimentsByAnimal(animalName);
descOfAnimalExpts = listOfAnimalExpts(:,2);
listOfAnimalExpts = listOfAnimalExpts(:,1);

sz = [length(listOfAnimalExpts) 13];
varTypes = {'string','string','string','string','string','datetime','datetime','string','string','datetime','datetime','cell','string'};
varNames = {'block','conditions','electrodeSheet','dataPrefix','dateTime','startMin','stopMin','timePostOp','patientID','refTime','blockTime','ECoGchannels','electrodeRev'};
metaData = table('Size',sz,'VariableTypes',varTypes,'VariableNames',varNames);
implantDate = getImplantDate(animalName);


doOnce = 1;
for i = 1:size(listOfAnimalExpts,1)
    exptDate = listOfAnimalExpts{i}(1:5);
    exptIndex = listOfAnimalExpts{i}(7:9);
    disp(['Pulling metadata for ' exptDate ' ' exptIndex]);
    if doOnce % this is assuming we're only pulling one animal within this loop.  MUST be changed if this is not the case
        [electrodeLocation,map,stmInfo] = getElectrodeLocationFromDateIndex(exptDate,exptIndex);
        doOnce = 0;
    end
    
    % ======= date, index for 'block' ==============
    metaData.block(i) = listOfAnimalExpts{i};
    
    % ======= drug, stim, etc. for condition =======    
   [conditionsDescription,electrodeType,drugDesc,timeInj,exptType] = getConditionsDescription(exptDate,exptIndex);
    metaData.conditions(i) = [drugDesc '_' timeInj '_' exptType];
    
    % ======= date and time ========================
    metaData.refTime.TimeZone = 'local';
    metaData.refTime(i) = datetime(implantDate.implantDate{1},'TimeZone','local')+hours(12);
    [indexDur,exptDatetime] = getTimeAndDurationFromIndex(exptDate,exptIndex);
    [exptDate_dbForm] = houseConvertDateTo_dbForm(exptDate);


    % ======= time since implant ===================
    

    metaData.timePostOp(i) = exptDatetime- metaData.refTime(i); %todo: subtract recording date from implant date for this number
    
    % ======= animal name ==========================
    metaData.patientID(i) = animalName;
    
    % ======= if we ever hold multiple blocks in one line, expand this to represent block times
    % It turns out this is important for any analysis that segments data.
%     metaData.blockTime(i) = timeOfDay; %this will need to be expanded if we ever break an index into chunks
    metaData.blockTime.TimeZone = 'local';
    metaData.blockTime(i) = datetime(datetime(exptDate_dbForm)+timeofday(exptDatetime),'TimeZone','local'); 
   
    % ======= create channel map and info structure ======= 
    % check each channel from the electrode info 
    iterate = 1;
    for ii = 1:16
        if ~isempty(electrodeLocation{ii})
            ECoGchannels(iterate).chanNum = iterate;
            ECoGchannels(iterate).oldROI = electrodeLocation(ii);
            ECoGchannels(iterate).contNum = ii;
            iterate = iterate+1;
        end
    end
    metaData.ECoGchannels(i) = {ECoGchannels}; % do we need these as a structure?
    
    % ======= misc stuff just to make the tables similar (do we need any of these?) ===============
    metaData.electrodeRev(i) = '';
    metaData.startMin(i) = '';
    metaData.stopMin(i) = '';
    metaData.electrodeSheet(i) = '';
    metaData.dataPrefix(i) = '';
    metaData.dateTime(i) = '';

    save(fileName,'metaData');
end

else
    load(fileName,'metaData');
end
