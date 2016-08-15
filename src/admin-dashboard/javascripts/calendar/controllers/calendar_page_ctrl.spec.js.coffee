'use strict';

describe 'BBAdminDashboard.calendar.controllers, CalendarPageCtrl', () ->
  $compile = null
  $controller = null
  $rootScope = null
  $state = null
  $log = null

  controllerInstance = null
  $scope = null

  pusherChannelMock = {
    bind: (name, callback) ->
  }

  companyMock = {
    getPusherChannel: (channelName) ->
      pusherChannelMock
  }

  setup = () ->
    module('ui.router')
    module('BBAdminDashboard.calendar.controllers')

    inject ($injector) ->
      $compile = $injector.get '$compile'
      $controller = $injector.get '$controller'
      $rootScope = $injector.get '$rootScope'
      $scope = $rootScope.$new()
      $state = $injector.get '$state'
      $log = $injector.get '$log'

    $scope.adminlte = {}
    $scope.company = companyMock;

    spyOn pusherChannelMock, 'bind'

  beforeEach setup

  it 'bind proper events on company\'s pusher_channel', () ->
    controllerInstance = $controller(
      'CalendarPageCtrl'
      '$scope': $scope
      '$state': $state
      '$log': $log
    )

    expect pusherChannelMock.bind.calls.argsFor(0)[0]
    .toEqual('create')

    expect pusherChannelMock.bind.calls.argsFor(1)[0]
    .toEqual('update')

    expect pusherChannelMock.bind.calls.argsFor(2)[0]
    .toEqual('destroy')
