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
| `ethtool` | NIC diagnostics |
| `iptables`, `conntrack` | Firewall & connection tracking |
| `curl`, `wget`, `httpie` | HTTP clients |
| `openssl` | TLS/SSL inspection |

### Filesystem

| Tool | Description |
|---|---|
| `mount`, `umount` | Mount/unmount filesystems |
| `showmount`, `mount.nfs`, `nfsstat` | NFS debugging |
| `rpcbind`, `rpcinfo` | RPC service inspection |
| `mount.cifs` | SMB/CIFS mounts |
| `sshfs` | FUSE-based SSH mounts |
| `lsof` | Open file handles |
| `fdisk`, `gdisk`, `parted` | Partition tables |
| `e2fsprogs`, `xfsprogs`, `dosfstools` | Filesystem utilities |
| `ncdu` | Disk usage analysis |
| `rsync` | File synchronization |
| `tree`, `file` | Directory & file inspection |

### Process

| Tool | Description |
|---|---|
| `ps`, `top`, `htop` | Process monitoring |
| `strace`, `ltrace` | Syscall & library call tracing |
| `gdb` | Debugger |
| `iostat`, `sar`, `mpstat` | System performance stats |
| `lsns`, `nsenter` | Namespace inspection |

### General

| Tool | Description |
|---|---|
| `vim`, `less` | Editors & pagers |
| `jq`, `yq` | JSON & YAML processing |
| `tmux` | Terminal multiplexer |
| `git` | Version control |
| `python3` | Scripting |

## Quick Start

```bash
# Build
make build

# Run interactively
docker run -it --privileged dcroche/sws-container

# Run without privilege (inspection only — no mounting)
docker run -it dcroche/sws-container
```

> `--privileged` is required for operations like mounting filesystems, tracing processes, or inspecting network interfaces. For basic inspection you can omit it.

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

## Publish

```bash
# Login to Docker Hub
docker login

# Build and push
make publish
```

## Image

`dcroche/sws-container:latest`
