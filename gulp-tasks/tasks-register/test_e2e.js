(function () {
    'use strict';

    module.exports = function (gulp, configuration) {

        var runSequence = require('run-sequence').use(gulp);

        gulp.task('test-e2e', function (cb) {
            runSequence('sdk-test-project:run-for-e2e', 'test-e2e:prepare', 'test-e2e:run', cb);
        });

    };

}).call(this);
