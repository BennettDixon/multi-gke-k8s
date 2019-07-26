#!/usr/bin/env bash
# deploy script for kubernetes cluster to google cloud

# build our production images for pushing to hub
docker build -t bennettdixon16/multi-client:latest -t bennettdixon16/multi-client:$GIT_SHA -f ./client/Dockerfile ./client
docker build -t bennettdixon16/multi-server:latest -t bennettdixon16/multi-server:$GIT_SHA -f ./server/Dockerfile ./server
docker build -t bennettdixon16/multi-worker:latest -t bennettdixon16/multi-worker:$GIT_SHA -f ./worker/Dockerfile ./worker

# push to docker hub (already logged in via travis)
docker push bennettdixon16/multi-client:latest
docker push bennettdixon16/multi-server:latest
docker push bennettdixon16/multi-worker:latest
docker push bennettdixon16/multi-client:$GIT_SHA
docker push bennettdixon16/multi-server:$GIT_SHA
docker push bennettdixon16/multi-worker:$GIT_SHA

# apply new configurations via gcloud (logged in via travis)
# IMPORTANT TO NOTE WE ARE LOGGED INTO GCLOUD VIA TRAVIS SO THIS EFFECTS PROD
kubectl apply -f k8s
# update the image the deployment uses (name unique to project)
kubectl set image deployments/server-deployment server=bennettdixon16/multi-server:$GIT_SHA
kubectl set image deployments/worker-deployment worker=bennettdixon16/multi-worker:$GIT_SHA
kubectl set image deployments/client-deployment client=bennettdixon16/multi-client:$GIT_SHA