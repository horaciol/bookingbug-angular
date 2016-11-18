'use strict';

angular.module('BB.Services').config ($translateProvider) ->
  'ngInject'

  translations = {
    CORE: {
      ALERTS: {
        ERROR_TITLE: "Error"
      }
      PAGINATION: {
        SUMMARY: "{{start}} - {{end}} of {{total}}"
      }
      MODAL: {
        CANCEL_BOOKING: {
          HEADER:               "Cancel"
          QUESTION:             "Are you sure you want to cancel this {{type}}?"
        }
        SCHEMA_FORM: {
          OK_BTN:     "@:COMMON.BTN.OK"
          CANCEL_BTN: "@:COMMON.BTN.CANCEL"
        }
      }
      FILTERS: {
        DISTANCE: {
          UNIT: "mi"
        }
        CURRENCY: {
          THOUSANDS_SEPARATOR: ","
          DECIMAL_SEPARATOR:   "."
          CURRENCY_FORMAT:     "%s%v"
        }
        PRETTY_PRICE: {
          FREE: "@:COMMON.TERMINOLOGY.PRICE_FREE"
        }
        TIME_PERIOD: {
          TIME_PERIOD: "{hours, plural, =0{} one{1 hour} other{# hours}}{show_seperator, plural, =0{} =1{, } other{}}{minutes, plural, =0{} one{1 minute} other{# minutes}}"
        }
      }
      EVENT: {
        SPACES_LEFT:   "Only {N, plural, one{one space}, others{# spaces}} left"
        JOIN_WAITLIST: "Join waitlist"
      }
    }
    COMMON: {
      TERMINOLOGY: {
        CATEGORY:          "Category"
        DURATION:          "Duration"
        RESOURCE:          "Resource"
        PERSON:            "Person"
        SERVICE:           "Service"
        WALLET:            "Wallet"
        SESSION:           "Session"
        EVENT:             "Event"
        EVENTS:            "Events"
        COURSE:            "Course"
        COURSES:           "Courses"
        DATE:              "Date"
        TIME:              "Time"
        WHEN:              "When"
        GIFT_CERTIFICATE:  "Gift Certificate"
        GIFT_CERTIFICATES: "Gift Certificates"
        ITEM:              "Item"
        FILTER:            "Filter"
        ANY:               "Any"
        RESET:             "Reset"
        TOTAL:             "Total"
        TOTAL_DUE_NOW:     "Total Due Now"
        BOOKING_FEE:       "Booking Fee"
        PRICE:             "Price"
        PRICE_FREE:        "Free"
        PRINT:             "Print"
        AND:               "and"
        APPOINTMENT:       "Appointment"
        TICKETS:           "Tickets"
        EXPORT:            "Export"
        RECIPIENT:         "Recipient"
        BOOKING_REF:       "Booking Reference"
        MORNING:           "Morning"
        AFTERNOON:         "Afternoon"
        EVENING:           "Evening"
        AVAILABLE:         "Available"
        UNAVAILABLE:       "Unavailable"
        CALENDAR:          "Calendar"
        QUESTIONS:         "Questions"
        BOOKING:           "Booking"
        ADMITTANCE:        "Admittance"
      }
      FORM: {
        FIRST_NAME:                    "First Name"
        FIRST_NAME_REQUIRED:           "Please enter your first name"
        LAST_NAME:                     "Last Name"
        LAST_NAME_REQUIRED:            "Please enter your last name"
        FULL_NAME:                     "Full Name"
        ADDRESS1:                      "Address"
        ADDRESS_REQUIRED:              "Please enter your address"
        ADDRESS3:                      "Town"
        ADDRESS4:                      "County"
        POSTCODE:                      "Postcode"
        POSTCODE_PATTERN:              "Please enter a valid postcode"
        PHONE:                         "Phone"
        MOBILE:                        "Mobile"
        MOBILE_REQUIRED:               "Please enter a valid mobile number"
        EMAIL:                         "Email"
        EMAIL_REQUIRED:                "Please enter your email"
        EMAIL_PATTERN:                 "Please enter a valid email address"
        FIELD_REQUIRED:                "This field is required"
        PASSWORD:                      "Password"
        PASSWORD_REQUIRED:             "Please enter your password"
        REQUIRED:                      "*Required"
        TERMS_AND_CONDITIONS:          "I agree to the terms and conditions"
        TERMS_AND_CONDITIONS_REQUIRED: "Please accept the terms and conditions"
      }
      BTN: {
        CANCEL:                "Cancel"
        CLOSE:                 "Close"
        NO:                    "No"
        OK:                    "Ok"
        YES:                   "Yes"
        BACK:                  "Back"
        NEXT:                  "Continue"
        LOGIN:                 "Login"
        CONFIRM:               "Confirm"
        SAVE:                  "Save"
        SELECT:                "Select"
        BOOK:                  "Book"
        CANCEL_BOOKING:        "Cancel Booking"
        DO_NOT_CANCEL_BOOKING: "Do not cancel"
        APPLY:                 "Apply"
        CLEAR:                 "Clear"
        PAY:                   "Pay"
        CHECKOUT:              "Checkout"
        TOP_UP:                "Top Up"
        ADD:                   "Add"
        SUBMIT:                "Submit"
        DETAILS:               "Details"
        MORE:                  "More"
        LESS:                  "Less"
        DELETE:                "Delete"
      }
      LANGUAGE: {
        EN: "English"
        DE: "Deutsch"
        ES: "Español"
        FR: "Français"
      }
    }
  }

  $translateProvider.translations('en', translations)

  return
