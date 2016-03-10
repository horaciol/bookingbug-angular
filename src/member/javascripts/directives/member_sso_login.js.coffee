angular.module('BBMember').directive 'memberSsoLogin', ($rootScope, LoginService, $sniffer, $timeout, QueryStringService) ->

  link = (scope, element, attrs) ->
    $rootScope.bb ||= {}
    $rootScope.bb.api_url ||= scope.apiUrl
    $rootScope.bb.api_url ||= "http://www.bookingbug.com"
    scope.qs = QueryStringService

    scope.member = null
    options =
      root: $rootScope.bb.api_url
      company_id: scope.companyId
    data = {}
    data.token = scope.token if scope.token
    data.token ||= scope.qs('sso_token') if scope.qs

    if $sniffer.msie && $sniffer.msie < 10 && $rootScope.iframe_proxy_ready == false
      $timeout () ->
        LoginService.ssoLogin(options, data).then (member) ->
          scope.member = member
      , 2000
    else
      LoginService.ssoLogin(options, data).then (member) ->
        scope.member = member

  link: link
  scope:
    token: '@memberSsoLogin'
    companyId: '@'
    apiUrl: '@'
    member: '='
  transclude: true
  template: """
<div ng-if='member' ng-transclude></div>
"""
