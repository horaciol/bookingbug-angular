'use strict'

app = angular.module('BB', [
  'BB.Controllers',
  'BB.Filters',
  'BB.Models',
  'BB.Services',
  'BB.Directives',

  'ngStorage',
  'angular-hal',
  'ui.bootstrap',
  'ngSanitize',
  'ui.map',
  'ui.router.util',
  'ngAnimate',
  'angular-data.DSCacheFactory', # newer version of jmdobry angular cache'
  'ngFileUpload',
  'schemaForm',
  'uiGmapgoogle-maps',
  'angular.filter',
  'ui-rangeSlider',
  'ngCookies',
  'pascalprecht.translate',
  'vcRecaptcha',
  'ui.select',
  'BB.i18n',
  'BB.uib',
  'angular-carousel'
])


# use this to inject application wide settings around the app
app.value('AppConfig', {
  appId: 'f6b16c23',
  appKey: 'f0bc4f65f4fbfe7b4b3b7264b655f5eb'
})

# airbrake-js authentication
app.value('AirbrakeConfig', {
  projectId: '122836',
  projectKey: 'e6d6710b2cf00be965e8452d6a384d37',
  environment: if window.location.hostname is 'localhost' then 'development' else 'production'
})

if (window.use_no_conflict)
  window.bbjq = $.noConflict()
  app.value '$bbug', jQuery.noConflict(true)
else
  app.value '$bbug', jQuery

app.constant('UriTemplate', window.UriTemplate)
app.config (uiGmapGoogleMapApiProvider) ->
  uiGmapGoogleMapApiProvider.configure({
    v: '3.20',
    libraries: 'weather,geometry,visualization'
  })
app.config ($locationProvider, $httpProvider, $provide, ie8HttpBackendProvider) ->
  $httpProvider.defaults.headers.common =
    'App-Id': 'f6b16c23',
    'App-Key': 'f0bc4f65f4fbfe7b4b3b7264b655f5eb'

  # this shouold not be enforced - but set per app for custom app that uses html paths
  # $locationProvider.html5Mode(false).hashPrefix('!')

  int = (str) ->
    parseInt(str, 10)

  lowercase = (string) ->
    if angular.isString(string) then string.toLowerCase() else string

  msie = int((/msie (\d+)/.exec(lowercase(navigator.userAgent)) || [])[1])
  if (isNaN(msie))
    msie = int((/trident\/.*; rv:(\d+)/.exec(lowercase(navigator.userAgent)) || [])[1])

  regexp = /Safari\/([\d.]+)/
  result = regexp.exec(navigator.userAgent)
  webkit = parseFloat(result[1]) if result

  if (msie && msie <= 9) or (webkit and webkit < 537)
    $provide.provider({$httpBackend: ie8HttpBackendProvider})


  moment.fn.toISODate ||= -> this.locale('en').format('YYYY-MM-DD')

app.run ($bbug, bbConfig, DebugUtilsService, FormDataStoreService, $log, $rootScope, $sessionStorage, $window) ->
  init = () ->
    exposeVersions()
    return

  # add methods to the rootscope if they are applicable to whole app
  $rootScope.$log = $log
  $rootScope.$setIfUndefined = FormDataStoreService.setIfUndefined

  $rootScope.bb ||= {}
  $rootScope.bb.api_url = $sessionStorage.getItem("host")

  # add bits of IE8 support
  if ($bbug.support.opacity == false)
    document.createElement('header')
    document.createElement('nav')
    document.createElement('section')
    document.createElement('footer')

  exposeVersions = () ->
    $window.BB =
      SDK_VERSION: bbConfig.BUILD.SDK_VERSION
      PROJECT_DEPLOY_VERSION: bbConfig.BUILD.DEPLOY_VERSION

    if $window.BB.SDK_VERSION is null
      $window.BB.SDK_VERSION = 'unreleased version'

    return

  init()

  return


angular.module('BB.Services', [
  'ngResource'
  'ngSanitize'
  'pascalprecht.translate'
])

angular.module('BB.Controllers', [
  'ngSanitize'
])

angular.module('BB.Directives', [])
angular.module('BB.Filters', [])
angular.module('BB.Models', [])

window.bookingbug =
  logout: (options) ->
    options ||= {}
    options.reload = true unless options.reload == false
    logout_opts =
      app_id: 'f6b16c23'
      app_key: 'f0bc4f65f4fbfe7b4b3b7264b655f5eb'
    logout_opts.root = options.root if options.root
    angular.injector(['BB.Services', 'BB.Models', 'ng'])
    .get('LoginService').logout(logout_opts)
    window.location.reload() if options.reload

# String::includes polyfill
if !String::includes

  String::includes = (search, start) ->
    if typeof start != 'number'
      start = 0
    if start + search.length > @length
      false
    else
      @indexOf(search, start) != -1

# Extend String with parameterise method
String::parameterise = (seperator = '-') ->
  @trim().replace(/\s/g, seperator).toLowerCase()

