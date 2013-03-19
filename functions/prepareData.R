## prepareData.R

## Erich S. Huang, MD, PhD
## Sage Bionetworks
## erich@post.harvard.edu
## erich.huang@sagebase.org

## Intersect the transcriptome and mutation call data so we're
## working on the full union of samples and make it into a 
## dataframe.

prepareData <- function(listObj){
  ## REQUIRE
  require(synapseClient)
  require(corpcor)
    
  ## INTERSECT ALL OF THE PATIENT IDS
  cat('[3] Taking the list object generated from loadData() and\n')
  cat('    intersecting by unique patient IDs\n')
  
  idList <- list('pik3ca' = rownames(listObj$pi3kInd),
                 'pten' = rownames(listObj$ptenInd),
                 'pik3r1' = rownames(listObj$pik3r1Ind),
                 'akt' = rownames(listObj$aktInd),
                 'rnaseq' = colnames(listObj$brcaRnaSeq))
  
  idIntersect <- Reduce(intersect, idList)
  
  ## CREATE A DATAFRAME FOR ALL THE MUTATIONS
  cat('[4] Creating a dataframe from the intersected mutation data\n')
  mutationDF <- data.frame(listObj$pi3kInd[idIntersect, 2],
                           listObj$ptenInd[idIntersect, 2],
                           listObj$pik3r1Ind[idIntersect, 2],
                           listObj$aktInd[idIntersect, 2])
  rownames(mutationDF) <- idIntersect
  colnames(mutationDF) <- c('pik3ca', 'pten', 'pik3r1', 'akt')
  
  ## FOR FORWARD COMPATIBILITY, INTERSECT WITH AFFYMETRIX ENTREZ IDS
  cat('[5] Performing a feature intersect with Entrez IDs for forward\n')
  cat('    compatibility with Sanger and CCLE data\n')
  affyFeatEnt <- loadEntity('syn1584462')
  affyFeatures <- affyFeatEnt$objects$sangEntrezFeatures
  ## intersect the RNA Seq ENTREZ IDs with the Affymetrix ENTREZ IDs
  featIntersect <- intersect(rownames(listObj$brcaRnaSeq), affyFeatures)
  
  ## INTERSECT THE RNA SEQ DATA
  intersectExpress <- listObj$brcaRnaSeq[featIntersect, idIntersect]
  
  ## INSPECT FOR OUTLIERS
  cat('[6] Removing outlier samples\n')
  svdDat <- fast.svd(intersectExpress)
  # plot(svdDat$v[ , 1], svdDat$v[ , 2])
  
  ## Looks like removing samples < -0.3 on Eigengene 2 is an easy win
  outlierSamps <- grep('TRUE', svdDat$v[ , 2] < -0.3)
  intersectExpress <- intersectExpress[ , -outlierSamps]
  mutationDF <- mutationDF[-outlierSamps, ]
  
  cat('[7] Returning objects as a list to Workspace\n')
  returnList <- list('intersectExpress' = intersectExpress,
                     'mutationDF' = mutationDF)
  
  return(returnList)
}