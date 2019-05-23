#!/bin/bash

#MINING_ADDRESS

context=$1
namespace=$2
network=$3
miningAddress=`echo -n $4 | base64`
rpcuser=`echo -n $5 | base64`
rpcpass=`echo -n $6 | base64`
masternodeprivkey=`echo -n $7 | base64`

echo "encrypted miningAddress: ${miningAddress}"


networkSuffix=""
if [[ ${network} != "" ]]
then
    networkSuffix="-${network}"
fi

namespaceArg=""
if [[ ${namespace} != "" ]]
then
    namespaceArg="--namespace ${namespace}${networkSuffix}"
fi

echo "miningAddress: ${miningAddress}"
#echo "rpcpass: $6"
#echo "masternodeprivkey: ${masternodeprivkey}"

cat ./secrets.yml | sed "s/\X_MINING_ADDRESS_X/${miningAddress}/" | \
                    sed "s/\X_RPCUSER_X/${rpcuser}/" | \
                    sed "s/\X_RPCPASS_X/${rpcpass}/" | \
                    sed "s/\X_MASTERNODEPRIVKEY_X/${masternodeprivkey}/" | \
                    kubectl --context=${context} ${namespaceArg} create -f -

#cat ./secrets.yml | sed "s/\X_MINING_ADDRESS_X/${miningAddress}/"


#./create-secrets.sh minikube masternode-pivx-kube mainnet empty devuser_change devpass_change
#./create-secrets.sh minikube masternode-pivx-kube simnet empty devuser_change devpass_change
#./create-secrets.sh minikube masternode-pivx-kube regtest empty devuser_change devpass_change