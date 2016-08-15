'use strict'

###*
* @ngdoc service
* @name BBAdminDashboard.RuntimeStates
*
* @description
* Returns an instance of $stateProvider that allows late state binding (on runtime)
###

###*
* @ngdoc service
* @name BBAdminDashboard.RuntimeStatesProvider
*
* @description
* Provider
*
* @example
  <pre>
  angular.module('ExampleModule').config ['RuntimeStatesProvider', '$stateProvider', (RuntimeStatesProvider, $stateProvider) ->
    RuntimeStatesProvider.setProvider($stateProvider)
  ]
  </pre>
###
angular.module('BBAdminDashboard').provider 'RuntimeStates', ['$stateProvider', ($stateProvider)->
  stateProvider  = $stateProvider
  @setProvider = (provider)->
    stateProvider = provider
  @$get = ->
    stateProvider
  return
]
