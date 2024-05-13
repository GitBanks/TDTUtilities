library(dplyr)
library(tidyr)
library(readxl)
library(ClusterR)

basePath = "//144.92.237.185/Data/PassiveEphys/AnimalData/"
xlsFilePath <- "//144.92.237.185/Data/PassiveEphys/mouseEEG/poster2023GroupInfo.xlsx"
saveFilePath <- "//144.92.237.185/Data/PassiveEphys/mouseEEG/poster2023GaussTrim.csv"

myTable <- read_excel(xlsFilePath)
#myTable <- myTable %>% filter(group %in% c("Saline; Saline","Saline; LPS"))


myTable <- myTable %>%
  filter(include==1) %>%
  mutate(csv_path = paste0(basePath,animalName,"/PSM_",animalName,"_",Dates,".csv")) %>%
  mutate(group = as.factor(group),animalName = as.factor(animalName))

myTable <- myTable %>% rename(ExptDate = `recording date in xls readable`)
  


avgDeltaFromHighMovement <- function(x) {
  d <- read.csv(x)
  
  d <- d %>% mutate(isPeak = factor(isPeak)) %>%
    mutate(sqrtMovt=sqrt(meanMovement)) %>%
    rowwise() %>%
    mutate(deltaMn=exp(mean(c(log(deltaA),log(deltaP)),na.rm=TRUE))) %>%
    filter(sqrtMovt>0) %>%
    filter(!is.na(deltaMn))
  
  fitgmm <- GMM(as.matrix(d$sqrtMovt),gaussian_comps=2)
  pr <- predict(fitgmm,newdata=as.matrix(d$sqrtMovt))
  cutoff <- min(max(d$sqrtMovt[pr==1]),max(d$sqrtMovt[pr==2]))
  
  rawBase <- mean(d$deltaMn[d$isPeak==0])
  rawPeak <- mean(d$deltaMn[d$isPeak==1])
  
 d <- d %>% filter(sqrtMovt>cutoff)
 out <- c(mean(d$deltaMn[d$isPeak==0]),mean(d$deltaMn[d$isPeak==1]),sum(d$isPeak==0),sum(d$isPeak==1),rawBase,rawPeak)
 names(out) <- c('Base_Selected','Peak_Selected','nBase','nPeak','Base_Raw','Peak_Raw')
 out
}

# You might want to save this 'out' variable; 'Base_Selected' and 'Peak_Selected' are averaged delta values for those windows,'nBase','nPeak' describe how much time (number of bins) was actually used from those windows
out <- cbind(myTable, t(sapply(myTable$csv_path,avgDeltaFromHighMovement)))

# After these lines "pivot_longer" makes each observation into a row, so that there is a column that tells you whether its base or peak and another column that has the delta values; this is a better format for fitting models and plotting in R
out <- out %>%
  pivot_longer(cols = c(Base_Selected,Peak_Selected,Base_Raw,Peak_Raw),names_to = c("epoch",".value"), names_sep="_") %>%
  mutate(epoch = factor(epoch,levels=c("Base","Peak")))

write.csv(out, file = saveFilePath)
