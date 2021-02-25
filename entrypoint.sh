#! /usr/bin/env bash

unset JAVA_HOME

mkdir -p ./${INPUT_GH_PAGES}
mkdir -p ./${INPUT_ALLURE_HISTORY}
cp -r ./${INPUT_GH_PAGES}/. ./${INPUT_ALLURE_HISTORY}

REPOSITORY_OWNER_SLASH_NAME=${INPUT_GITHUB_REPO}
REPOSITORY_NAME=${REPOSITORY_OWNER_SLASH_NAME##*/}
GITHUB_PAGES_WEBSITE_URL="https://${INPUT_GITHUB_REPO_OWNER}.github.io/${REPOSITORY_NAME}"
#echo "Github pages url $GITHUB_PAGES_WEBSITE_URL"

for d in ${INPUT_ALLURE_RESULTS}/*/; do

  SUBFOLDER=${d:${#INPUT_ALLURE_RESULTS}+1}
  SUBFOLDER=${SUBFOLDER%/*} # cut slash at the end

  ALLURE_REPORT="allure-report-${SUBFOLDER}"
  INPUT_ALLURE_HISTORY="${INPUT_ALLURE_HISTORY}/${ALLURE_REPORT}"
  echo "NEW allure history folder ${INPUT_ALLURE_HISTORY}"
  mkdir -p ./${INPUT_ALLURE_HISTORY}
  GITHUB_PAGES_WEBSITE_URL="${GITHUB_PAGES_WEBSITE_URL}/${ALLURE_REPORT}"
  echo "NEW github pages url ${GITHUB_PAGES_WEBSITE_URL}"

  #echo "index.html"
  echo "<!DOCTYPE html><meta charset=\"utf-8\"><meta http-equiv=\"refresh\" content=\"0; URL=${GITHUB_PAGES_WEBSITE_URL}/${INPUT_GITHUB_RUN_NUM}/\">" >./${INPUT_ALLURE_HISTORY}/index.html # path
  echo "<meta http-equiv=\"Pragma\" content=\"no-cache\"><meta http-equiv=\"Expires\" content=\"0\">" >>./${INPUT_ALLURE_HISTORY}/index.html
  #cat ./${INPUT_ALLURE_HISTORY}/index.html

  #echo "executor.json"
  echo '{"name":"GitHub Actions","type":"github","reportName":"Allure Report with history",' >executor.json
  echo "\"url\":\"${GITHUB_PAGES_WEBSITE_URL}\"," >>executor.json # ???
  echo "\"reportUrl\":\"${GITHUB_PAGES_WEBSITE_URL}/${INPUT_GITHUB_RUN_NUM}/\"," >>executor.json
  echo "\"buildUrl\":\"https://github.com/${INPUT_GITHUB_REPO}/actions/runs/${INPUT_GITHUB_RUN_ID}\"," >>executor.json
  echo "\"buildName\":\"GitHub Actions Run #${INPUT_GITHUB_RUN_ID}\",\"buildOrder\":\"${INPUT_GITHUB_RUN_NUM}\"}" >>executor.json
  #cat executor.json
  mv ./executor.json ./${d}

  #environment.properties
  echo "URL=${GITHUB_PAGES_WEBSITE_URL}" >environment.properties
  mv ./environment.properties ./${d}

  echo "keep allure history from ${INPUT_ALLURE_HISTORY}/last-history to ${d}/history"
  cp -r ./${INPUT_ALLURE_HISTORY}/last-history/. ./${d}/history

  #echo "version ${INPUT_ALLURE_VERSION}"

  echo "generating report from ${d} to ${ALLURE_REPORT} ..."
  #ls -l ${dS}
  allure generate --clean ${d} -o ${ALLURE_REPORT}
  #echo "listing report directory ..."
  #ls -l ${ALLURE_REPORT}

  echo "copy allure-report to ${INPUT_ALLURE_HISTORY}/${INPUT_GITHUB_RUN_NUM}"
  cp -r ./${ALLURE_REPORT}/. ./${INPUT_ALLURE_HISTORY}/${INPUT_GITHUB_RUN_NUM}
  echo "copy allure-report history to /${INPUT_ALLURE_HISTORY}/last-history"
  cp -r ./${ALLURE_REPORT}/history/. ./${INPUT_ALLURE_HISTORY}/last-history

done
