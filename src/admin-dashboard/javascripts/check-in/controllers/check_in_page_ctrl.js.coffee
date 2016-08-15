'use strict';

###
* @ngdoc controller
* @name BBAdminDashboard.check-in.controllers.controller:CheckInPageCtrl
#
* @description
* Controller for the check-in page
###
angular.module('BBAdminDashboard.check-in.controllers')
.controller 'CheckInPageCtrl',['$scope', '$state', '$log', ($scope, $state, $log) ->
  pusher_channel = $scope.company.getPusherChannel('bookings')
  refetch = _.throttle (data) ->
    $log.info '== booking push received in checkin  == ', data
    $scope.$broadcast 'refetchCheckin' , data
  , 1000, {leading: false}

  pusher_channel.bind 'create', refetch
  pusher_channel.bind 'update', refetch
  pusher_channel.bind 'destroy', refetch
]