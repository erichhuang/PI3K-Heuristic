## buildPrelimHeuristic.R

## Erich S. Huang, MD, PhD
## Sage Bionetworks
## erich@post.harvard.edu
## erich.huang@sagebase.org

## Now build the PIK3CA mutation-based pathway heuristic model
## 

buildPrelimHeuristic <- function(){
  require(randomForest)
  require(synapseClient)
  
  ## LOAD DATA OBJECTS FROM SYNAPSE
  mutEnt <- loadEntity('syn1810390')
  intExEnt <- loadEntity('syn1810391')
  
  mutationDF <- mutEnt$objects$mutationDF
  intersectExpress <- intExEnt$objects$intersectExpress
  
  ## MUTATION EXCLUSIVITY INDICATOR
  cat('[10] Identifying samples that only have single locus PI3K pathway mutations\n')
  excInd <- apply(mutationDF, 1, sum)
  ## 6 samples have mutations at two of our loci of interest
  exclusivePi3k <- rownames(mutationDF)[mutationDF$pik3ca == 1 & excInd < 2]
  exclusivePten <- rownames(mutationDF)[mutationDF$pten == 1 & excInd < 2]
  exclusivePik3r1 <- rownames(mutationDF)[mutationDF$pik3r1 == 1 & excInd < 2]
  exclusiveAkt <- rownames(mutationDF)[mutationDF$akt == 1 & excInd < 2]
  
  allExc <- c(exclusivePi3k, exclusivePten, exclusivePik3r1, exclusiveAkt)
  
  ## WE WANT TO BUILD THE MODEL ON EXCLUSIVELY PI3K MUTANT PATIENTS VERSUS WT
  cat('[9] Subsetting the data on WT versus PIK3CA mutant samples\n')
  wtExpress <- intersectExpress[ , !colnames(intersectExpress) %in% allExc]
  pi3kExpress <- intersectExpress[ , exclusivePi3k]
  
  ## RANDOMLY DIVIDE INTO TRAINING AND VALIDATION COHORTS
  cat('[11] Dividing the data into training & validation cohorts\n')
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
  cat('[12] Building prototype PI3K heuristic model\n')
  pi3kPrelimModel <- randomForest(t(trainExpress),
                                  as.factor(trainClass),
                                  ntree = 500,
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
  trainExEnt <- loadEntity('syn1810659')
  trainExEnt <- addObject(trainExEnt, trainExpress)
  trainExEnt <- storeEntity(trainExEnt)
  
  validExEnt <- loadEntity('syn1810660')
  validExEnt <- addObject(validExEnt, validExpress)
  validExEnt <- storeEntity(validExEnt)
  
  tClassEnt <- loadEntity('syn1810661')
  tClassEnt <- addObject(tClassEnt, trainClass)
  tClassEnt <- storeEntity(tClassEnt)
  
  vClassEnt <- loadEntity('syn1810662')
  vClassEnt <- addObject(vClassEnt, validClass)
  vClassEnt <- storeEntity(vClassEnt)
  
  modEnt <- loadEntity('syn1810663')
  modEnt <- addObject(modEnt, pi3kPrelimModel)
  modEnt <- storeEntity(modEnt)
  
  vClassHatEnt <- loadEntity('syn1810664')
  vClassHatEnt <- addObject(vClassHatEnt, validScoreHat)
  vClassHatEnt <- storeEntity(vClassHatEnt)
  
  cat('[14] Returning objects as a list to Workspace\n')
  returnList <- list('trainExpress' = trainExpress,
                     'validExpress' = validExpress,
                     'trainClass' = trainClass,
                     'validClass' = validClass,
                     'model' = pi3kPrelimModel,
                     'validScoreHat' = validScoreHat,
                     'rankSum' = rankSum)
}