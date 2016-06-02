'use strict'

angular.module('BBAdminDashboard.calendar.controllers', [])
angular.module('BBAdminDashboard.calendar.services', [])
angular.module('BBAdminDashboard.calendar.directives', [])

angular.module('BBAdminDashboard.calendar', [
  'BBAdminDashboard.calendar.controllers',
  'BBAdminDashboard.calendar.services',
  'BBAdminDashboard.calendar.directives'
])
.run ['RuntimeStates', 'AdminCalendarOptions', (RuntimeStates, AdminCalendarOptions) ->
  # Choose to opt out of the default routing
  if AdminCalendarOptions.use_default_states

    RuntimeStates
      .state 'calendar',
        parent: AdminCalendarOptions.parent_state
        url: "/calendar/:assets"
        templateUrl: "calendar_page.html"
        controller: 'CalendarPageCtrl'
]    