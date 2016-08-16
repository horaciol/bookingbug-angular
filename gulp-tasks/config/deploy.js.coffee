module.exports = (gulp, plugins, path) ->

  awspublish = require('gulp-awspublish')
  awspublishRouter = require('gulp-awspublish-router')
  rename = require('gulp-rename')

  gulp.task 'deploy', ['build','build:widget'], () ->
    publisher = awspublish.create
      params:
        Bucket: 'angular.bookingbug.com'
      region: 'eu-west-1'
    gulp.src(['./build/**','!./build/*/bower_components/**'])
      .pipe(rename((path) ->
        path.dirname = "/#{process.env.TRAVIS_BRANCH}/#{path.dirname}"
      ))
      .pipe(publisher.publish())
      .pipe(publisher.cache())
      .pipe(awspublish.reporter())

