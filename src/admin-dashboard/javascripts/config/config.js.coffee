'use strict'

angular.module('BBAdminDashboard.config.controllers', [])
angular.module('BBAdminDashboard.config.services', [])
angular.module('BBAdminDashboard.config.directives', [])
angular.module('BBAdminDashboard.config.translations', [])

angular.module('BBAdminDashboard.config', [
  'BBAdminDashboard.config.controllers',
  'BBAdminDashboard.config.services',
  'BBAdminDashboard.config.directives',
  'BBAdminDashboard.config.translations'
])
.run ['RuntimeStates', 'AdminConfigOptions', 'SideNavigationPartials', (RuntimeStates, AdminConfigOptions, SideNavigationPartials) ->
  # Choose to opt out of the default routing
  if AdminConfigOptions.use_default_states

    RuntimeStates
      .state 'config',
        parent: AdminConfigOptions.parent_state
        url: 'config'
        templateUrl: 'config/index.html'
        controller: 'ConfigPageCtrl'
        deepStateRedirect:
          default:
            state: 'config.business.people'

      .state 'config.business',
        url: '/business'
        templateUrl: 'core/tabbed-substates-page.html'
        controller: 'ConfigBusinessPageCtrl'
        deepStateRedirect:
          default:
            state: 'config.business.people'

      .state 'config.business.people',
        url: '/people'
        templateUrl: 'config/people.html'
        controller: 'ConfigSubPageCtrl'

      .state 'config.business.resources',
        url: '/resources'
        templateUrl: 'config/resources.html'
        controller: 'ConfigSubPageCtrl'

      .state 'config.business.services',
        url: '/services'
        templateUrl: 'config/services.html'
        controller: 'ConfigSubPageCtrl'

      # .state 'config.event-settings',
      #   url: '/event-settings'
      #   templateUrl: 'core/tabbed-substates-page.html'
      #   controller: 'ConfigEventSettingsPageCtrl'
      #   deepStateRedirect: {
      #     default: {
      #       state: 'config.event-settings.page'
      #       params: {
      #         path: 'sessions/courses'
      #       }
      #     }
      #   }
      # .state 'config.event-settings.page',
      #   url: '/page/:path'
      #   templateUrl: 'config/settings.html'
      #   controller: 'ConfigSubPageCtrl'

      # .state 'config.promotions',
      #   url: '/promotions'
      #   templateUrl: 'core/tabbed-substates-page.html'
      #   controller: 'ConfigPromotionsPageCtrl'
      #   deepStateRedirect: {
      #     default: {
      #       state: 'config.promotions.page'
      #       params: {
      #         path: 'price/deal/summary'
      #       }
      #     }
      #   }
      # .state 'config.promotions.page',
      #   url: '/page/:path'
      #   templateUrl: 'config/promotions.html'
      #   controller: 'ConfigSubPageCtrl'

      # .state 'config.booking-settings',
      #   url: '/booking-settings'
      #   templateUrl: 'core/tabbed-substates-page.html'
      #   controller: 'ConfigBookingSettingsPageCtrl'
      #   deepStateRedirect: {
      #     default: {
      #       state: 'config.booking-settings.page'
      #       params: {
      #         path: 'detail_type'
      #       }
      #     }
      #   }
      # .state 'config.booking-settings.page',
      #   url: '/page/:path'
      #   templateUrl: 'config/booking.html'
      #   controller: 'ConfigSubPageCtrl'

  if AdminConfigOptions.show_in_navigation
    SideNavigationPartials.addPartialTemplate('config', 'config/nav.html')
]
