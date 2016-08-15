'use strict';

describe 'BBAdminDashboard, bbAdminDashboard directive', () ->
  $compile = null
  $rootScope = null
  $scope = null
  $localStorage = null
  $templateCache = null
  $httpBackend = null
  adminLoginService = null
  $state = null
  alertService = null
  directiveHtml = '<bb-admin-dashboard></bb-admin-dashboard>'
  directive = null
  directiveController = null;

  setup = () ->
    module 'ngStorage'
    module 'ngCookies'
    module 'BBAdminDashboard'

    module ($provide) ->
      $provide.value '$element', directiveHtml
      return

    inject ($injector) ->
      $compile = $injector.get '$compile'
      $rootScope = $injector.get '$rootScope'
      $scope = $rootScope.$new()
      $localStorage = $injector.get '$localStorage'
      $templateCache = $injector.get '$templateCache'
      $httpBackend = $injector.get '$httpBackend'
      adminLoginService = $injector.get 'AdminLoginService'
      $state = $injector.get '$state'
      alertService = $injector.get 'AlertService'

  beforeEach setup

  prepareDirective = ->
    directiveTemplate = 'admin_dashboard.html'
    $httpBackend.whenGET(directiveTemplate).respond 200

    directive = angular.element(directiveHtml);
    $compile(directive)($scope);

    $httpBackend.flush();
    $rootScope.$digest();

    directiveController = directive.controller('bbAdminDashboard');

  xit 'once initialised, sets bb.api_url to value from localStorage', ->
    spyOn localStorage, 'getItem'
    .and.returnValue 'someValue'

    prepareDirective()

    expect $scope.bb.api_url
    .toBe 'someValue'

  xit 'once initialised, isLoading is null', ->
    prepareDirective()
    expect $scope.isLoading
    .toBeUndefined()

  xit 'method closeAlert triggers proper method on AlertService', ->
    spyOn alertService, 'closeAlert'
    prepareDirective()

    $scope.closeAlert 'test'

    expect alertService.closeAlert
    .toHaveBeenCalledWith 'test'

  xit 'method logout', ->
    spyOn adminLoginService, 'logout'
    prepareDirective()

    $scope.logout()

    expect adminLoginService.logout
    .toHaveBeenCalled()

  xit 'on state change error', ->
    prepareDirective()

    $scope.$apply()

    expect $scope.isLoading
    .toBeUndefined() #this one is wrong should be

    $state.go 'login'

    $scope.$apply()

    expect $scope.isLoading
    .toBe false
