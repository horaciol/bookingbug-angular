'use strict';

###
* @ngdoc controller
* @name BBAdminDashboard.clients.controllers.controller:ClientsAllPageCtrl
#
* @description
* Controller for the clients all page
###
angular.module('BBAdminDashboard.clients.controllers')
.controller 'ClientsAllPageCtrl',['$scope', '$state', ($scope, $state) ->
  $scope.set_current_client(null)
]