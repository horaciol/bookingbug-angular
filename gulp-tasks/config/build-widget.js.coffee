module.exports = (gulp, plugins, path) ->

  mainBowerFiles = require('main-bower-files')
  concat = require('gulp-concat')
  uglify = require('gulp-uglify')
  sourcemaps = require('gulp-sourcemaps')
  plumber = require('gulp-plumber')
  sass = require('gulp-sass')
  cssSelectorLimit = require('gulp-css-selector-limit')
  bower = require('gulp-bower')

  gulp.task 'bower-widget', ['build'], () ->
    bower({cwd: './build/booking-widget', directory: './bower_components'})

  gulp.task 'build:widget-script', ['bower-widget'], () ->
    gulp.src(mainBowerFiles(
      filter: new RegExp('.js$')
      paths:
        bowerDirectory: './build/booking-widget/bower_components'
        bowerJson: './build/booking-widget/bower.json'
    ))
      .pipe(concat('booking-widget.js'))
      .pipe(gulp.dest('./build/booking-widget/dist'))
      .pipe(uglify({mangle: false}))
      .pipe(concat('booking-widget.min.js'))
      .pipe(gulp.dest('./build/booking-widget/dist'))

  gulp.task 'build:widget-style', ['bower-widget'], () ->
    gulp.src('./build/booking-widget/src/stylesheets/main.scss')
      .pipe(sourcemaps.init())
      .pipe(plumber())
      .pipe(sass(
        includePaths: ['./build/booking-widget/bower_components/bootstrap-sass/assets/stylesheets']
        outputStyle: 'compressed'
        errLogToConsole: true
      ))
      .pipe(concat('booking-widget.css'))
      .pipe(cssSelectorLimit.reporter('fail'))
      .pipe(sourcemaps.write('maps', { includeContent: false }))
      .pipe(gulp.dest('./build/booking-widget/dist'))

  filterStylesheets = (path) ->
    path.match(new RegExp('.css$')) &&
    !path.match(new RegExp('(bower_components\/bookingbug-angular-).+(\.css)')) &&
    path.indexOf('bootstrap.') == -1

  gulp.task 'build:widget-dependency-style', ['bower-widget'], () ->
    gulp.src(mainBowerFiles(
      includeDev: true
      filter: filterStylesheets
      paths:
        bowerDirectory: './build/booking-widget/bower_components'
        bowerJson: './build/booking-widget/bower.json'
    ))
      .pipe(concat('booking-widget-dependencies.css'))
      .pipe(gulp.dest('./build/booking-widget/dist'))

  gulp.task 'build:widget', [
    'build:widget-script'
    'build:widget-style'
    'build:widget-dependency-style'
  ]

