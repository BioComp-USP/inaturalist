#!/bin/sh
# echo "ELASTICSEARCH START"
# bundle exec rake es:start

# echo "ELASTICSEARCH REBUILD"
# bundle exec rake es:rebuild

echo "START DELAYED JOB"
./script/delayed_job start

echo "START APPLICATION"
bundle exec rails s -p 80 -b '0.0.0.0'
