'use strict';

###
* @ngdoc controller
* @name BBAdminDashboard.config.controllers.controller:ConfigEventSettingsPageCtrl
#
* @description
* Controller for the config page
###
angular.module('BBAdminDashboard.config.controllers')
.controller 'ConfigEventSettingsPageCtrl',['$scope', '$state', '$rootScope', ($scope, $state, $rootScope) ->
  $scope.pageHeader = 'ADMIN_DASHBOARD.CONFIG_PAGE.EVENT_SETTINGS.TITLE'

  $scope.tabs = [
    {
      name: 'ADMIN_DASHBOARD.CONFIG_PAGE.EVENT_SETTINGS.TAB_COURSES',
      icon: 'fa fa-clipboard',
      path: 'config.event-settings.page({path: "sessions/courses"})'
    },
    {
      name: 'ADMIN_DASHBOARD.CONFIG_PAGE.EVENT_SETTINGS.TAB_SINGLE_EVENTS',
      icon: 'fa fa-ticket',
      path: 'config.event-settings.page({path: "sessions/events"})'
    },
    {
      name: 'ADMIN_DASHBOARD.CONFIG_PAGE.EVENT_SETTINGS.TAB_REGULAR_EVENTS',
      icon: 'fa fa-calendar',
      path: 'config.event-settings.page({path: "sessions/recurring"})'
    },
    {
      name: 'ADMIN_DASHBOARD.CONFIG_PAGE.EVENT_SETTINGS.TAB_GROUPS',
      icon: 'fa fa-object-group',
      path: 'config.event-settings.page({path: "sessions/types"})'
    },
    {
      name: 'ADMIN_DASHBOARD.CONFIG_PAGE.EVENT_SETTINGS.TAB_TEMPLATES',
      icon: 'fa fa-folder-open',
      path: 'config.event-settings.page({path: "sessions/template"})'
    }
  ]

]
