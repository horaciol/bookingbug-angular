'use strict'

###
* @ngdoc controller
* @name BBAdminDashboard.config.controllers.controller:ConfigPageCtrl
#
* @description
* Controller for the config page
###
angular.module('BBAdminDashboard.config.controllers')
.controller 'ConfigPageCtrl',['$scope', '$state', '$rootScope', ($scope, $state, $rootScope) ->

  $scope.parent_state = $state.is("config")
  $scope.path = "edit"

  $rootScope.$on '$stateChangeStart', (event, toState, toParams, fromState, fromParams) ->
    $scope.parent_state = false
    if (toState.name == "config")
      $scope.parent_state = true
]
