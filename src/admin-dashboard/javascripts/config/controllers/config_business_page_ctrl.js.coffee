'use strict'

###
* @ngdoc controller
* @name BBAdminDashboard.config.controllers.controller:ConfigBusinessPageCtrl
#
* @description
* Controller for the config page
###
angular.module('BBAdminDashboard.config.controllers')
.controller 'ConfigBusinessPageCtrl', ($scope, $state, $rootScope) ->

  $scope.pageHeader = 'ADMIN_DASHBOARD.CONFIG_PAGE.BUSINESS.TITLE'

  $scope.tabs = [
    {
      name: 'ADMIN_DASHBOARD.CONFIG_PAGE.BUSINESS.TAB_SERVICES',
      icon: 'fa fa-wrench',
      path: 'config.business.services'
    }
  ]

  if $scope.company.$has('resources')
    $scope.tabs.push {
      name: 'ADMIN_DASHBOARD.CONFIG_PAGE.BUSINESS.TAB_RESOURCES',
      icon: 'fa fa-diamond',
      path: 'config.business.resources'
    }

  if $scope.company.$has('people')
    $scope.tabs.push {
      name: 'ADMIN_DASHBOARD.CONFIG_PAGE.BUSINESS.TAB_STAFF',
      icon: 'fa fa-male',
      path: 'config.business.people'
    }

