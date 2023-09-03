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

# Установка компонентов python3
pip3 install fastcrc

# Go to work dir
cd ${srcdir}
rm -rf ${srcdir}/${repo}

# Update code
echo "https://github.com/${author}/${repo}.git -> ${branch}"
git clone --recursive https://github.com/${author}/${repo}.git
cd ${repo} && git checkout ${branch} && git submodule update --init --recursive

if [ -f "/usr/local/bin/mytoncore/mytoncore.db" ]; then
  # migrate old locations
  # todo
  echo Migrating old...
fi
#migrate to ~/.local/share
if [[ "$OSTYPE" =~ darwin.* ]]; then
  kickstart -k system/mytoncore
else
  systemctl restart mytoncore
fi

# Конец
echo -e "${COLOR}[1/1]${ENDC} MyTonCtrl components update completed"
exit 0
