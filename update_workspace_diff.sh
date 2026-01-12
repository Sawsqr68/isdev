#!/bin/bash

INSTALLED=~/kadai/$COURSEYEAR/

REPO=./$COURSEYEAR/env/

function ConfirmExecution() {

  echo "----------------------------"
  echo "テスト環境(${INSTALLED})からリポジトリに同期しますか?"
  echo "  実行する場合は yes、実行をキャンセルする場合は no と入力して下さい."
  read input

  if [ -z $input ] ; then

    echo "  yes または no を入力して下さい."
    ConfirmExecution

  elif [ $input = 'yes' ] || [ $input = 'YES' ] || [ $input = 'y' ] ; then

    echo "  同期を実行します."
    ConfirmVersionUpdate
    RsyncEnvironment ${INSTALLED} ${REPO}

  elif [ $input = 'no' ] || [ $input = 'NO' ] || [ $input = 'n' ] ; then

    echo "  同期を実行しません."

  else

    echo "  yes または no を入力して下さい."
    ConfirmExecution

  fi

}
function ConfirmVersionUpdate() {

  echo "----------------------------"
  echo "Workspaceのバージョン番号を更新しますか?"
  echo " 更新する場合は yes、しない場合は no と入力して下さい."
  read input

  if [ -z $input ] ; then

    echo "  yes または no を入力して下さい."
    ConfirmVersionUpdate

  elif [ $input = 'yes' ] || [ $input = 'YES' ] || [ $input = 'y' ] ; then

    echo "  Workspaceのバージョン番号を更新します."
    UpdateVersionNumber

  elif [ $input = 'no' ] || [ $input = 'NO' ] || [ $input = 'n' ] ; then

    echo "  バージョン番号を更新しません."

  else

    echo "  yes または no を入力して下さい."
    ConfirmVersionUpdate

  fi

}
function RsyncEnvironment_old() {
  echo "$1から$2への同期を行います $3"
  rsync -avm --checksum $3 \
        --include='*/'  \
        --include='.version'  \
        --include='settings.json'  \
        --include='launch.json'  \
        --include='org.eclipse.jdt.core.prefs'  \
        --include='.classpath'  \
        --include='.project'  \
        --exclude='*'  \
        "$1" "$2"

}

function RsyncEnvironment() {
  echo "$1から$2への同期を行います $3"
  rsync -avm --checksum $3 \
        --include='.version' \
        --exclude='.log/*' \
        --exclude='*.git/' \
        --exclude='*.gradle/' \
        --exclude='*bin/' \
        --exclude='*build/' \
        "$1" "$2"

}

function UpdateVersionNumber() {
  echo "./log/.versionを更新します"
  echo [${COURSEYEAR}_workspace]`date "+%Y%m%d%H%M"` > ${INSTALLED}.log/.version
}

function CheckDiff() {
    diff -r ${INSTALLED} ${REPO} | grep -v -e '.*\.java' -e '.*\.class' -e '.*\.git.*' -e '.*\.7z' -e '.*\.md' -e '.*\.sh' -e '.*\.history*'

}

RsyncEnvironment ${INSTALLED} ${REPO} --dry-run
CheckDiff

ConfirmExecution
name: "CodeQL"
on:
  push:
    branches:
      - main
  pull_request:
    # تفعيل الفحص على طلبات السحب (Pull Requests)
    branches:
      - main
jobs:
  analyze:
    name: "Analyze"
    runs-on: ubuntu-latest
    steps:
      - name: "Checkout Repository"
        uses: actions/checkout@v3
      - name: "Set up CodeQL"
        uses: github/codeql-action/init@v2
        with:
          languages: "python, javascript" # يمكن التعديل حسب لغة المشروع
      - name: "Perform Code Scanning"
        uses: github/codeql-action/analyze@v2
