# socks-proxy

## Opening SOCKS proxies quickly

When accessing web-based tools on servers that only allow ssh access, using SOCKS proxies and connecting a local browser to those are usually more efficient than doing X forwarding over ssh, especially when multiple ssh hops are necessary to reach the servers. As just locking your screen can have the adverse affect of killing your proxies, at least if you're working over some VPNs, it can still become annoying - hence the need to (re)open SOCKS proxies in a quick and easy manner.

## Defining SOCKS proxies

In a Linux/Unix-like environment, this is most easily done in your private ssh configuration file, `~/.ssh/config`. An example entry with a two-level jump:

```ssh
Host socks-target
    DynamicForward 6789
    User admin
    ProxyJump gateway-server
    RequestTTY no
    SessionType none
    ForkAfterAuthentication yes
```

If you have keybased access properly setup and are using a key agent, this should open port 6789 on your localhost, and tunnel traffic to `socks-target` over `gateway-server`, accessing as user **admin**. As a bonus, it releases the terminal and skips unneeded session stuff. All without asking for passwords, yay! :-)

I've chosen to define my handful of SOCKS proxies all using the same portnumber, which has the drawback of only allowing one active proxy at a time. But as the scripts provided here helps you opening a SOCKS proxy really fast, swapping between them isn't really an issue anymore. And it makes the browser configuration simpler as well.

## Working with a dedicated browser for SOCKS access

I've ended up using FireFox for accessing web resources via SOCKS, as it has a clean and simple setup for proxy use. Once configured for using my preferred port, it's done. Swapping proxies under FireFox's nose is something the browser is ignorant about, it will happily connect via whatever is connected on the configured SOCKS port.

## The scripts

### find-socks-proxies.sh

A short bash script, using **awk** and some filters to list the host names of any SOCKS proxies you have defined locally.

### socks-proxy.sh

The main bash script - it kills old sessions/processes for SOCKS proxies, and starts a new one on for the requested host, if the given host is a valid choice. In short, it matches your request with the output of `find-socks-proxies.sh`, and won't continue if your requested host isn't listed.

```console
workstation:~ username$ socks-proxy.sh -h

Usage: socks-proxy.sh [OPTIONS]

Options:
  -p <proxy-host>     A defined proxy host (~/.ssh/config)
  -v                  Verbose
  -h                  Help

```

### completion-socks-proxy.bash

As a bonus, there's a completion script for bash - this completes options/flags as well as proxy hosts. This should be sourced before you try executing the main script, preferably in your bash login setup.


