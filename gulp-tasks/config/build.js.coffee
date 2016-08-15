module.exports = (gulp, plugins, path) ->

  bbGulp = require('../../bb-gulp.js')

  gulp.task 'build:core:javascripts', () ->
    bbGulp.javascripts('core')

  gulp.task 'build:core:stylesheets', () ->
    bbGulp.stylesheets('core')

  gulp.task 'build:core:templates', () ->
    bbGulp.templates('core')

  gulp.task 'build:core:bower', () ->
    bbGulp.bower('core')

  gulp.task 'build:core', [
    'build:core:javascripts'
    'build:core:stylesheets'
    'build:core:templates'
    'build:core:bower'
  ]

  gulp.task 'build:public-booking:javascripts', () ->
    bbGulp.javascripts('public-booking')

  gulp.task 'build:public-booking:stylesheets', () ->
    bbGulp.stylesheets('public-booking')

  gulp.task 'build:public-booking:fonts', () ->
    bbGulp.fonts('public-booking')

  gulp.task 'build:public-booking:images', () ->
    bbGulp.images('public-booking')

  gulp.task 'build:public-booking:templates', () ->
    bbGulp.templates('public-booking')

  gulp.task 'build:public-booking:bower', () ->
    bbGulp.bower('public-booking')

  gulp.task 'build:public-booking', [
    'build:public-booking:javascripts'
    'build:public-booking:stylesheets'
    'build:public-booking:fonts'
    'build:public-booking:images'
    'build:public-booking:templates'
    'build:public-booking:bower'
  ]

  gulp.task 'build:member:javascripts', () ->
    bbGulp.javascripts('member')

  gulp.task 'build:member:stylesheets', () ->
    bbGulp.stylesheets('member')

  gulp.task 'build:member:templates', () ->
    bbGulp.templates('member')

  gulp.task 'build:member:bower', () ->
    bbGulp.bower('member')

  gulp.task 'build:member', [
    'build:member:javascripts'
    'build:member:stylesheets'
    'build:member:templates'
    'build:member:bower'
  ]

  gulp.task 'build:admin:javascripts', () ->
    bbGulp.javascripts('admin')

  gulp.task 'build:admin:images', () ->
    bbGulp.images('admin')

  gulp.task 'build:admin:templates', () ->
    bbGulp.templates('admin')

  gulp.task 'build:admin:bower', () ->
    bbGulp.bower('admin')

  gulp.task 'build:admin', [
    'build:admin:javascripts'
    'build:admin:images'
    'build:admin:templates'
    'build:admin:bower'
  ]

  gulp.task 'build:admin-booking:javascripts', () ->
    bbGulp.javascripts('admin:booking')

  gulp.task 'build:admin-booking:stylesheets', () ->
    bbGulp.stylesheets('admin:booking')

  gulp.task 'build:admin-booking:templates', () ->
    bbGulp.templates('admin:booking')

  gulp.task 'build:admin-booking:bower', () ->
    bbGulp.bower('admin-booking')

  gulp.task 'build:admin-booking', [
    'build:admin-booking:javascripts'
    'build:admin-booking:stylesheets'
    'build:admin-booking:templates'
    'build:admin-booking:bower'
  ]

  gulp.task 'build:admin-dashboard:javascripts', () ->
    bbGulp.javascripts('admin-dashboard')

  gulp.task 'build:admin-dashboard:stylesheets', () ->
    bbGulp.stylesheets('admin-dashboard')

  gulp.task 'build:admin-dashboard:images', () ->
    bbGulp.images('admin-dashboard')

  gulp.task 'build:admin-dashboard:templates', () ->
    bbGulp.templates('admin-dashboard')

  gulp.task 'build:admin-dashboard:bower', () ->
    bbGulp.bower('admin-dashboard')

  gulp.task 'build:admin-dashboard', [
    'build:admin-dashboard:javascripts'
    'build:admin-dashboard:stylesheets'
    'build:admin-dashboard:images'
    'build:admin-dashboard:templates'
    'build:admin-dashboard:bower'
  ]

  gulp.task 'build:events:javascripts', () ->
    bbGulp.javascripts('events')

  gulp.task 'build:events:templates', () ->
    bbGulp.templates('events')

  gulp.task 'build:events:bower', () ->
    bbGulp.bower('events')

  gulp.task 'build:events', [
    'build:events:javascripts'
    'build:events:templates'
    'build:events:bower'
  ]

  gulp.task 'build:queue:javascripts', () ->
    bbGulp.javascripts('queue')

  gulp.task 'build:queue:templates', () ->
    bbGulp.templates('queue')

  gulp.task 'build:queue:bower', () ->
    bbGulp.bower('queue')

  gulp.task 'build:queue', [
    'build:queue:javascripts'
    'build:queue:templates'
    'build:queue:bower'
  ]

  gulp.task 'build:services:javascripts', () ->
    bbGulp.javascripts('services')

  gulp.task 'build:services:templates', () ->
    bbGulp.templates('services')

  gulp.task 'build:services:bower', () ->
    bbGulp.bower('services')

  gulp.task 'build:services', [
    'build:services:javascripts'
    'build:services:templates'
    'build:services:bower'
  ]

  gulp.task 'build:settings:javascripts', () ->
    bbGulp.javascripts('settings')

  gulp.task 'build:settings:templates', () ->
    bbGulp.templates('settings')

  gulp.task 'build:settings:bower', () ->
    bbGulp.bower('settings')

  gulp.task 'build:settings', [
    'build:settings:javascripts'
    'build:settings:templates'
    'build:settings:bower'
  ]

  gulp.task 'build', [
    'build:core'
    'build:public-booking'
    'build:member'
    'build:admin'
    'build:admin-booking'
    'build:admin-dashboard'
    'build:events'
    'build:queue'
    'build:services'
    'build:settings'
  ]

  gulp.task 'build:watch', ['build'], () ->
    gulp.watch(['src/core/javascripts/**/*'], ['build:core:javascripts'])
    gulp.watch(['src/core/stylesheets/**/*'], ['build:core:stylesheets'])
    gulp.watch(['src/core/templates/**/*'], ['build:core:templates'])
    gulp.watch(['src/public-booking/javascripts/**/*'], ['build:public-booking:javascripts'])
    gulp.watch(['src/public-booking/stylesheets/**/*'], ['build:public-booking:stylesheets'])
    gulp.watch(['src/public-booking/fonts/**/*'], ['build:public-booking:fonts'])
    gulp.watch(['src/public-booking/images/**/*'], ['build:public-booking:images'])
    gulp.watch(['src/public-booking/templates/**/*'], ['build:public-booking:templates'])
    gulp.watch(['src/member/javascripts/**/*'], ['build:member:javascripts'])
    gulp.watch(['src/member/stylesheets/**/*'], ['build:member:stylesheets'])
    gulp.watch(['src/member/templates/**/*'], ['build:member:templates'])
    gulp.watch(['src/admin/javascripts/**/*'], ['build:admin:javascripts'])
    gulp.watch(['src/admin/images/**/*'], ['build:admin:images'])
    gulp.watch(['src/admin/templates/**/*'], ['build:admin:templates'])
    gulp.watch(['src/admin-booking/javascripts/**/*'], ['build:admin-booking:javascripts'])
    gulp.watch(['src/admin-booking/stylesheets/**/*'], ['build:admin-booking:stylesheets'])
    gulp.watch(['src/admin-booking/templates/**/*'], ['build:admin-booking:templates'])
    gulp.watch(['src/admin-dashboard/javascripts/**/*'], ['build:admin-dashboard:javascripts'])
    gulp.watch(['src/admin-dashboard/stylesheets/**/*'], ['build:admin-dashboard:stylesheets'])
    gulp.watch(['src/admin-dashboard/images/**/*'], ['build:admin-dashboard:images'])
    gulp.watch(['src/admin-dashboard/templates/**/*'], ['build:admin-dashboard:templates'])
    gulp.watch(['src/events/javascripts/**/*'], ['build:events:javascripts'])
    gulp.watch(['src/events/templates/**/*'], ['build:events:templates'])
    gulp.watch(['src/queue/javascripts/**/*'], ['build:queue:javascripts'])
    gulp.watch(['src/queue/templates/**/*'], ['build:queue:templates'])
    gulp.watch(['src/services/javascripts/**/*'], ['build:services:javascripts'])
    gulp.watch(['src/services/templates/**/*'], ['build:services:templates'])
    gulp.watch(['src/settings/javascripts/**/*'], ['build:settings:javascripts'])
    gulp.watch(['src/settings/templates/**/*'], ['build:settings:templates'])

