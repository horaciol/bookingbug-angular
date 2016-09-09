'use strict'

###*
* @ngdoc service
* @name BBAdminDashboard.RuntimeTranslate
*
* @description
* Returns an instance of $translateProvider that allows late language binding (on runtime)
###

###*
* @ngdoc service
* @name BBAdminDashboard.RuntimeTranslateProvider
*
* @description
* Provider
*
* @example
  <pre>
  angular.module('ExampleModule').config ['RuntimeTranslateProvider', '$translateProvider', (RuntimeTranslateProvider, $translateProvider) ->
    RuntimeTranslateProvider.setProvider($translateProvider)
  ]
  </pre>
###
angular.module('BB.i18n').provider 'RuntimeTranslate', ($translateProvider)->
  'ngInject'

  translateProvider = $translateProvider
  @setProvider = (provider)->
    translateProvider = provider
  @$get = ->
    translateProvider
  return
