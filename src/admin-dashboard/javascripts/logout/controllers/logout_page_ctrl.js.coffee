'use strict';

###
* @ngdoc controller
* @name BBAdminDashboard.logout.controllers.controller:LogoutPageCtrl
#
* @description
* Controller for the logout page
###
angular.module('BBAdminDashboard.logout.controllers')
.controller 'LogoutPageCtrl',['$scope', '$state', 'AdminLoginService', '$timeout', ($scope, $state, AdminLoginService, $timeout) ->
  AdminLoginService.logout()
  $timeout () ->
    $state.go 'login', {}, {reload: true}

]