FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends \
    # --- Network ---
    iputils-ping \
    traceroute \
    mtr-tiny \
    dnsutils \
    net-tools \
    iproute2 \
    netcat-openbsd \
    socat \
    tcpdump \
    tshark \
    nmap \
    iperf3 \
    ethtool \
    bridge-utils \
    iptables \
    conntrack \
    openssl \
    ca-certificates \
    wget \
    curl \
    httpie \
    # --- Filesystem ---
    nfs-common \
    rpcbind \
    cifs-utils \
    sshfs \
    fuse3 \
    e2fsprogs \
    xfsprogs \
    dosfstools \
    parted \
    fdisk \
    gdisk \
    mount \
    lsof \
    tree \
    file \
    ncdu \
    rsync \
    # --- Process ---
    procps \
    htop \
    sysstat \
    strace \
    ltrace \
    gdb \
    linux-tools-common \
    util-linux \
    # --- General ---
    vim \
    less \
    jq \
    yq \
    bash-completion \
    man-db \
    tmux \
    git \
    python3 \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /workspace

ENTRYPOINT ["/bin/bash"]
