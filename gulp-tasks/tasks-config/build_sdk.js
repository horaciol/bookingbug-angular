(function () {
    'use strict';

    var bbGulp = require('../helpers/bb-gulp.js');
    var path = require('path');

    module.exports = function (gulp, configuration) {

        var srcPath = path.join(configuration.rootPath, 'src');
        var destPath = path.join(configuration.rootPath, 'build');

        gulp.task('build-sdk:admin:javascripts', function () {
            return bbGulp.javascripts('admin', srcPath, destPath, configuration.uglify);
        });

        gulp.task('build-sdk:admin:images', function () {
            return bbGulp.images('admin', srcPath, destPath);
        });

        gulp.task('build-sdk:admin:templates', function () {
            return bbGulp.templates('admin', srcPath, destPath);
        });

        gulp.task('build-sdk:admin:bower', function () {
            return bbGulp.bower('admin', srcPath, destPath);
        });

        gulp.task('build-sdk:admin', [
            'build-sdk:admin:javascripts',
            'build-sdk:admin:images',
            'build-sdk:admin:templates',
            'build-sdk:admin:bower'
        ]);

        gulp.task('build-sdk:admin-booking:javascripts', function () {
            bbGulp.coreJavascripts('admin-dashboard', srcPath, destPath, 'BBAdminDashboard', configuration.uglify);
            return bbGulp.lazyJavascripts('admin-dashboard', srcPath, destPath, 'BBAdminDashboard', configuration.uglify);
            //bbutil.lazyJavascripts('admin-dashboard', 'BBAdminDashboard')
            //bbGulp.javascripts('admin-dashboard', srcPath, destPath, plugins.config.uglify)
        });

        gulp.task('build-sdk:admin-booking:stylesheets', function () {
            return bbGulp.stylesheets('admin-booking', srcPath, destPath);
        });

        gulp.task('build-sdk:admin-booking:templates', function () {
            return;
            //return bbGulp.templates('admin-booking', srcPath, destPath, 'BBAdminBooking');
        });

        gulp.task('build-sdk:admin-booking:bower', function () {
            return bbGulp.bower('admin-booking', srcPath, destPath, 'BBAdminBooking');
        });

        gulp.task('build-sdk:admin-booking', [
            'build-sdk:admin-booking:javascripts',
            'build-sdk:admin-booking:stylesheets',
            'build-sdk:admin-booking:templates',
            'build-sdk:admin-booking:bower'
        ]);

        gulp.task('build-sdk:admin-dashboard:javascripts', function () {
            return bbGulp.javascripts('admin-dashboard', srcPath, destPath, configuration.uglify);
        });

        gulp.task('build-sdk:admin-dashboard:stylesheets', function () {
            return bbGulp.stylesheets('admin-dashboard', srcPath, destPath);
        });

        gulp.task('build-sdk:admin-dashboard:images', function () {
            return bbGulp.images('admin-dashboard', srcPath, destPath);
        });

        gulp.task('build-sdk:admin-dashboard:templates', function () {
            return bbGulp.templates('admin-dashboard', srcPath, destPath, false, false);
        });

        gulp.task('build-sdk:admin-dashboard:bower', function () {
            return bbGulp.bower('admin-dashboard', srcPath, destPath);
        });

        gulp.task('build-sdk:admin-dashboard', [
            'build-sdk:admin-dashboard:javascripts',
            'build-sdk:admin-dashboard:stylesheets',
            'build-sdk:admin-dashboard:images',
            'build-sdk:admin-dashboard:templates',
            'build-sdk:admin-dashboard:bower'
        ]);

        gulp.task('build-sdk:core:javascripts', function () {
            return bbGulp.javascripts('core', srcPath, destPath, configuration.uglify);
        });

        gulp.task('build-sdk:core:stylesheets', function () {
            return bbGulp.stylesheets('core', srcPath, destPath);
        });

        gulp.task('build-sdk:core:templates', function () {
            return bbGulp.templates('core', srcPath, destPath);
        });

        gulp.task('build-sdk:core:bower', function () {
            return bbGulp.bower('core', srcPath, destPath);
        });

        gulp.task('build-sdk:core', [
            'build-sdk:core:javascripts',
            'build-sdk:core:stylesheets',
            'build-sdk:core:templates',
            'build-sdk:core:bower'
        ]);

        gulp.task('build-sdk:events:javascripts', function () {
            return bbGulp.javascripts('events', srcPath, destPath, configuration.uglify);
        });

        gulp.task('build-sdk:events:templates', function () {
            return bbGulp.templates('events', srcPath, destPath);
        });

        gulp.task('build-sdk:events:bower', function () {
            return bbGulp.bower('events', srcPath, destPath);
        });

        gulp.task('build-sdk:events', [
            'build-sdk:events:javascripts',
            'build-sdk:events:templates',
            'build-sdk:events:bower'
        ]);

        gulp.task('build-sdk:member:javascripts', function () {
            return bbGulp.javascripts('member', srcPath, destPath, configuration.uglify);
        });

        gulp.task('build-sdk:member:stylesheets', function () {
            return bbGulp.stylesheets('member', srcPath, destPath);
        });

        gulp.task('build-sdk:member:templates', function () {
            return bbGulp.templates('member', srcPath, destPath);
        });

        gulp.task('build-sdk:member:bower', function () {
            return bbGulp.bower('member', srcPath, destPath);
        });

        gulp.task('build-sdk:member', [
            'build-sdk:member:javascripts',
            'build-sdk:member:stylesheets',
            'build-sdk:member:templates',
            'build-sdk:member:bower'
        ]);

        gulp.task('build-sdk:public-booking:javascripts', function () {
            return bbGulp.javascripts('public-booking', srcPath, destPath, configuration.uglify);
        });

        gulp.task('build-sdk:public-booking:stylesheets', function () {
            return bbGulp.stylesheets('public-booking', srcPath, destPath);
        });

        gulp.task('build-sdk:public-booking:fonts', function () {
            return bbGulp.fonts('public-booking', srcPath, destPath);
        });

        gulp.task('build-sdk:public-booking:images', function () {
            return bbGulp.images('public-booking', srcPath, destPath);
        });

        gulp.task('build-sdk:public-booking:templates', function () {
            return bbGulp.templates('public-booking', srcPath, destPath);
        });

        gulp.task('build-sdk:public-booking:bower', function () {
            return bbGulp.bower('public-booking', srcPath, destPath);
        });

        gulp.task('build-sdk:public-booking', [
            'build-sdk:public-booking:javascripts',
            'build-sdk:public-booking:stylesheets',
            'build-sdk:public-booking:fonts',
            'build-sdk:public-booking:images',
            'build-sdk:public-booking:templates',
            'build-sdk:public-booking:bower'
        ]);

        gulp.task('build-sdk:queue:javascripts', function () {
            return bbGulp.javascripts('queue', srcPath, destPath, configuration.uglify);
        });

        gulp.task('build-sdk:queue:templates', function () {
            return bbGulp.templates('queue', srcPath, destPath);
        });

        gulp.task('build-sdk:queue:bower', function () {
            return bbGulp.bower('queue', srcPath, destPath);
        });

        gulp.task('build-sdk:queue', [
            'build-sdk:queue:javascripts',
            'build-sdk:queue:templates',
            'build-sdk:queue:bower'
        ]);

        gulp.task('build-sdk:services:javascripts', function () {
            return bbGulp.javascripts('services', srcPath, destPath, configuration.uglify);
        });

        gulp.task('build-sdk:services:stylesheets', function () {
            return bbGulp.stylesheets('services', srcPath, destPath);
        });

        gulp.task('build-sdk:services:templates', function () {
            return bbGulp.templates('services', srcPath, destPath);
        });

        gulp.task('build-sdk:services:bower', function () {
            return bbGulp.bower('services', srcPath, destPath);
        });

        gulp.task('build-sdk:services', [
            'build-sdk:services:javascripts',
            'build-sdk:services:stylesheets',
            'build-sdk:services:templates',
            'build-sdk:services:bower'
        ]);

        gulp.task('build-sdk:settings:javascripts', function () {
            return bbGulp.javascripts('settings', srcPath, destPath, configuration.uglify);
        });

        gulp.task('build-sdk:settings:templates', function () {
            return bbGulp.templates('settings', srcPath, destPath);
        });

        gulp.task('build-sdk:settings:bower', function () {
            return bbGulp.bower('settings', srcPath, destPath);
        });

        gulp.task('build-sdk:settings', [
            'build-sdk:settings:javascripts',
            'build-sdk:settings:templates',
            'build-sdk:settings:bower'
        ]);
    };

}).call(this);
