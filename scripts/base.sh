#!/bin/bash

set -e
set -o pipefail

#### Overwrite the default Debian mirrors/sources with the Kali mirrors/sources
cat > /etc/apt/sources.list <<EOL
deb http://http.kali.org/kali kali-rolling main non-free contrib
EOL

#### Download and import the official Kali Linux key
wget -q -O - https://www.kali.org/archive-key.asc | gpg --import
gpg -a --export ED444FF07D8D0BF6 | sudo apt-key add -

#### Update our apt db
apt-get update

#### Install the Kali keyring
apt-get -y install kali-archive-keyring

#### Preconfigure things so our install will work without any user input
## mysql
pass=$(head -c 24 /dev/urandom | base64)
echo "MySQL Root Password: $pass"
debconf-set-selections <<< "mysql-server-5.6 mysql-server/root_password_again password $pass"
debconf-set-selections <<< "mysql-server-5.6 mysql-server/root_password password $pass"

## wireshark
debconf-set-selections <<< "wireshark-common wireshark-common/install-setuid boolean false"

## Kismet
debconf-set-selections <<< 'kismet kismet/install-setuid boolean false'
debconf-set-selections <<< 'kismet kismet/install-users string'

## sslh
debconf-set-selections <<< 'sslh sslh/inetd_or_standalone select standalone'

#### Prevent apt-get from asking us questions while isntalling software
export DEBIAN_FRONTEND=noninteractive

#### Install the base software
apt-get -o Dpkg::Options::="--force-confnew" -fuy dist-upgrade
apt-get -y install kali-linux-full

#### Update to the newest version of Kali
apt-get -y upgrade

#### Clean up after apt-get
apt-get -y autoremove --purge
apt-get -y clean
