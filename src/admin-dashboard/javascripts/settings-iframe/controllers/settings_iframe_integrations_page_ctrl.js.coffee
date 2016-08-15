'use strict';

###
* @ngdoc controller
* @name BBAdminDashboard.settings-iframe.controllers.controller:SettingsIframeIntegrationsPageCtrl
#
* @description
* Controller for the settings page
###
angular.module('BBAdminDashboard.settings-iframe.controllers')
.controller 'SettingsIframeIntegrationsPageCtrl',['$scope', '$state', '$rootScope', ($scope, $state, $rootScope) ->
  $scope.pageHeader = 'SETTINGS_IFRAME_PAGE.INTEGRATIONS.TITLE'

  $scope.tabs = [
    {
      name: 'SETTINGS_IFRAME_PAGE.INTEGRATIONS.TAB_PAYMENT',
      icon: 'fa fa-credit-card',
      path: 'settings.integrations.page({path: "conf/addons/payment"})'
    },
    {
      name: 'SETTINGS_IFRAME_PAGE.INTEGRATIONS.TAB_ACCOUNTING',
      icon: 'fa fa-pencil-square-o',
      path: 'settings.integrations.page({path: "conf/addons/accounting"})'
    },
    {
      name: 'SETTINGS_IFRAME_PAGE.INTEGRATIONS.TAB_OTHER',
      icon: 'fa fa-question',
      path: 'settings.integrations.page({path: "conf/addons/other"})'
    }
  ]

  $scope.contentsLoading = false

  $scope.$on 'iframeLoaded', ()->
    $scope.contentsLoading = false
    $scope.$apply()

  $scope.$on 'iframeLoading', ()->
    $scope.contentsLoading = true
]