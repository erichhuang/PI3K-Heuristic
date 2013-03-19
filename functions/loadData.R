## loadData.R

## Erich S. Huang, MD, PhD
## Sage Bionetworks
## erich@post.harvard.edu
## erich.huang@sagebase.org

## Load the data necessary for the first steps in building
## a pathway heuristic model of PI3K signalling in breast
## cancer using the TCGA dataset.

loadData <- function(){
  ## REQUIRE
  require(synapseClient)
  require(Biobase)
  
  ## synapseLogin('my-name@email.com', 'mypassword')
  cat('[1] Loading Synapse entities & accessory files\n')
  ## LOAD DATA
  # tcga rna seq data from metagenomics
  brcaEnt <- loadEntity('syn595321')
  brcaEset <- brcaEnt$objects$eset
  brcaRnaSeq <- exprs(brcaEset)
  
  # Read in mutation indicators for pi3k pathway related genes from cbio
  pi3kInd <- read.table('mutations/pi3kIndicatorUpdate.txt')
  rownames(pi3kInd) <- pi3kInd[ , 1]
  
  ptenInd <- read.table('mutations/ptenIndicatorUpdate.txt')
  rownames(ptenInd) <- ptenInd[ , 1]
  
  pik3r1Ind <- read.table('mutations/pik3r1Indicator.txt')
  rownames(pik3r1Ind) <- pik3r1Ind[ , 1]
  
  aktInd <- read.table('mutations/akt1Indicator.txt')
  rownames(aktInd) <- aktInd[ , 1]
  
  colnames(brcaRnaSeq) <- sapply(strsplit(colnames(brcaRnaSeq), '-'), function(x){
    paste(x[1:3], collapse="-")
  })
  
  cat('[2] Returning objects as a list to Workspace\n')
  datReturn <- list('brcaRnaSeq' = brcaRnaSeq,
                    'pi3kInd' = pi3kInd,
                    'ptenInd' = ptenInd,
                    'pik3r1Ind' = pik3r1Ind,
                    'aktInd' = aktInd)
  
  return(datReturn)
}