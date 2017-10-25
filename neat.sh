#!/bin/bash

# Uninstall older version of Docker if present
sudo apt-get remove docker docker-engine

# Update the apt package index
sudo apt-get update

# Install packages to allow apt to use a repository over HTTPS
sudo apt-get -y install \
    apt-transport-https \
    ca-certificates \
    curl \
    software-properties-common

# Add Docker’s official GPG key
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

# Set up the stable repository
sudo add-apt-repository \
    "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
    $(lsb_release -cs) \
    stable"

# Update the apt package index
sudo apt-get update

# Install the latest version of Docker Community Edition
sudo apt-get -y install docker-ce

# Install pip
sudo apt-get -y install python-pip

# Install Docker Compose
sudo pip install docker-compose

# Increase the memory map count for Elasticsearch
sudo sysctl -w vm.max_map_count=262144

# Make this setting permanent by editing /etc/sysctl.conf
echo "vm.max_map_count = 262144" | sudo tee -a /etc/sysctl.conf

# Download the Cyphondock Git repository into the /opt/cyphon directory
sudo git clone https://github.com/dunbarcyber/cyphondock.git /opt/cyphon/cyphondock

# Copy generic settings to the `config` directory for this project instance
cd /opt/cyphon/cyphondock/
sudo cp -R config-COPYME config

# Set up Elasticsearch and PostgreSQL data directories
sudo mkdir -p /opt/cyphon/data/elasticsearch
sudo mkdir /opt/cyphon/data/postgresql
sudo chown -R 1000:1000 /opt/cyphon/data/elasticsearch
sudo chown -R 999:999 /opt/cyphon/data/postgresql

# Build production environment
sudo docker-compose up -d

echo "Loading configurations"
sudo docker exec -it cyphondock_cyphon_1 sh -c "python manage.py loaddata ./fixtures/starter-fixtures.json"

echo "Create a user account for Cyphon"
echo "sudo docker exec -it cyphondock_cyphon_1 sh -c "python manage.py createsuperuser""

echo "Note: To get Twitter working, don't forget to enable the reservoir!"
echo "Note: You will need to add the index pattern on http://ip_addr:5601/ (cyphon-*)"
