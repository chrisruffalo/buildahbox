#!/bin/bash

# since travis only accepts one "script" deploy instruction...
./deploy.sh
PREFIX="debian-" ./deploy.sh