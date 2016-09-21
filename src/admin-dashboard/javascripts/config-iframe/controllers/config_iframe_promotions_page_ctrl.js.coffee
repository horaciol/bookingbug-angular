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
  $scope.pageHeader = 'ADMIN_DASHBOARD.CONFIG_IFRAME_PAGE.PROMOTIONS.TITLE'

  $scope.tabs = [
    {
      name: 'ADMIN_DASHBOARD.CONFIG_IFRAME_PAGE.PROMOTIONS.TAB_DEALS',
      icon: 'fa fa-exclamation-triangle',
      path: 'config-iframe.promotions.page({path: "price/deal/summary"})'
    },
    {
      name: 'ADMIN_DASHBOARD.CONFIG_IFRAME_PAGE.PROMOTIONS.TAB_COUPONS',
      icon: 'fa fa-money',
      path: 'config-iframe.promotions.page({path: "price/coupon"})'
    },
    {
      name: 'ADMIN_DASHBOARD.CONFIG_IFRAME_PAGE.PROMOTIONS.TAB_BULK_PURCHASES',
      icon: 'fa fa-th',
      path: 'config-iframe.promotions.page({path: "price/block"})'
    },
    {
      name: 'ADMIN_DASHBOARD.CONFIG_IFRAME_PAGE.PROMOTIONS.TAB_PACKAGES',
      icon: 'fa fa-gift',
      path: 'config-iframe.promotions.page({path: "package"})'
    }
  ]

  $scope.contentsLoading = false

  $scope.$on 'iframeLoaded', ()->
    $scope.contentsLoading = false
    $scope.$apply()

  $scope.$on 'iframeLoading', ()->
    $scope.contentsLoading = true
]
