(function () {
    'use strict';

    module.exports = function (gulp, configuration) {

        var runSequence = require('run-sequence').use(gulp);

        gulp.task('sdk-test-project:release', releaseTask);
        gulp.task('sdk-test-project:release:watch', releaseWatchTask);

        function releaseTask(cb) {

            var tasks = [
                'build-sdk',
                'sdk-test-project:clean',
                'sdk-test-project:bower-prepare',
                'sdk-test-project:bower-symlinks',
                'sdk-test-project:bower-install',
                'sdk-test-project:scripts:vendors',
                'sdk-test-project:scripts:client',
                'sdk-test-project:templates',
                'sdk-test-project:stylesheets:vendors',
                'sdk-test-project:stylesheets:client',
                'sdk-test-project:fonts',
                'sdk-test-project:images',
                'sdk-test-project:www',
                cb
            ];

            runSequence.apply(null, tasks);
        }

        function releaseWatchTask(cb) {

            runSequence(
                'sdk-test-project:release',
                'sdk-test-project:watch',
                'sdk-test-project:watch-sdk',
                cb
            );
        }
    };

}).call(this);
