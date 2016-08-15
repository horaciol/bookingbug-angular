'use strict';

###
* @ngdoc controller
* @name BBAdminDashboard.members-iframe.controllers.controller:MembersIframePageCtrl
#
* @description
* Controller for the members page
###
angular.module('BBAdminDashboard.members-iframe.controllers')
.controller 'MembersIframePageCtrl',['$scope', '$state', '$rootScope', '$window', ($scope, $state, $rootScope, $window) ->

  $scope.parent_state = $state.is("members")

  $rootScope.$on '$stateChangeStart', (event, toState, toParams, fromState, fromParams) ->
    $scope.parent_state = false
    if (toState.name == "members")
      $scope.parent_state = true
      $scope.clearCurrentClient()

  $scope.setCurrentClient = (client) ->
    console.log "set current", client
    if client
      $rootScope.client_id = client
      $scope.extra_params = "id=#{client}"
    else
      $scope.clearCurrentClient()
      
  $scope.clearCurrentClient = ->
    $rootScope.client_id = null
    $scope.extra_params = ""

  $window.addEventListener 'message', (event) =>
    if event && event.data
      if event.data.controller == "client"
        if event.data.id
          $scope.setCurrentClient(event.data.id)
        if event.data.action == "single"
          $state.go "members.page", {path: 'client/single', id: event.data.id}
]