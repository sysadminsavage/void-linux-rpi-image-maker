# RPi Void Linux image maker
a script to automate the building of custom void linux images for the Raspberry Pi  
This tool is intended to be automated with my modified version of [drist]() to run the build on a remote build server and then copy the image back.  
It also assumes the remote build server is a void linux host. Building void linux requires the use of the offical void-mklive repository, and its tooling is not guarenteed to work on systems that are *not* void. So the remote build server must be a void liux host. This tool will automatically download the void-mklive repo and its dependencies to the remote host in a temporary working directory that will be removed once compiliation is complete is complete.
---

**rpi-upstream** - default official image, no changes

---

**rpi-incus** - incus host (cluster node)
deviates from the default void linux image in the following ways:
- hostname is set to the raspberry pi's serial number
- sudo is replaced with doas
- dhcpcd, chronyd, sshd and incus enabled on boot
- new user is added: 'void'
- ssh is enabled for 'void' and 'root'
- see makefile for embedding sshkeys into the image during build time

---

## Makefile Usage
```
RPi Void Linux image maker
-------------------------------------
This tool uses drist to run the build on a remote server
and copy the image back to the local client

Tell make what build server to use like so:
  echo "SERVER=user@build-server" > config.mk

Or just specify the build server on the command line:
  make <target> SERVER=user@build-server

The same goes for embedding ssh keys into images:
  make <target> SERVER=user@build-server SSH_KEY=~.ssh/id_ed25519.pub

Usage:
  make <target> <SERVER> [SSH_KEY]

Targets:
  - rpi-upstream, rpi-minimal, rpi-incus

Examples:
  make rpi-upstream SERVER=void@192.34.56.171
  make rpi-minimal SERVER=void@192.34.56.171
  make rpi-incus SERVER=builder SSH_KEY=~/.ssh/id_ed25519.pub
```
