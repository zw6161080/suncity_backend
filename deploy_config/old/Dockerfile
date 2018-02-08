FROM phusion/passenger-ruby23

RUN echo "Asia/Shanghai" > /etc/timezone
RUN dpkg-reconfigure -f noninteractive tzdata
RUN apt-get update && apt-get install -y libreoffice && apt-get install -y fonts-wqy-zenhei fonts-wqy-microhei fonts-arphic-ukai fonts-arphic-uming
ENV HOME /root
CMD ["/sbin/my_init"]

WORKDIR /tmp
ADD ./Gemfile Gemfile
ADD ./Gemfile.lock Gemfile.lock
RUN bundle install

RUN rm -f /etc/service/nginx/down && rm /etc/nginx/sites-enabled/default
ADD docker_config/nginx.conf /etc/nginx/sites-enabled/webapp.conf
ADD docker_config/nginx-env.conf /etc/nginx/main.d/nginx-env.conf

#增加初始化运行脚本
RUN mkdir -p /etc/my_init.d

#Migrate
ADD docker_config/migrate.sh /etc/my_init.d/31_migrate.sh

#SideKiq
RUN mkdir /etc/service/sidekiq
ADD docker_config/sidekiq_start.sh /etc/service/sidekiq/run

EXPOSE 80
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
ADD . /home/app/webapp
RUN touch /home/app/webapp/log/staging.log && touch /home/app/webapp/log/production.log && touch /home/app/webapp/log/sidekiq.log && chown -R app:app /home/app/webapp
WORKDIR /home/app/webapp
RUN cp config/database.ci.yml config/database.yml
RUN cat /home/app/webapp/public/api_doc.yaml | ruby -r yaml -r json -e 'puts YAML.load($stdin.read).to_json' | /sbin/setuser app tee -a /home/app/webapp/public/api_doc.json
