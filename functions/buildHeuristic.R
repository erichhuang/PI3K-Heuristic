## buildHeuristic.R

## Erich S. Huang, MD, PhD
## Sage Bionetworks
## erich@post.harvard.edu
## erich.huang@sagebase.org

## Take the preliminary heuristic results and optimize

buildHeuristic <- function(prelimObj){
  require(randomForest)
  require(plyr)
  require(gtools)
  require(synapseClient)
  
  cat('Loading preliminary model\n')
  prelimEnt <- loadEntity('syn1810663')
  prelimMod <- prelimEnt$objects$pi3kPrelimModel
  
  cat('Loading training transcriptome data\n')
  trainExEnt <- loadEntity('syn1810659')
  trainExpress <- trainExEnt$objects$trainExpress
  
  cat('Loading training class vector\n')
  trainClassEnt <- loadEntity('syn1810661')
  trainClass <- trainClassEnt$objects$trainClass
  
  cat('Loading validation transcriptome data\n')
  validExEnt <- loadEntity('syn1810660')
  validExpress <- validExEnt$objects$validExpress
  
  cat('Using the preliminary model importance metrics to identify a\n')
  cat('reduced feature set\n')
  
  impMat <- importance(prelimMod)
  impDF <- as.data.frame(impMat)
  impDF <- data.frame(rownames(impDF), impDF)
  mdaQuant <- quantcut(impDF$MeanDecreaseAccuracy)
  mdgQuant <- quantcut(impDF$MeanDecreaseGini)
  mdaQuantNum <- as.numeric(mdaQuant)
  mdgQuantNum <- as.numeric(mdgQuant)

#   mdaQuantLev <- levels(mdaQuant)
#   mdgQuantLev <- levels(mdgQuant)
  
#   topMdaProbes <- impDF[mdaQuant == mdaQuantLev[3], 1]
#   topMdgProbes <- impDF[mdgQuant == mdgQuantLev[4], 1]
  
  topMdaProbes <- impDF[mdaQuantNum >= 3, 1]
  topMdgProbes <- impDF[mdgQuantNum == 4, 1]
  
  selectProbes <- intersect(as.character(topMdaProbes), as.character(topMdgProbes))
  
  trainExpress <- trainExpress[selectProbes, ]
  validExpress <- validExpress[selectProbes, ]
  
  cat('Generating a new PI3K pathway heuristic model on a reduced feature set\n')
  
  pi3kSelectModel <- randomForest(t(trainExpress),
                                  as.factor(trainClass),
                                  ntree = 500,
                                  do.trace = 2,
                                  importance = TRUE,
                                  proximity = TRUE)
  validScoreHat <- predict(pi3kSelectModel, t(validExpress), type = 'prob')
}