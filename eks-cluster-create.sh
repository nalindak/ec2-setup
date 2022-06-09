#!/bin/bash

export KEYPAIR_ID="key-xxxxxxxxx"
export REGION="xxxxxxx"
export NAME="xxxxxxxx"
export VERSION="1.22"
export SSH_KEY="key-name"
eksctl create cluster \
--name $NAME \
--version $VERSION \
--region $REGION \
--nodegroup-name linux-nodes \
--node-type c5.4xlarge \
--nodes 3 \
--nodes-min 1 \
--nodes-max 4 \
--ssh-access \
--ssh-public-key $SSH_KEY \
--managed
--verbose 4

# setup metrics server
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/download/v0.3.7/components.yaml