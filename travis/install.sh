#!/usr/bin/env bash

npm install -g bower

npm install

gulp test:unit-dependencies
cd unit-tests
bower install
