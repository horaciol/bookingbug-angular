module.exports = (gulp, plugins, path) ->

  bbGulp = require('../../bb-gulp.js')

  gulp.task 'build-skd:core:javascripts', () ->
    bbGulp.javascripts('core')

  gulp.task 'build-skd:core:stylesheets', () ->
    bbGulp.stylesheets('core')

  gulp.task 'build-skd:core:templates', () ->
    bbGulp.templates('core')

  gulp.task 'build-skd:core:bower', () ->
    bbGulp.bower('core')

  gulp.task 'build-skd:core', [
    'build-skd:core:javascripts'
    'build-skd:core:stylesheets'
    'build-skd:core:templates'
    'build-skd:core:bower'
  ]

  gulp.task 'build-skd:public-booking:javascripts', () ->
    bbGulp.javascripts('public-booking')

  gulp.task 'build-skd:public-booking:stylesheets', () ->
    bbGulp.stylesheets('public-booking')

  gulp.task 'build-skd:public-booking:fonts', () ->
    bbGulp.fonts('public-booking')

  gulp.task 'build-skd:public-booking:images', () ->
    bbGulp.images('public-booking')

  gulp.task 'build-skd:public-booking:templates', () ->
    bbGulp.templates('public-booking')

  gulp.task 'build-skd:public-booking:bower', () ->
    bbGulp.bower('public-booking')

  gulp.task 'build-skd:public-booking', [
    'build-skd:public-booking:javascripts'
    'build-skd:public-booking:stylesheets'
    'build-skd:public-booking:fonts'
    'build-skd:public-booking:images'
    'build-skd:public-booking:templates'
    'build-skd:public-booking:bower'
  ]

  gulp.task 'build-skd:member:javascripts', () ->
    bbGulp.javascripts('member')

  gulp.task 'build-skd:member:stylesheets', () ->
    bbGulp.stylesheets('member')

  gulp.task 'build-skd:member:templates', () ->
    bbGulp.templates('member')

  gulp.task 'build-skd:member:bower', () ->
    bbGulp.bower('member')

  gulp.task 'build-skd:member', [
    'build-skd:member:javascripts'
    'build-skd:member:stylesheets'
    'build-skd:member:templates'
    'build-skd:member:bower'
  ]

  gulp.task 'build-skd:admin:javascripts', () ->
    bbGulp.javascripts('admin')

  gulp.task 'build-skd:admin:images', () ->
    bbGulp.images('admin')

  gulp.task 'build-skd:admin:templates', () ->
    bbGulp.templates('admin')

  gulp.task 'build-skd:admin:bower', () ->
    bbGulp.bower('admin')

  gulp.task 'build-skd:admin', [
    'build-skd:admin:javascripts'
    'build-skd:admin:images'
    'build-skd:admin:templates'
    'build-skd:admin:bower'
  ]

  gulp.task 'build-skd:admin-booking:javascripts', () ->
    bbGulp.javascripts('admin-booking')

  gulp.task 'build-skd:admin-booking:stylesheets', () ->
    bbGulp.stylesheets('admin-booking')

  gulp.task 'build-skd:admin-booking:templates', () ->
    bbGulp.templates('admin-booking', false, false, 'BBAdminBooking')

  gulp.task 'build-skd:admin-booking:bower', () ->
    bbGulp.bower('admin-booking')

  gulp.task 'build-skd:admin-booking', [
    'build-skd:admin-booking:javascripts'
    'build-skd:admin-booking:stylesheets'
    'build-skd:admin-booking:templates'
    'build-skd:admin-booking:bower'
  ]

  gulp.task 'build-skd:admin-dashboard:javascripts', () ->
    bbGulp.javascripts('admin-dashboard')

  gulp.task 'build-skd:admin-dashboard:stylesheets', () ->
    bbGulp.stylesheets('admin-dashboard')

  gulp.task 'build-skd:admin-dashboard:images', () ->
    bbGulp.images('admin-dashboard')

  gulp.task 'build-skd:admin-dashboard:templates', () ->
    bbGulp.templates('admin-dashboard', false, false, false, false)

  gulp.task 'build-skd:admin-dashboard:bower', () ->
    bbGulp.bower('admin-dashboard')

  gulp.task 'build-skd:admin-dashboard', [
    'build-skd:admin-dashboard:javascripts'
    'build-skd:admin-dashboard:stylesheets'
    'build-skd:admin-dashboard:images'
    'build-skd:admin-dashboard:templates'
    'build-skd:admin-dashboard:bower'
  ]

  gulp.task 'build-skd:events:javascripts', () ->
    bbGulp.javascripts('events')

  gulp.task 'build-skd:events:templates', () ->
    bbGulp.templates('events')

  gulp.task 'build-skd:events:bower', () ->
    bbGulp.bower('events')

  gulp.task 'build-skd:events', [
    'build-skd:events:javascripts'
    'build-skd:events:templates'
    'build-skd:events:bower'
  ]

  gulp.task 'build-skd:queue:javascripts', () ->
    bbGulp.javascripts('queue')

  gulp.task 'build-skd:queue:templates', () ->
    bbGulp.templates('queue')

  gulp.task 'build-skd:queue:bower', () ->
    bbGulp.bower('queue')

  gulp.task 'build-skd:queue', [
    'build-skd:queue:javascripts'
    'build-skd:queue:templates'
    'build-skd:queue:bower'
  ]

  gulp.task 'build-skd:services:javascripts', () ->
    bbGulp.javascripts('services')

  gulp.task 'build-skd:services:templates', () ->
    bbGulp.templates('services')

  gulp.task 'build-skd:services:bower', () ->
    bbGulp.bower('services')

  gulp.task 'build-skd:services', [
    'build-skd:services:javascripts'
    'build-skd:services:templates'
    'build-skd:services:bower'
  ]

  gulp.task 'build-skd:settings:javascripts', () ->
    bbGulp.javascripts('settings')

  gulp.task 'build-skd:settings:templates', () ->
    bbGulp.templates('settings')

  gulp.task 'build-skd:settings:bower', () ->
    bbGulp.bower('settings')

  gulp.task 'build-skd:settings', [
    'build-skd:settings:javascripts'
    'build-skd:settings:templates'
    'build-skd:settings:bower'
  ]

  gulp.task 'build-sdk', [
    'build-skd:core'
    'build-skd:public-booking'
    'build-skd:member'
    'build-skd:admin'
    'build-skd:admin-booking'
    'build-skd:admin-dashboard'
    'build-skd:events'
    'build-skd:queue'
    'build-skd:services'
    'build-skd:settings'
  ]

  gulp.task 'build-skd:watch', ['build'], () ->
    gulp.watch(['src/core/javascripts/**/*'], ['build-skd:core:javascripts'])
    gulp.watch(['src/core/stylesheets/**/*'], ['build-skd:core:stylesheets'])
    gulp.watch(['src/core/templates/**/*'], ['build-skd:core:templates'])
    gulp.watch(['src/public-booking/javascripts/**/*'], ['build-skd:public-booking:javascripts'])
    gulp.watch(['src/public-booking/stylesheets/**/*'], ['build-skd:public-booking:stylesheets'])
    gulp.watch(['src/public-booking/fonts/**/*'], ['build-skd:public-booking:fonts'])
    gulp.watch(['src/public-booking/images/**/*'], ['build-skd:public-booking:images'])
    gulp.watch(['src/public-booking/templates/**/*'], ['build-skd:public-booking:templates'])
    gulp.watch(['src/member/javascripts/**/*'], ['build-skd:member:javascripts'])
    gulp.watch(['src/member/stylesheets/**/*'], ['build-skd:member:stylesheets'])
    gulp.watch(['src/member/templates/**/*'], ['build-skd:member:templates'])
    gulp.watch(['src/admin/javascripts/**/*'], ['build-skd:admin:javascripts'])
    gulp.watch(['src/admin/images/**/*'], ['build-skd:admin:images'])
    gulp.watch(['src/admin/templates/**/*'], ['build-skd:admin:templates'])
    gulp.watch(['src/admin-booking/javascripts/**/*'], ['build-skd:admin-booking:javascripts'])
    gulp.watch(['src/admin-booking/stylesheets/**/*'], ['build-skd:admin-booking:stylesheets'])
    gulp.watch(['src/admin-booking/templates/**/*'], ['build-skd:admin-booking:templates'])
    gulp.watch(['src/admin-dashboard/javascripts/**/*'], ['build-skd:admin-dashboard:javascripts'])
    gulp.watch(['src/admin-dashboard/stylesheets/**/*'], ['build-skd:admin-dashboard:stylesheets'])
    gulp.watch(['src/admin-dashboard/images/**/*'], ['build-skd:admin-dashboard:images'])
    gulp.watch(['src/admin-dashboard/templates/**/*'], ['build-skd:admin-dashboard:templates'])
    gulp.watch(['src/events/javascripts/**/*'], ['build-skd:events:javascripts'])
    gulp.watch(['src/events/templates/**/*'], ['build-skd:events:templates'])
    gulp.watch(['src/queue/javascripts/**/*'], ['build-skd:queue:javascripts'])
    gulp.watch(['src/queue/templates/**/*'], ['build-skd:queue:templates'])
    gulp.watch(['src/services/javascripts/**/*'], ['build-skd:services:javascripts'])
    gulp.watch(['src/services/templates/**/*'], ['build-skd:services:templates'])
    gulp.watch(['src/settings/javascripts/**/*'], ['build-skd:settings:javascripts'])
    gulp.watch(['src/settings/templates/**/*'], ['build-skd:settings:templates'])

