function tempAnimalData2 = mergeHTRExperimentInfo(animalData)
% standalone function, so that we can add flexibility in the future
% (merging across days, etc
% step through expts, add the 24 hour REC to previous day as appropriate

tempAnimalData = struct;
for iList = 1:size(animalData,2)
    newX = struct();
    if animalData(iList).data.hourOfRecording(1) > 24
        indexSearch = -1;
        thisAnimal = animalData(iList).data.animalName;
        %animalData(iList).data.animalName = [];
        while indexSearch < 0 %we need to find the correct previous index to merge
            %if ~isempty(animalData(iList+indexSearch).data.animalName)
            if animalData(iList+indexSearch).data.animalName == thisAnimal
                foundIndex = iList+indexSearch;
                indexSearch = 1;
            end
            %end
            indexSearch = indexSearch-1;
            if iList+indexSearch < 1
                error('found a 24 hour later day with no preceeding recording')
            end
        end
        disp(['merging ' num2str(foundIndex) ' and ' num2str(iList) ' to index ' num2str(foundIndex)]);
        theseFields = fields(animalData(foundIndex).data);
        for iFields = 1:size(theseFields,1)
            newX.data.(theseFields{iFields}) = [animalData(foundIndex).data.(theseFields{iFields}),animalData(iList).data.(theseFields{iFields})];
        end
        tempAnimalData(foundIndex).data = newX.data;
        tempAnimalData(foundIndex).data.animalName = thisAnimal;
        clear newX
        %animalData(iList).data = [];
    else
        disp(['assigning ' num2str(iList) ' to index ' num2str(iList)]);
        tempAnimalData(iList).data = animalData(iList).data;
    end
end
tempAnimalData2 = struct;
structIterator = 1;
for iList = 1:size(tempAnimalData,2)
    if ~isempty(tempAnimalData(iList).data)
        disp(['reassigning ' num2str(iList) ' to index ' num2str(structIterator)]);
        tempAnimalData2(structIterator).data = tempAnimalData(iList).data;
        structIterator = structIterator+1;
    end
end

end