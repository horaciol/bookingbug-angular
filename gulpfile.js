var gulp = require('gulp'),
    coffee = require('gulp-coffee'),
    concat = require('gulp-concat'),
    gulpif = require('gulp-if'),
    filelog = require('gulp-filelog'),
    gutil = require('gulp-util'),
    del = require('del'),
    connect = require('gulp-connect'),
    templateCache = require('gulp-angular-templatecache'),
    imagemin = require('gulp-imagemin'),
    rename = require('gulp-rename'),
    flatten = require('gulp-flatten'),
    sass = require('gulp-sass'),
    merge = require('merge-stream'),
    mainBowerFiles = require('main-bower-files'),
    streamqueue = require('streamqueue'),
    uglify = require('gulp-uglify'),
    gulpDocs = require('gulp-ngdocs'),
    KarmaServer = require('karma').Server,
    protractor = require('gulp-protractor').protractor,
    bower = require('gulp-bower'),
    argv = require('yargs').argv;

gulp.task('clean', function(cb) {
  del.sync(['release']);
  cb();
});


gulp.task('list', function() {
  return gulp.src(mainBowerFiles({filter: new RegExp('.js$')}))
    .pipe(filelog());
});

gulp.task('javascripts', function(cb) {
  var javascripts = gulp.src(mainBowerFiles({filter: new RegExp('.js$')}).concat([
        './bower_components/moment/locale/en-gb.js',
        './bower_components/lodash/dist/lodash.js',
        './bower_components/angular-google-maps/dist/angular-google-maps.js',
        './bower_components/webshim/js-webshim/dev/polyfiller.js',
        './bower_components/airbrake-js-client/dist/client.min.js',
        './src/javascripts/core/main.js.coffee',
        './src/*/javascripts/main.js.coffee',
        './src/*/main.js.coffee',
        './src/core/javascripts/services/widget.js.coffee',
        './src/core/javascripts/collections/base.js.coffee',
        './src/*/javascripts/**/*',
        './src/*/directives/**/*',
        './src/*/models/**/*',
        './src/*/services/**/*',
        '!./src/**/*_test.js.coffee',
        '!./**/*~']))
    // .pipe(filelog())
    .pipe(gulpif(/.*coffee$/, coffee().on('error', function (e) {
      gutil.log(e);
      this.emit('end');
    })));
  var templates = gulp.src('./src/*/templates/**/*.html')
    .pipe(flatten())
    .pipe(templateCache({module: 'BB'}));
  streamqueue({objectMode: true}, javascripts, templates)
    .pipe(concat('bookingbug-angular.js'))
    .pipe(gulpif(argv.env != 'development' && argv.env != 'dev',
            uglify({mangle: false}))).on('error', gutil.log)
    .pipe(gulp.dest('release'))
    .on('end', cb);
});

gulp.task('images', function() {
  return gulp.src('src/*/images/*')
    .pipe(imagemin())
    .pipe(flatten())
    .pipe(gulp.dest('release/images'));
});

gulp.task('shims', function() {
  return gulp.src('bower_components/webshim/js-webshim/minified/shims/*')
    .pipe(gulp.dest('release/shims'));
});

gulp.task('stylesheets', function() {
  var css_stream = gulp.src(mainBowerFiles({filter: new RegExp('.css$')}));
  var sass_stream = gulp.src('src/*/stylesheets/main.scss')
    .pipe(sass({errLogToConsole: true}))
    .pipe(flatten());
  return streamqueue({objectMode: true}, css_stream, sass_stream)
    .pipe(concat('bookingbug-angular.css'))
    .pipe(gulp.dest('release'));
});

gulp.task('widget', function() {
  return gulp.src('src/widget/stylesheets/main.scss')
    .pipe(sass({errLogToConsole: true}))
    .pipe(flatten())
    .pipe(concat('bookingbug-widget.css'))
    .pipe(gulp.dest('release'));
});

gulp.task('theme', function() {
  return gulp.src('src/*/stylesheets/bb_light_theme.scss')
    .pipe(sass({errLogToConsole: true}))
    .pipe(flatten())
    .pipe(concat('bb-theme.css'))
    .pipe(gulp.dest('release'));
});

gulp.task('fonts', function() {
  return gulp.src('src/*/fonts/*')
    .pipe(flatten())
    .pipe(gulp.dest('release/fonts'));
});


gulp.task('watch', function() {
  gulp.watch(['./src/**/*', '!./**/*~'], ['assets']);
});

gulp.task('webserver', ['assets'], function() {
  connect.server({
    root: ['release', 'examples', 'bower_components'],
    port: 8888
  });
});

gulp.task('assets', ['clean', 'javascripts', 'images', 'stylesheets','fonts', 'theme', 'shims', 'widget']);

gulp.task('default', ['assets', 'watch', 'webserver']);

gulp.task('cleandocs', function(cb) {
  del.sync(['docs']);
  cb();
});

gulp.task('ngdocs', [], function () {
  var options = {
    html5Mode: false,
    editExample: true,
    sourceLink: true,
    image: "custom-template/logo.png",
    imageLink: "custom-template/logo.png",
    navTemplate: 'custom-template/custom-head.html',
    styles: "custom-template/custom-style.css",
    loadDefaults: {
      angular: false,
      angularAnimate: false
    },
    title: "BookingBug SDK Docs",
    scripts: [
      'examples/booking-widget.js'
    ]
  };
  return gulp.src('src/*/javascripts/**')
    .pipe(gulpif(/.*coffee$/, coffee().on('error', gutil.log)))
    .pipe(gulpDocs.process(options))
    .pipe(gulp.dest('./docs'));
});

gulp.task('docs', ['cleandocs','ngdocs'], function (cb) {
  gulp.watch('src/*/javascripts/**', ['ngdocs']);
  return connect.server({
    root: ['docs'],
    port: 8000
  });
});

gulp.task('bower', function() {
  return bower();
});

gulp.task('dependencies', ['bower'], function() {
  return gulp.src(mainBowerFiles({filter: new RegExp('.js$')}))
    .pipe(concat('bookingbug-angular-dependencies.js'))
    .pipe(gulp.dest('release'));
});

gulp.task('unit-tests', ['dependencies'], function (done) {
  new KarmaServer({
    configFile: __dirname + '/karma.conf.js',
    singleRun: true
  }, done).start();
});

gulp.task('e2e-tests', ['webserver'], function(cb) {
  return gulp.src(['e2e-tests/booking.js.coffee'])
    .pipe(protractor({
      configFile: 'e2e-tests/protractor.conf.js'
    }))
    .on('error', console.error.bind(console))
    .on('end', cb);
});

gulp.task('test', ['unit-tests', 'e2e-tests']);
