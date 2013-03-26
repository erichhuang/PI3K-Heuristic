## predictionPlots.R

## Erich S. Huang, MD, PhD
## Sage Bionetworks
## erich@post.harvard.edu
## erich.huang@sagebase.org

## Plot a boxplot of the prediction result for a 
## random forest heuristic model 

predictionPlots <- function(predictObj, classVector){
  require(ggplot2)
  plotDF <- data.frame('class' = classVector, 'activityscore' = predictObj[ , 2])
  boxPlot <- ggplot(plotDF, aes(factor(class), activityscore)) +
    geom_boxplot() +
    geom_jitter(aes(colour = factor(class)), size = 4)
  densPlot <- ggplot(plotDF, aes(activityscore, fill = factor(class))) +
    geom_density(alpha = 0.3)
  
  plotList <- list('boxPlot' = boxPlot,
                   'densityPlot' = densPlot)
  return(plotList)
}