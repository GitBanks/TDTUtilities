# add libraries
# install.packages("MatchIt")
# install.packages("tidyverse")
# install.packages("lme4")
# install.packages("lmerTest")
# install.packages("optmatch")
library(MatchIt)
library(tidyverse)
library(lme4)
library(lmerTest)
library(optmatch)

# Propensity matching approach for mouse EEG
# adapted from earlier code from Bryan
# 8/28/20 can now be run as a function
# Further adapted from Ziyad's work to be run with new pipeline 06/27/22-ZZ  


animalName <- "EEG200"
exptDate <- "22614"

calc_prop_score <- 
function(
animalName,
exptDate
){

basePath = "//144.92.237.185/Data/PassiveEphys/AnimalData/"

csv_path <- paste0(basePath,animalName,"/PSM_",animalName,"_",exptDate,".csv")
fnameFullOutput <- paste0(basePath,animalName,"/PSM_",animalName,"_",exptDate,"_deltaPower_movement_summariesFULL.csv")
fnameWindowByWindow <- paste0(basePath,animalName,"/PSM_",animalName,"_",exptDate,"_deltaPropScoreMatching.csv")
fnameMatchingCriteria <- paste0(basePath,animalName,"/PSM_",animalName,"_",exptDate,"_deltaPSM_matchingCriteria.csv")
fnameWMeanTA <- paste0(basePath,animalName,"/PSM_",animalName,"_",exptDate,"_deltaPSM_matchedMovement_wMeanTA.csv")
fnameWMeanTP <- paste0(basePath,animalName,"/PSM_",animalName,"_",exptDate,"_deltaPSM_matchedMovement_wMeanTP.csv")


# read dataframe into environment  
dToMatch <- read.csv(csv_path)

dToMatch <- dToMatch %>% mutate(sqrtMovt=sqrt(meanMovement)) # TAKE SQUARE ROOT OF MOVEMENT (can't take log so this is how to get a normal distribution)
dToMatch <- dToMatch %>% dplyr::select(animalName,win,winTime,date,drug,isPeak,sqrtMovt,deltaA,deltaP) # filter for only these variables
dToMatch <- na.omit(dToMatch) # remove nan entries? does this actually remove nans? why are there nans
dToMatch <- dToMatch %>% filter(sqrtMovt>0) #KEEP ONLY NON-ZERO MOVEMENT VALUES

allSummaries <- list() # preallocate

matchMovement <- function(d) {
  match.it <- matchit(!isPeak ~ sqrtMovt, data=d, method='full', replace=TRUE, m.order='random', reestimate=TRUE, discard="both")
  allSummaries[as.character(d$animalName[1])] <<- summary(match.it)[2]
  summary(match.it)
  plot(match.it, type="jitter",interactive=FALSE)
  match.data(match.it)
}

mvtMatched <- dToMatch %>% group_by(animalName,drug) %>% do(matchMovement(.))

# Write CSV
write.csv(allSummaries, file = fnameFullOutput)

# SAVE window by window output of PSM
write.csv(mvtMatched, file = fnameWindowByWindow)

# summarize data
meanTA <- mvtMatched %>% group_by(animalName,isPeak,drug) %>% summarise(weightedMean = weighted.mean(deltaA,weights), weightedMvt = weighted.mean(sqrtMovt,weights))
meanTP <- mvtMatched %>% group_by(animalName,isPeak,drug) %>% summarise(weightedMean = weighted.mean(deltaP,weights), weightedMvt = weighted.mean(sqrtMovt,weights))

mvtMatched %>% group_by(animalName, isPeak, drug) %>% summarize(weightedMean

# check how well the movement distributions were matched
paired <- inner_join(meanTA %>% filter(isPeak==0) %>% mutate(baseMvt = weightedMvt) %>% ungroup() %>% dplyr::select(animalName,baseMvt,drug),meanTA %>% filter(isPeak==1) %>% mutate(peakMvt = weightedMvt) %>% ungroup() %>% dplyr::select(animalName,peakMvt,drug))
paired <- mutate(paired, mvtDiff = abs(peakMvt - baseMvt)/(baseMvt) ) %>% arrange(mvtDiff) # if >0.01, check...
view(paired) 
# check how well the movement distributions were matched
paired <- inner_join(meanTP %>% filter(isPeak==0) %>% mutate(baseMvt = weightedMvt) %>% ungroup() %>% dplyr::select(animalName,baseMvt,drug),meanTP %>% filter(isPeak==1) %>% mutate(peakMvt = weightedMvt) %>% ungroup() %>% dplyr::select(animalName,peakMvt,drug))
paired <- mutate(paired, mvtDiff = abs(peakMvt - baseMvt)/(baseMvt) ) %>% arrange(mvtDiff) # if >0.01, check...
view(paired) 


# SAVE matching criteria
write.csv(paired, file = fnameMatchingCriteria)

# Exclude ones we don't like. This should be based on the "paired" analysis which compares the weighted movement means; large differences (means >=1% different) = failed matching
#meanT <- meanT %>% filter(!(animalName %in% c('EEG11','EEG34','EEG48','EEG66','EEG80','EEG131','EEG134')))
meanTA <- meanTA %>% filter(!(animalName %in% c()))
meanTP <- meanTP %>% filter(!(animalName %in% c()))

# summary data
gdA <- meanTA %>% group_by(drug,isPeak) %>% summarize(grandMean = mean(weightedMean)) 
gdP <- meanTP %>% group_by(drug,isPeak) %>% summarize(grandMean = mean(weightedMean)) 

# Write CSV with meanT as output to plot in MATLAB
write.csv(gdA, file = fnameWMeanTA)
write.csv(gdP, file = fnameWMeanTP)


# weighted mean
#ggplot(data=meanT, aes(x=group,y=weightedMean,color=factor(isPeak))) + geom_jitter()
#m <- lmer(weightedMean ~ group * isPeak + (1|animalName),data=meanT)
#summary(m)

# m <- lmer(weightedMean ~ group * isPeak + (1|animalName),data=meanT %>% filter(group %in% c("Sham", "Low LPS", "High LPS"))) #("Saline + Low LPS","CAFc + Low LPS")))
# summary(m)



}