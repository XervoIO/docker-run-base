#!/bin/bash
set -e
set -x

# Base image sets these based on runtime.
# Need to set them back for bootstrapping the container.
TEMP_DIR=/tmp
TMPDIR=/tmp
TMP_DIR=/tmp

apt-get update
apt-get install -y supervisor python-setuptools build-essential \
  libmagickcore-dev libmagickwand-dev libjpeg8-dev libsqlite-dev \
  libexpat1 libexpat1-dev libicu-dev libpq-dev libcairo2-dev \
  libpango1.0-dev libgif-dev libxml2-dev libkrb5-dev \
  libunwind8 gettext libssl-dev libcurl4-openssl-dev zlib1g \
  uuid-dev ghostscript poppler-utils

easy_install superlance

# Copy supervisor's base configuration.
cp /opt/modulus/supervisord.conf /etc/supervisor/

# Setup supervisor's service.
mkdir /etc/service/supervisor/
cp /opt/modulus/supervisor-service.sh /etc/service/supervisor/run

# Rename versioned navi to just navi.
mv /opt/modulus/bin/navi* /opt/modulus/bin/navi

# Make things executable.
chmod +x /etc/service/supervisor/run
chmod +x /opt/modulus/bin/navi

# Install ImageMagick
export MAKEFLAGS="-j $(grep -c ^processor /proc/cpuinfo)"
cd /opt
wget http://www.imagemagick.org/download/ImageMagick.tar.gz
tar -xf ImageMagick.tar.gz && mv ImageMagick-* ImageMagick && cd ImageMagick && ./configure && make && sudo make install
# Disable coders that have known vulnerabilities in them
sed -i '/<policymap>/a <policy domain="coder" rights="none" pattern="EPHEMERAL" />\n  <policy domain="coder" rights="none" pattern="URL" />\n  <policy domain="coder" rights="none" pattern="HTTPS" />\n  <policy domain="coder" rights="none" pattern="MVG" />\n  <policy domain="coder" rights="none" pattern="MSL" />\n  <policy domain="coder" rights="none" pattern="TEXT" />\n  <policy domain="coder" rights="none" pattern="SHOW" />\n  <policy domain="coder" rights="none" pattern="WIN" />\n  <policy domain="coder" rights="none" pattern="PLT" />\n' /usr/local/etc/ImageMagick-7/policy.xml
ldconfig /usr/local/lib && rm -rf /opt/ImageMagick*

# Install GraphicsMagick
cd /opt
wget http://sourceforge.net/projects/graphicsmagick/files/graphicsmagick/1.3.23/GraphicsMagick-1.3.23.tar.gz
tar -xf GraphicsMagick-*
cd GraphicsMagick-*
./configure && make && make install
cd /opt && rm -rf cd GraphicsMagick-*

# Install ffmpeg
cd /opt
wget http://johnvansickle.com/ffmpeg/releases/ffmpeg-release-64bit-static.tar.xz
tar -xf ffmpeg-*
cd ffmpeg-*
cp ./* /usr/bin || true #ignore directory warning
rm -rf /opt/ffmpeg*

# Install phantomjs
cd /opt
wget https://bitbucket.org/ariya/phantomjs/downloads/phantomjs-1.9.8-linux-x86_64.tar.bz2
tar -xf phantomjs-*
mv phantomjs-*/bin/phantomjs /usr/bin/phantomjs
rm -rf phantomjs*

# Clean stuff up that's no longer needed
apt-get remove build-essential && apt-get purge build-essential
apt-get autoclean && apt-get autoremove -y && apt-get clean
