'use strict';

###
* @ngdoc controller
* @name BBAdminDashboard.clients.controllers.controller:ClientsPageCtrl
#
* @description
* Controller for the clients page
###
angular.module('BBAdminDashboard.clients.controllers')
.controller 'ClientsPageCtrl',['$scope', '$state', ($scope, $state) ->
  
  $scope.clientsOptions = {search: null}

  $scope.set_current_client = (client) ->
    $scope.current_client = client

]