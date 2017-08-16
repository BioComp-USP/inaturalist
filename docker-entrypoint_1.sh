#!/bin/sh
echo "INSTALL NODE MODULES"
npm install && npm install -g gulp && gulp default

echo "INAT PERMISSION"
chown -R inat /home/inat

echo "DB SETUP"
rake db:setup

echo "LOAD SOURCES"
rails r tools/load_sources.rb

echo "CREATE SITE"
rails r "Site.create( name: 'iNaturalist' )"
