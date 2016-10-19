(function () {
    'use strict';

    var deepMerge = require('deepmerge');
    var deepRenameKeys = require('deep-rename-keys');
    var gulpNgConstant = require('gulp-ng-constant');
    var gulpRename = require('gulp-rename');
    var jsonFile = require('jsonfile');
    var mkdirp = require('mkdirp');
    var path = require('path');
    var fsFinder = require('fs-finder');

    module.exports = function (gulp, configuration) {

        gulp.task('test-unit-config', configTask);

        var unitPath = path.join(configuration.rootPath, '/test/unit/');
        var destPath = path.join(unitPath, 'tmp');

        function configTask() {

            mkdirp.sync(destPath);

            var configProject = getConfigData(unitPath + 'config.json');

            var configSdk = {};

            getSdkConfigFileNames().forEach(function (configFileName) {
                var configData = getConfigData(configFileName);
                configSdk = deepMerge(configSdk, configData);
            });

            configProject = deepMerge(configSdk, configProject);
            configProject = deepRenameKeys(configProject, upperCaseKey);

            var options = {
                constants: {
                    bbConfig: configProject
                },
                deps: false,
                merge: true,
                name: "BB",
                space: '    ',
                stream: true,
                wrap: false
            };

            return gulpNgConstant(options)
                .pipe(gulpRename('config.constants.js'))
                .pipe(gulp.dest(destPath));
        }

        /**
         * @param {String} key
         * @returns {String}
         */
        function upperCaseKey(key) {
            return key.toUpperCase();
        }

        /**
         * @param {String} fileName
         * @returns {Object}
         */
        function getConfigData(fileName) {
            try {
                return jsonFile.readFileSync(fileName);
            } catch (error) {
                console.error('could not load config file. path = ' + fileName);
                console.error(error);
                process.exit(0);
            }
        }

        /**
         * @returns {Array.<String>}
         */
        function getSdkConfigFileNames() {
            return fsFinder.from(path.join(configuration.rootPath, '/src')).findFiles('/config/*.json');
        }

    };

}).call(this);
