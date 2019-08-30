#!/bin/bash

# Setup Script to be used in Debian (Tested with DietPi) - Requires sudo to be installed

# Install Required Packages
sudo apt-get update
sudo apt-get install python python-flask python-setuptools shellinabox iptables curl busybox debootstrap debian-archive-keyring dnsmasq -y
sudo apt-get --install-suggests install lxc lxc-templates bridge-utils python-lxc -y
sudo apt-get install python-dev libldap2-dev libsasl2-dev libffi-dev libssl-dev -y

# Install Node
curl -sL https://deb.nodesource.com/setup_8.x | sudo -E bash -
sudo apt-get update
sudo apt-get install build-essential nodejs npm -y

# Build Files
cd jsbuild
npm install
node_modules/.bin/bower install --allow-root
node_modules/.bin/grunt --allow-root
cd ..

# Install Python Package
sudo python setup.py install

# Copy Configuration Files
sudo mkdir /etc/lwp
sudo cp lwp.example.conf /etc/lwp/lwp.conf
sudo mkdir /var/lwp
sudo cp lwp.db /var/lwp/lwp.db

# Enable Bridge Interface
if [ ! -f '/etc/default/lxc-net' ]; then
   sudo echo 'USE_LXC_BRIDGE="false"' > /etc/default/lxc-net
   sudo echo 'LXC_BRIDGE="lxcbr0"' >> /etc/default/lxc-net
   sudo echo 'LXC_ADDR="10.0.3.1"' >> /etc/default/lxc-net
   sudo echo 'LXC_NETMASK="255.255.255.0"' >> /etc/default/lxc-net
   sudo echo 'LXC_NETWORK="10.0.3.0/24"' >> /etc/default/lxc-net
   sudo echo 'LXC_DHCP_RANGE="10.0.3.2,10.0.3.254"' >> /etc/default/lxc-net
   sudo echo 'LXC_DHCP_MAX="253"' >> /etc/default/lxc-net
fi

sudo systemctl disable dnsmasq
sudo systemctl stop dnsmasq

sudo systemctl enable lxc-net
sudo systemctl start lxc-net
sudo systemctl status lxc-net

# Copy Startup Script
sudo cp ./debian/lwp.service /etc/systemd/system/lwp.service
sudo systemctl enable lwp
sudo systemctl start lwp
sudo systemctl status lwp

# DONE
echo "SETUP FINISHED. Start LWP with command 'sudo lwp'"
echo "You might want to disable the shellinabox service if not used"
echo "To disable it run 'sudo systemctl disable shellinabox'
