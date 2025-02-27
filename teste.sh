#!/bin/bash

REPO="repo2"

RUN_ID=$(curl -s -L \
                -H "Accept: application/vnd.github+json" \
                -H "Authorization: token $PAT" \
                -H "X-GitHub-Api-Version: 2022-11-28" \
                https://api.github.com/repos/malaquiasLAB/$REPO/actions/runs?branch=main | \
		jq '.workflow_runs| map(select(.status == "waiting" and .head_branch == "main" and .path == ".github/workflows/workflow.yml" ))' | \
		jq .[0] | jq .id)

DEPLOYMENT_ID=$(curl -s L \
	        -H "Accept: application/vnd.github+json" \
              	-H "Authorization: token $PAT" \ 
	       	https://api.github.com/repos/malaquiasLAB/$REPO/deployments  | jq .[0] | jq .id)

echo "ID de deploy = $DEPLOYMENT_ID"
echo
echo "ID de run    = $RUN_ID"



