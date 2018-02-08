#! /bin/bash
cd /home/app/webapp
exec /sbin/setuser app bundle exec sidekiq -C config/sidekiq.yml
