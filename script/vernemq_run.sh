#!/bin/bash

set -e

sigterm_handler() {
    echo "SIGTERM received, shutting down Vernemq gracefully..."
    /vernemq/bin/vmq-admin node stop >/dev/null
}

siguser1_handler() {
    echo "SIGUSR1 received, shutting down Vernemq gracefully..."
    /vernemq/bin/vmq-admin node stop >/dev/null
}

trap 'siguser1_handler' SIGUSR1
trap 'sigterm_handler' SIGTERM

/vernemq/bin/vernemq console -noshell -noinput $@ &
pid=$!

wait $pid