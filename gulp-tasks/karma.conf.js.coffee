module.exports = (config) ->

  config.set

    autoWatch: true

    browsers: ['PhantomJS']

    coffeeCoverage: {
      preprocessor: {
        instrumentor: 'istanbul'
      }
    }

    coffeePreprocessor:
      options:
        bare: false
        sourceMap: true

      transformPath: (path) ->
        path.replace /\.coffee$/, '.js'

    coverageReporter:
      reporters: [
        {
          type: 'lcov'
          dir: './unit-tests/reports/coverage-lcov/'
          file: 'lcov.info'
          subdir: '.'
        }
      ]

    colors: true

    frameworks: ['jasmine']

    logLevel: config.LOG_INFO

    port: 9876

    preprocessors: {
      'src/*/javascripts/*.html': 'html2js'
      'src/*/javascripts/**/*.html': 'html2js'
      'src/*/javascripts/*.spec.js.coffee': ['coffee']
      'src/*/javascripts/**/*.spec.js.coffee': ['coffee']
      'src/*/javascripts/!(*.spec).js.coffee': ['coffee-coverage']
      'src/*/javascripts/**/!(*.spec).js.coffee': ['coffee-coverage']
    }

    reporters: ['dots', 'coverage']

    singleRun: false
