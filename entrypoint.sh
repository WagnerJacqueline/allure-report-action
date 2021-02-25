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
  ALLURE_HISTORY="${INPUT_ALLURE_HISTORY}/${ALLURE_REPORT}"
  echo "NEW allure history folder ${ALLURE_HISTORY}"
  ## NEW allure history folder allure-history/allure-report-e2e
  ## NEW allure history folder allure-history/allure-report-e2e/allure-report-oracle
  ## NEW allure history folder allure-history/allure-report-e2e/allure-report-oracle/allure-report-postgre
  mkdir -p ./${ALLURE_HISTORY}
  NEW_GITHUB_PAGES_WEBSITE_URL="${GITHUB_PAGES_WEBSITE_URL}/${ALLURE_REPORT}"
  echo "NEW github pages url ${NEW_GITHUB_PAGES_WEBSITE_URL}"
  ## NEW github pages url https://DedalusDIIT.github.io/aar-dicom/allure-report-e2e
  ## NEW github pages url https://DedalusDIIT.github.io/aar-dicom/allure-report-e2e/allure-report-oracle
  ## NEW github pages url https://DedalusDIIT.github.io/aar-dicom/allure-report-e2e/allure-report-oracle/allure-report-postgre
  

  #echo "index.html"
  echo "<!DOCTYPE html><meta charset=\"utf-8\"><meta http-equiv=\"refresh\" content=\"0; URL=${NEW_GITHUB_PAGES_WEBSITE_URL}/${INPUT_GITHUB_RUN_NUM}/\">" >./${ALLURE_HISTORY}/index.html # path
  echo "<meta http-equiv=\"Pragma\" content=\"no-cache\"><meta http-equiv=\"Expires\" content=\"0\">" >>./${ALLURE_HISTORY}/index.html
  #cat ./${ALLURE_HISTORY}/index.html

  #echo "executor.json"
  echo '{"name":"GitHub Actions","type":"github","reportName":"Allure Report with history",' >executor.json
  echo "\"url\":\"${NEW_GITHUB_PAGES_WEBSITE_URL}\"," >>executor.json # ???
  echo "\"reportUrl\":\"${NEW_GITHUB_PAGES_WEBSITE_URL}/${INPUT_GITHUB_RUN_NUM}/\"," >>executor.json
  echo "\"buildUrl\":\"https://github.com/${INPUT_GITHUB_REPO}/actions/runs/${INPUT_GITHUB_RUN_ID}\"," >>executor.json
  echo "\"buildName\":\"GitHub Actions Run #${INPUT_GITHUB_RUN_ID}\",\"buildOrder\":\"${INPUT_GITHUB_RUN_NUM}\"}" >>executor.json
  #cat executor.json
  mv ./executor.json ./${d}

  #environment.properties
  echo "URL=${NEW_GITHUB_PAGES_WEBSITE_URL}" >environment.properties
  mv ./environment.properties ./${d}

  echo "keep allure history from ${ALLURE_HISTORY}/last-history to ${d}history"
  ## keep allure history from allure-history/allure-report-e2e/last-history to allure-results/e2e//history
  ## keep allure history from allure-history/allure-report-e2e/allure-report-oracle/last-history to allure-results/oracle//history
  ## keep allure history from allure-history/allure-report-e2e/allure-report-oracle/allure-report-postgre/last-history to allure-results/postgre//history
  cp -r ./${ALLURE_HISTORY}/last-history/. ./${d}history

  #echo "version ${INPUT_ALLURE_VERSION}"

  echo "generating report from ${d} to ${ALLURE_REPORT} ..."
  ## generating report from allure-results/e2e/ to allure-report-e2e ...
  ## generating report from allure-results/oracle/ to allure-report-oracle ...
  ## generating report from allure-results/postgre/ to allure-report-postgre ...
  #ls -l ${dS}
  allure generate --clean ${d} -o ${ALLURE_REPORT}
  ## Report successfully generated to allure-report-e2e
  ## Report successfully generated to allure-report-oracle
  #echo "listing report directory ..."
  #ls -l ${ALLURE_REPORT}

  echo "copy allure-report to ${ALLURE_HISTORY}/${INPUT_GITHUB_RUN_NUM}"
  ## copy allure-report to allure-history/allure-report-e2e/404
  ## copy allure-report to allure-history/allure-report-e2e/allure-report-oracle/404
  ## copy allure-report to allure-history/allure-report-e2e/allure-report-oracle/allure-report-postgre/404
  cp -r ./${ALLURE_REPORT}/. ./${ALLURE_HISTORY}/${INPUT_GITHUB_RUN_NUM}
  echo "copy allure-report history to /${ALLURE_HISTORY}/last-history"
  ## copy allure-report history to /allure-history/allure-report-e2e/last-history
  ## copy allure-report history to /allure-history/allure-report-e2e/allure-report-oracle/last-history
  ## copy allure-report history to /allure-history/allure-report-e2e/allure-report-oracle/allure-report-postgre/last-history
  cp -r ./${ALLURE_REPORT}/history/. ./${ALLURE_HISTORY}/last-history

done
