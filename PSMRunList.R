# 1. Load appropriate libraries - includes all libraries that your funciton depends on
# 2. load your custom function script
# use the function source("myRscript.R")
# EEG189 Failed 

# install.packages("readxl",dependancies=TRUE)#,dependancies=TRUE)
library(readxl)
setwd("C:/Users/Matt Banks/Documents/Code/TDTUtilities/")
source("PropensityScoreMatching.R") 
#xlsFilePath <- "//144.92.237.185/Data/PassiveEphys/mouseEEG/FLVXGroupInfo.xlsx"
#xlsFilePath <- "//144.92.237.185/Data/PassiveEphys/mouseEEG/Sigma1GroupInfo.xlsx"
#xlsFilePath <- "//144.92.237.185/Data/PassiveEphys/mouseEEG/combinedGroupInfo.xlsx"
xlsFilePath <- "//144.92.237.185/Data/PassiveEphys/mouseEEG/DOIKetanserinGroupInfo.xlsx"

myTable <- read_excel(xlsFilePath)
# calc_prop_score("EEG234","23131") # this fails...
for (x in 29:37) {
	thisAnimal <- myTable[x, "animalName"]
	thisDate <- myTable[x, "Dates"]
	calc_prop_score(thisAnimal,thisDate)
}

# calc_prop_score("EEG221","22904")
# calc_prop_score("EEG242","23210")