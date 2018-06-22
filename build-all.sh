#!/bin/bash

# Exit if anything fails
set -e

/bin/sh nagios-host/build.sh
/bin/sh nagios-client/build.sh
