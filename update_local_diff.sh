#!/bin/bash
on:
  workflow_call:
    inputs:
      config-path:
        required: true
        type: string
    secrets:
      personal_access_token:
        required: true
INSTALLED=/c/oit/${BYOD}/`/usr/local/bin/coursegit`
#INSTALLED_VSC=/c/oit/${BYOD}/`/usr/local/bin/coursevscode`/data/appdata/Code/User/settings.json
INSTALLED_VSC=/c/oit/${BYOD}/`/usr/local/bin/coursevscode`/data/user-data/User/settings.json
INSTALLED_ETC=${INSTALLED}/etc/
INSTALLED_BIN=${INSTALLED}/usr/local/bin/

REPO=./PortableGit
REPO_ETC=${COURSEYEAR}/etc/
REPO_BIN=${COURSEYEAR}/local/bin/
REPO_VSC=${COURSEYEAR}/vscode/settings.json

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
    RsyncEnvironment ${INSTALLED_ETC} ${REPO_ETC}
    RsyncEnvironment ${INSTALLED_BIN} ${REPO_BIN}
    RsyncEnvironment ${INSTALLED_VSC} ${REPO_VSC}

  elif [ $input = 'no' ] || [ $input = 'NO' ] || [ $input = 'n' ] ; then

    echo "  同期を実行しません."

  else

    echo "  yes または no を入力して下さい."
    ConfirmExecution

  fi

}
function ConfirmVersionUpdate() {

  echo "----------------------------"
  echo "getversionのバージョン番号を更新しますか?"
  echo " 更新する場合は yes、しない場合は no と入力して下さい."
  read input

  if [ -z $input ] ; then

    echo "  yes または no を入力して下さい."
    ConfirmVersionUpdate

  elif [ $input = 'yes' ] || [ $input = 'YES' ] || [ $input = 'y' ] ; then

    echo "  getversionのバージョン番号を更新します."
    UpdateVersionNumber local

  elif [ $input = 'no' ] || [ $input = 'NO' ] || [ $input = 'n' ] ; then

    echo "  バージョン番号を更新しません."

  else

    echo "  yes または no を入力して下さい."
    ConfirmVersionUpdate

  fi

}
function RsyncEnvironment() {
  echo "$1から$2への同期を行います $3"
  rsync -av --checksum $3 \
        --exclude='bash.bash_logout'  \
        --exclude='bash.bashrc'  \
        --exclude='DIR_COLORS'  \
        --exclude='docx2txt.config'  \
        --exclude='fstab'  \
        --exclude='hosts'  \
        --exclude='inputrc'  \
        --exclude='msystem'  \
        --exclude='mtab'  \
        --exclude='nanorc'  \
        --exclude='networks'  \
        --exclude='package-versions.txt'  \
        --exclude='pkcs11'  \
        --exclude='pki'  \
        --exclude='protocols'  \
        --exclude='services'  \
        --exclude='ssh'  \
        --exclude='tigrc'  \
        --exclude='vimrc'  \
        $1 $2

}

function CheckDiff() {
ETC_IGNORED="-v -e bash.bash_logout
             -v -e bash.bashrc
             -v -e DIR_COLORS
             -v -e docx2txt.config
             -v -e fstab
             -v -e hosts
             -v -e inputrc
             -v -e msystem
             -v -e mtab
             -v -e nanorc
             -v -e networks
             -v -e package-versions.txt
             -v -e pkcs11
             -v -e pki
             -v -e protocols
             -v -e services
             -v -e ssh
             -v -e tigrc
             -v -e vimrc"

diff -r ${INSTALLED_ETC} ${REPO_ETC} | grep ${ETC_IGNORED}
diff ${INSTALLED_BIN} ${REPO_BIN}
diff ${INSTALLED_VSC} ${REPO_VSC}
}

# arg $1 is local
function UpdateVersionNumber() {
  echo "getversionを更新します"
  sed -i -E "s/\[localenv\][0-9]{12}/\[localenv\]`date "+%Y%m%d%H%M"`/g" ${INSTALLED_BIN}getversion
  sed -i -E "s/\[localenv\][0-9]{8}/\[localenv\]`date "+%Y%m%d"`/g" ${INSTALLED_BIN}getversion
}

RsyncEnvironment ${INSTALLED_ETC} ${REPO_ETC} --dry-run
RsyncEnvironment ${INSTALLED_BIN} ${REPO_BIN} --dry-run
RsyncEnvironment ${INSTALLED_VSC} ${REPO_VSC} --dry-run
CheckDiff

ConfirmExecution
