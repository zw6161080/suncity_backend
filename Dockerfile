FROM phusion/passenger-ruby23

# 安裝依赖库以及文檔轉換的依賴Lib
RUN apt-get update && \
    apt-get install -y tzdata && \
    apt-get install -y libreoffice && \
    apt-get install -y graphviz && \
    apt-get install -y fonts-wqy-zenhei fonts-wqy-microhei fonts-arphic-ukai fonts-arphic-uming && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN echo "Asia/Shanghai" > /etc/timezone
RUN dpkg-reconfigure -f noninteractive tzdata

ENV HOME /root
CMD ["/sbin/my_init"]

# 安裝依賴
WORKDIR /tmp
COPY ./deploy_config/freetds-1.00.15.tar.gz freetds-1.00.15.tar.gz
RUN ls -l && \
    tar -xzvf ./freetds-1.00.15.tar.gz && \
    cd freetds-1.00.15 && \
    ./configure && \
    make && \
    make install
ADD ./Gemfile Gemfile
ADD ./Gemfile.lock Gemfile.lock
RUN gem install bundler
RUN bundle install

# 啟用和配置Nginx
RUN rm -f /etc/service/nginx/down && rm /etc/nginx/sites-enabled/default
ADD deploy_config/nginx.docker.conf /etc/nginx/sites-enabled/webapp.conf
ADD deploy_config/nginx.http_setting.conf /etc/nginx/conf.d/http_setting.conf
ADD deploy_config/nginx.env.conf /etc/nginx/main.d/nginx-env.conf

# 准备初始化运行脚本
RUN mkdir -p /etc/my_init.d
# 1. Migrate
ADD deploy_config/migrate.sh /etc/my_init.d/31_migrate.sh
# 2. Run SideKiq as Daemon
RUN mkdir /etc/service/sidekiq
ADD deploy_config/sidekiq_run.sh /etc/service/sidekiq/run
# 3. Update Crontab
ADD deploy_config/whenever.sh /etc/my_init.d/whenever.sh

EXPOSE 80

# 加入源码
ADD . /home/app/webapp

# 創建Log,修改讀寫權限
RUN touch /home/app/webapp/log/docker.log && \
    touch /home/app/webapp/log/sidekiq.log && \
    chown -R app:app /home/app/webapp

WORKDIR /home/app/webapp

# 創建數據庫配置文件
RUN cp config/database.template.yml config/database.yml

# 生成 Swagger UI 文檔
RUN cat /home/app/webapp/public/api_doc.yaml | \
    ruby -r yaml -r json -e 'puts YAML.load($stdin.read).to_json' | \
    /sbin/setuser app tee -a /home/app/webapp/public/api_doc.json

