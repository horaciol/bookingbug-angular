(function () {
    'use strict';

    var del = require('del');
    var path = require('path');

    module.exports = function (gulp, configuration) {

        gulp.task('clean-sdk', cleanSdkTask);

        function cleanSdkTask(cb) {

            var buildPath = path.join(configuration.rootPath, 'build');

            del.sync([
                buildPath + '/**',
                '!' + buildPath,
                '!' + buildPath + '/booking-widget',
                '!' + buildPath + '/booking-widget/**'
            ], {force: true});

            cb();
        }

    };

}).call(this);
