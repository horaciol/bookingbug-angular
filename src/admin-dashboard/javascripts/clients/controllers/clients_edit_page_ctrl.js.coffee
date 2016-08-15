'use strict';

###
* @ngdoc controller
* @name BBAdminDashboard.clients.controllers.controller:ClientsEditPageCtrl
#
* @description
* Controller for the clients edit page
###
angular.module('BBAdminDashboard.clients.controllers')
.controller 'ClientsEditPageCtrl',['$scope', 'client', '$state', 'company', 'AdminClientService', ($scope, client, $state, company, AdminClientService) ->
  $scope.client = client
  $scope.historicalStartDate = moment().add(-1, 'years')
  $scope.historicalEndDate = moment()
  # Refresh Client Resource after save
  $scope.memberSaveCallback = ()->
    params =
      company_id: company.id
      id: $state.params.id
      flush: true

    AdminClientService.query(params).then (client)->
      $scope.client = client

]