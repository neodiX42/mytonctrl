#!/bin/bash
set -e

# Проверить sudo
if [ "$(id -u)" != "0" ]; then
	echo "Please run script as root"
	exit 1
fi

# Set default arguments
author="ton-blockchain"
repo="ton"
branch="master"

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

if [[ "$OSTYPE" =~ darwin.* ]]; then
  srcdir="/usr/local/src/"
  bindir="/usr/local/bin/"
	su $SUDO_USER -c "brew install secp256k1 libsodium ninja automake autogen autoconf libtool texinfo"
	export PKG_CONFIG_PATH="/opt/homebrew/opt/openssl@1.1/lib/pkgconfig"
else
  srcdir="/usr/src/"
  bindir="/usr/bin/"
  # Установить дополнительные зависимости
  apt-get install -y libsecp256k1-dev libsodium-dev ninja-build automake autogen autoconf libtool texinfo
fi


# bugfix if the files are in the wrong place
wget "https://ton-blockchain.github.io/global.config.json" -O global.config.json
if [ -f "/var/ton-work/keys/liteserver.pub" ]; then
    echo "Ok"
else
	echo "bugfix"
	mkdir /var/ton-work/keys
    cp ${bindir}/ton/validator-engine-console/client /var/ton-work/keys/client
    cp ${bindir}/ton/validator-engine-console/client.pub /var/ton-work/keys/client.pub
    cp ${bindir}/ton/validator-engine-console/server.pub /var/ton-work/keys/server.pub
    cp ${bindir}/ton/validator-engine-console/liteserver.pub /var/ton-work/keys/liteserver.pub
fi

# Go to work dir
cd ${srcdir}
rm -rf ${srcdir}/${repo}

# Update code
echo "https://github.com/${author}/${repo}.git -> ${branch}"
git clone --recursive https://github.com/${author}/${repo}.git
cd ${repo} && git checkout ${branch} && git submodule update --init --recursive
export CC=/usr/bin/clang
export CXX=/usr/bin/clang++
export CCACHE_DISABLE=1

# Update binary
cd ${bindir}/${repo}
ls --hide=global.config.json | xargs -d '\n' rm -rf
rm -rf .ninja_*
memory=$(cat /proc/meminfo | grep MemAvailable | awk '{print $2}')
let "cpuNumber = memory / 2100000" || cpuNumber=1
cmake -DCMAKE_BUILD_TYPE=Release ${srcdir}/${repo} -GNinja
ninja -j ${cpuNumber} fift validator-engine lite-client pow-miner validator-engine-console generate-random-id dht-server func tonlibjson rldp-http-proxy

if [[ "$OSTYPE" =~ darwin.* ]]; then
  launchctl kickstart -k system/validator
else
  systemctl restart validator
fi

# Конец
echo -e "${COLOR}[1/1]${ENDC} TON components update completed"
exit 0
