(function () {
    'use strict';

    var fs = require('fs');
    var karma = require('karma');
    var path = require('path');

    module.exports = function (gulp, configuration) {

        var prepareKarmaFiles = function () {
            var bowerFiles, projectFiles;
            bowerFiles = require('main-bower-files')({
                filter: ['**/*.js'],
                paths: {
                    bowerDirectory: 'test/unit/bower_components',
                    bowerJson: 'test/unit/bower.json'
                }
            });
            projectFiles = [
                'src/core/javascripts/main.js.coffee',
                'src/*/javascripts/main.js.coffee',
                'src/*/javascripts/core/config.js.coffee',
                'src/*/javascripts/**/*.module.js.coffee',
                'src/*/templates/**/*.html',
                'src/*/templates/*.html',
                'src/core/javascripts/collections/*.coffee',
                'src/*/javascripts/*.coffee',
                'src/*/javascripts/*.js',
                'src/*/javascripts/**/*.coffee',
                'src/*/javascripts/**/*.js',
                path.join(configuration.rootPath, '/test/unit/tmp/config.constants.js')
            ];
            return bowerFiles.concat(projectFiles);
        };

        /*
         * @param {Boolean} isDev
         */
        var getKarmaServerSettings = function (isDev) {
            var serverSettings;
            serverSettings = {
                configFile: path.join(__dirname, '/../karma.conf.js'),
                basePath: '../',
                files: prepareKarmaFiles(),
                autoWatch: true,
                singleRun: false
            };
            if (!isDev) {
                serverSettings.autoWatch = false;
                serverSettings.singleRun = true;
            }
            return serverSettings;
        };

        gulp.task('test-unit-start-karma:watch', function (cb) {
            return new karma.Server(getKarmaServerSettings(true), cb).start();
        });

        gulp.task('test-unit-start-karma', function (cb) {
            return new karma.Server(getKarmaServerSettings(false), cb).start();
        });
    };

}).call(this);
