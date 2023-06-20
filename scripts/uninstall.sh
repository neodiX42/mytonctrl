#!/bin/bash

# Проверить sudo
if [ "$(id -u)" != "0" ]; then
	echo "Please run script as root"
	exit 1
fi

# Цвета
COLOR='\033[34m'
ENDC='\033[0m'

if [[ "$OSTYPE" =~ darwin.* ]]; then
  # Остановка служб
  launchctl stop validator
  launchctl stop mytoncore
  launchctl stop dht-server

  # Переменные
  #str=$(launchctl cat mytoncore | grep User | cut -d '=' -f2)
  #user=$(echo ${str})

  # Удаление служб
  rm -rf /Library/LaunchDaemons/validator.plist
  rm -rf /Library/LaunchDaemons/mytoncore.plist
  rm -rf /Library/LaunchDaemons/dht-server.plist

  # Удаление файлов
  rm -rf /usr/local/src/ton
  rm -rf /usr/local/bin/ton
  rm -rf /usr/local/src/mytonctrl
  rm -rf /var/ton-work
  rm -rf /var/ton-dht-server
  rm -rf /tmp/myton*
  rm -rf /usr/local/bin/mytoninstaller/
  rm -rf /usr/local/bin/mytoncore/mytoncore.db
  rm -rf /home/$USER/.local/share/mytonctrl
  rm -rf /home/$USER/.local/share/mytoncore/mytoncore.db

  # Удаление ссылок
  rm -rf /usr/bin/fift
  rm -rf /usr/bin/liteclient
  rm -rf /usr/bin/validator-console
  rm -rf /usr/bin/mytonctrl
else
  # Остановка служб
  systemctl stop validator
  systemctl stop mytoncore
  systemctl stop dht-server

  # Переменные
  str=$(systemctl cat mytoncore | grep User | cut -d '=' -f2)
  user=$(echo ${str})

  # Удаление служб
  rm -rf /etc/systemd/system/validator.service
  rm -rf /etc/systemd/system/mytoncore.service
  rm -rf /etc/systemd/system/dht-server.service
  systemctl daemon-reload

  # Удаление файлов
  rm -rf /usr/src/ton
  rm -rf /usr/src/mytonctrl
  rm -rf /usr/bin/ton
  rm -rf /var/ton-work
  rm -rf /var/ton-dht-server
  rm -rf /tmp/myton*
  rm -rf /usr/local/bin/mytoninstaller/
  rm -rf /usr/local/bin/mytoncore/mytoncore.db
  rm -rf /home/${user}/.local/share/mytonctrl
  rm -rf /home/${user}/.local/share/mytoncore/mytoncore.db

  # Удаление ссылок
  rm -rf /usr/bin/fift
  rm -rf /usr/bin/liteclient
  rm -rf /usr/bin/validator-console
  rm -rf /usr/bin/mytonctrl
fi
# Конец
echo -e "${COLOR}Uninstall Complete${ENDC}"
