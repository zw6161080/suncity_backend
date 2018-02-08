#!/bin/sh
echo "start update crontab"
bash -c "cd /home/app/webapp; bin/bundle exec whenever --update-crontab --set environment='docker'";
echo "update crontab finshed"
