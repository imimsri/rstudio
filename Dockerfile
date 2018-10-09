FROM rocker/verse:3.5

ARG SLURM_TAG=slurm-18-08-1-1

RUN apt-get update && apt-get -y dist-upgrade
RUN apt-get install -y squashfs-tools munge curl gcc make bzip2 supervisor python python-dev \
    libmunge-dev libmunge2 lua5.2 lua5.2-dev libopenmpi-dev openmpi-bin \
    gfortran vim python-mpi4py python-numpy python-psutil sudo psmisc \
    software-properties-common iputils-ping \
    openssh-server openssh-client default-jdk uuid-dev \
    build-essential \
    libssl-dev \
    uuid-dev \
    libgpgme11-dev wget git munge
    
#RUN echo deb http://ftp.de.debian.org/debian stretch main  >>/etc/apt/sources.list.d/testing.list
#RUN apt-get update
#RUN apt-get install -y slurm-wlm munge
RUN chown root /var/log/munge
RUN mkdir /var/run/munge
RUN chown root /var/lib/munge
RUN chown root /etc/munge/munge.key
RUN chmod 600 /etc/munge/munge.key
RUN chown root /etc/munge
RUN echo session-timeout-minutes=30 >>/etc/rstudio/rsession.conf
RUN echo limit-file-upload-size-mb=10240 >>/etc/rstudio/rsession.conf

# Install slurm
RUN set -x \
    && git clone https://github.com/SchedMD/slurm.git \
    && cd slurm \
    && git checkout tags/$SLURM_TAG \
    && ./configure --enable-debug --enable-front-end --prefix=/usr \
       --sysconfdir=/etc/slurm --with-mysql_config=/usr/bin \
       --libdir=/usr/lib64 \
    && make install \
    && install -D -m644 etc/cgroup.conf.example /etc/slurm/cgroup.conf.example \
    && install -D -m644 etc/slurm.conf.example /etc/slurm/slurm.conf.example \
    && install -D -m644 etc/slurmdbd.conf.example /etc/slurm/slurmdbd.conf.example \
    && install -D -m644 contribs/slurm_completion_help/slurm_completion.sh /etc/profile.d/slurm_completion.sh \
    && cd .. \
    && rm -rf slurm \
    && groupadd -r slurm  \
    && useradd -r -g slurm slurm 

RUN mkdir -p /etc/sysconfig/slurm \
        /var/spool/slurmd \
        /var/run/slurmd \
        /var/lib/slurmd \
        /var/log/slurm \
    && chown slurm:root /var/spool/slurmd \
        /var/run/slurmd \
        /var/lib/slurmd \
        /var/log/slurm 

#    && /sbin/create-munge-key

# Install singularity
RUN export VERSION=1.11 OS=linux ARCH=amd64 && cd /tmp && wget https://dl.google.com/go/go$VERSION.$OS-$ARCH.tar.gz && tar -C /usr/local -xzf go$VERSION.$OS-$ARCH.tar.gz
RUN echo 'export GOPATH=${HOME}/go' >> ~/.bashrc 
RUN echo 'export PATH=/usr/local/go/bin:${PATH}:${GOPATH}/bin' >> ~/.bashrc
ENV GOPATH /root/go
ENV PATH /usr/local/go/bin:${PATH}:${GOPATH}/bin
RUN mkdir -p $GOPATH/src/github.com/sylabs \
    && cd $GOPATH/src/github.com/sylabs && git clone https://github.com/sylabs/singularity.git && cd singularity  \
    && go get -u -v github.com/golang/dep/cmd/dep && cd $GOPATH/src/github.com/sylabs/singularity && ./mconfig && make -C builddir && make -C builddir install

# Install Nextflow
RUN cd /usr/local/bin && curl -fsSL get.nextflow.io | bash
RUN chmod +rw /usr/local/bin/nextflow

RUN install2.r rslurm

ADD userconf.sh /userconf.sh
RUN chmod +x /userconf.sh
CMD "/userconf.sh"
