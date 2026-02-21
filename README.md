# sws-container

A general-purpose Docker debug container for troubleshooting network, filesystem, and process issues in Docker and Kubernetes environments.

## Included Tools

### Network

| Tool | Description |
|---|---|
| `ping`, `mtr` | Connectivity & latency |
| `traceroute` | Path tracing |
| `dig`, `nslookup` | DNS resolution |
| `ss`, `netstat` | Socket & connection state |
| `nc`, `socat` | Arbitrary TCP/UDP connections |
| `tcpdump`, `tshark` | Packet capture & analysis |
| `nmap` | Port scanning & service discovery |
| `iperf3` | Bandwidth testing |
| `iftop` | Real-time per-connection bandwidth |
| `nethogs` | Per-process network bandwidth |
| `ethtool` | NIC diagnostics |
| `brctl` | Bridge utilities |
| `iptables`, `conntrack` | Firewall & connection tracking |
| `arping` | ARP-level ping & duplicate IP detection |
| `hping3` | TCP/IP packet crafting & analysis |
| `curl`, `wget`, `httpie` | HTTP clients |
| `openssl` | TLS/SSL inspection |
| `whois` | Domain & IP ownership lookup |
| `ipcalc` | IP/subnet calculator |

### Filesystem

| Tool | Description |
|---|---|
| `mount`, `umount` | Mount/unmount filesystems |
| `showmount`, `mount.nfs`, `nfsstat` | NFS debugging |
| `rpcbind`, `rpcinfo` | RPC service inspection |
| `mount.cifs` | SMB/CIFS mounts |
| `sshfs` | FUSE-based SSH mounts (FUSE3) |
| `lsof` | Open file handles |
| `fdisk`, `gdisk`, `parted` | Partition tables |
| `e2fsprogs`, `xfsprogs`, `dosfstools` | Filesystem utilities |
| `ncdu` | Disk usage analysis |
| `rsync` | File synchronization |
| `fio` | Flexible I/O tester & benchmarking |
| `inotifywait`, `inotifywatch` | Filesystem event monitoring |
| `tree`, `file` | Directory & file inspection |

### Process

| Tool | Description |
|---|---|
| `ps`, `top`, `htop` | Process monitoring |
| `atop` | Advanced system & process monitor |
| `strace`, `ltrace` | Syscall & library call tracing |
| `gdb` | Debugger |
| `iostat`, `sar`, `mpstat` | System performance stats |
| `dstat` | Versatile resource stats |
| `stress-ng` | System stress testing |
| `pv` | Pipe throughput monitor |
| `lsns`, `nsenter` | Namespace inspection |

### General

| Tool | Description |
|---|---|
| `vim`, `less` | Editors & pagers |
| `jq`, `yq` | JSON & YAML processing |
| `tmux` | Terminal multiplexer |
| `git` | Version control |
| `python3` | Scripting |
| `ssh`, `scp` | Remote access |
| `zip`, `unzip` | Archive handling |
| `gpg` | Key & signature management |
| `bash-completion`, `man` | Shell productivity |

### Kubernetes

| Tool | Description |
|---|---|
| `kubectl` | Kubernetes CLI |

## Quick Start

```bash
# Pull from Docker Hub
docker pull dcroche/sws-container

# Run interactively
docker run -it --privileged dcroche/sws-container

# Run without privilege (inspection only — no mounting)
docker run -it dcroche/sws-container
```

> `--privileged` is required for operations like mounting filesystems, tracing processes, or inspecting network interfaces. For basic inspection you can omit it.

The default working directory inside the container is `/workspace`.

To build locally (single-platform, loads into local Docker):

```bash
docker buildx build --load -t dcroche/sws-container .
```

## Common Debugging Commands

### Network

```bash
# Test connectivity & latency
ping -c 4 <host>
mtr --report <host>

# DNS lookup
dig <hostname>

# Check listening ports and connections
ss -tlnp

# Capture traffic on a specific port
tcpdump -i any port 2049 -w /workspace/capture.pcap

# Scan open ports on a host
nmap -sT <host>

# Test bandwidth
iperf3 -c <host>

# Inspect TLS certificate
openssl s_client -connect <host>:443 </dev/null
```

### Filesystem

```bash
# List NFS exports
showmount -e <nfs-server>

# Check RPC services
rpcinfo -p <nfs-server>

# Mount NFS share
mount -t nfs <nfs-server>:/export/path /mnt

# Trace mount syscalls
strace -e trace=network,file mount -t nfs <server>:/path /mnt

# Find open files on a mount
lsof +f -- /mnt

# Disk usage analysis
ncdu /mnt
```

### Process

```bash
# Interactive process monitor
htop

# Trace syscalls of a running process
strace -p <pid>

# System performance overview
sar -u 1 5

# List namespaces
lsns

# Enter a container's namespace from the host
nsenter -t <pid> -m -u -i -n -p
```

## Kubernetes Debug Pod

Attach a debug pod running this image to a specific node using `kubectl debug`.

### Using the `sysadmin` profile

```bash
kubectl debug node/<node-name> -it \
  --image=dcroche/sws-container \
  --profile=sysadmin
```

This grants elevated capabilities (e.g. `SYS_PTRACE`, `SYS_ADMIN`, `NET_ADMIN`) without full privileged mode. The host filesystem is mounted at `/host`.

### Using privileged mode

```bash
kubectl debug node/<node-name> -it \
  --image=dcroche/sws-container \
  --profile=sysadmin \
  -- chroot /host
```

Or for a fully privileged pod with host namespaces:

```bash
kubectl run sws-debug --rm -it \
  --image=dcroche/sws-container \
  --overrides='{
    "spec": {
      "nodeName": "<node-name>",
      "hostNetwork": true,
      "hostPID": true,
      "containers": [{
        "name": "sws-debug",
        "image": "dcroche/sws-container",
        "stdin": true,
        "tty": true,
        "securityContext": { "privileged": true },
        "volumeMounts": [{ "name": "host", "mountPath": "/host" }]
      }],
      "volumes": [{ "name": "host", "hostPath": { "path": "/" } }]
    }
  }' \
  --restart=Never
```

This gives full access to the host filesystem (`/host`), network, and process namespace — useful for inspecting mounts, networking, and kernel-level state on the node.

## Image

| | |
|---|---|
| **Registry** | [Docker Hub](https://hub.docker.com/r/dcroche/sws-container) |
| **Source** | [GitHub](https://github.com/daxroc/sws-container) |
| **Dockerfile** | [Dockerfile](https://github.com/daxroc/sws-container/blob/main/Dockerfile) |
| **Base** | Ubuntu 24.04 |
| **Platforms** | `linux/amd64`, `linux/arm64` |
| **Tags** | `latest`, `<version>` (e.g. `0.3.0`), `<version>-alpha` |
| **Supply chain** | SBOM and provenance attestations included |

```bash
docker pull dcroche/sws-container:latest
```

## Versioning

The version is tracked in the `VERSION` file and drives all image tags and git tags.

- Bump `VERSION` in your PR to set the next release number.
- On merge to `main`, CI creates a git tag `v<version>` and pushes the versioned + `latest` images.
- PR builds automatically publish an alpha image tagged `<version>-alpha`.

## CI/CD

Two GitHub Actions workflows automate builds:

- **PR Build** (`.github/workflows/pr.yml`) — on pull request to `main`, builds and pushes a multi-arch alpha image (`<version>-alpha`).
- **Release** (`.github/workflows/release.yml`) — on push to `main`, creates a git tag and pushes versioned + `latest` multi-arch images to Docker Hub. Skips if the tag already exists.

Both workflows produce SBOM and provenance attestations.

## Release Process

### Automated (recommended)

1. Bump the `VERSION` file in your PR.
2. Merge to `main` — CI handles tagging and publishing.

### Manual

```bash
docker login
make publish
```

This builds and pushes the multi-arch image, then creates and pushes a git tag.
