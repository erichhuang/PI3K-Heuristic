## provMutationData.R

## Erich S. Huang
## Sage Bionetworks
## erich.huang@sagebase.org

## REQUIRE 
require(synapseClient)
require(rGithubClient)

## SOURCE CONVENIENCE FUNCTIONS
sourceRepoFile('erichhuang/rStartup', 'startupFunctions.R')

## DATA OUTPUTS
aktEnt <- getEntity('syn1728346')
pik3caEnt <- getEntity('syn1728330')
pik3r1Ent <- getEntity('syn1728348')
ptenEnt <- getEntity('syn1728344')

## DEFINE ACTIVITY
mutAct <- Activity(list(name = 'MutSig mutation data via cBio', 
                        used = list(
                          list(url = 'http://www.cbioportal.org/public-portal/study.do?cancer_study_id=brca_tcga',
                               name = 'MSKCC cBio Portal for Cancer Genomics',
                               wasExecuted = FALSE)
                          )))

mutAct <- createEntity(mutAct)

# An object of class "Activity"
# Slot "properties":
#   $id
# [1] "1809702"
# 
# $name
# [1] "MutSig mutation data via cBio"
# 
# $description
# NULL
# 
# $etag
# [1] "b04a311e-305b-4035-b54f-e7c03678871f"
# 
# $createdOn
# [1] "2013-04-29T22:38:45.012Z"
# 
# $modifiedOn
# [1] "2013-04-29T22:38:45.012Z"
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
# [1] "org.sagebionetworks.repo.model.provenance.UsedURL"
# 
# $used[[1]]$wasExecuted
# [1] FALSE
# 
# $used[[1]]$name
# [1] "MSKCC cBio Portal for Cancer Genomics"
# 
# $used[[1]]$url
# [1] "http://www.cbioportal.org/public-portal/study.do?cancer_study_id=brca_tcga"

## DEFINE PROVENANCE
outputList <- list(aktEnt, pik3caEnt, pik3r1Ent, ptenEnt)
generatedByList(outputList, mutAct)