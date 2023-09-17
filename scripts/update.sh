#!/bin/bash
set -e

# Проверить sudo
if [ "$(id -u)" != "0" ]; then
	echo "Please run script as root"
	exit 1
fi

# Set default arguments
author="ton-blockchain"
repo="mytonctrl"
branch="master"
if [[ "$OSTYPE" =~ darwin.* ]]; then
  srcdir="/usr/local/src/"
  bindir="/usr/local/bin/"
else
  srcdir="/usr/src/"
  bindir="/usr/bin/"
fi

# Get arguments
while getopts a:r:b: flag
do
	case "${flag}" in
		a) author=${OPTARG};;
		r) repo=${OPTARG};;
		b) branch=${OPTARG};;
	esac
done

# Цвета
COLOR='\033[92m'
ENDC='\033[0m'

migrate() {
  folder=$1
  if [ ! -d "~root/.local/share/mytoncore/$folder/" ]; then
    mkdir -p ~root/.local/share/mytoncore/$folder
  fi
  cd ~root/.local/share/mytoncore/$folder/
  if [ $(find . -type f | grep -v .backup | wc -l) -ne 0 ] ; then
      for fn in $(find . -type f | grep -v .backup); do mv $fn $fn.backup; done
  fi
  if [ -d "/usr/local/bin/mytoncore/$folder" ]; then
    if [ $(find /usr/local/bin/mytoncore/$folder -type f | wc -l) -ne 0 ] ; then
      for fn in /usr/local/bin/mytoncore/$folder/*; do cp -R $fn $(basename $fn); done
    fi
  fi
  return 0
}

if [ ! -f "${srcdir}/updated" ]; then
  # Установка компонентов python3
  pip3 install fastcrc

  # Go to work dir
  cd ${srcdir}
  rm -rf ${srcdir}/${repo}

  # Update code
  echo "https://github.com/${author}/${repo}.git -> ${branch}"
  git clone --recursive https://github.com/${author}/${repo}.git
  cd ${repo} && git checkout ${branch} && git submodule update --init --recursive
  chmod +x ${srcdir}/mytonctrl/scripts/update.sh
  touch ${srcdir}/updated
  #restart current script
  ${srcdir}/mytonctrl/scripts/update.sh && exit
else
  rm ${srcdir}/updated
fi

# migrate old locations for root user
#if [ -f "/usr/local/bin/mytoncore/mytoncore.db" ]; then
#  echo -e "${COLOR}Migrating /usr/local/bin/ to $(echo ~root/.local/share/)${ENDC}"
#  migrate "pools"
#  migrate "contracts"
#  if migrate "wallets"; then
#    echo -e "${COLOR}Migration successful. Old data stored under /usr/local/bin/mytoncore.backup${ENDC}"
#    mv /usr/local/bin/mytoncore /usr/local/bin/mytoncore.backup
#  fi
#fi

if [[ "$OSTYPE" =~ darwin.* ]]; then
  launchctl bootout system /Library/LaunchDaemons/mytoncore.plist
  launchctl bootstrap system /Library/LaunchDaemons/mytoncore.plist
else
  systemctl restart mytoncore
fi

# Конец
echo -e "${COLOR}[1/1]${ENDC} MyTonCtrl components update completed"
exit 0
