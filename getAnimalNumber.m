function animalNum = getAnimalNumber(animalName)
% given an animal name, return the number associated with the string

animalNum = str2double(animalName(end-2:end));
if isnan(animalNum)
   animalNum = str2double(animalName(end-1:end));
end

end