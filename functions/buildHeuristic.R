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
  
  cat('Using the preliminary model importance metrics to identify a\n')
  cat('reduced feature set\n')
  
  impMat <- importance(prelimObj$model)
  impDF <- as.data.frame(impMat)
  impDF <- data.frame(rownames(impDF), impDF)
  mdaQuant <- quantcut(impDF$MeanDecreaseAccuracy)
  mdgQuant <- quantcut(impDF$MeanDecreaseGini)
  mdaQuantLev <- levels(mdaQuant)
  mdgQuantLev <- levels(mdgQuant)
  topMdaProbes <- impDF[mdaQuant == mdaQuantLev[3], 1]
  topMdgProbes <- impDF[mdgQuant == mdgQuantLev[4], 1]
  
  selectProbes <- intersect(as.character(topMdaProbes), as.character(topMdgProbes))
  
  prelimObj$trainExpress <- prelimObj$trainExpress[selectProbes, ]
  prelimObj$validExpress <- prelimObj$validExpress[selectProbes, ]
  
  cat('Generating a new PI3K pathway heuristic model on a reduced feature set\n')
  
  pi3kSelectModel <- randomForest(t(prelimObj$trainExpress),
                                  as.factor(trainClass),
                                  ntree = 500,
                                  do.trace = 2,
                                  importance = TRUE,
                                  proximity = TRUE)
  validScoreHat <- predict(pi3kSelectModel, t(prelimObj$validExpress), type = 'prob')
}