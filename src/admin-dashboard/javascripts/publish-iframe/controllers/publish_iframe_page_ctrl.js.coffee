'use strict';

###
* @ngdoc controller
* @name BBAdminDashboard.publish-iframe.controllers.controller:PublishIframePageCtrl
#
* @description
* Controller for the publish page
###
angular.module('BBAdminDashboard.publish-iframe.controllers')
.controller 'PublishIframePageCtrl',['$scope', '$state', '$rootScope', ($scope, $state, $rootScope) ->

  $scope.parent_state = $state.is("publish")
  $scope.path = "conf"

  $rootScope.$on '$stateChangeStart', (event, toState, toParams, fromState, fromParams) ->
    $scope.parent_state = false
    if (toState.name == "setting")
      $scope.parent_state = true
]