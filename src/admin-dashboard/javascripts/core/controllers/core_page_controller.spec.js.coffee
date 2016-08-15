'use strict';

describe 'BBAdminDashboard, CorePageController', () ->
  $controller = null
  $state = null
  company = null

  controllerInstance = null
  $scope = null

  companyMock = {
    timezone: 'Europe/London'
  }

  beforeEachFn = () ->

    module('BBAdminDashboard')

    module ($provide) ->
      $provide.value 'company', companyMock
      return

    inject ($injector) ->
      $controller = $injector.get '$controller'
      $scope = $injector.get '$rootScope'
      $state = $injector.get '$state'
      company = $injector.get 'company'
      return

    spyOn moment.tz, 'setDefault'
    spyOn $state, 'includes'

    controllerInstance = $controller(
      'CorePageController'
      '$scope': $scope
      '$state': $state
      'company': companyMock
    )

    $scope.$apply()

    return

  beforeEach beforeEachFn

  it 'defines "company" and "bb.company" properties on $scope', () ->
    expect $scope.company
    .toBe companyMock

    expect $scope.bb.company
    .toBe companyMock

    return

  it 'uses company timezone globally', () ->
    expect moment.tz.setDefault
    .toHaveBeenCalledWith company.timezone
    return

  it 'defines isState function on $scope', () ->
    testStateName = 'dashboard'

    $scope.isState testStateName

    expect $state.includes
    .toHaveBeenCalledWith(testStateName)

    return
