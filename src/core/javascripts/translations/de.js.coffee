'use strict';

angular.module('BB.Services').config ($translateProvider) ->
  'ngInject'

  translations = {
    CORE: {
      ALERTS: {
        ERROR_TITLE: 'Error'
      }
      MODAL: {
        CANCEL_BOOKING: {
          HEADER: 'Cancel'
          QUESTION: 'Are you sure you want to cancel this {{type}}?'
          APPOINTMENT_QUESTION: 'Are you sure you want to cancel this appointment?'
        }
        SCHEMA_FORM: {
          OK_BTN: '@:CORE.COMMON.BTN.OK'
          CANCEL_BTN: '@:CORE.COMMON.BTN.CANCEL'
        }
      }
      FILTERS: {
        DISTANCE: {
          UNIT: 'mi'
        }
        CURRENCY: {
          THOUSANDS_SEPARATOR: ','
          DECIMAL_SEPARATOR: '.'
          CURRENCY_FORMAT: '%s%v'
        }
        PRETTY_PRICE: {
          FREE: '@:CORE.COMMON.TERMINOLOGY.PRICE_FREE'
        }
        TIME_PERIOD: {
          TIME_SEPARATOR: " and "
        }
      }
      EVENT: {
        SPACES_LEFT: 'Only {N, plural, one{one space}, others{# spaces}} left'
        JOIN_WAITLIST: 'Beitreten Warteliste'
      }
    }
    COMMON: {
      TERMINOLOGY: {
        CATEGORY: 'Kategorie'
        DURATION: 'Duration'
        RESOURCE: 'Ressource'
        PERSON: 'Person'
        SERVICE: 'Service'
        WALLET: 'Brieftasche'
        SESSION: 'Session'
        EVENT: 'Event'
        COURSE: 'Course'
        DATE: 'Datum'
        TIME: 'Zeit'
        WHEN: 'Wann'
        GIFT_CERTIFICATE: 'Gift Certificate'
        ITEM: 'Artikel'
        FILTER: 'Filter'
        ANY: 'Jeder'
        RESET: 'Rücksetzen'
        TOTAL: 'Gesamt'
        TOTAL_DUE_NOW: 'Insgesamt Aufgrund Now'
        PRICE: 'Preis'
        PRICE_FREE: 'Kostenlos'
        PRINT: ' Drucken'
        AND: 'und'
      }
      FORM: {
        FIRST_NAME: 'First Name'
        FIRST_NAME_REQUIRED: 'Please enter your first name'
        LAST_NAME: 'Last Name'
        LAST_NAME_REQUIRED: 'Please enter your last name'
        FULL_NAME: 'Full Name'
        ADDRESS1: 'Address'
        ADDRESS_REQUIRED: ''
        ADDRESS3: 'Town'
        ADDRESS4: 'County'
        POSTCODE: 'Postcode'
        PHONE: 'Phone'
        MOBILE: 'Mobile'
        MOBILE_REQUIRED: 'Please enter a valid mobile number'
        EMAIL: 'Email'
        EMAIL_REQURIED: 'Please enter your email'
        EMAIL_PATTERN: 'Please enter a valid email address'
        FIELD_REQUIRED: ''
        PASSWORD: 'Password'
        PASSWORD_REQUIRED: 'Please enter your password'
      }
      BTN: {
        CANCEL: 'Cancel'
        CLOSE: 'Close'
        NO: 'No'
        OK: 'OK'
        YES: 'Yes'
        BACK: 'Zurück'
        NEXT: 'Nächster'
        LOGIN: 'Login'
        CONFIRM: 'Confirm'
        SAVE: 'Save'
        SELECT: 'Wählen'
        BOOK: 'Buchen'
        CANCEL_BOOKING: 'Reservierung stornieren'
        DO_NOT_CANCEL_BOOKING: 'Do not cancel'
        APPLY: 'Anwenden'

      }
      LANGUAGE: {
        EN: 'English'
        FR: 'Français'
      }

    }
  }

  $translateProvider.translations('de', translations)

  return