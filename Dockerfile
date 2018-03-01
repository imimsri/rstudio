FROM rocker/verse

ENV SLURM_VER=16.05.3

RUN apt-get update && apt-get -y  dist-upgrade
RUN apt-get install -y squashfs-tools munge curl gcc make bzip2 supervisor python python-dev \
    libmunge-dev libmunge2 lua5.2 lua5.2-dev libopenmpi-dev openmpi-bin \
    gfortran vim python-mpi4py python-numpy python-psutil sudo psmisc \
    software-properties-common iputils-ping \
    openssh-server openssh-client default-jdk libuuid-devel
RUN echo deb http://ftp.de.debian.org/debian stretch main  >>/etc/apt/sources.list.d/testing.list
RUN apt-get update
RUN apt-get install -y slurm-wlm munge
RUN chown root /var/log/munge
RUN mkdir /var/run/munge
RUN chown root /var/lib/munge
RUN chown root /etc/munge/munge.key
RUN chmod 600 /etc/munge/munge.key
RUN chown root /etc/munge
RUN cd /usr/local/bin && curl -fsSL get.nextflow.io | bash
RUN chmod +rw /usr/local/bin/nextflow
RUN install2.r rslurm
RUN echo session-timeout-minutes=30 >>/etc/rstudio/rsession.conf
RUN echo limit-file-upload-size-mb=10240 >>/etc/rstudio/rsession.conf


# Install singularity
RUN apt-get update
RUN apt-get -y install build-essential curl git sudo man vim autoconf libtool default-jdk
RUN apt-get -y install python
RUN git clone https://github.com/singularityware/singularity.git
RUN cd singularity && git checkout development && ./autogen.sh && ./configure --prefix=/usr/local && make && make install
ADD userconf.sh /userconf.sh
RUN chmod +x /userconf.sh
CMD "/userconf.sh"
