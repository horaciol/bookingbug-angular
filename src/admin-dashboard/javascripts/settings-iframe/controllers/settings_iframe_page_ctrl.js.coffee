'use strict';

###
* @ngdoc controller
* @name BBAdminDashboard.settings-iframe.controllers.controller:SettingsIframePageCtrl
#
* @description
* Controller for the settings page
###
angular.module('BBAdminDashboard.settings-iframe.controllers')
.controller 'SettingsIframePageCtrl',['$scope', '$state', '$rootScope', ($scope, $state, $rootScope) ->

  $scope.parent_state = $state.is("setting")
  $scope.path = "conf"

  $rootScope.$on '$stateChangeStart', (event, toState, toParams, fromState, fromParams) ->
    $scope.parent_state = false
    if (toState.name == "setting")
      $scope.parent_state = true
]