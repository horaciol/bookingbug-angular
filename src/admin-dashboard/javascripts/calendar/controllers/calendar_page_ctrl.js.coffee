'use strict';

###
* @ngdoc controller
* @name BBAdminDashboard.calendar.controllers.controller:CalendarPageCtrl
#
* @description
* Controller for the calendar page
###
angular.module('BBAdminDashboard.calendar.controllers')
.controller 'CalendarPageCtrl',['$scope', '$state', '$log', ($scope, $state, $log) ->
  pusher_channel = $scope.company.getPusherChannel('bookings')
  refetch = _.throttle (data) ->
    $log.info '== booking push received in bookins == ', data
    $scope.$broadcast 'refetchBookings' , data
  , 1000, {leading: false}

  pusher_channel.bind 'create', refetch
  pusher_channel.bind 'update', refetch
  pusher_channel.bind 'destroy', refetch
]