#!/bin/bash

# Setup Script to be used in Debian (Tested with DietPi) - Requires sudo to be installed

# Install Required Packages
sudo apt-get update
sudo apt-get install lxc bridge-utils python python-lxc python-flask python-setuptools shellinabox iptables curl
sudo apt-get install python-dev libldap2-dev libsasl2-dev libffi-dev libssl-dev

# Install Node
curl -sL https://deb.nodesource.com/setup_8.x | sudo -E bash -
sudo apt-get update
sudo apt-get install build-essential nodejs

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
fi
sudo systemctl enable lxc-net
sudo systemctl start lxc-net
sudo systemctl status lxc-net

# DONE
echo "SETUP FINISHED. Start LWP with command 'sudo lwp'"
echo "You might want to disable the shellinabox service if not used"
echo "To disable it run 'sudo systemctl disable shellinabox'
