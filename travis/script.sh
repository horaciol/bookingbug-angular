#!/usr/bin/env bash

set -ev
# The -e flag causes the script to exit as soon as one command returns a non-zero exit code. This can be handy if you want whatever script you have to exit early. It also helps in complex installation scripts where one failed command wouldn’t otherwise cause the installation to fail.
# The -v flag makes the shell print all lines in the script before executing them, which helps identify which steps failed.

echo "TRAVIS BRANCH: $TRAVIS_BRANCH"

gulp test:unit-ci # !!! generates lcov reports per module - can be used with Climate

