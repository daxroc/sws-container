FROM ubuntu:24.04

LABEL org.opencontainers.image.source="https://github.com/daxroc/sws-container"
LABEL org.opencontainers.image.description="General-purpose Docker debug container"
LABEL org.opencontainers.image.url="https://github.com/daxroc/sws-container"

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
    iftop \
    nethogs \
    whois \
    ipcalc \
    iputils-arping \
    hping3 \
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
    fio \
    inotify-tools \
    # --- Process ---
    procps \
    htop \
    sysstat \
    strace \
    ltrace \
    gdb \
    linux-tools-common \
    util-linux \
    stress-ng \
    pv \
    atop \
    dstat \
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
    openssh-client \
    unzip \
    zip \
    gnupg \
    && rm -rf /var/lib/apt/lists/* \
    && ARCH=$(dpkg --print-architecture) \
    && curl -fsSL "https://dl.k8s.io/release/$(curl -fsSL https://dl.k8s.io/release/stable.txt)/bin/linux/${ARCH}/kubectl" \
       -o /usr/local/bin/kubectl \
    && chmod +x /usr/local/bin/kubectl

WORKDIR /workspace

ENTRYPOINT ["/bin/bash"]
