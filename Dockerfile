FROM debian:stretch
LABEL maintainer="Robert Rice"

ENV DEBIAN_FRONTEND noninteractive

# Install `apt` dependencies + cleanup.
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
       sudo systemd \
       build-essential \
       wget \
       libffi-dev \
       libssl-dev \
       python-pip \
       python-dev \
       python-setuptools \
       python-wheel \
    && rm -rf /var/lib/apt/lists/* \
    && rm -Rf /usr/share/doc \
    && rm -Rf /usr/share/man \
    && apt-get clean \
    && wget https://bootstrap.pypa.io/get-pip.py \
    && python get-pip.py

# Install `pip` dependencies
RUN pip install ansible \
    cryptography \
    yamllint \
    ansible-lint \
    flake8 \
    testinfra \
    molecule

# Drop in (fake) init script
COPY initctl_faker .
RUN chmod +x initctl_faker \
    && rm -fr /sbin/initctl \
    && ln -s /initctl_faker /sbin/initctl

# Stub out a basic inventory
RUN mkdir -p /etc/ansible
RUN echo "[local]\nlocalhost ansible_connection=local" > /etc/ansible/hosts

VOLUME ["/sys/fs/cgroup"]
CMD ["/lib/systemd/systemd"]
