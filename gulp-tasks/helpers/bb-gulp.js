(function () {
    'use strict';

    var fs = require('fs');
    var gulp = require('gulp');
    var gutil = require('gulp-util');
    var gulpif = require('gulp-if');
    var coffee = require('gulp-coffee');
    var concat = require('gulp-concat');
    var uglify = require('gulp-uglify');
    var sass = require('gulp-sass');
    var flatten = require('gulp-flatten');
    var imagemin = require('gulp-imagemin');
    var filter = require('gulp-filter');
    var templateCache = require('gulp-angular-templatecache');
    var path = require('path');
    var rename = require('gulp-rename');
    var plumber = require('gulp-plumber');
    var clone = require('gulp-clone');
    var args = require('../helpers/args.js');

    module.exports = {
        javascripts: function (module, srcpath, releasepath) {

            srcpath || (srcpath = './src');
            releasepath || (releasepath = './build');

            var files = [
                srcpath + '/' + module + '/javascripts/main.js.coffee',
                srcpath + '/' + module + '/javascripts/**/*.module.js.coffee',
                srcpath + '/' + module + '/javascripts/**/*',
                srcpath + '/' + module + '/i18n/en.js',
                '!' + srcpath + '/' + module + '/javascripts/**/*~',
                '!' + srcpath + '/' + module + '/javascripts/**/*.js.js',
                '!' + srcpath + '/' + module + '/javascripts/**/*.js.js.map',
                '!' + srcpath + '/**/*_test.js.coffee',
                '!' + srcpath + '/**/*.spec.js.coffee'
            ];

            var stream = gulp.src(files, {allowEmpty: true})
                .pipe(plumber())
                .pipe(gulpif(/.*coffee$/, coffee().on('error', gutil.log)))
                .pipe(concat('bookingbug-angular-' + module + '.js'))
                .pipe(gulp.dest(releasepath + '/' + module));

            if (args.getEnvironment() !== 'local' && args.getEnvironment() !== 'dev') {
                var cloneSink = clone.sink();
                stream.pipe(cloneSink)
                    .pipe(uglify({mangle: false})).on('error', gutil.log)
                    .pipe(rename({extname: '.min.js'}))
                    .pipe(cloneSink.tap())
                    .pipe(gulp.dest(releasepath + '/' + module));
            }


        },
        i18n: function (module, srcpath, releasepath) {
            srcpath || (srcpath = './src');
            releasepath || (releasepath = './build');
            return gulp
                .src(srcpath + '/core/i18n/**/*')
                .pipe(gulp.dest(releasepath + '/core/i18n'));
        },
        stylesheets: function (module, srcpath, releasepath) {
            srcpath || (srcpath = './src');
            releasepath || (releasepath = './build');
            return gulp.src(srcpath + '/' + module + '/stylesheets/**')
                .pipe(gulp.dest(releasepath + '/' + module + '/src/stylesheets'))
        },
        images: function (module, srcpath, releasepath) {
            srcpath || (srcpath = './src');
            releasepath || (releasepath = './build');
            return gulp.src(srcpath + '/' + module + '/images/*')
                .pipe(imagemin())
                .pipe(flatten())
                .pipe(gulp.dest(releasepath + '/' + module));
        },
        fonts: function (module, srcpath, releasepath) {
            srcpath || (srcpath = './src');
            releasepath || (releasepath = './build');
            return gulp.src(srcpath + '/' + module + '/fonts/*')
                .pipe(flatten())
                .pipe(gulp.dest(releasepath + '/' + module));
        },
        templates: function (module, srcpath, releasepath, mod_name) {
            srcpath || (srcpath = './src');
            releasepath || (releasepath = './build');

            if (mod_name === undefined || mod_name == '' || !mod_name) {
                mod_name = 'BB';
            }

            return gulp.src(srcpath + '/' + module + '/templates/**/*.html')
                .pipe(templateCache({module: mod_name}))
                .pipe(concat('bookingbug-angular-' + module + '-templates.js'))
                .pipe(gulp.dest(releasepath + '/' + module));
        },
        bower: function (module, srcpath, releasepath) {
            srcpath || (srcpath = './src');
            releasepath || (releasepath = './build');
            return gulp.src(path.join(srcpath, module, 'bower.json'))
                .pipe(gulp.dest(path.join(releasepath, module)));
        }
    };
}).call(this);
