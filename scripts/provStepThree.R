## provStepThree.R

## Erich S. Huang
## Sage Bionetworks
## erich.huang@sagebase.org

## REQUIRE 
require(synapseClient)
require(rGithubClient)

## SOURCE CONVENIENCE FUNCTIONS
sourceRepoFile('erichhuang/rStartup', 'startupFunctions.R')

## SOURCE ANALYSIS GITHUB REPO
codeRepo <- getRepo('erichhuang/PI3K-Heuristic/')

## DATA OUTPUTS
intDataTab <- folderContents('syn1810386')
stepThreeIDs <- intDataTab$entity.id[grep('stepThree', intDataTab$entity.name)]

stepThreeEnts <- lapply(stepThreeIDs, getEntity)

## DATA INPUTS
stepTwoIDs <- intDataTab$entity.id[grep('stepTwo', intDataTab$entity.name)]

aEnt <- getEntity(stepTwoIDs[1])
bEnt <- getEntity(stepTwoIDs[2])

## CODE INPUT
stepThreeLink <- getPermlink(codeRepo, 'functions/buildPrelimHeuristic.R')

## DEFINE ACTIVITY
stepThreeAct <- Activity(name = 'Build Preliminary PI3K Heuristic Model',
                       used = list(
                         list(url = stepThreeLink, name = basename(stepThreeLink), wasExecuted = T),
                         list(entity = aEnt, wasExecuted = F),
                         list(entity = bEnt, wasExecuted = F)
                       ))

stepThreeAct <- createEntity(stepThreeAct)

# An object of class "Activity"
# Slot "properties":
#   $id
# [1] "1810704"
# 
# $name
# [1] "Build Preliminary PI3K Heuristic Model"
# 
# $description
# NULL
# 
# $etag
# [1] "0a24f09b-e677-49c0-b74a-d5802ff1c2f7"
# 
# $createdOn
# [1] "2013-04-30T20:33:09.737Z"
# 
# $modifiedOn
# [1] "2013-04-30T20:33:09.737Z"
# 
# $createdBy
# [1] "273956"
# 
# $modifiedBy
# [1] "273956"
# 
# $used
# $used[[1]]
# $used[[1]]$concreteType
# [1] "org.sagebionetworks.repo.model.provenance.UsedEntity"
# 
# $used[[1]]$wasExecuted
# [1] FALSE
# 
# $used[[1]]$reference
# $used[[1]]$reference$targetVersionNumber
# [1] 2
# 
# $used[[1]]$reference$targetId
# [1] "syn1810390"
# 
# 
# 
# $used[[2]]
# $used[[2]]$concreteType
# [1] "org.sagebionetworks.repo.model.provenance.UsedEntity"
# 
# $used[[2]]$wasExecuted
# [1] FALSE
# 
# $used[[2]]$reference
# $used[[2]]$reference$targetVersionNumber
# [1] 2
# 
# $used[[2]]$reference$targetId
# [1] "syn1810391"
# 
# 
# 
# $used[[3]]
# $used[[3]]$concreteType
# [1] "org.sagebionetworks.repo.model.provenance.UsedURL"
# 
# $used[[3]]$wasExecuted
# [1] TRUE
# 
# $used[[3]]$name
# [1] "buildPrelimHeuristic.R"
# 
# $used[[3]]$url
# [1] "https://github.com/erichhuang/PI3K-Heuristic/blob/4847f2de9d1498fa252b5640f6f3d8b4c8c34292/functions/buildPrelimHeuristic.R"

generatedByList(stepThreeEnts, stepThreeAct)