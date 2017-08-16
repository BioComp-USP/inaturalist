FROM ruby:2.3.1
RUN mkdir /opt/java && cd /opt/java && \
    wget --no-cookies --no-check-certificate --header "Cookie: gpw_e24=http%3A%2F%2Fwww.oracle.com%2F; oraclelicense=accept-securebackup-cookie" "http://download.oracle.com/otn-pub/java/jdk/8u131-b11/d54c1d3a095b4ff2b6607d096fa80163/jdk-8u131-linux-x64.tar.gz" && \
    tar xzf jdk-8u131-linux-x64.tar.gz

RUN update-alternatives --install /usr/bin/java java /opt/java/jdk1.8.0_131/bin/java 1 && \
    update-alternatives --install /usr/bin/jar jar /opt/java/jdk1.8.0_131/bin/jar 1 && \
    update-alternatives --install /usr/bin/javac javac /opt/java/jdk1.8.0_131/bin/javac 1 && \
    update-alternatives --install /usr/bin/javaws javaws /opt/java/jdk1.8.0_131/bin/javaws 1 && \
    update-alternatives --set jar /opt/java/jdk1.8.0_131/bin/jar && \
    update-alternatives --set javac /opt/java/jdk1.8.0_131/bin/javac

ENV JAVA_HOME="/opt/java/jdk1.8.0_131" LANG="C.UTF-8" APP_HOME="/home/inat/web/"

RUN apt-get update -qq && apt-get install -y ruby-full ruby-execjs postgresql-client gdal-bin proj-bin libgeos-dev libgeos++-dev libproj-dev wkhtmltopdf nano

RUN curl -sL https://deb.nodesource.com/setup_5.x -o nodesource_setup.sh && bash nodesource_setup.sh && apt-get install -y nodejs

RUN useradd -m inat && usermod -aG sudo inat

RUN mkdir $APP_HOME

WORKDIR $APP_HOME

ADD . $APP_HOME

RUN bundle

RUN gem update

RUN bundle exec gem uninstall rgeo -a -I

RUN bundle install
