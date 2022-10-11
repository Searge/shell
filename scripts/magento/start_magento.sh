#!/bin/bash

set -e

project=$(hostname)
User='example'

cd /var/www/"${project}"/current

sudo -u"${User}" bin/magento setup:upgrade --keep-generated
sudo -u"${User}" bin/magento sampledata:deploy
