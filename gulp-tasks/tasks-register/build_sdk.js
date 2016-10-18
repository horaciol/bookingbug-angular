(function () {
    'use strict';

    module.exports = function (gulp, configuration) {

        var runSequence = require('run-sequence').use(gulp);

        gulp.task('build-sdk', buildSdkTask);

        function buildSdkTask(cb) {
            runSequence(
                'clean-sdk',
                'build-sdk:core',
                'build-sdk:public-booking',
                'build-sdk:member',
                'build-sdk:admin',
                'build-sdk:admin-booking',
                'build-sdk:admin-dashboard',
                'build-sdk:events',
                'build-sdk:services',
                'build-sdk:settings',
                cb
            );
        }
    };

}).call(this);
