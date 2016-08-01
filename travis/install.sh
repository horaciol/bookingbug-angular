#!/usr/bin/env bash

npm install -g bower

echo "TRAVIS BRANCH: $TRAVIS_BRANCH"

npm install
bower install

gulp test:unit-dependencies

cd src/test-examples/unit-tests
bower install

cd ../../core/unit-tests
bower install

cd ../../admin/unit-tests
bower install

cd ../../admin-booking/unit-tests
bower install

cd ../../admin-dashboard/unit-tests
bower install

cd ../../events/unit-tests
bower install

cd ../../member/unit-tests
bower install

cd ../../services/unit-tests
bower install

cd ../../settings/unit-tests
bower install
