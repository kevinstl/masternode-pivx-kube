#!/bin/bash

#ex: ./create-pv.sh minikube masternode-pivx-kube-testnet testnet

context=$1
namespace=$2
networkSuffix=$3
network=$4
storage=$5
deployEnv=$6

echo "create-pv.sh"

echo "context: ${context}"
echo "namespace: ${namespace}"
echo "networkSuffix: ${networkSuffix}"
echo "network: ${network}"
echo "storage: ${storage}"
echo "deployEnv: ${deployEnv}"

kubeContextArg=""
if [[ ${context} != "" ]]
then
    kubeContextArg="--kube-context ${context}"
fi

namespaceArg=""
if [[ ${namespace} != "" ]]
then
    namespaceArg="--namespace ${namespace}"
fi

pvYaml="./masternode-pivx-kube-pvc.yaml"
if [[ ${deployEnv} == "gke" ]]
then
    pvYaml="./masternode-pivx-kube-pvc-gke.yaml"
fi

if [[ ${deployEnv} != "gke" ]]
then
    cat ./masternode-pivx-kube-pv.yaml | sed "s/\X_NETWORK_SUFFIX_X/${networkSuffix}/" | sed "s/\X_STORAGE_X/${storage}/" | sed "s/\X_NETWORK_X/${network}/" | kubectl ${kubeContextArg} ${namespaceArg} create -f -
fi

cat ${pvYaml} | sed "s/\X_NETWORK_SUFFIX_X/${networkSuffix}/" | sed "s/\X_STORAGE_X/${storage}/" | kubectl ${kubeContextArg} ${namespaceArg} create -f -

#cat ./masternode-pivx-kube-pvc.yaml | sed "s/\X_NETWORK_SUFFIX_X/${networkSuffix}/" | kubectl ${kubeContextArg} ${namespaceArg} create -f -

#./create-pv.sh "" masternode-pivx-kube-simnet -simnet simnet 5Gi gke
#./create-pv.sh "" masternode-pivx-kube-regtest -regtest regtest 5Gi gke

#./create-pv.sh "" masternode-pivx-kube-regtest -regtest regtest 25Gi gke

#./create-pv.sh "" masternode-pivx-kube-mainnet -mainnet mainnet 5Gi
#./create-pv.sh "" masternode-pivx-kube-mainnet -mainnet mainnet 275Gi gke



#./create-pv.sh "" masternode-pivx-kube "" "" 5Gi
#./create-pv.sh "" masternode-pivx-kube "" "" 5Gi gke