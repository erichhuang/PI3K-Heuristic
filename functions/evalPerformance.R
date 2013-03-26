## evalPerformance.R

## Erich S. Huang, MD, PhD
## Sage Bionetworks
## erich@post.harvard.edu
## erich.huang@sagebase.org

## Evaluate performance

evalPerformance <- function(predObj, classVector){
  require(ROCR)
  require(ggplot2)
  
  cat('Generating performance metrics\n')
  rocrObj <- prediction(as.numeric(predObj[ , 2]), as.numeric(classVector))
  tprFpr <- performance(rocrObj, 'tpr', 'fpr')
  sensSpec <- performance(rocrObj, 'sens', 'spec')
  auc <- performance(rocrObj, 'auc')
  ppv <- performance(rocrObj, 'ppv')
  npv <- performance(rocrObj, 'npv')
  youdenJ <- sensSpec@x.values[[1]] + sensSpec@y.values[[1]] - 1
  jMax <- which.max(youdenJ)
  optCut <- tprFpr@alpha.values[[1]][jMax]
  optSens <- unlist(sensSpec@x.values)[jMax]
  optSpec <- unlist(sensSpec@y.values)[jMax]
  optNPV <- unlist(npv@y.values)[jMax]
  optPPV <- unlist(ppv@y.values)[jMax]
  auroc <- unlist(auc@y.values)
  
  cat('Generating ROC curve\n')
  perfDF <- data.frame('falsePosRate' = unlist(tprFpr@x.values),
                       'truePosRate' = unlist(tprFpr@y.values))
  rocCurve <- ggplot(perfDF, aes(falsePosRate, truePosRate)) +
    geom_line() + geom_abline(slope = 1, colour = 'red')
  
  cat('Returning objects as a list to Workspace\n')
  resultList <- list('optCutoff' = optCut,
                     'optSensitivity' = optSens,
                     'optSpecificity' = optSpec,
                     'optNPV' = optNPV,
                     'optPPV' = optPPV,
                     'auc' = auroc,
                     'rocCurve' = rocCurve)
  return(resultList)
}