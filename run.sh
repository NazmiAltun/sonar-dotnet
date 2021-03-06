#!/bin/bash -l

set -e

echo "Installing dotnet-sonarscanner...."
sh -c "dotnet tool install --global dotnet-sonarscanner --version 4.8.0"


begin_cmd="dotnet-sonarscanner begin \\
    /k:\"${PROJECT_KEY}\" \\
    /n:\"${PROJECT_NAME}\" \\
    /o:\"${ORGANIZATION}\" \\
    /d:sonar.host.url=\"${SONAR_SERVER_URL}\" \\
    /version:\"${GITHUB_RUN_NUMBER}\" \\
    /d:sonar.login=\"${SONAR_TOKEN:?Please set the SONAR_TOKEN environment variable.}\""

if [ -n "${OPENCOVER_REPORT_PATH}" ]
then
    # sh -c "sed -i 's/\/home\/runner\/work\/${GITHUB_REPOSITORY##*/}\/${GITHUB_REPOSITORY##*/}\//\/github\/workspace\//g' ${OPENCOVER_REPORT_PATH}"
    begin_cmd="$begin_cmd /d:sonar.cs.opencover.reportsPaths=\"${OPENCOVER_REPORT_PATH}\""
fi

if [ -n "${CPD_EXCLUSIONS}" ]
then
    begin_cmd="$begin_cmd /d:sonar.cpd.exclusions=\"${CPD_EXCLUSIONS}\""
fi

if [ -n "${PR_KEY}" ]
then
    begin_cmd="$begin_cmd /d:sonar.pullrequest.github.repository=\"${GITHUB_REPOSITORY}\" \\
    /d:sonar.pullrequest.github.branch=\"${GITHUB_REF#refs/heads/}\" \\
    /d:sonar.pullrequest.github.key=\"${PR_KEY}\""
fi

sh -c "$begin_cmd"
sh -c "dotnet restore --locked-mode ${SOLUTION_PATH}"
sh -c "dotnet build --no-restore -c Release ${SOLUTION_PATH}"
sh -c "dotnet-sonarscanner end /d:sonar.login=\"${SONAR_TOKEN}\""