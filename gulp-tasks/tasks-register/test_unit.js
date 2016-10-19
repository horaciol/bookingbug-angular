(function () {
    'use strict';

    module.exports = function (gulp, configuration) {

        var runSequence = require('run-sequence').use(gulp);

        gulp.task('test-unit', function (cb) {
            runSequence('test-unit-bower-prepare', 'test-unit-bower-install', 'test-unit-config', 'test-unit-start-karma', cb);
        });
        gulp.task('test-unit:watch', function (cb) {
            runSequence('test-unit-bower-prepare', 'test-unit-bower-install', 'test-unit-config', 'test-unit-start-karma:watch', cb);
        });
    };

}).call(this);
