'use strict';

###
* @ngdoc controller
* @name BBAdminDashboard.settings-iframe.controllers.controller:SettingsIframeSubscriptionPageCtrl
#
* @description
* Controller for the settings page
###
angular.module('BBAdminDashboard.settings-iframe.controllers')
.controller 'SettingsIframeSubscriptionPageCtrl',['$scope', '$state', '$rootScope', ($scope, $state, $rootScope) ->
  $scope.pageHeader = 'SETTINGS_IFRAME_PAGE.SUBSCRIPTION.TITLE'

  $scope.tabs = [
    {
      name: 'SETTINGS_IFRAME_PAGE.SUBSCRIPTION.TAB_STATUS',
      icon: null,
      path: 'settings.subscription.page({path: "subscription/show"})'
    },
    {
      name: 'SETTINGS_IFRAME_PAGE.SUBSCRIPTION.TAB_PAYMENT_HISTORY',
      icon: null,
      path: 'settings.subscription.page({path: "payment_event"})'
    },
    {
      name: 'SETTINGS_IFRAME_PAGE.SUBSCRIPTION.TAB_INVOICES',
      icon: null,
      path: 'settings.subscription.page({path: "payment_invoice"})'
    }
  ]

  $scope.contentsLoading = false

  $scope.$on 'iframeLoaded', ()->
    $scope.contentsLoading = false
    $scope.$apply()

  $scope.$on 'iframeLoading', ()->
    $scope.contentsLoading = true
]