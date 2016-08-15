'use strict';

###*
* @ngdoc overview
* @name BBAdminDashboard.translations
* @description
* Translations for the admin core module
###

config = ($translateProvider) ->
  'ngInject'

  enTranslations = {
    'SIDE_NAV_BOOKINGS': 'BOOKINGS',
    'SIDE_NAV_CONFIG': 'CONFIGURATION',
    'LANGUAGE_EN': 'English',
    'GREETING': 'Hi',
    'LOGOUT': 'Logout'
    'VERSION': 'Version',
    'COPYRIGHT': 'Copyright'
  }

  $translateProvider.translations('en', enTranslations)

  return


angular.module('BBAdminDashboard').config config
