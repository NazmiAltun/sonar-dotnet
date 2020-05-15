#!/bin/bash -l

set -eu

echo "Installing dotnet-sonarscanner...."
sh -c "dotnet tool install --global dotnet-sonarscanner --version 4.8.0"


begin_cmd="/dotnet-sonarscanner begin \\
    /k:\"${PROJECT_KEY}\" \\
    /n:\"${PROJECT_NAME}\" \\
    /o:\"${ORGANIZATION}\" \\
    /d:sonar.host.url=\"${SONAR_SERVER_URL}\" \\
    /version:\"${GITHUB_RUN_NUMBER}\" \\
    /d:sonar.login=\"${SONAR_TOKEN:?Please set the SONAR_TOKEN environment variable.}\""

if [ -z "${OPENCOVER_REPORT_PATH}" ]
then
    # sh -c "sed -i 's/\/home\/runner\/work\/${GITHUB_REPOSITORY##*/}\/${GITHUB_REPOSITORY##*/}\//\/github\/workspace\//g' ${OPENCOVER_REPORT_PATH}"
    begin_cmd="$begin_cmd /d:sonar.cs.opencover.reportsPaths=\"${OPENCOVER_REPORT_PATH}\""
fi

if [ -z "${CPD_EXCLUSIONS}" ]
then
    begin_cmd="$begin_cmd /d:sonar.cpd.exclusions=\"${CPD_EXCLUSIONS}\""
fi

if [ -z "${PR_KEY}" ]
then
    begin_cmd="$begin_cmd /d:sonar.pullrequest.github.repository=\"${GITHUB_REPOSITORY}\" \\
    /d:sonar.pullrequest.github.branch=\"${GITHUB_REF#refs/heads/}\" \\
    /d:sonar.pullrequest.github.key=\"${PR_KEY}\""
fi

sh -c "$begin_cmd"
sh -c "dotnet build -c Release ${SOLUTION_PATH}"
sh -c "/dotnet-sonarscanner end /d:sonar.login=\"${SONAR_TOKEN}\""