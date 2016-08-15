color = require "colors"
gulp = require "gulp"
gulpLoadPlugins = require("gulp-load-plugins")
includeAll = require "include-all"
path = require "path"

plugins = null

configuration =
  env: process.env.ENV_VARIABLE || "development"
  modulePath: {
    adminDashbaord: 'src/admin-dashboard'
    core: 'src/core'
    admin: 'src/admin'
    adminBooking: 'src/admin-booking'
    events: 'src/events'
    member: 'src/member'
    services: 'src/services'
    settings: 'src/settings'
    testExamples: 'src/test-examples'
  }

init = () ->
  preparePlugins()
  prepareTasks()
  return

preparePlugins = () ->
  plugins = gulpLoadPlugins(
    pattern: [
      "gulp-*"
      "merge-*"
      "run-*"
      "main*"
      "karma*"
    ]
    replaceString: /\bgulp[\-.]|run[\-.]|merge[\-.]|main[\-.]/
    camelizePluginName: true
    lazy: true
  )

  plugins.config = configuration
  plugins.colors = color

  return

loadTasks = (taskPath)->
  includeAll(
    dirname: path.resolve __dirname, taskPath
    filter: /(.+)\.(js|coffee)$/
  ) or {}

invokeConfigFn = (tasks) ->
  for taskName of tasks
    plugins.error = (error)->
      plugins.util.log error.toString()
    tasks[taskName] gulp, plugins, path  if tasks.hasOwnProperty(taskName)
  return

prepareTasks = ()->
  taskConfigurations = loadTasks "./config"
  registerDefinitions = loadTasks "./register"

  if not registerDefinitions['default.js']
    registerDefinitions.default = (gulp)->
      gulp.task 'default', []

  invokeConfigFn taskConfigurations
  invokeConfigFn registerDefinitions
  return

init()

module.exports = gulp
