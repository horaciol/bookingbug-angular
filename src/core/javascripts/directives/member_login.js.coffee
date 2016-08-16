angular.module('BB').directive 'bbMemberLogin', (PathSvc) ->
  restrict: 'A'
  controller: 'MemberLogin'
  templateUrl : (elem, attrs) ->
    if attrs.bbCustomLoginForm?
      PathSvc.directivePartial "_member_login_form"
    else
      PathSvc.directivePartial "_member_login_schema_form"


angular.module('BB.Controllers').controller 'MemberLogin', ($scope, $log, $rootScope, $templateCache, $q, halClient, BBModel, $sessionStorage, $window, AlertService, LoginService, ValidatorService) ->

  $scope.login = {}

  $scope.validator = ValidatorService

  $rootScope.connection_started.then () ->

    if LoginService.checkLogin()
      $scope.setClient($rootScope.member)
      if $scope.bb.destination
        $scope.redirectTo($scope.bb.destination)
      else
        $scope.setLoaded $scope
        $scope.skipThisStep()
        $scope.decideNextPage()
    else
      halClient.$get("#{$scope.bb.api_url}/api/v1").then (root) ->
        root.$get("new_login").then (new_login) ->
          $scope.form = new_login.form
          $scope.schema = new_login.schema
        , (err) ->
          console.log 'err ', err
      , (err) ->
        console.log 'err ', err


  $scope.submit = () ->

    $scope.login.role = 'member'

    $scope.company.$post('login', {}, $scope.login).then (login) ->
      if login.$has('members')
        login.$get('members').then (members) ->
          $scope.handleLogin(members[0])
      else if login.$has('member')
        login.$get('member').then (member) ->
          $scope.handleLogin(member)
    , (err) ->
      if err.data.error is "Account has been disabled"
        AlertService.raise('ACCOUNT_DISABLED')
      else
        AlertService.raise('LOGIN_FAILED')


  $scope.handleLogin = (member) ->
    member = LoginService.setLogin(member, $scope.login.persist_login)
    $scope.setClient(member)
    if $scope.bb.destination
      $scope.redirectTo($scope.bb.destination)
    else
      $scope.skipThisStep()
      $scope.decideNextPage()
