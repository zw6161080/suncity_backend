#! /bin/bash

cd /home/app/webapp
exec /sbin/setuser app bundle exec sidekiq -L log/sidekiq.log -C config/sidekiq.yml -e docker
