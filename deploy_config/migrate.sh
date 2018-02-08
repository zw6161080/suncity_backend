#!/bin/sh
echo "ENV:"
env
echo "PWD:"
pwd
echo "waiting for postgres setup"
sleep 20
echo "start migrate"
bash -c 'cd /home/app/webapp; bundle exec rake db:migrate RAILS_ENV=docker';
bash -c 'cd /home/app/webapp; bundle exec rake migrate_data:load_predefined RAILS_ENV=docker';
echo "migrate finshed"
