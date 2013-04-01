## provenance.R

## Erich S. Huang, MD, PhD
## Sage Bionetworks
## erich@post.harvard.edu
## erich.huang@sagebase.org

## Defining the provenance of the analysis

# How load data generates 'stepOneIntermediateData'
resultEntity <- synapseExecute(executable = list(repoName = '/erichhuang/PI3K-Heuristic', sourceFile = 'functions/loadData.R'), 
                               resultParentId = 'syn1723854', 
                               codeParentId = 'syn1723855', 
                               resultEntityName = 'stepOneIntermediateData', 
                               args = list())

# Next step in the analysis
secondResultEnt <- synapseExecute(executable = list(repoName = '/erichhuang/PI3K-Heuristic',
                                                    sourceFile = 'functions/prepareData.R'),
                                  resultParentId = 'syn1723854',
                                  codeParentId = 'syn1723855',
                                  resultEntityName = 'stepTwoIntermediateData',
                                  args = list(firstStep))


##############
synPut <- function(object){
  require(synapseClient)
  entName <- readline('Please enter the name for your new Entity: \n')
  cat(sprintf('Creating %s\n', entName))
  synEnt <- Data(list(name = entName, parentId = 'syn1728328'))
  synEnt <- createEntity(synEnt)
  synEnt <- addObject(synEnt, object)
  cat(sprintf('Storing %s\n', entName))
  synEnt <- storeEntity(synEnt)
  cat(sprintf('Completed creation and storage of %s\n', entName))
}