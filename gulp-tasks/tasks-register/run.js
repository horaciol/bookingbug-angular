(function () {
    'use strict';

    module.exports = function (gulp, configuration) {

        var runSequence = require('run-sequence').use(gulp);

        gulp.task('sdk-test-project:run', runTask);
        gulp.task('sdk-test-project:run:watch', runWatchTask);
        gulp.task('sdk-test-project:run-for-e2e', runForE2ETask);

        function runTask(cb) {

            runSequence('sdk-test-project:release', 'sdk-test-project:webserver', 'sdk-test-project:webserver:open-browser', cb);
        }

        function runForE2ETask(cb) {

            runSequence('sdk-test-project:release', 'sdk-test-project:webserver', cb);
        }

        function runWatchTask(cb) {

            runSequence('sdk-test-project:release:watch', 'sdk-test-project:webserver', 'sdk-test-project:webserver:open-browser', cb);
        }

    };

}).call(this);
