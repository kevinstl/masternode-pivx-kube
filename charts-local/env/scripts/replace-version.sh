#!/bin/bash

projectBaseDir=$1
newRequirementsFile=$2
app=$3
version=$4

echo "projectBaseDir: ${projectBaseDir}"
echo "newRequirementsFile: ${newRequirementsFile}"
echo "app: ${app}"
echo "version: ${version}"

requirementsTemplate=${projectBaseDir}/scripts/templates/requirements.yaml

generateNewRequirementsFile () {
    versionLine=$((${appLine} + ${offset}))

    echo "versionLine: ${versionLine}"

    pwd

    cat ${requirementsTemplate}

    cat ${requirementsTemplate} > ${newRequirementsFile}

    versionReplacement="  version: ${version}"

#    sed -i "" "${versionLine}s/.*/${versionReplacement}/" ${newRequirementsFile} #mac
    sed -i "${versionLine}s/.*/${versionReplacement}/" ${newRequirementsFile}

    cat ${newRequirementsFile}
}



offset=2

pwd
ls -al

appLine=$(grep -n ${app} ${requirementsTemplate} | head -n 1 | cut -d: -f1)

echo "appLine: ${appLine}"

if [[ ${appLine} != "" ]]
then
    generateNewRequirementsFile
else
    echo "Error generating requirements file."
    exit;
fi


