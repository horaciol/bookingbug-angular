'use strict'

angular.module('BBAdminDashboard.config-iframe.controllers', [])
angular.module('BBAdminDashboard.config-iframe.services', [])
angular.module('BBAdminDashboard.config-iframe.directives', [])
angular.module('BBAdminDashboard.config-iframe.translations', [])

angular.module('BBAdminDashboard.config-iframe', [
  'BBAdminDashboard.config-iframe.controllers',
  'BBAdminDashboard.config-iframe.services',
  'BBAdminDashboard.config-iframe.directives',
  'BBAdminDashboard.config-iframe.translations'
])
.run ['RuntimeStates', 'AdminConfigIframeOptions', 'SideNavigationPartials', (RuntimeStates, AdminConfigIframeOptions, SideNavigationPartials) ->
  # Choose to opt out of the default routing
  if AdminConfigIframeOptions.use_default_states

    RuntimeStates
      .state 'config-iframe',
        parent: AdminConfigIframeOptions.parent_state
        url: 'config'
        templateUrl: 'config-iframe/index.html'
        controller: 'ConfigIframePageCtrl'
        deepStateRedirect: {
          default: {
            state: 'config-iframe.business.page'
            params: {
              path: 'person'
            }
          }
        }

      .state 'config-iframe.business',
        url: '/business'
        templateUrl: 'core/tabbed-substates-page.html'
        controller: 'ConfigIframeBusinessPageCtrl'
        deepStateRedirect: {
          default: {
            state: 'config-iframe.business.page'
            params: {
              path: 'person'
            }
          }
        }
      .state 'config-iframe.business.page',
        url: '/page/:path'
        templateUrl: 'core/iframe-page.html'
        controller: 'ConfigSubIframePageCtrl'

      .state 'config-iframe.event-settings',
        url: '/event-settings'
        templateUrl: 'core/tabbed-substates-page.html'
        controller: 'ConfigIframeEventSettingsPageCtrl'
        deepStateRedirect: {
          default: {
            state: 'config-iframe.event-settings.page'
            params: {
              path: 'sessions/courses'
            }
          }
        }
      .state 'config-iframe.event-settings.page',
        url: '/page/:path'
        templateUrl: 'core/iframe-page.html'
        controller: 'ConfigSubIframePageCtrl'

      .state 'config-iframe.promotions',
        url: '/promotions'
        templateUrl: 'core/tabbed-substates-page.html'
        controller: 'ConfigIframePromotionsPageCtrl'
        deepStateRedirect: {
          default: {
            state: 'config-iframe.promotions.page'
            params: {
              path: 'price/deal/summary'
            }
          }
        }
      .state 'config-iframe.promotions.page',
        url: '/page/:path'
        templateUrl: 'core/iframe-page.html'
        controller: 'ConfigSubIframePageCtrl'

      .state 'config-iframe.booking-settings',
        url: '/booking-settings'
        templateUrl: 'core/tabbed-substates-page.html'
        controller: 'ConfigIframeBookingSettingsPageCtrl'
        deepStateRedirect: {
          default: {
            state: 'config-iframe.booking-settings.page'
            params: {
              path: 'detail_type'
            }
          }
        }
      .state 'config-iframe.booking-settings.page',
        url: '/page/:path'
        templateUrl: 'core/iframe-page.html'
        controller: 'ConfigSubIframePageCtrl'

  if AdminConfigIframeOptions.show_in_navigation
    SideNavigationPartials.addPartialTemplate('config-iframe', 'config-iframe/nav.html')
]
