module.exports = (gulp, plugins, path)->
  fs = require('fs')
  jsonFile = require('jsonfile')
  mkDirP = require('mkdirp')

  ###
  * @param {String} dependencyName
  * @returns {Boolean}
  ###
  isBBDependency = (dependencyName) ->
    return new RegExp(/^bookingbug-angular.*/).test dependencyName


  prepareTestBowerJson = () ->
    nonBBDependencies = {}

    testBowerJson = JSON.parse(fs.readFileSync('unit-tests/bower.json', 'utf8'))

    orderedSubModulesNames = [
      'core'
      'admin'
      'admin-booking'
      'events'
      'member'
      'services'
      'settings'
      'test-examples'
      'admin-dashboard'
    ]

    for subModuleName in orderedSubModulesNames
      bowerJson = JSON.parse(fs.readFileSync(path.join('src', subModuleName, '/bower.json'), 'utf8'))

      for depName,depVersion of bowerJson.dependencies
        if not isBBDependency depName
          nonBBDependencies[depName] = depVersion

    testBowerJson.name = 'bb-unit-test'
    testBowerJson.dependencies = nonBBDependencies

    mkDirP.sync 'unit-tests'
    jsonFile.writeFile 'unit-tests/bower.json', testBowerJson, (err) ->
      console.log err if err isnt null
    return

  prepareKarmaFiles = () ->
    bowerFiles = require('main-bower-files')(
      filter: [
        '**/*.js'
      ]
      paths:
        bowerDirectory: 'unit-tests/bower_components',
        bowerJson: 'unit-tests/bower.json'
    )

    projectFiles = [
      'src/core/javascripts/main.js.coffee'
      'src/*/javascripts/main.js.coffee'
      'src/*/javascripts/core/config.js.coffee'
      'src/*/templates/**/*.html'
      'src/*/templates/*.html'
      'src/core/javascripts/collections/*.coffee'
      'src/*/javascripts/*.coffee'
      'src/*/javascripts/*.js'
      'src/*/javascripts/**/*.coffee'
      'src/*/javascripts/**/*.js'
    ]

    return bowerFiles.concat projectFiles

  ###
  * @param {Boolean} isDev
  ###
  getKarmaServerSettings = (isDev) ->
    serverSettings =
      configFile: path.join(__dirname, '/../karma.conf.js'),
      basePath: '../'
      files: prepareKarmaFiles()
      autoWatch: true
      singleRun: false

    if not isDev
      serverSettings.autoWatch = false
      serverSettings.singleRun = true

    return serverSettings

  gulp.task 'test:unit-dependencies', (cb)->
    prepareTestBowerJson()
    cb()
    return

  gulp.task 'test:unit', (cb)->
    return new plugins.karma.Server(getKarmaServerSettings(true), cb).start()

  gulp.task 'test:unit-ci', (cb)->
    return new plugins.karma.Server(getKarmaServerSettings(false), cb).start()

  return
