FROM ubuntu:16.04
ENV container docker
ENV LC_ALL C
ENV DEBIAN_FRONTEND noninteractive

#RUN sed -i "s/^exit 101$/exit 0/" /usr/sbin/policy-rc.d

# Install common dependencies
RUN apt-get -y clean && apt-get -y update && apt-get install -qqyf \
    ca-certificates \
    lxc \
    iptables \
    jq \
    software-properties-common \
    apt-transport-https \
    curl \
    git


#Delete systemd services we do not need
RUN (cd /lib/systemd/system/sysinit.target.wants/; for i in *; do [ $i == systemd-tmpfiles-setup.service ] || rm -f $i; done); \
    rm -f /lib/systemd/system/multi-user.target.wants/*;\
    rm -f /etc/systemd/system/*.wants/*;\
    rm -f /lib/systemd/system/local-fs.target.wants/*; \
    rm -f /lib/systemd/system/sockets.target.wants/*udev*; \
    rm -f /lib/systemd/system/sockets.target.wants/*initctl*; \
    rm -f /lib/systemd/system/basic.target.wants/*;\
    rm -f /lib/systemd/system/anaconda.target.wants/*;


RUN apt-get update &&\
    apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D &&\
    apt-add-repository 'deb https://apt.dockerproject.org/repo ubuntu-xenial main' &&\
    apt-get update -qq &&\
    apt-cache policy docker-engine &&\
    apt-get install -qqyf docker-engine=1.12.6-0~ubuntu-xenial && \
    rm -rfv /var/run/docker.sock


#*****************************************
#Install k8s
#*****************************************
#Step 1 - Install kubeadm dependencies
#Step 2 - Install components
RUN curl -sSL https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add - &&\
    echo deb http://apt.kubernetes.io/ kubernetes-xenial main >> /etc/apt/sources.list.d/kubernetes.list &&\
    apt-get update -qq && apt-get install -qqy \
        kubelet \
        kubectl \
        kubernetes-cni
#*****************************************


#*****************************************
#Install go and configure
#*****************************************
RUN apt-get install -yq python-software-properties &&\
    apt-get install -qqy golang &&\
    mkdir -p /workspace/go/bin &&\
    echo "export GOPATH=/workspace/go" >> ~/.bashrc &&\
    echo "export GOROOT=/usr/lib/go" >> ~/.bashrc &&\
    echo "export GOBIN=/workspace/go/bin" >> ~/.bashrc &&\
    echo "PATH=$PATH:$GOBIN:$GOPATH:$GOROOT" >> ~/.bashrc
#*****************************************

ENV GOPATH /workspace/go
ENV GOROOT /usr/lib/g
ENV GOBIN /workspace/go/bin
ENV PATH $PATH:$GOBIN:$GOPATH:$GOROOT

#Install glide
RUN curl https://glide.sh/get | sh

#Install cep-commons
RUN apt-get install -qqy ceph-common

VOLUME /sys/fs/cgroup
VOLUME /lib/modules
VOLUME /sys



CMD /sbin/init