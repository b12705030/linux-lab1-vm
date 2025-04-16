FROM ubuntu:24.04

ENV container docker
ENV DEBIAN_FRONTEND=noninteractive

RUN apt update && apt install -y \
    systemd \
    sudo \
    cron \
    vim \
    nano \
    net-tools \
    procps \
    openssh-server \
 && apt clean && rm -rf /var/lib/apt/lists/*

RUN useradd -ms /bin/bash student && \
    echo "student:student" | chpasswd && \
    adduser student sudo

COPY break_system.sh /usr/local/bin/break_system.sh
COPY logme_cron.sh /usr/local/bin/logme_cron.sh
COPY watcher.sh /usr/local/bin/watcher.sh
COPY reset.sh /usr/local/bin/reset.sh
COPY status.sh /usr/local/bin/status.sh
RUN chmod +x /usr/local/bin/*.sh

USER student
CMD ["/bin/bash"]
