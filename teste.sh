#!/bin/bash

curl -s -L \
                -H "Accept: application/vnd.github+json" \
                -H "Authorization: token $PAT" \
                -H "X-GitHub-Api-Version: 2022-11-28" \
                https://api.github.com/repos/malaquiasLAB/repo1/actions/runs?branch=main | \
                jq '.workflow_runs| map(select(.status == "waiting" and .head_branch == "main" and .path == ".github/workflows/workflow.yml" ))' 



#curl -s -H "Accept: application/vnd.github.v3+json" -H "Authorization: token $PAT }}" https://api.github.com/repos/malaquiasLAB/repo1/actions/runs | jq -r '.workflow_runs[] | select(.name == "workflow.yml") | select(.status == "waiting") | .id' 
