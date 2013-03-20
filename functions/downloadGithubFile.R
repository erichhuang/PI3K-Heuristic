## downloadGithubFile.R

## Erich S. Huang, MD, PhD
## Sage Bionetworks
## erich@post.harvard.edu
## erich.huang@sagebase.org

## A helper function that appropriately reads in text files
## as tables

downloadGithubFile <- function(url, target, filename){
  download.file(url, filename, method = 'wget')
  returnObj <- read.table(filename)
}