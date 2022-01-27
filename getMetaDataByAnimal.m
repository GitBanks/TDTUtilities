function [metaData] = getMetaDataByAnimal(animalName)
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

listOfAnimalExpts = getExperimentsByAnimal(animalName);
descOfAnimalExpts = listOfAnimalExpts(:,2);
listOfAnimalExpts = listOfAnimalExpts(:,1);

sz = [length(listOfAnimalExpts) 13];
varTypes = {'string','string','string','string','string','datetime','datetime','string','string','datetime','datetime','struct','string'};
varNames = {'block','conditions','electrodeSheet','dataPrefix','dateTime','startMin','stopMin','timePostOp','patientID','refTime','blockTime','ECoGchannels','electrodeRev'};
metaData = table('Size',sz,'VariableTypes',varTypes,'VariableNames',varNames);
implantDate = getImplantDate(animalName);

implantDate = convertvars(implantDate, @isdatetime, @(t) datetime(t, 'TimeZone', 'local'));

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
    metaData.conditions(i) = conditionsDescription;
    
    % ======= date and time ========================
    [indexDur,timeOfDay] = getTimeAndDurationFromIndex(exptDate,exptIndex);
%     metaData.startMin(i) = timeOfDay;
%     metaData.stopMin(i) = timeOfDay+indexDur;

    % ======= time since implant ===================
    metaData.timePostOp(i) = implantDate.implantDate{1}; %todo: subtract recording date from implant date for this number
    
    % ======= animal name ==========================
    metaData.patientID(i) = animalName;
    
    % ======= if we ever hold multiple blocks in one line, expand this to represent block times
%     metaData.blockTime(i) = timeOfDay; %this will need to be expanded if we ever break an index into chunks
      metaData.blockTime(i) = ''; 

    % ======= create channel map and info structure ======= 
    
    % check each channel from the electrode info 
    iterate = 1;
%     for ii = 1:size(electrodeLocation,1)
    for ii = 1:16
        if ~isempty(electrodeLocation{ii})
            metaData.ECoGchannels(i).chanNum(iterate) = iterate;
            metaData.ECoGchannels(i).Region(iterate) = electrodeLocation(ii);
            metaData.ECoGchannels(i).contNum(iterate) = ii;
            iterate = iterate+1;
        end
    end
%     metaData.ECoGchannels(i) = ECoGchannels; % do we need these as a structure?
    
    % ======= misc stuff just to make the tables similar (do we need any of these?) ===============
    metaData.refTime(i) = '';
    metaData.electrodeRev(i) = '';
    metaData.startMin(i) = '';
    metaData.stopMin(i) = '';
    metaData.electrodeSheet(i) = '';
    metaData.dataPrefix(i) = '';
    metaData.dateTime(i) = '';
end


end
