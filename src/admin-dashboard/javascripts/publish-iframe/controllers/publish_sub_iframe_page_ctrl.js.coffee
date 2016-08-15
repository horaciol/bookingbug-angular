'use strict';

###
* @ngdoc controller
* @name BBAdminDashboard.publish-iframe.controllers.controller:PublishSubIframePageCtrl
#
* @description
* Controller for the publish sub page
###
angular.module('BBAdminDashboard.publish-iframe.controllers')
.controller 'PublishSubIframePageCtrl',['$scope', '$state', '$stateParams', ($scope, $state, $stateParams) ->
  $scope.path = $stateParams.path

  $scope.loading = true
  $scope.$on 'iframeLoaded', ()->
  	$scope.loading = false
  	$scope.$apply()
]