#!/bin/bash

context=$1
namespace=$2
networkSuffix=$3
network=$4
deployEnv=$5

echo "delete-pv.sh"

echo "context: ${context}"
echo "namespace: ${namespace}"
echo "networkSuffix: ${networkSuffix}"
echo "network: ${network}"
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

cat ./masternode-pivx-kube-pvc.yaml | sed "s/\X_NETWORK_SUFFIX_X/${networkSuffix}/" | sed "s/\X_NETWORK_X/${network}/" | kubectl ${kubeContextArg} ${namespaceArg} delete -f -

if [[ ${deployEnv} != "gke" ]]
then
    cat ./masternode-pivx-kube-pv.yaml | sed "s/\X_NETWORK_SUFFIX_X/${networkSuffix}/" | kubectl ${kubeContextArg} ${namespaceArg} delete -f -
fi

#cat ./masternode-pivx-kube-pvc.yaml | sed "s/\X_NETWORK_SUFFIX_X/${networkSuffix}/" | kubectl ${kubeContextArg} ${namespaceArg} delete -f -


#./delete-pv.sh "" masternode-pivx-kube-simnet -simnet simnet gke
#./delete-pv.sh "" masternode-pivx-kube-regtest -regtest regtest gke
#./delete-pv.sh "" masternode-pivx-kube-mainnet -mainnet mainnet gke

#./delete-pv.sh "" masternode-pivx-kube "" ""