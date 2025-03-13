#!/bin/bash

for ROW in $(cat deploy.json | jq -r '.[] | @base64'); do
 _jq() {
   echo ${ROW} | base64 --decode | jq -r ${1}
 }
  
 export REPOSITORY=$(_jq '.repository')
 export WORKFLOW_FILE=$(_jq '.workflow_file')
 export IMAGE_VERSION=$(_jq '.image_version')
 export ENVIRONMENT=$(_jq '.environment')
 export TRIGGER_WITH_APPROVE=$(_jq '.trigger_with_approve')
 export REPOSITORY_LOG=$(echo $REPOSITORY | awk -F'/' '{print $2}')
 export BRANCH="release/$IMAGE_VERSION"
                              
 _workflow_trigger_approve() {
    # get run_id
    RUN_ID=$(curl -s -L -H "Accept: application/vnd.github+json" \
    -H "Authorization: token ${{ secrets.PAT }}" \
    https://api.github.com/repos/$REPOSITORY/actions/runs?branch=$BRANCH | \
    jq '.workflow_runs | map(select(.status == "waiting" and .head_branch == "'$BRANCH'" and .path == ".github/workflows/'$WORKFLOW_FILE'"))' | \
    jq .[0] | jq .id)
                                 
    # get environment_ids
    ENVIRONMENT_ID=$(curl -s -L \
    -H "Accept: application/vnd.github.v3+json" \
    -H "Authorization: token ${{ secrets.PAT }}" \
    https://api.github.com/repos/$REPOSITORY/environments | \
    jq '.environments | map(select(.name == "'$ENVIRONMENT'"))' | \
    jq .[] | jq .id)
    
    echo "## trigger approve deployment"
    curl -s -L -X POST \
    -H "Accept: application/vnd.github+json" \
    -H "Authorization: token ${{ secrets.PAT }}" \
    https://api.github.com/repos/$REPOSITORY/actions/runs/$RUN_ID/pending_deployments \
    -d '{"environment_ids":['$ENVIRONMENT_ID'],"state":"approved","comment":"Auto aprovado pelo workflow automatizado!"}' | jq -r '.[] | .statuses_url' > statuses_url.txt
    STATUSES_URL=$(cat statuses_url.txt)
 }  
 _workflow_check_status(){             
    echo "## Check the status of the deployment"
    sleep 20
    DEPLOY_STATUS=$(curl -s -L \
    -H "Accept: application/vnd.github+json" \
    -H "Authorization: token ${{ secrets.PAT }}" \
    $STATUSES_URL | jq -r '.[0].state')
      if [ "$DEPLOY_STATUS" == "in_progress" ]; then
      echo "::notice ::INFO: Deployment for $REPOSITORY workflow $WORKFLOW_FILE was approved!"
      else
      echo "::warning ::WARNING!!! Deployment for $REPOSITORY workflow $WORKFLOW_FILE failed with status: $DEPLOY_STATUS"
      fi
 }
                          
 if [ "'$WORKFLOW_FILE'" = "deploy.yml" ] && [ "'$TRIGGER_WITH_APPROVE'" = "TRUE"] ; then
   echo "inicio da execucao!"
   _workflow_trigger_approve
   echo
   #_workflow_check_status
   exit 0
 else
   echo "::error ::ERROR!!! Invalid workflow file $WORKFLOW_FILE and variable $TRIGGER_WITH_APPROVE, workflow file expected here is deploy.yml and TRIGGER_WITH_APPROVE value TRUE" 
 fi
                    
 if [ "'$WORKFLOW_FILE'" = "release_deploy.yml" ] ; then
   echo "inicio da execucao!2"
   _workflow_trigger_approve
   echo
   #_workflow_check_status
   exit 0
 else
   echo "::error ::ERROR!!! Invalid workflow file $WORKFLOW_FILE, workflow file expected here is release_deploy.yml"
 fi  

done