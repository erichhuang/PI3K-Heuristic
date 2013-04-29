## provStepOne.R

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

## DATA INPUTS
rnaSeqEnt <- getEntity('syn1446183')
aktEnt <- getEntity('syn1728346')
pik3caEnt <- getEntity('syn1728330')
pik3r1Ent <- getEntity('syn1728348')
ptenEnt <- getEntity('syn1728344')

## INTERMEDIATE RESULT
stepOneOutput <- getEntity('syn1809484')

## CODE USED
stepOneLink <- getPermlink(codeRepo, 'functions/loadData.R')

stepOneAct <- Activity(name = 'Load Pan-Cancer TCGA RNA Seq & cBio Mutation Data',
                   used = list(
                     list(url = stepOneLink, name = basename(stepOneLink), wasExecuted = T),
                     list(entity = rnaSeqEnt, wasExecuted = F),
                     list(entity = aktEnt, wasExecuted = F),
                     list(entity = pik3caEnt, wasExecuted = F),
                     list(entity = pik3r1Ent, wasExecuted = F),
                     list(entity = ptenEnt, wasExecuted = F)
                   ))


stepOneAct <- createEntity(stepOneAct)

generatedBy(stepOneOutput) <- stepOneAct
stepOneOutput <- updateEntity(stepOneOutput)