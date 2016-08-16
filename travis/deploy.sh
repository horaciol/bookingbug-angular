#!/usr/bin/env bash

echo "TRAVIS BRANCH: $TRAVIS_BRANCH"
echo "TRAVIS TAG: $TRAVIS_TAG"
echo "TRAVIS PULL REQUEST: $TRAVIS_PULL_REQUEST"

if [ "$TRAVIS_PULL_REQUEST" = 'false' ]; then
  gulp deploy
fi

