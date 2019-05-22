#!/bin/bash
set -x

USER=pivx

chown -R ${USER} .
exec gosu ${USER} "$@"