(function () {
    'use strict';

    var bbGulp = require('../helpers/bb-gulp.js');
    var path = require('path');

    module.exports = function (gulp, configuration) {

        var srcPath = path.join(configuration.rootPath, 'src');
        var destPath = path.join(configuration.rootPath, 'build');

        gulp.task('build-sdk:admin:javascripts', function () {
            return bbGulp.javascripts('admin', srcPath, destPath);
        });

        gulp.task('build-sdk:admin:stylesheets', function () {
            return bbGulp.stylesheets('admin', srcPath, destPath);
        });

        gulp.task('build-sdk:admin:images', function () {
            return bbGulp.images('admin', srcPath, destPath);
        });

        gulp.task('build-sdk:admin:fonts', function () {
            return bbGulp.fonts('admin', srcPath, destPath);
        });

        gulp.task('build-sdk:admin:templates', function () {
            return bbGulp.templates('admin', srcPath, destPath);
        });

        gulp.task('build-sdk:admin:config', function () {
            return bbGulp.config('admin', srcPath, destPath);
        });

        gulp.task('build-sdk:admin:bower', function () {
            return bbGulp.bower('admin', srcPath, destPath);
        });

        gulp.task('build-sdk:admin', [
            'build-sdk:admin:javascripts',
            'build-sdk:admin:templates',
            'build-sdk:admin:stylesheets',
            'build-sdk:admin:images',
            'build-sdk:admin:fonts',
            'build-sdk:admin:config',
            'build-sdk:admin:bower'
        ]);

        gulp.task('build-sdk:admin-booking:javascripts', function () {
            return bbGulp.javascripts('admin-booking', srcPath, destPath);
        });

        gulp.task('build-sdk:admin-booking:stylesheets', function () {
            return bbGulp.stylesheets('admin-booking', srcPath, destPath);
        });

        gulp.task('build-sdk:admin-booking:templates', function () {
            return bbGulp.templates('admin-booking', srcPath, destPath, 'BBAdminBooking');
        });

        gulp.task('build-sdk:admin-booking:images', function () {
            return bbGulp.images('admin-booking', srcPath, destPath);
        });

        gulp.task('build-sdk:admin-booking:fonts', function () {
            return bbGulp.fonts('admin-booking', srcPath, destPath);
        });

        gulp.task('build-sdk:admin-booking:config', function () {
            return bbGulp.config('admin-booking', srcPath, destPath);
        });

        gulp.task('build-sdk:admin-booking:bower', function () {
            return bbGulp.bower('admin-booking', srcPath, destPath, 'BBAdminBooking');
        });

        gulp.task('build-sdk:admin-booking', [
            'build-sdk:admin-booking:javascripts',
            'build-sdk:admin-booking:templates',
            'build-sdk:admin-booking:stylesheets',
            'build-sdk:admin-booking:images',
            'build-sdk:admin-booking:fonts',
            'build-sdk:admin-booking:config',
            'build-sdk:admin-booking:bower'
        ]);

        gulp.task('build-sdk:admin-dashboard:javascripts', function () {
            return bbGulp.javascripts('admin-dashboard', srcPath, destPath);
        });

        gulp.task('build-sdk:admin-dashboard:stylesheets', function () {
            return bbGulp.stylesheets('admin-dashboard', srcPath, destPath);
        });

        gulp.task('build-sdk:admin-dashboard:images', function () {
            return bbGulp.images('admin-dashboard', srcPath, destPath);
        });

        gulp.task('build-sdk:admin-dashboard:templates', function () {
            return bbGulp.templates('admin-dashboard', srcPath, destPath, false);
        });

        gulp.task('build-sdk:admin-dashboard:fonts', function () {
            return bbGulp.fonts('admin-dashboard', srcPath, destPath);
        });

        gulp.task('build-sdk:admin-dashboard:config', function () {
            return bbGulp.config('admin-dashboard', srcPath, destPath);
        });

        gulp.task('build-sdk:admin-dashboard:bower', function () {
            return bbGulp.bower('admin-dashboard', srcPath, destPath);
        });

        gulp.task('build-sdk:admin-dashboard', [
            'build-sdk:admin-dashboard:javascripts',
            'build-sdk:admin-dashboard:templates',
            'build-sdk:admin-dashboard:stylesheets',
            'build-sdk:admin-dashboard:images',
            'build-sdk:admin-dashboard:fonts',
            'build-sdk:admin-dashboard:config',
            'build-sdk:admin-dashboard:bower'
        ]);

        gulp.task('build-sdk:core:javascripts', function () {
            return bbGulp.javascripts('core', srcPath, destPath);
        });

        gulp.task('build-sdk:core:stylesheets', function () {
            return bbGulp.stylesheets('core', srcPath, destPath);
        });

        gulp.task('build-sdk:core:templates', function () {
            return bbGulp.templates('core', srcPath, destPath);
        });

        gulp.task('build-sdk:core:images', function () {
            return bbGulp.images('core', srcPath, destPath);
        });

        gulp.task('build-sdk:core:fonts', function () {
            return bbGulp.fonts('core', srcPath, destPath);
        });

        gulp.task('build-sdk:core:config', function () {
            return bbGulp.config('core', srcPath, destPath);
        });

        gulp.task('build-sdk:core:bower', function () {
            return bbGulp.bower('core', srcPath, destPath);
        });

        gulp.task('build-sdk:core', [
            'build-sdk:core:javascripts',
            'build-sdk:core:templates',
            'build-sdk:core:stylesheets',
            'build-sdk:core:images',
            'build-sdk:core:fonts',
            'build-sdk:core:config',
            'build-sdk:core:bower'
        ]);

        gulp.task('build-sdk:events:javascripts', function () {
            return bbGulp.javascripts('events', srcPath, destPath);
        });

        gulp.task('build-sdk:events:stylesheets', function () {
            return bbGulp.stylesheets('events', srcPath, destPath);
        });

        gulp.task('build-sdk:events:templates', function () {
            return bbGulp.templates('events', srcPath, destPath);
        });

        gulp.task('build-sdk:events:images', function () {
            return bbGulp.images('events', srcPath, destPath);
        });

        gulp.task('build-sdk:events:fonts', function () {
            return bbGulp.fonts('events', srcPath, destPath);
        });

        gulp.task('build-sdk:events:config', function () {
            return bbGulp.config('events', srcPath, destPath);
        });

        gulp.task('build-sdk:events:bower', function () {
            return bbGulp.bower('events', srcPath, destPath);
        });

        gulp.task('build-sdk:events', [
            'build-sdk:events:javascripts',
            'build-sdk:events:templates',
            'build-sdk:events:stylesheets',
            'build-sdk:events:images',
            'build-sdk:events:fonts',
            'build-sdk:events:config',
            'build-sdk:events:bower'
        ]);

        gulp.task('build-sdk:member:javascripts', function () {
            return bbGulp.javascripts('member', srcPath, destPath);
        });

        gulp.task('build-sdk:member:stylesheets', function () {
            return bbGulp.stylesheets('member', srcPath, destPath);
        });

        gulp.task('build-sdk:member:templates', function () {
            return bbGulp.templates('member', srcPath, destPath);
        });

        gulp.task('build-sdk:member:images', function () {
            return bbGulp.images('member', srcPath, destPath);
        });

        gulp.task('build-sdk:member:fonts', function () {
            return bbGulp.fonts('member', srcPath, destPath);
        });

        gulp.task('build-sdk:member:config', function () {
            return bbGulp.config('member', srcPath, destPath);
        });

        gulp.task('build-sdk:member:bower', function () {
            return bbGulp.bower('member', srcPath, destPath);
        });

        gulp.task('build-sdk:member', [
            'build-sdk:member:javascripts',
            'build-sdk:member:templates',
            'build-sdk:member:stylesheets',
            'build-sdk:member:images',
            'build-sdk:member:fonts',
            'build-sdk:member:config',
            'build-sdk:member:bower'
        ]);

        gulp.task('build-sdk:public-booking:javascripts', function () {
            return bbGulp.javascripts('public-booking', srcPath, destPath);
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

        gulp.task('build-sdk:public-booking:config', function () {
            return bbGulp.config('public-booking', srcPath, destPath);
        });

        gulp.task('build-sdk:public-booking:bower', function () {
            return bbGulp.bower('public-booking', srcPath, destPath);
        });

        gulp.task('build-sdk:public-booking', [
            'build-sdk:public-booking:javascripts',
            'build-sdk:public-booking:templates',
            'build-sdk:public-booking:stylesheets',
            'build-sdk:public-booking:images',
            'build-sdk:public-booking:fonts',
            'build-sdk:public-booking:config',
            'build-sdk:public-booking:bower'
        ]);

        gulp.task('build-sdk:queue:javascripts', function () {
            return bbGulp.javascripts('queue', srcPath, destPath);
        });

        gulp.task('build-sdk:queue:stylesheets', function () {
            return bbGulp.stylesheets('queue', srcPath, destPath);
        });

        gulp.task('build-sdk:queue:templates', function () {
            return bbGulp.templates('queue', srcPath, destPath);
        });

        gulp.task('build-sdk:queue:images', function () {
            return bbGulp.images('queue', srcPath, destPath);
        });

        gulp.task('build-sdk:queue:fonts', function () {
            return bbGulp.fonts('queue', srcPath, destPath);
        });

        gulp.task('build-sdk:queue:config', function () {
            return bbGulp.config('queue', srcPath, destPath);
        });

        gulp.task('build-sdk:queue:bower', function () {
            return bbGulp.bower('queue', srcPath, destPath);
        });

        gulp.task('build-sdk:queue', [
            'build-sdk:queue:javascripts',
            'build-sdk:queue:templates',
            'build-sdk:queue:stylesheets',
            'build-sdk:queue:images',
            'build-sdk:queue:fonts',
            'build-sdk:queue:config',
            'build-sdk:queue:bower'
        ]);

        gulp.task('build-sdk:services:javascripts', function () {
            return bbGulp.javascripts('services', srcPath, destPath);
        });

        gulp.task('build-sdk:services:stylesheets', function () {
            return bbGulp.stylesheets('services', srcPath, destPath);
        });

        gulp.task('build-sdk:services:templates', function () {
            return bbGulp.templates('services', srcPath, destPath);
        });

        gulp.task('build-sdk:services:images', function () {
            return bbGulp.images('services', srcPath, destPath);
        });

        gulp.task('build-sdk:services:fonts', function () {
            return bbGulp.fonts('services', srcPath, destPath);
        });

        gulp.task('build-sdk:services:config', function () {
            return bbGulp.config('services', srcPath, destPath);
        });

        gulp.task('build-sdk:services:bower', function () {
            return bbGulp.bower('services', srcPath, destPath);
        });

        gulp.task('build-sdk:services', [
            'build-sdk:services:javascripts',
            'build-sdk:services:templates',
            'build-sdk:services:stylesheets',
            'build-sdk:services:images',
            'build-sdk:services:fonts',
            'build-sdk:services:config',
            'build-sdk:services:bower'
        ]);

        gulp.task('build-sdk:settings:javascripts', function () {
            return bbGulp.javascripts('settings', srcPath, destPath);
        });

        gulp.task('build-sdk:settings:stylesheets', function () {
            return bbGulp.stylesheets('settings', srcPath, destPath);
        });

        gulp.task('build-sdk:settings:templates', function () {
            return bbGulp.templates('settings', srcPath, destPath);
        });

        gulp.task('build-sdk:settings:images', function () {
            return bbGulp.images('settings', srcPath, destPath);
        });

        gulp.task('build-sdk:settings:fonts', function () {
            return bbGulp.fonts('settings', srcPath, destPath);
        });

        gulp.task('build-sdk:settings:config', function () {
            return bbGulp.config('settings', srcPath, destPath);
        });

        gulp.task('build-sdk:settings:bower', function () {
            return bbGulp.bower('settings', srcPath, destPath);
        });

        gulp.task('build-sdk:settings', [
            'build-sdk:settings:javascripts',
            'build-sdk:settings:templates',
            'build-sdk:settings:stylesheets',
            'build-sdk:settings:images',
            'build-sdk:settings:fonts',
            'build-sdk:settings:config',
            'build-sdk:settings:bower'
        ]);
    };

}).call(this);
