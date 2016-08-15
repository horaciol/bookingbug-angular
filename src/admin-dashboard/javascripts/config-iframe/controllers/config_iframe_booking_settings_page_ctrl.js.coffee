'use strict';

###
* @ngdoc controller
* @name BBAdminDashboard.config-iframe.controllers.controller:ConfigIframeBookingSettingsPageCtrl
#
* @description
* Controller for the config page
###
angular.module('BBAdminDashboard.config-iframe.controllers')
.controller 'ConfigIframeBookingSettingsPageCtrl',['$scope', '$state', '$rootScope', ($scope, $state, $rootScope) ->
  $scope.pageHeader = 'CONFIG_IFRAME_PAGE.BOOKING_SETTINGS.TITLE'

  $scope.tabs = [
    {
      name: 'CONFIG_IFRAME_PAGE.BOOKING_SETTINGS.TAB_QUESTIONS',
      icon: 'fa fa-question-circle',
      path: 'config.booking-settings.page({path: "detail_type"})'
    },
    {
      name: 'CONFIG_IFRAME_PAGE.BOOKING_SETTINGS.TAB_QUESTION_GROUPS',
      icon: 'fa fa-question-circle',
      path: 'config.booking-settings.page({path: "detail_group"})'
    },
    {
      name: 'CONFIG_IFRAME_PAGE.BOOKING_SETTINGS.TAB_BOOKING_TEXT',
      icon: 'fa fa-file-text',
      path: 'config.booking-settings.page({path: "conf/text/text_edit"})'
    },
    {
      name: 'CONFIG_IFRAME_PAGE.BOOKING_SETTINGS.TAB_ADDRESSES',
      icon: 'fa fa-building-o',
      path: 'config.booking-settings.page({path: "address"})'
    },
    {
      name: 'CONFIG_IFRAME_PAGE.BOOKING_SETTINGS.TAB_IMAGES',
      icon: 'fa fa-picture-o',
      path: 'config.booking-settings.page({path: "media/image/all"})'
    }
  ]

  $scope.contentsLoading = false

  $scope.$on 'iframeLoaded', ()->
    $scope.contentsLoading = false
    $scope.$apply()

  $scope.$on 'iframeLoading', ()->
    $scope.contentsLoading = true
]