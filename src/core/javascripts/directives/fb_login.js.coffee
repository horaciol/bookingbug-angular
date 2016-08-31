'use strict'

angular.module("BB.Directives").directive "bbFbLogin", (LoginService,
    $rootScope, AlertService, LoadingService) ->

  restrict: 'A'
  scope: true
  link: (scope, element, attrs) ->

    loader = LoadingService.$loader(scope)

    options = scope.$eval(attrs.bbFbLogin) or {}
    $rootScope.connection_started.then ->
      checkLoginState()

    statusChangeCallback = (response) ->
      if response.status == 'connected'
        params = {}
        params.access_token = response.authResponse.accessToken
        params.login_only = options.login_only if options.login_only
        loginToBBWithFBUser(params)
      else if response.status == 'not_authorized'
         scope.loginFB()
      else
        scope.loginFB()
      return

    checkLoginState = () ->
      FB.getLoginStatus (response) ->
        statusChangeCallback response
        return
      return

    loginToBBWithFBUser = (params) ->
      LoginService.FBLogin(scope.bb.company, params).then (member) ->
        $rootScope.member = member
        scope.setClient($rootScope.member)
        if scope.bb.destination
          scope.redirectTo(scope.bb.destination)
        else
          loader.setLoaded()
          scope.decideNextPage()
      , (err) ->
        if err.data.error == "FACEBOOK-LOGIN-MEMBER-NOT-FOUND"
          AlertService.raise('FB_LOGIN_NOT_A_MEMBER')
        else
          AlertService.raise('LOGIN_FAILED')


    scope.loginFB = () ->
      FB.login ((response) ->
        if response.status == 'connected'
          params = {}
          params.access_token = response.authResponse.accessToken
          params.login_only = options.login_only if options.login_only
          loginToBBWithFBUser(params)
        else if response.status == 'not_authorized'
          AlertService.raise('LOGIN_FAILED')
        else
          AlertService.raise('LOGIN_FAILED')
        return
      ), scope: 'public_profile,email'

