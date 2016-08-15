'use strict';

###*
* @ngdoc controller
* @name BBAdminDashboard.controller:CorePageController
* @description
* Controller for the layout (root state)
###
controller = ($scope, $state, company) ->
  'ngInject'

  $scope.company = company
  $scope.bb.company = company

  #Set timezone globally per company basis (company contains timezone info)
  moment.tz.setDefault(company.timezone)

  # checks to see if passed in state is part of the active chain
  $scope.isState = (states)->
    return $state.includes states

  return

angular.module('BBAdminDashboard').controller 'CorePageController', controller
