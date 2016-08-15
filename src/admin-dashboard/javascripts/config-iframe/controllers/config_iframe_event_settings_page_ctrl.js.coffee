'use strict';

###
* @ngdoc controller
* @name BBAdminDashboard.config-iframe.controllers.controller:ConfigIframeEventSettingsPageCtrl
#
* @description
* Controller for the config page
###
angular.module('BBAdminDashboard.config-iframe.controllers')
.controller 'ConfigIframeEventSettingsPageCtrl',['$scope', '$state', '$rootScope', ($scope, $state, $rootScope) ->
  $scope.pageHeader = 'CONFIG_IFRAME_PAGE.EVENT_SETTINGS.TITLE'

  $scope.tabs = [
    {
      name: 'CONFIG_IFRAME_PAGE.EVENT_SETTINGS.TAB_COURSES',
      icon: 'fa fa-clipboard',
      path: 'config.event-settings.page({path: "sessions/courses"})'
    },
    {
      name: 'CONFIG_IFRAME_PAGE.EVENT_SETTINGS.TAB_SINGLE_EVENTS',
      icon: 'fa fa-ticket',
      path: 'config.event-settings.page({path: "sessions/events"})'
    },
    {
      name: 'CONFIG_IFRAME_PAGE.EVENT_SETTINGS.TAB_REGULAR_EVENTS',
      icon: 'fa fa-calendar',
      path: 'config.event-settings.page({path: "sessions/recurring"})'
    },
    {
      name: 'CONFIG_IFRAME_PAGE.EVENT_SETTINGS.TAB_GROUPS',
      icon: 'fa fa-object-group',
      path: 'config.event-settings.page({path: "sessions/types"})'
    },
    {
      name: 'CONFIG_IFRAME_PAGE.EVENT_SETTINGS.TAB_TEMPLATES',
      icon: 'fa fa-folder-open',
      path: 'config.event-settings.page({path: "sessions/template"})'
    }
  ]

  $scope.contentsLoading = false

  $scope.$on 'iframeLoaded', ()->
    $scope.contentsLoading = false
    $scope.$apply()

  $scope.$on 'iframeLoading', ()->
    $scope.contentsLoading = true
]