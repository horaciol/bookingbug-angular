'use strict'

BBAdminDashboardDependencies = [
  'ngStorage',
  'ngResource',
  'ngTouch',
  'ngSanitize',
  'ngIdle',
  'ngLocalData',
  'ngInputDate',
  'ngCookies',

  'BBAdmin',
  'BBAdminServices',
  'BBAdminBooking',
  'BBAdmin.Directives',
  'BBMember',

  'ui.calendar',
  'ui.bootstrap',
  'ui.router',
  'ui.select',
  'ct.ui.router.extras',
  'trNgGrid',
  'toggle-switch',
  'pascalprecht.translate',
  'angular-loading-bar',
  'ngScrollable',
  'toastr',

  'BBAdminDashboard.check-in',
  'BBAdminDashboard.clients',
  'BBAdminDashboard.login',
  'BBAdminDashboard.logout',
  'BBAdminDashboard.calendar',
  'BBAdminDashboard.dashboard-iframe',
  'BBAdminDashboard.members-iframe',
  'BBAdminDashboard.settings-iframe',
  'BBAdminDashboard.config-iframe',
  'BBAdminDashboard.publish-iframe'
]

adminBookingApp = angular.module('BBAdminDashboard', BBAdminDashboardDependencies)
.run ['RuntimeStates', 'AdminCoreOptions', 'RuntimeRoutes', (RuntimeStates, AdminCoreOptions, RuntimeRoutes) ->

  RuntimeRoutes.otherwise('/')

  RuntimeStates
    .state 'root',
      url: '/'
      templateUrl: "core/layout.html"
      resolve:
        sso: ($q, sso_token, AdminLoginService, $injector) ->
          defer = $q.defer()

          AdminLoginService.isLoggedIn().then (loggedIn)->
            if not loggedIn and sso_token != false
              # Use the injector to avoid errors for including a
              # service with dependencies on construct (AdminSsoLogin requires company_id value)
              AdminSsoLogin = $injector.get 'AdminSsoLogin'

              AdminSsoLogin sso_token, (admin)->
                AdminLoginService.setLogin admin
                defer.resolve()
            else
              defer.resolve()

          defer.promise

        user: ($q, AdminLoginService, $timeout, $state, sso) ->
          defer = $q.defer()
          AdminLoginService.user().then (user) ->
            if user
              defer.resolve(user)
            else
              $timeout () ->
                $state.go 'login', {}, {reload: true}
          , (err) ->
            $timeout () ->
              $state.go 'login', {}, {reload: true}
          defer.promise
        company: (user, $q, $timeout, $state) ->
          defer = $q.defer()
          user.getCompanyPromise().then (company) ->
            if company.companies && company.companies.length > 0
              $timeout () ->
                $state.go 'login', {}, {reload: true}
            else
              defer.resolve(company)
          , (err) ->
            $timeout () ->
              console.log('failed to get company')
              $state.go 'login', {}, {reload: true}
          defer.promise
      controller: 'CorePageController'
      deepStateRedirect: {
        default: {
          state: AdminCoreOptions.default_state
        }
      }

]
.config ($logProvider, $httpProvider) ->
  $logProvider.debugEnabled(true)
  $httpProvider.defaults.withCredentials = true

.constant('idleTimeout', 600)
.constant('idleStart', 300)
.value 'company_id', null
.value 'sso_token', false

.config ($idleProvider, idleStart, idleTimeout) ->
  $idleProvider.idleDuration(idleStart)
  $idleProvider.warningDuration(idleTimeout)

# Translatition Configuration
.config ['$translateProvider', 'AdminCoreOptionsProvider', ($translateProvider, AdminCoreOptionsProvider) ->
  # Sanitisation strategy
  $translateProvider.useSanitizeValueStrategy('sanitize');
  # Persist language selection in localStorage
  $translateProvider.useLocalStorage()

  $translateProvider
    .fallbackLanguage(AdminCoreOptionsProvider.getOption('available_languages'))
]
.run ['$translate', 'AdminCoreOptions', 'RuntimeTranslate', ($translate, AdminCoreOptions, RuntimeTranslate) ->

  # Register available languages and their associations
  RuntimeTranslate.registerAvailableLanguageKeys(AdminCoreOptions.available_languages,AdminCoreOptions.available_language_associations)

  # define fallback
  $translate.preferredLanguage AdminCoreOptions.default_language

  # Depending on configuration use the browser to decide prefered language
  if AdminCoreOptions.use_browser_language
    browserLocale = $translate.negotiateLocale($translate.resolveClientLocale())

    if _.contains(AdminCoreOptions.available_languages, browserLocale)
      $translate.preferredLanguage browserLocale
]
