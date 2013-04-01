## provenance.R

## Erich S. Huang, MD, PhD
## Sage Bionetworks
## erich@post.harvard.edu
## erich.huang@sagebase.org

## REQUIRE
require(synapseClient)

## Defining the provenance of the analysis

## STEP ONE
dataCont <- synapseQuery('SELECT id, name FROM entity WHERE entity.parentId == "syn1728328"')

aktMutEnt <- getEntity(dataCont[1, 2])
rnaseqEnt <- getEntity(dataCont[2, 2])
pik3caMutEnt <- getEntity(dataCont[3, 2])
pik3r1MutEnt <- getEntity(dataCont[4, 2])
ptenMutEnt <- getEntity(dataCont[5, 2])

codeCont <- synapseQuery('SELECT id, name FROM entity WHERE entity.parentId == "syn1723855"')
loadDatEnt <- getEntity(codeCont[2, 2])
prepDatEnt <- getEntity(codeCont[3, 2])

dataActivity <- Activity(
  list(name = 'Load Data Objects', 
       used = list(
         list(entity = loadDatEnt, wasExecuted = T),
         list(entity = rnaseqEnt, wasExecuted = F),
         list(entity = pik3caMutEnt, wasExecuted = F),
         list(entity = aktMutEnt, wasExecuted = F),
         list(entity = ptenMutEnt, wasExecuted = F),
         list(entity = pik3r1MutEnt, wasExecuted = F))))

dataActivity <- createEntity(dataActivity)

loadedEnt <- loadEntity('syn1729632')
generatedBy(loadedEnt) <- dataActivity
loadedEnt <- storeEntity(loadedEnt)

## STEP TWO
prepareEnt <- loadEntity('syn1729567')
loadedEnt <- loadEntity('syn1729632')
intEnt <- loadEntity('syn1729346')
mutEnt <- loadEntity('syn1729370')

prepActivity <- Activity(
  list(name = 'Prepare Data for Modeling',
       used = list(
         list(entity = prepareEnt, wasExecuted = T),
         list(entity = loadedEnt, wasExecuted = F))))

prepActivity <- createEntity(prepActivity)

generatedBy(intEnt) <- prepActivity

intEnt <- storeEntity(intEnt)
prepActivity <- getActivity('1730114')

generatedBy(mutEnt) <- prepActivity
mutEnt <- storeEntity(mutEnt)

# # How load data generates 'stepOneIntermediateData'
# resultEntity <- synapseExecute(executable = list(repoName = '/erichhuang/PI3K-Heuristic', sourceFile = 'functions/loadData.R'), 
#                                resultParentId = 'syn1723854', 
#                                codeParentId = 'syn1723855', 
#                                resultEntityName = 'stepOneIntermediateData', 
#                                args = list())
# 
# # Next step in the analysis
# secondResultEnt <- synapseExecute(executable = list(repoName = '/erichhuang/PI3K-Heuristic',
#                                                     sourceFile = 'functions/prepareData.R'),
#                                   resultParentId = 'syn1723854',
#                                   codeParentId = 'syn1723855',
#                                   resultEntityName = 'stepTwoIntermediateData',
#                                   args = list(firstStep))
# 

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