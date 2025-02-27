#!/bin/bash

REPOSITORY="malaquiasLAB/repo1"
BRANCH="main"
WORKFLOW_FILE="workflow.yml"
ENVIRONMENT="dev"


# get ultimo run id

RUN_ID=$(curl -s -L -H "Accept: application/vnd.github+json" -H "Authorization: token $PAT" -H "X-GitHub-Api-Version: 2022-11-28" https://api.github.com/repos/$REPOSITORY/actions/runs?branch=$BRANCH | jq '.workflow_runs| map(select(.status == "waiting" and .head_branch == "'$BRANCH'" and .path == ".github/workflows/'$WORKFLOW_FILE'" ))' | jq .[0] | jq .id)
		   
# get environment_ids
ENVIRONMENT_ID=$(curl -s -L -H "Accept: application/vnd.github.v3+json" -H "Authorization: token $PAT" https://api.github.com/repos/$REPOSITORY/environments | jq '.environments| map (select (.name == "'$ENVIRONMENT'"))'| jq .[] | jq .id )

# triger funcionou
curl -L -X POST -H "Accept: application/vnd.github+json" -H "Authorization: token $PAT" -H "X-GitHub-Api-Version: 2022-11-28" https://api.github.com/repos/$REPOSITORY/actions/runs/$RUN_ID/pending_deployments -d '{"environment_ids":['$ENVIRONMENT_ID'],"state":"approved","comment":"Auto aprovado pelo workflow automatizado!"}'
 
