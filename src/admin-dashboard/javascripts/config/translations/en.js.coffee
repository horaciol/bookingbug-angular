'use strict';

###
* @ngdoc overview
* @name BBAdminDashboard.config.translations
#
* @description
* Translations for the admin config module
###
angular.module('BBAdminDashboard.config.translations')
.config ['$translateProvider', ($translateProvider)->
  $translateProvider.translations('en', {
    'ADMIN_DASHBOARD': {
      'SIDE_NAV'          : {
        'CONFIG_PAGE': {
          'CONFIG'          : 'Config',
          'YOUR_BUSINESS'   : 'Your business',
          'EVENT_SETTINGS'  : 'Event settings',
          'PROMOTIONS'      : 'Promotions',
          'BOOKING_SETTINGS': 'Booking settings',
        }
      },
      'CONFIG_PAGE': {
        'BUSINESS'        : {
          'TITLE'             : 'Configure: Business',
          'TAB_STAFF'         : 'Staff',
          'TAB_RESOURCES'     : 'Resource',
          'TAB_SERVICES'      : 'Services',
          'TAB_WHO_WHAT_WHERE': 'Who / What / Where',
          'TAB_QUEUES'        : 'Queues'
        },
        'EVENT_SETTINGS'  : {
          'TITLE'             : 'Event settings',
          'TAB_COURSES'       : 'Courses',
          'TAB_SINGLE_EVENTS' : 'Single events',
          'TAB_REGULAR_EVENTS': 'Regular events',
          'TAB_GROUPS'        : 'Groups',
          'TAB_TEMPLATES'     : 'Templates'
        },
        'PROMOTIONS'      : {
          'TITLE'             : 'Promotions',
          'TAB_DEALS'         : 'Deals',
          'TAB_COUPONS'       : 'Coupons',
          'TAB_BULK_PURCHASES': 'Bulk purchases',
          'TAB_PACKAGES'      : 'Packages'
        },
        'BOOKING_SETTINGS': {
          'TITLE'              : 'Booking settings',
          'TAB_QUESTIONS'      : 'Questions',
          'TAB_QUESTION_GROUPS': 'Question Groups',
          'TAB_BOOKING_TEXT'   : 'Booking text',
          'TAB_ADDRESSES'      : 'Addresses',
          'TAB_IMAGES'         : 'Images'
        }
      }
    }
  })
]
