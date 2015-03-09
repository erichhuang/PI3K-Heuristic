## buildPrelimHeuristic.R

## Erich S. Huang, MD, PhD
## Division of Translational Bioinformatics
## Department of Biostatistics & Bioinformatics
## Duke University School of Medicine
## erich.huang@duke.edu

## Now build the PIK3CA mutation-based pathway heuristic model
## 

buildPrelimHeuristic <- function(){
  require(randomForest)
  require(synapseClient)
  
  functionEnv <- new.env()
  
  ## LOAD DATA OBJECTS FROM SYNAPSE
  ## NOTES ON SYNAPSE CLIENT 1.6-1: Breaking API changes and a total reconfiguration
  # of the ~/.synapseCache mean that 'legacy' R Objects no longer have a slot with
  # Synapse entities, and that these R objects are no longer automatically unzipped
  # therefore I'll create a 'synLegacy()' function that unzips the R Objects and load 
  # them into memory
  synLegacy <- function(fileEntity)
  {
    require(synapseClient)
    filePath <- getFileLocation(fileEntity)
    rObject <- load(unzip(filePath, 
                          exdir = strsplit(filePath, '/archive.zip')[[1]][1]),
                    envir = functionEnv)
    return(rObject)
  }
  
  cat('[] Loading processed data\n')
  mutEnt <- synGet('syn1810390')
  intExEnt <- synGet('syn1810391')
  
  # Obsolete accessor slots from legacy R client
  #   mutationDF <- mutEnt$objects$mutationDF
  #   intersectExpress <- intExEnt$objects$intersectExpress
  
  # Use 'synLegacy()' function
  synLegacy(mutEnt)
  synLegacy(intExEnt)
  
  mutationDF <- functionEnv$mutationDF
  intersectExpress <- functionEnv$intersectExpress
  
  ## MUTATION EXCLUSIVITY INDICATOR
  cat('[] Identifying samples that only have single locus PI3K pathway mutations\n')
  excInd <- apply(mutationDF, 1, sum)
  ## 6 samples have mutations at two of our loci of interest
  exclusivePi3k <- rownames(mutationDF)[mutationDF$pik3ca == 1 & excInd < 2]
  exclusivePten <- rownames(mutationDF)[mutationDF$pten == 1 & excInd < 2]
  exclusivePik3r1 <- rownames(mutationDF)[mutationDF$pik3r1 == 1 & excInd < 2]
  exclusiveAkt <- rownames(mutationDF)[mutationDF$akt == 1 & excInd < 2]
  
  allExc <- c(exclusivePi3k, exclusivePten, exclusivePik3r1, exclusiveAkt)
  
  ## WE WANT TO BUILD THE MODEL ON EXCLUSIVELY PI3K MUTANT PATIENTS VERSUS WT
  cat('[] Subsetting the data on WT versus PIK3CA mutant samples\n')
  wtExpress <- intersectExpress[ , !colnames(intersectExpress) %in% allExc]
  pi3kExpress <- intersectExpress[ , exclusivePi3k]
  
  ## RANDOMLY DIVIDE INTO TRAINING AND VALIDATION COHORTS
  cat('[] Dividing the data into training & validation cohorts\n')
  set.seed(1212121745)
  wtSampInd <- sample(1:dim(wtExpress)[2], dim(wtExpress)[2]/2)
  pi3kSampInd <- sample(1:dim(pi3kExpress)[2], dim(pi3kExpress)[2]/2)
  
  trainExpress <- cbind(wtExpress[ , wtSampInd],
                        pi3kExpress[ , pi3kSampInd])
  
  validExpress <- cbind(wtExpress[ , -wtSampInd],
                        pi3kExpress[ , -pi3kSampInd])
  
  trainClass <- mutationDF[colnames(trainExpress), 1]
  validClass <- mutationDF[colnames(validExpress), 1]
  
  ## GENERATE THE NEW RANDOM FOREST MODEL PHASE 1
  cat('[] Building prototype PI3K heuristic model\n')
  pi3kPrelimModel <- randomForest(t(trainExpress),
                                  as.factor(trainClass),
                                  ntree = 50,
                                  do.trace = 2,
                                  importance = TRUE,
                                  proximity = TRUE)
  
  ## VALIDATE THE MODEL
  validScoreHat <- predict(pi3kPrelimModel, t(validExpress), type = 'prob')
  
  # Nonparametric ranksum
  validNumeric <- as.numeric(validClass)
  rankSum <- wilcox.test(validScoreHat[validNumeric == 0, 2], 
                         validScoreHat[validNumeric == 1, 2])
  
  ## SENDING INTERMEDIATE OBJECTS UP TO SYNAPSE
  #   trainExEnt <- loadEntity('syn1810659')
  #   trainExEnt <- addObject(trainExEnt, trainExpress)
  #   trainExEnt <- storeEntity(trainExEnt)
  #   
  #   validExEnt <- loadEntity('syn1810660')
  #   validExEnt <- addObject(validExEnt, validExpress)
  #   validExEnt <- storeEntity(validExEnt)
  #   
  #   tClassEnt <- loadEntity('syn1810661')
  #   tClassEnt <- addObject(tClassEnt, trainClass)
  #   tClassEnt <- storeEntity(tClassEnt)
  #   
  #   vClassEnt <- loadEntity('syn1810662')
  #   vClassEnt <- addObject(vClassEnt, validClass)
  #   vClassEnt <- storeEntity(vClassEnt)
  #   
  #   modEnt <- loadEntity('syn1810663')
  #   modEnt <- addObject(modEnt, pi3kPrelimModel)
  #   modEnt <- storeEntity(modEnt)
  #   
  #   vClassHatEnt <- loadEntity('syn1810664')
  #   vClassHatEnt <- addObject(vClassHatEnt, validScoreHat)
  #   vClassHatEnt <- storeEntity(vClassHatEnt)
  
  cat('[] Returning objects as a list to Workspace\n')
  returnList <- list('trainExpress' = trainExpress,
                     'validExpress' = validExpress,
                     'trainClass' = trainClass,
                     'validClass' = validClass,
                     'model' = pi3kPrelimModel,
                     'validScoreHat' = validScoreHat,
                     'rankSum' = rankSum)
  return(returnList)
}