# 1. Load appropriate libraries - includes all libraries that your funciton depends on
# 2. load your custom function script
# use the function source("myRscript.R")

# install.packages("readxl",dependancies=TRUE)#,dependancies=TRUE)
library(readxl)
setwd("C:/Users/Matt Banks/Documents/Code/TDTUtilities/")
source("PropensityScoreMatching.R") 
xlsFilePath <- "//144.92.237.185/Data/PassiveEphys/mouseEEG/FLVXGroupInfo.xlsx"
myTable <- read_excel(xlsFilePath)
# calc_prop_score("EEG200","22614")
for (x in 6:30) {
	thisAnimal <- myTable[x, "animalName"]
	thisDate <- myTable[x, "Dates"]
	calc_prop_score(thisAnimal,thisDate)
}

# failed here: EEG189 22401 