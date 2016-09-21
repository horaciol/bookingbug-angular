'use strict'

###
* @ngdoc controller
* @name BBAdminDashboard.config.controllers.controller:ConfigSubPageCtrl
#
* @description
* Controller for the config sub page
###
angular.module('BBAdminDashboard.config.controllers')
.controller 'ConfigSubPageCtrl',['$scope', '$state', '$stateParams', ($scope, $state, $stateParams) ->
  $scope.path = $stateParams.path
  $scope.pageHeader = null

]
