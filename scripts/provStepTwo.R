## provStepTwo.R

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
stepOneEnt <- getEntity('syn1810387')

## CODE USED
stepTwoLink <- getPermlink(codeRepo, 'functions/prepareData.R')

## OUTPUT
aEnt <- getEntity('syn1810391')
bEnt <- getEntity('syn1810390')

outputList <- list(aEnt, bEnt)

## DEFINE ACTIVITY
stepTwoAct <- Activity(name = 'Prepare Mutation and Transcriptome Data for Analysis',
                       used = list(
                         list(url = stepTwoLink, name = basename(stepTwoLink), wasExecuted = T),
                         list(entity = stepOneEnt, wasExecuted = F)
                       ))


stepTwoAct <- createEntity(stepTwoAct)

generatedByList(outputList, stepTwoAct)