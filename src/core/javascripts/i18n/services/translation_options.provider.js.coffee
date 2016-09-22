'use strict'

angular.module('BB.i18n').provider 'TranslationOptions', () ->
  'ngInject'
  
  options = {
    default_language               : 'en',
    use_browser_language           : true,
    available_languages            : ['en'],
    available_language_associations: {
      'en_*': 'en'
    }
  }

  @setOption = (option, value) ->
    if options.hasOwnProperty(option)
      options[option] = value
    return

  @getOption = (option) ->
    if options.hasOwnProperty(option)
      return options[option]
    return

  @$get = ->
    return options

  return
