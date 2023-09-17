#!/bin/bash
set -e

# Проверить sudo
if [ "$(id -u)" != "0" ]; then
	echo "Please run script as root"
	exit 1
fi

# Get arguments
while getopts u: flag
do
	case "${flag}" in
		u) user=${OPTARG};;
	esac
done

# Цвета
COLOR='\033[95m'
ENDC='\033[0m'

SOURCES_DIR=/usr/src
BIN_DIR=/usr/bin
if [[ "$OSTYPE" =~ darwin.* ]]; then
	SOURCES_DIR=/usr/local/src
	BIN_DIR=/usr/local/bin
fi

# Установка компонентов python3
echo -e "${COLOR}[1/4]${ENDC} Installing required packages"
pip3 install Werkzeug json-rpc cloudscraper pyotp jsonpickle pyopenssl

# Клонирование репозиториев с github.com
echo -e "${COLOR}[2/4]${ENDC} Cloning github repository"
cd ${SOURCES_DIR}
rm -rf mtc-jsonrpc
git clone --recursive --single-branch --branch more-oses https://github.com/neodiX42/mtc-jsonrpc.git

# Прописать автозагрузку
echo -e "${COLOR}[3/4]${ENDC} Add to startup"
if [[ "$OSTYPE" =~ darwin.* ]]; then
  cmd="from sys import path; path.append('${SOURCES_DIR}/mytonctrl/'); from mypylib.mypylib import *; Add2LaunchdJsonServer(name='mtc-jsonrpc', user='${user}', start='/usr/bin/python3 ${SOURCES_DIR}/mtc-jsonrpc/mtc-jsonrpc.py')"
  python3 -c "${cmd}"
  launchctl stop system/mtc-jsonrpc
  launchctl start system/mtc-jsonrpc
else
  cmd="from sys import path; path.append('${SOURCES_DIR}/mytonctrl/'); from mypylib.mypylib import *; Add2Systemd(name='mtc-jsonrpc', user='${user}', start='/usr/bin/python3 ${SOURCES_DIR}/mtc-jsonrpc/mtc-jsonrpc.py')"
  python3 -c "${cmd}"
  systemctl restart mtc-jsonrpc
fi

# Выход из программы
echo -e "${COLOR}[4/4]${ENDC} JsonRPC installation complete"
exit 0
