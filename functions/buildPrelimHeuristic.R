## buildPrelimHeuristic.R

## Erich S. Huang, MD, PhD
## Sage Bionetworks
## erich@post.harvard.edu
## erich.huang@sagebase.org

## Now build the PIK3CA mutation-based pathway heuristic model
## 

buildPrelimHeuristic <- function(listObj){
  require(randomForest)
  
  ## MUTATION EXCLUSIVITY INDICATOR
  cat('[8] Identifying samples that only have single locus PI3K pathway mutations\n')
  excInd <- apply(listObj$mutationDF, 1, sum)
  ## 6 samples have mutations at two of our loci of interest
  exclusivePi3k <- rownames(listObj$mutationDF)[listObj$mutationDF$pi3k == 1 & excInd < 2]
  exclusivePten <- rownames(listObj$mutationDF)[listObj$mutationDF$pten == 1 & excInd < 2]
  exclusivePik3r1 <- rownames(listObj$mutationDF)[listObj$mutationDF$pik3r1 == 1 & excInd < 2]
  exclusiveAkt <- rownames(listObj$mutationDF)[listObj$mutationDF$akt == 1 & excInd < 2]
  
  allExc <- c(exclusivePi3k, exclusivePten, exclusivePik3r1, exclusiveAkt)
  
  ## WE WANT TO BUILD THE MODEL ON EXCLUSIVELY PI3K MUTANT PATIENTS VERSUS WT
  cat('[9] Subsetting the data on WT versus PIK3CA mutant samples\n')
  wtExpress <- listObj$intersectExpress[ , !colnames(listObj$intersectExpress) %in% allExc]
  pi3kExpress <- listObj$intersectExpress[ , exclusivePi3k]
  
  ## RANDOMLY DIVIDE INTO TRAINING AND VALIDATION COHORTS
  cat('[10] Dividing the data into training & validation cohorts\n')
  set.seed(1212121745)
  wtSampInd <- sample(1:dim(wtExpress)[2], dim(wtExpress)[2]/2)
  pi3kSampInd <- sample(1:dim(pi3kExpress)[2], dim(pi3kExpress)[2]/2)
  
  trainExpress <- cbind(wtExpress[ , wtSampInd],
                        pi3kExpress[ , pi3kSampInd])
  
  validExpress <- cbind(wtExpress[ , -wtSampInd],
                        pi3kExpress[ , -pi3kSampInd])
  
  trainClass <- listObj$mutationDF[colnames(trainExpress), 1]
  validClass <- listObj$mutationDF[colnames(validExpress), 1]
  
  ## GENERATE THE NEW RANDOM FOREST MODEL PHASE 1
  cat('[11] Building prototype PI3K heuristic model\n')
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
  
  cat('[12] Returning objects as a list to Workspace\n')
  returnList <- list('trainExpress' = trainExpress,
                     'validExpress' = validExpress,
                     'trainClass' = trainClass,
                     'validClass' = validClass,
                     'model' = pi3kPrelimModel,
                     'validScoreHat' = validScoreHat,
                     'rankSum' = rankSum)
}