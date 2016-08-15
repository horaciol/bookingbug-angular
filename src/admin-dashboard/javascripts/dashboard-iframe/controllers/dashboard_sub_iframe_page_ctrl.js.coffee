'use strict';

###
* @ngdoc controller
* @name BBAdminDashboard.dashboard-iframe.controllers.controller:DashboardSubIframePageCtrl
#
* @description
* Controller for the dashboard sub page
###
angular.module('BBAdminDashboard.dashboard-iframe.controllers')
.controller 'DashboardSubIframePageCtrl',['$scope', '$state', '$stateParams', ($scope, $state, $stateParams) ->
  $scope.path = $stateParams.path

  if $scope.path == 'view/dashboard/index'
  	$scope.fullHeight = true
]