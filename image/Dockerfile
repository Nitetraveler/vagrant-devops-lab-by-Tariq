FROM ubuntu:24.04

ARG BOX_VERSION=dev
ARG EXTRA_PACKAGES=""
ARG DEBIAN_FRONTEND=noninteractive

# SSH server, sudo and python3 (needed later by Ansible), plus diagnostics tools
RUN apt-get update \
 && apt-get install -y --no-install-recommends \
      openssh-server openssh-client sudo python3 curl ca-certificates \
      iproute2 iputils-ping procps less ${EXTRA_PACKAGES} \
 && rm -rf /var/lib/apt/lists/*

# Vagrant conventions: user "vagrant", passwordless sudo, SSH key auth
RUN (userdel -r ubuntu 2>/dev/null || true) \
 && useradd -m -u 1000 -s /bin/bash vagrant \
 && echo 'vagrant:vagrant' | chpasswd \
 && echo 'vagrant ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/vagrant \
 && chmod 0440 /etc/sudoers.d/vagrant \
 && mkdir -p /home/vagrant/.ssh /run/sshd \
 && ssh-keygen -A

COPY vagrant_lab_key.pub /home/vagrant/.ssh/authorized_keys

RUN chown -R vagrant:vagrant /home/vagrant/.ssh \
 && chmod 0700 /home/vagrant/.ssh \
 && chmod 0600 /home/vagrant/.ssh/authorized_keys \
 && echo "devops/ubuntu2404 ${BOX_VERSION}" > /etc/box-release

EXPOSE 22
CMD ["/usr/sbin/sshd", "-D", "-e"]
