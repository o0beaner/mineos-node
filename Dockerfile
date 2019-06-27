FROM debian:stretch
MAINTAINER Tyler Bean <tyler.j.bean@gmail.com

#update and accept all prompts
RUN apt-get update && apt-get install -y \
  supervisor \
  rdiff-backup \
  screen \
  procps \
  rsync \
  git \
  curl \
  rlwrap \
  default-jre-headless \
  ca-certificates-java \
  && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

#install node from nodesource
RUN curl https://deb.nodesource.com/node_8.x/pool/main/n/nodejs/nodejs_8.9.4-1nodesource1_amd64.deb > node.deb \
 && dpkg -i node.deb \
 && rm node.deb

#download mineos from github
RUN mkdir /usr/games/minecraft \
  && cd /usr/games/minecraft \
  && git clone --depth=1 https://github.com/o0beaner/mineos-node.git . \
  && sed -i 's/true/false/g' mineos.conf \
  && cp mineos.conf /etc/mineos.conf \
  && chmod +x webui.js mineos_console.js service.js

#build npm deps and clean up apt for image minimalization
RUN cd /usr/games/minecraft \
  && apt-get update \
  && apt-get install -y build-essential \
  && npm install \
  && apt-get remove --purge -y build-essential \
  && apt-get autoremove -y \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

#configure and run supervisor
RUN cp /usr/games/minecraft/init/supervisor_conf /etc/supervisor/conf.d/mineos.conf

#entrypoint allowing for setting of mc password
COPY entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]

EXPOSE 8443 25565-25570
VOLUME /var/games/minecraft
