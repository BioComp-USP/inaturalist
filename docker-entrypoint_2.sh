#!/bin/sh
echo "START DELAYED JOB"
./script/delayed_job start

echo "START APPLICATION"
bundle exec rails s -p 80 -b '0.0.0.0'
