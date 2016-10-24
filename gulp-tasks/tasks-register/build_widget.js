(function () {
    'use strict';

    module.exports = function (gulp, configuration) {

        var runSequence = require('run-sequence').use(gulp);

        gulp.task('build-widget', function (cb) {
            runSequence(
                'build-sdk',
                'build-widget:bower-install',
                'build-widget:script',
                'build-widget:style',
                'build-widget:dependency-style',
                cb
            );
        });

    };

}).call(this);
