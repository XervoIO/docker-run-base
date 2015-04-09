#!/bin/bash
set -e
set -x

apt-get update
apt-get install -y supervisor git

# Copy supervisor's base configuration.
cp /opt/modulus/supervisord.conf /etc/supervisor/

# Setup supervisor's service.
mkdir /etc/service/supervisor/
cp /opt/modulus/supervisor-service.sh /etc/service/supervisor/run
