# Katzenpost Nix Packages

## Prerequisites

Install the [Nix package manager](https://nixos.org/nix/download.html) or [NixOS](https://nixos.org/nixos/download.html)

## Update package definitions

Use [go2nix v2](https://github.com/kamilchm/go2nix/tree/v2) to update package definitions:

```
go get -u -v github.com/katzenpost/daemons
cd ~/go/src/github.com/katzenpost/daemons
dep ensure
go2nix
```

This generates 2 files: default.nix and deps.nix

In this repository
- update version, git rev & sha256 in default.nix
- replace deps.nix with the newly generated one


supported by
============

.. image:: https://katzenpost.mixnetworks.org/_static/images/eu-flag-tiny.jpg

This project has received funding from the European Union’s Horizon 2020
research and innovation programme under the Grant Agreement No 653497, Privacy
and Accountability in Networks via Optimized Randomized Mix-nets (Panoramix).
