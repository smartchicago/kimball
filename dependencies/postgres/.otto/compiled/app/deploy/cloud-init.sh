#!/bin/bash
set -e

# Install cURL if we have to
apt-get update -y
apt-get install -y curl

# Install Docker
curl -sSL https://get.docker.com/ | sh

# Create the container
docker create -p 5432:5432 POSTGRES_PASSWORD=mysecretpassword --name="postgres" postgres

# Write the service
cat >/etc/init/postgres.conf <<EOF
description "Docker container: postgres"

start on filesystem and started docker
stop on runlevel [!2345]

respawn

post-stop exec sleep 5

script
  /usr/bin/docker start postgres
end script
EOF

# Start the service
start postgres
