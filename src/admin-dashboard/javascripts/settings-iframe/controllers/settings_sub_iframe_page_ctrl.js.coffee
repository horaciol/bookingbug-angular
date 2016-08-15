'use strict';

###
* @ngdoc controller
* @name BBAdminDashboard.settings-iframe.controllers.controller:SettingsSubIframePageCtrl
#
* @description
* Controller for the settings sub page
###
angular.module('BBAdminDashboard.settings-iframe.controllers')
.controller 'SettingsSubIframePageCtrl',['$scope', '$state', '$stateParams', ($scope, $state, $stateParams) ->
  $scope.path = $stateParams.path
  if $stateParams.id
    $scope.extra_params = "id=#{$stateParams.id}"
  else
    $scope.extra_params = ""

  $scope.pageHeader = null

  # For iframe content in a tabbed context
  $scope.$emit 'iframeLoading',{}
  $scope.onIframeLoad = ()->
    $scope.$emit 'iframeLoaded',{}

  # For iframe content in a stand-alone context
  $scope.loading = true
  $scope.$on 'iframeLoaded', ()->
    $scope.loading = false
    $scope.$apply()
]