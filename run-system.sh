#!/bin/sh

set -e



docker run -d --name assignment \
       -p 3000:80 \
    assignment-demo:1.0

sleep 10
echo "Container started"
