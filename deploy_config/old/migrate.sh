#!/bin/sh
echo "start migrate"
bash -c 'cd /home/app/webapp; bundle exec rake db:migrate';
echo "migrate finshed"
