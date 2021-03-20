# Cardano Node Docker for Raspberry Pi

**THIS IS STILL EXPERIMENTAL**

## Vision

A quick and easy way to get started with `cardano-node` node on a Raspberry Pi.

## Get Started

This Cardano Node Docker image is split up into two stages: the build stage and
the play stage. If you're familiar with Docker and want to create a swarm or a
Kubernetes cluster you can use `pilina/cardano-node-build` image and save
yourself countless hours of building from source.

If you're less experienced and just want to get up and running quickly, try out
`pilina/cardano-node`. This is a rather opinionanted image that's supposed to
be very much out of the box. You should be able to slap it on a Raspberry Pi and
be up and running in less than an hour.

Let's dive in:

### The Build Stage

The build stage really does just that. It builds the binaries for `cardano-node`
and `cardano-cli`. You can control the rest by creating a `Dockerfile` with:

```
FROM --platform=linux/arm64 pilina/cardano-node-build:latest
RUN ...
```

This image has been built on a Raspberry Pi 4b running [RaspiOS Lite Buster arm64](https://downloads.raspberrypi.org/raspios_lite_arm64/images/raspios_lite_arm64-2020-08-24/).
As long as you're running this os with an [up to date docker install](https://github.com/tstachl/dotfiles/blob/master/.config/yadm/bootstrap#L7-L11)
you should be good to run it. I have noticed building Cardano Node on a system
running purely on SD cards (no USB SSD harddrive) takes a lot longer. That's why
I would strongly urge to run this on a system with SSD hard drive. I'm going to
test running a relay on a Raspberry Pi 4b with 4GB RAM and SD card only at some
point in the future. But I would, at present, not recommend it for a production
stake pool.

### The opinionated Play Stage

Use this to get started right away. Without having to build anything, you can
just use this image to get a container up and running with one command:

```
$ docker run -it pilina/cardano-node node run \
    --topology mainnet-topology.json \
    --database-path db \
    --socket-path db/node.socket \
    --host-addr <PUBLIC IPv4 ADDRESS> \
    --port <PORT> \
    --config mainnet-config.json
```

This is also where this docker image becomes very opinionated. While you can use
`pilina/cardano-node-build` in a docker swarm, mapping custom ports, and so on,
`pilina/cardano-node` is built to get up and running quickly. It assumes there
will only be one container per host, maps the default ports, and mounts
`/opt/cardano-node` as the default directory for database and configuration.
Doing this allows you to use docker as and encapsulated build of the latest
binaries without sacrifcing the ease of use of those binaries.

You also have full access to `cardano-cli` by running:

```
$ docker run -it pilina/cardano-node cli query tip --mainnet
```

To make this even more powerful, add some aliases to your shell:

```
alias cardano-node="docker run -it pilina/cardano-node node"
alias cardano-cli="docker run -it pilina/cardano-node cli"
```

Keep in mind, docker runs in a container on your host and is not your host. That
means you'll have to expose ports and volumes between the container and your
host to make it work properly. For ease of use, I've set up the defaults based
on the [Cardano Node](https://docs.cardano.org/projects/cardano-node/en/latest/index.html)
documentation. Feel free to change those to your liking though.
