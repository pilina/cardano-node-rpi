#!/bin/bash
# Super simple entrypoint that allows to call `cardano-cli` and `cardano-node`.
case "$1" in
  cli* | node*) cardano-$@ ;;
  *) echo "I don't understand '$@'."; exit 1 ;;
esac

