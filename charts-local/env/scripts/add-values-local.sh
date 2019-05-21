#!/bin/bash

projectBaseDir=$1
updatedValuesFile=$2

echo "projectBaseDir: ${projectBaseDir}"
echo "updatedValuesFile: ${updatedValuesFile}"

cat ${projectBaseDir}/scripts/templates/values-local.yaml >> ${updatedValuesFile}

