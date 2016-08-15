'use strict';

###
* @ngdoc controller
* @name BBAdminDashboard.members-iframe.controllers.controller:MembersSubIframePageCtrl
#
* @description
* Controller for the members sub page
###
angular.module('BBAdminDashboard.members-iframe.controllers')
.controller 'MembersSubIframePageCtrl',['$scope', '$state', '$stateParams', ($scope, $state, $stateParams) ->
  $scope.path = $stateParams.path
  if $stateParams.id
    $scope.extra_params = "id=#{$stateParams.id}"
  else
    $scope.extra_params = ""

  $scope.loading = true
  $scope.$on 'iframeLoaded', ()->
  	$scope.loading = false
  	$scope.$apply()
]