FROM ubuntu:16.04
ENV container docker
ENV LC_ALL C
ENV DEBIAN_FRONTEND noninteractive

RUN sed -i "s/^exit 101$/exit 0/" /usr/sbin/policy-rc.d

#RUN echo "nameserver 10.211.55.1" | tee /etc/resolv.conf > /dev/null
RUN echo "nameserver 8.8.8.8" | tee /etc/resolv.conf > /dev/null
#RUN systemctl daemon-reload
#RUN systemctl restart docker

RUN apt-get -y clean


# Install common dependencies
RUN apt-get -y update
RUN apt-get install -qqy \
    apt-transport-https \
    ca-certificates \
    curl \
    lxc \
    iptables \
    linux-image-$(uname -r) \
    linux-image-extra-$(uname -r) \
    linux-image-extra-virtual \
    jq \
    software-properties-common \
    git

COPY setup-rook-test-infra /usr/bin/setup-rook-test-infra

RUN chown root /usr/bin/setup-rook-test-infra
RUN chmod 755 /usr/bin/setup-rook-test-infra



#COPY setup /etc/init.d/setup-rook-infra
#RUN chmod +x /etc/init.d/setup-rook-infra
#RUN update-rc.d setup-rook-infra defaults

#Delete systemd services we do not need
RUN (cd /lib/systemd/system/sysinit.target.wants/; for i in *; do [ $i == systemd-tmpfiles-setup.service ] || rm -f $i; done); \
rm -f /lib/systemd/system/multi-user.target.wants/*;\
rm -f /etc/systemd/system/*.wants/*;\
rm -f /lib/systemd/system/local-fs.target.wants/*; \
rm -f /lib/systemd/system/sockets.target.wants/*udev*; \
rm -f /lib/systemd/system/sockets.target.wants/*initctl*; \
rm -f /lib/systemd/system/basic.target.wants/*;\
rm -f /lib/systemd/system/anaconda.target.wants/*;


#*****************************************
#Install Docker
#*****************************************

# Step 1 - Add Docker’s official GPG key
RUN curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -

# Step 2 -Add Docker stable repository
RUN add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"

# Step 3 - Install pinned & tested version of Docker-CE
RUN apt-get update -qq && apt-get install -qqy docker-ce=17.03.0~ce-0~ubuntu-xenial
#*****************************************


#*****************************************
#Install k8s
#*****************************************

#Step 1 - Install kubeadm dependencies
RUN curl -sSL https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
RUN echo deb http://apt.kubernetes.io/ kubernetes-xenial main >> /etc/apt/sources.list.d/kubernetes.list

#Step 2 - Install components
RUN apt-get update -qq && apt-get install -qqy \
    kubelet \
    kubectl \
    kubernetes-cni
#*****************************************

#Install ceph-common
RUN apt-get install -qqy ceph-common

#COPY rc.local /etc/rc.local
#RUN chown root /etc/rc.local
#RUN chmod 755 /etc/rc.local

VOLUME /sys/fs/cgroup
VOLUME /lib/modules
VOLUME /var/lib/docker
VOLUME /sys
#VOLUME /var/run/docker.sock


#RUN ln -s /var/run/docker.sock /docker.sock

EXPOSE 8080

CMD /sbin/init
