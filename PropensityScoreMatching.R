# add libraries
library(MatchIt)
library(tidyverse)
library(lme4)
library(lmerTest)

# Propensity matching approach for mouse EEG
# adapted from earlier code from Bryan
# 8/28/20 can now be run as a function
# Further adapted from Ziyad's work to be run with new pipeline 06/27/22-ZZ  
    

# load window by window file
csv_path <- "M:/mouseLFP/MatlabCSV/ZZ1422120psilocybin.csv"
fname <- "M:/mouseEEG/Power vs activity/test22629.csv"



args <- commandArgs(TRUE)
csv_path <- args[1] # csv file with all of the windows
fname <- args[2] # set the name of the output file 

# read dataframe into environment  
dToMatch <- read.csv(csv_path)

#dToMatch <- dToMatch %>% mutate(group = factor(group,levels=c("Sham","Low LPS","PXM + Low LPS","Saline + Low LPS","CAFc + Low LPS","Aged Low LPS","High LPS")))
dToMatch <- dToMatch %>% mutate(sqrtMovt=sqrt(meanMovement)) # TAKE SQUARE ROOT OF MOVEMENT (can't take log so this is how to get a normal distribution)
#dToMatch <- dToMatch %>% dplyr::select(animalName,group,age,date,isPeak,sqrtMovt,delta) # filter for only these variables
dToMatch <- dToMatch %>% dplyr::select(animalName,date,drug,isPeak,sqrtMovt,delta) # filter for only these variables
dToMatch <- na.omit(dToMatch) # remove nan entries? does this actually remove nans? why are there nans
dToMatch <- dToMatch %>% filter(sqrtMovt>0) # KEEP ONLY NON-ZERO MOVEMENT VALUES

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
fname = "M:/mouseLFP/Power vs Activity/Tables/deltaPower_movementPropensityScoresMatched_ZZ1422120psilocybin_summariesFULL.csv"
write.csv(allSummaries, file = fname)

# SAVE window by window output of PSM
fname = "M:/mouseLFP/Power vs Activity/Tables/deltaPropScoreMatching-ZZ1422120psilocybin.csv"
write.csv(mvtMatched, file = fname)

# summarize data
#meanT <- mvtMatched %>% group_by(animalName,isPeak,group) %>% summarise(weightedMean = weighted.mean(delta,weights), weightedMvt = weighted.mean(sqrtMovt,weights))
 meanT <- mvtMatched %>% group_by(animalName,isPeak,drug) %>% summarise(weightedMean = weighted.mean(delta,weights), weightedMvt = weighted.mean(sqrtMovt,weights))

# check how well the movement distributions were matched
paired <- inner_join(meanT %>% filter(isPeak==0) %>% mutate(baseMvt = weightedMvt) %>% ungroup() %>% dplyr::select(animalName,baseMvt,drug),meanT %>% filter(isPeak==1) %>% mutate(peakMvt = weightedMvt) %>% ungroup() %>% dplyr::select(animalName,peakMvt,drug))
paired <- mutate(paired, mvtDiff = abs(peakMvt - baseMvt)/(baseMvt) ) %>% arrange(mvtDiff)
view(paired) 

# SAVE matching criteria
fname = "M:/mouseEEG/Power vs activity/Tables/deltaPSM_matchingCriteria_20624.csv"
write.csv(paired, file = fname)

# Exclude ones we don't like. This should be based on the "paired" analysis which compares the weighted movement means; large differences (means >=1% different) = failed matching
#meanT <- meanT %>% filter(!(animalName %in% c('EEG11','EEG34','EEG48','EEG66','EEG80','EEG131','EEG134')))
meanT <- meanT %>% filter(!(animalName %in% c()))

#meanT <- meanT %>% mutate(group = factor(group,levels=c("Sham","Low LPS","PXM + Low LPS","Saline + Low LPS","CAFc + Low LPS","Aged Low LPS","High LPS"))) 

# summary data
gd <- meanT %>% group_by(drug,isPeak) %>% summarize(grandMean = mean(weightedMean)) 

# plot 
#ggplot(data=meanT,aes(x=isPeak,y=weightedMean,group=animalName)) +
# geom_line(size=1) + 
#geom_point(data=gd,aes(y=grandMean,group=NULL),color='red',size=2)  + # draw individual lines & mean points
#  geom_line(data=gd,aes(y=grandMean,group=NULL),color='red',size=1) + # draw mean line
#  facet_grid(cols=vars(group)) + theme_minimal() + # set number of facets
#  scale_x_continuous(name="",breaks=c(0,1),limits=c(-1,2),labels=c("0"="base","1"="peak")) + # change axis limits and labels
#  labs(y = 'mean log delta (weighted)',x = 'isPeak', title = "Movement Propensity Score Matching") # add labels 

# Write CSV with meanT as output to plot in MATLAB
write.csv(meanT, file = fname)

# weighted mean
#ggplot(data=meanT, aes(x=group,y=weightedMean,color=factor(isPeak))) + geom_jitter()
#m <- lmer(weightedMean ~ group * isPeak + (1|animalName),data=meanT)
#summary(m)

# m <- lmer(weightedMean ~ group * isPeak + (1|animalName),data=meanT %>% filter(group %in% c("Sham", "Low LPS", "High LPS"))) #("Saline + Low LPS","CAFc + Low LPS")))
# summary(m)