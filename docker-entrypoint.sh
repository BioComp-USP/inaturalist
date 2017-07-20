#!/bin/sh
echo "SLEEP 5"
sleep 5

echo "DB SETUP"
rake db:setup

echo "ES START"
rake es:start

echo "ES REBUILD"
rake es:rebuild

echo "LOAD SOURCES"
rails r tools/load_sources.rb

echo "LOAD ICONIC TAXA"
rails r tools/load_iconic_taxa.rb

echo "CREATE SITE"
rails r "Site.create( name: 'iNaturalist' )"

echo "START DELAYED JOB"
./script/delayed_job start

echo "START APPLICATION"
bundle exec rails s -p 80 -b '0.0.0.0'