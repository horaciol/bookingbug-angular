'use strict';

###
* @ngdoc controller
* @name BBAdminDashboard.config-iframe.controllers.controller:ConfigIframePromotionsPageCtrl
#
* @description
* Controller for the config page
###
angular.module('BBAdminDashboard.config-iframe.controllers')
.controller 'ConfigIframePromotionsPageCtrl',['$scope', '$state', '$rootScope', ($scope, $state, $rootScope) ->
  $scope.pageHeader = 'CONFIG_IFRAME_PAGE.PROMOTIONS.TITLE'

  $scope.tabs = [
    {
      name: 'CONFIG_IFRAME_PAGE.PROMOTIONS.TAB_DEALS',
      icon: 'fa fa-exclamation-triangle',
      path: 'config.promotions.page({path: "price/deal/summary"})'
    },
    {
      name: 'CONFIG_IFRAME_PAGE.PROMOTIONS.TAB_COUPONS',
      icon: 'fa fa-money',
      path: 'config.promotions.page({path: "price/coupon"})'
    },
    {
      name: 'CONFIG_IFRAME_PAGE.PROMOTIONS.TAB_BULK_PURCHASES',
      icon: 'fa fa-th',
      path: 'config.promotions.page({path: "price/block"})'
    },
    {
      name: 'CONFIG_IFRAME_PAGE.PROMOTIONS.TAB_PACKAGES',
      icon: 'fa fa-gift',
      path: 'config.promotions.page({path: "package"})'
    }
  ]

  $scope.contentsLoading = false

  $scope.$on 'iframeLoaded', ()->
    $scope.contentsLoading = false
    $scope.$apply()

  $scope.$on 'iframeLoading', ()->
    $scope.contentsLoading = true
]