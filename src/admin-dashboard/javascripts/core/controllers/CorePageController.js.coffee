'use strict';

###
* @ngdoc controller
* @name BBAdminDashboard.controllers.controller:CorePageController
#
* @description
* Controller for the layout (root state)
###
angular.module('BBAdminDashboard.controllers')
.controller 'CorePageController',['$scope', '$state', 'company', '$modalStack', '$rootScope',($scope, $state, company, $modalStack, $rootScope) ->
  $scope.company = company
  $scope.bb.company = company
  #Set timezone globally per company basis (company contains timezone info)
  moment.tz.setDefault(company.timezone)

  # close any modals that might be open
  $rootScope.$on '$stateChangeStart', () ->
    $modalStack.dismissAll()

]