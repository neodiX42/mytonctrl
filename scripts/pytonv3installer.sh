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
COLOR='\033[92m'
ENDC='\033[0m'

SOURCES_DIR=/usr/src
BIN_DIR=/usr/bin
if [[ "$OSTYPE" =~ darwin.* ]]; then
	SOURCES_DIR=/usr/local/src
	BIN_DIR=/usr/local/bin
fi

# Установка компонентов python3
echo -e "${COLOR}[1/4]${ENDC} Installing required packages"
pip3 install pipenv==2022.3.28

# Клонирование репозиториев с github.com
echo -e "${COLOR}[2/4]${ENDC} Cloning github repository"
cd ${SOURCES_DIR}
rm -rf pytonv3
#git clone https://github.com/EmelyanenkoK/pytonv3
git clone https://github.com/igroman787/pytonv3

# Установка модуля
cd ${SOURCES_DIR}/pytonv3
python3 setup.py install

# Скомпилировать недостающий бинарник
cd ${BIN_DIR}/ton && make tonlibjson

# Прописать автозагрузку
echo -e "${COLOR}[3/4]${ENDC} Add to startup"
if [[ "$OSTYPE" =~ darwin.* ]]; then
  cmd="from sys import path; path.append('${SOURCES_DIR}/mytonctrl/'); from mypylib.mypylib import *; Add2LaunchdPytonv3(name='pytonv3', user='${user}', workdir='${SOURCES_DIR}/pytonv3', start='${BIN_DIR}/python3 -m pyTON --liteserverconfig ${BIN_DIR}/ton/local.config.json --libtonlibjson ${BIN_DIR}/ton/tonlib/libtonlibjson.so')"
  python3 -c "${cmd}"
  launchctl kickstart -k system/ pytonv3
else
  cmd="from sys import path; path.append('${SOURCES_DIR}/mytonctrl/'); from mypylib.mypylib import *; Add2Systemd(name='pytonv3', user='${user}', workdir='${SOURCES_DIR}/pytonv3', start='${BIN_DIR}/python3 -m pyTON --liteserverconfig ${BIN_DIR}/ton/local.config.json --libtonlibjson ${BIN_DIR}/ton/tonlib/libtonlibjson.so')"
  python3 -c "${cmd}"
  systemctl restart pytonv3
fi

# Конец
echo -e "${COLOR}[4/4]${ENDC} pyTONv3 installation complete"
exit 0
