(function () {
    'use strict';

    module.exports = function (gulp, configuration) {

        var runSequence = require('run-sequence').use(gulp);

        gulp.task('docs', function (cb) {
            runSequence('docs:clean', 'docs:sdk-generate', cb);
        });

        gulp.task('docs:watch', function (cb) {
            runSequence('docs:clean', 'docs:sdk-generate', 'docs:sdk-watch', cb);
        });
    };

}).call(this);
