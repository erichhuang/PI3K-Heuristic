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
#   brcaEnt <- loadEntity('syn595321')
#   brcaEset <- brcaEnt$objects$eset
  #   brcaRnaSeq <- exprs(brcaEset)
  #   
    
  # tcga rna seq data from the TCGA Pan Can synapse project
  cat('[1.1] Reading Pan-Cancer Project RNA Seq data into memory\n')
  rnaSeqEnt <- synGet('syn1446183')
  brcaRnaSeq <- read.delim(file.path(rnaSeqEnt$cacheDir, rnaSeqEnt$files), header = F, as.is = T)
  colnames(brcaRnaSeq) <- brcaRnaSeq[1, ]
  seqRows <- brcaRnaSeq[ , 1]
  brcaRnaSeq <- brcaRnaSeq[-1, -1]
  
  cat('[1.2] Converting text matrix to numeric\n')
  brcaRnaSeq <- sapply(brcaRnaSeq, as.numeric)
  rownames(brcaRnaSeq) <- seqRows[-1]

  # Read in mutation indicators for pi3k pathway related genes from cbio
#   pi3kInd <- read.table('mutations/pi3kIndicatorUpdate.txt') # Need to revise for switch
#   rownames(pi3kInd) <- pi3kInd[ , 1]                         # to Synapse files
#   
#   ptenInd <- read.table('mutations/ptenIndicatorUpdate.txt')
#   rownames(ptenInd) <- ptenInd[ , 1]
#   
#   pik3r1Ind <- read.table('mutations/pik3r1Indicator.txt')
#   rownames(pik3r1Ind) <- pik3r1Ind[ , 1]
#   
#   aktInd <- read.table('mutations/akt1Indicator.txt')
#   rownames(aktInd) <- aktInd[ , 1]
  
  cat('[1.3] Reading CBio Mutsig calls into memory\n')
  aktEnt <- loadEntity('syn1728346')
  aktInd <- aktEnt$objects$aktInd
  
  pik3caEnt <- loadEntity('syn1728330')
  pik3caInd <- pik3caEnt$objects$pik3caInd
  
  pik3r1Ent <- loadEntity('syn1728348')
  pik3r1Ind <- pik3r1Ent$objects$pik3r1Ind
  
  ptenEnt <- loadEntity('syn1728344')
  ptenInd <- ptenEnt$objects$ptenInd
  
  # Make sure the column names of the RNA seq data are compatible
  colnames(brcaRnaSeq) <- sapply(strsplit(colnames(brcaRnaSeq), '-'), function(x){
    paste(x[1:3], collapse = "-")
  })
    
  cat('[2] Returning objects as a list to Workspace\n')
  datReturn <- list('brcaRnaSeq' = brcaRnaSeq,
                    'pik3caInd' = pik3caInd,
                    'ptenInd' = ptenInd,
                    'pik3r1Ind' = pik3r1Ind,
                    'aktInd' = aktInd)
  
  cat('[3] Sending objects as a list to Synapse\n')
  datEnt <- loadEntity('syn1810387')
  datEnt <- addObject(datEnt, datReturn, name = 'object')
  datEnt <- storeEntity(datEnt)
  
  return(datReturn)
}