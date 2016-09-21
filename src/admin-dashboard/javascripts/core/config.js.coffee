'use strict'

BBAdminDashboardDependencies = [
  'ngStorage',
  'ngResource',
  'ngTouch',
  'ngSanitize',
  'ngLocalData',
  'ngCookies',

  'BBAdmin',
  'BBAdminServices',
  'BBAdminBooking',
  'BBAdmin.Directives',
  'BBMember',

  'ui.calendar',
  'ui.bootstrap',
  'ui.router',
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
  # 'BBAdminDashboard.config',
  'BBAdminDashboard.config-iframe',
  'BBAdminDashboard.publish-iframe'
]

adminBookingApp = angular.module('BBAdminDashboard', BBAdminDashboardDependencies)
.run ['RuntimeStates', 'AdminCoreOptions', 'RuntimeRoutes','AdminLoginService', (RuntimeStates, AdminCoreOptions, RuntimeRoutes, AdminLoginService) ->

  RuntimeRoutes.otherwise('/')

  RuntimeStates
    .state 'root',
      url: '/'
      templateUrl: "core/layout.html"
      resolve:
        user: ($q, BBModel, AdminSsoLogin) ->
          defer = $q.defer()
          BBModel.Admin.Login.$user().then (user) ->
            if user
              defer.resolve(user)
            else
              AdminSsoLogin.ssoLoginPromise().then (admin)->
                BBModel.Admin.Login.$setLogin admin
                BBModel.Admin.Login.$user().then (user) ->
                  defer.resolve(user)
                , (err) ->
                  defer.reject({reason: 'GET_USER_ERROR', error: err})
              , (err) ->
                defer.reject({reason: 'NOT_LOGGABLE_ERROR'})
          , (err) ->
            defer.reject({reason: 'LOGIN_SERVICE_ERROR', error: err})
          defer.promise

        company: (user, $q, BBModel) ->
          defer = $q.defer()
          user.$getCompany().then (company) ->
            if company.companies && company.companies.length > 0
              defer.reject({reason: 'COMPANY_IS_PARENT'})
            else
              defer.resolve(company)
          , (err) ->
            BBModel.Admin.Login.$logout().then ()->
              defer.reject({reason: 'GET_COMPANY_ERROR'})
            , (err)->
              defer.reject({reason: 'LOGOUT_ERROR'})
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

