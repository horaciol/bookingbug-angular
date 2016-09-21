'use strict'

###
* @ngdoc controller
* @name BBAdminDashboard.config.controllers.controller:ConfigPromotionsPageCtrl
#
* @description
* Controller for the config page
###
angular.module('BBAdminDashboard.config.controllers')
.controller 'ConfigPromotionsPageCtrl',['$scope', '$state', '$rootScope', ($scope, $state, $rootScope) ->
  $scope.pageHeader = 'ADMIN_DASHBOARD.CONFIG_PAGE.PROMOTIONS.TITLE'

  $scope.tabs = [
    {
      name: 'ADMIN_DASHBOARD.CONFIG_PAGE.PROMOTIONS.TAB_DEALS',
      icon: 'fa fa-exclamation-triangle',
      path: 'config.promotions.page({path: "price/deal/summary"})'
    },
    {
      name: 'ADMIN_DASHBOARD.CONFIG_PAGE.PROMOTIONS.TAB_COUPONS',
      icon: 'fa fa-money',
      path: 'config.promotions.page({path: "price/coupon"})'
    },
    {
      name: 'ADMIN_DASHBOARD.CONFIG_PAGE.PROMOTIONS.TAB_BULK_PURCHASES',
      icon: 'fa fa-th',
      path: 'config.promotions.page({path: "price/block"})'
    },
    {
      name: 'ADMIN_DASHBOARD.CONFIG_PAGE.PROMOTIONS.TAB_PACKAGES',
      icon: 'fa fa-gift',
      path: 'config.promotions.page({path: "package"})'
    }
  ]

]
