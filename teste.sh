#!/bin/bash

deploys=$(cat deploy.json)

echo ::set-output name=DEPLOYS::$deploys

echo $DEPLOYS

echo

echo $deploys
