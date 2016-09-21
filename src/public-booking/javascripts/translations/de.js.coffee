'use strict';

angular.module('BB.Services').config ($translateProvider) ->
  'ngInject'

  translations = {
    PUBLIC_BOOKING: {
      ACCORDION_RANGE_GROUP: {
        AVAILABLE: '{number, plural, =0{Keine verfügbar} one{1 verfügbar} other{# verfügbare}}'
      }
      ALERTS: {
        ACCOUNT_DISABLED: "Your account appears to be disabled. Please contact the business you're booking with if the problem persists."
        ALREADY_REGISTERED: "You have already registered with this email address. Please login or reset your password."
        APPT_AT_SAME_TIME: "Your appointment is already booked for this time"
        ATTENDEES_CHANGED: "Your booking has been successfully updated"
        EMAIL_ALREADY_REGISTERED_ADMIN: "There's already an account registered with this email. Use the search field to find the customers account."
        EMPTY_BASKET_FOR_CHECKOUT:"Es sind keine Artikel im Warenkorb zur Kasse gehen."
        FB_LOGIN_NOT_A_MEMBER: "Sorry, we couldn't find a login associated with this Facebook account. You will need to sign up using Facebook first"
        FORM_INVALID: "Bitte füllen Sie alle Felder aus"
        GENERIC:"Leider scheint es, dass etwas schief gelaufen ist. Bitte versuchen Sie es erneut oder rufen Sie das Unternehmen sind Sie bei der Buchung mit, wenn das Problem weiterhin besteht."
        GEOLOCATION_ERROR: "Leider konnten wir Dein Ort wurde nicht festzustellen. Bitte versuchen Sie statt."
        GIFT_CERTIFICATE_REQUIRED: "A valid Gift Certificate is required to proceed with this booking"
        INVALID_POSTCODE: "Bitte GEBEN Sie eine Gültige Postleitzahl ein"
        ITEM_NO_LONGER_AVAILABLE: "Entschuldigung. Das Element, das Sie versuchten, zu buchen ist nicht mehr verfügbar. Bitte versuchen Sie es erneut."
        NO_WAITLIST_SPACES_LEFT: "Sorry, the space has now been taken, you are still in the waitlist and we will notify you if more spaces become available"
        LOCATION_NOT_FOUND: "Sorry, we don't recognise that location"
        LOGIN_FAILED: "Sorry, your email or password was not recognised. Please try again or reset your password."
        SSO_LOGIN_FAILED: "Something went wrong when trying to log you in. Please try again."
        MAXIMUM_TICKETS: "Sorry, the maximum number of tickets per person has been reached."
        MISSING_LOCATION: "Bitte geben Sie Ihren Standort"
        MISSING_POSTCODE: "Bitte geben Sie eine Postleitzahl ein"
        PASSWORD_INVALID: "Sorry, your password is invalid"
        PASSWORD_MISMATCH: "Your passwords don't match"
        PASSWORD_RESET_FAILED: "Sorry, we couldn't update your password. Please try again."
        PASSWORD_RESET_REQ_FAILED: "Sorry, we didn't find an account registered with that email."
        PASSWORD_RESET_REQ_SUCCESS: "We have sent you an email with instructions on how to reset your password."
        PASSWORD_RESET_SUCESS: "Your password has been updated."
        PAYMENT_FAILED: "We were unable to take payment. Please contact your card issuer or try again using a different card"
        PHONE_NUMBER_ALREADY_REGISTERED_ADMIN: "There's already an account registered with this phone number. Use the search field to find the customers account."
        REQ_TIME_NOT_AVAIL: "The requested time slot is not available. Please choose a different time."
        TIME_SLOT_NOT_SELECTED: "You need to select a time slot"
        STORE_NOT_SELECTED: "You need to select a store"
        TOPUP_FAILED: "Sorry, your topup failed. Please try again."
        TOPUP_SUCCESS: "Your wallet has been topped up"
        UPDATE_FAILED: "Update failed. Please try again"
        UPDATE_SUCCESS: "Updated"
        WAITLIST_ACCEPTED: "Your booking is now confirmed!"
        BOOKING_CANCELLED: "Your booking has been cancelled."
        NOT_BOOKABLE_PERSON: "Sorry, this person does not offer this service, please select another"
        NOT_BOOKABLE_RESOURCE: "Sorry, resource does not offer this service, pelase select another"
        SPEND_AT_LEAST: "You need to spend at least {{min_spend | pretty_price}} to make a booking."
      }
      ITEM_DETAILS: {
        MOVE_BOOKING_SUCCESS_MSG: "Your booking has been moved to {{datetime | datetime: 'LLLL'}}"
        MOVE_BOOKING_FAIL_MSG: "Failed to move booking. Please try again."
      }
      ADD_RECIPIENT: {
        MODAL_TITLE: "Recipient"
        WHO_TO_QUESTION: "Who should we send the gift voucher to?"
        WHO_TO_OPTION_ME: "Me"
        WHO_TO_OPTION_NOT_ME: "Someone else"
        NAME_LABEL: "Name"
        NAME_VALIDATION_MSG: "Bitte geben Sie den vollständigen Namen des Empfängers ein"
        EMAIL_LABEL: "Email"
        EMAIL_VALIDATION_MSG: "Bitte geben Sie eine gültige E-Mail-Adresse"
        ADD_LABEL: "Add Recipient"
        CANCEL_LABEL: "Cancel"
      }
      BASKET_DETAILS: {
        BASKET_DETAILS_TITLE: "Warenkorb Details"
        BASKET_DETAILS_NO: "Keine Artikel in den Warenkorb hinzugefügt."
        ITEM: "@:CORE.COMMON.TERMINOLOGY.ITEM"
        BASKET_ITEM_APPOINTMENT: "Ernennung"
        TIME_AND_DURATION: "{{ time | datetime: 'LLLL':false}} für {{ duration | time_period }}"
        PROGRESS_CANCEL: "@:CORE.COMMON.BTN.CANCEL"
        BASKET_CHECKOUT: "Kasse"
        BASKET_STATUS: "{N, plural, =0 {empty}, one {One item in your basket}, others {#items in your basket}}"
      }
      BASKET_ITEM_SUMMARY: {
        ITEM_DURATION: "@:CORE.COMMON.TERMINOLOGY.DURATION"
        ITEM_RESOURCE: "@:CORE.COMMON.TERMINOLOGY.RESOURCE"
        ITEM_PERSON: "@:CORE.COMMON.TERMINOLOGY.PERSON"
        ITEM_PRICE: "@:CORE.COMMON.TERMINOLOGY.PRICE"
        ITEM_DATE: "@:CORE.COMMON.TERMINOLOGY.DATE"
        ITEM_TIME: "@:CORE.COMMON.TERMINOLOGY.TIME"
      }
      CALENDAR: {
        PROGRESS_NEXT: '@:CORE.BTN.NEXT'
        PROGRESS_MOVE_BOOKING: '@:CORE.BTN.BOOK'
        PROGRESS_BACK: '@:CORE.BTN.BACK'
      }
      CATEGORY : {
        APPOINTMENT_TYPE: 'Select appointment type'
        PROGRESS_BOOK: '@:CORE.COMMON.BTN.BOOK'
        PROGRESS_BACK: '@:CORE.COMMON.BTN.BACK'
      }
      CANCEL_MODAL: {
        CANCEL_QUESTION: "Sind Sie sicher, Sie wollen diesen Buchung stornieren?"
        ITEM_SERVICE: "@:CORE.COMMON.TERMINOLOGY.SERVICE"
        ITEM_WHEN: "@:CORE.COMMON.TERMINOLOGY.WHEN"
        PROGRESS_CANCEL_BOOKING: "@:CORE.COMMON.BTN.CANCEL_BOOKING"
        PROGRESS_CANCEL_CANCEL: "Stornieren Sie nicht"
      }
      MEMBER_LOGIN_FORM: {
        EMAIL_LABEL: "Email"
        EMAIL_VALIDATION_REQUIRED_MESSAGE: "Please enter your email"
        EMAIL_VALIDATION_PATTERN_MESSAGE: "Please enter a valid email address"
        PASSWORD_LABEL: "Password"
        PLEASE_ENTER_PASSWORD: "Please enter your password"
        REMEMBER_ME: "Remember me"
        LOGIN: "Login"
      }
      MONTH_PICKER: {
        PROGRESS_PREVIOUS: "@:CORE.COMMON.BTN.CANCEL"
        PROGRESS_NEXT: "Nächster"
      }
      POPOUT_EXPORT_BOOKING: {
        LONG_EXPORT_LABEL: "Export to calendar"
        SHORT_EXPORT_LABEL: "Export"
      }
      PRICE_FILTER: {
        ITEM_PRICE: "@:CORE.COMMON.TERMINOLOGY.PRICE"
      }
      SERVICE_LIST_FILTER: {
        FILTER: "@:CORE.COMMON.TERMINOLOGY.FILTER"
        FILTER_CATEGORY: "@:CORE.COMMON.TERMINOLOGY.CATEGORY"
        FILTER_ANY: "@:CORE.COMMON.TERMINOLOGY.ANY"
        ITEM_SERVICE: "@:CORE.COMMON.TERMINOLOGY.SERVICE"
        FILTER_RESET: "@:CORE.COMMON.TERMINOLOGY.RESET"
      }
      WEEK_CALENDAR: {
        ALL_TIMES_IN: "All times are shown in {{time_zone_name}}."
        NO_AVAILABILITY: "{time_range_length, plural, It looks like there's no availability for the next {time_range_length} one{day} other{days}}"
        NEXT_AVAIL: "Jump to Next Available Day"
        ANY_DATE: "- Any Date -"
      }
      BASKET: {
        BASKET_TITLE: "Ihr Warenkorb"
        BASKET_ITEM_NO: "Es sind keine Artikel im Warenkorb"
        BASKET_ITEM_ADD_INSTRUCT: "Please press the add another item button if you wish to add a product or service"
        ITEM: "@:CORE.COMMON.TERMINOLOGY.ITEM"
        ITEM_PRICE: "@:CORE.COMMON.TERMINOLOGY.PRICE"
        BASKET_RECIPIENT: "Recipient"
        BASKET_CERTIFICATE_PAID: "Certicicate Bezahlt"
        BASKET_GIFT_CERTIFICATES: "Geschenkgutscheine"
        BASKET_PRICE_ORIGINAL: "Neupreis"
        BASKET_BOOKING_FEE: "Buchungsgebühr"
        BASKET_GIFT_CERTIFICATES_TOTAL: "Insgesamt Geschenkgutscheine"
        BASKET_GIFT_CERTIFICATE_BALANCE: "Restwert auf Geschenkgutscheine"
        BASKET_COUPON_DISCOUNT: "Coupon Rabatt"
        BASKET_TOTAL: "@:CORE.COMMON.TERMINOLOGY.TOTAL"
        BASKET_TOTAL_DUE_NOW: "@:CORE.COMMON.TERMINOLOGY.TOTAL_DUE_NOW"
        BASKET_WALLET: "@:CORE.COMMON.TERMINOLOGY.WALLET"
        BASKET_WALLET_BALANCE: "Aktuelle Wallet Balance"
        BASKET_WALLET_BALANCE_INSUFFICIENT: "Ach nein! Sie haben derzeit nicht genügend Geld in der Brieftasche Konto. Sie können entweder den vollen Betrag, oder nach oben, um mehr Geld, um Ihre Brieftasche hinzufügen."
        BASKET_WALLET_REMAINDER_PART_ONE: "Du wirst haben"
        BASKET_WALLET_REMAINDER_PART_TWO: "in Ihrer Brieftasche nach diesem Kauf links"
        BASKET_WALLET_TOP_UP: "Nachfüllen"
        BASKET_COUPON_APPLY: "Anwendung der Rabatt"
        PROGRESS_APPLY: "@:CORE.COMMON.BTN.APPLY"
        BASKET_GIFT_CERTIFICATE_QUESTION: "Haben Sie einen Gutschein?"
        BASKET_GIFT_CERTIFICATE_APPLY: "Tragen Sie einen Geschenkgutschein"
        BASKET_GIFT_CERTIFICATE_APPLY_ANOTHER: "Gelten Andere Geschenkgutschein"
        PROGRESS_CANCEL: "@:CORE.COMMON.BTN.CANCEL"
        BASKET_ITEM_ADD: "Fügen Sie ein anderes Element"
        BASKET_CHECKOUT: "Kasse"
        PROGRESS_BACK: "@:CORE.COMMON.BTN.BACK"
      }
      BASKET_ITEM_SUMMARY: {
        STEP_TITLE: "Summary"
        STEP_DESCRIPTION: "Please review the following information"
        DURATION_LABEL: "@:CORE.COMMON.TERMINOLOGY.DURATION"
        FULL_NAME_LABEL: "Full name"
        EMAIL_LABEL: "Email"
        MOBILE_LABEL: "Mobile"
        ADDRESS_LABEL: "Address"
        PRICE_LABEL: "@:CORE.COMMON.TERMINOLOGY.PRICE"
        CONFIRM_BUTTON: "Confirm"
        BACK_BUTTON: "@:CORE.COMMON.BTN.BACK"
      }
      BASKET_WAITLIST: {
        WAITLIST_BOOKING_TITLE: "Ihre Warteliste Buchung"
        BOOKING_REFERENCE: "Buchungsnummer"
        ITEM_SERVICE: "@:CORE.COMMON.TERMINOLOGY.SERVICE"
        ITEM_DATE_AND_OR_TIME: "@:CORE.COMMON.TERMINOLOGY.DATE/Time"
        ITEM_PRICE: "@:CORE.COMMON.TERMINOLOGY.PRICE"
        PROGRESS_BOOK: "@:CORE.COMMON.BTN.BOOK"
        BASKET_TOTAL: "@:CORE.COMMON.TERMINOLOGY.TOTAL"
        BASKET_TOTAL_DUE_NOW: "@:CORE.COMMON.TERMINOLOGY.TOTAL_DUE_NOW"
        CONFIRMATION_WAITLIST_SUBHEADER: "Danke {{ member_name }}. Sie haben successully auf gebucht {{ purchase_item }}."
        PRINT: "@:CORE.COMMON.TERMINOLOGY.PRINT"
        PROGRESS_BACK: "@:CORE.COMMON.BTN.BACK"
      }
      ERROR_MODAL: {
        PROGRESS_OK: "Ok"
      }
      MEMBER_FORM: {
        FIRST_NAME_LABEL: "@:CORE.COMMON.FORM.FIRST_NAME"
        LAST_NAME_LABEL: "@:CORE.COMMON.FORM.LAST_NAME"
        EMAIL_LABEL: "Email"
        PHONE_LABEL: "Phone"
        MOBILE_LABEL: "Mobile"
        SAVE_BUTTON: "@:CORE.COMMON.BTN.SAVE"
      }
      BASKET_WALLET: {
        BASKET_WALLET_MAKE_PAYMENT: "Zahlung"
        BASKET_WALLET_TOP_UP: "Nachfüllen"
        BASKET_WALLET_AMOUNT: "Menge"
        BASKET_WALLET: "@:CORE.COMMON.TERMINOLOGY.WALLET"
        BASKET_WALLET_AMOUNT_MINIMUM: "Mindest nachfüllen Betrag muss größer sein als"
        PROGRESS_BACK: "@:CORE.COMMON.BTN.BACK"
      }
      DASH: {
        DASHBOARD: "Armaturenbrett"
        DASHBOARD_TITLE: "Wählen Sie einen Ort / Dienst"
      }
      DAY: {
        AVAIL_MONTH_PREVIOUS: "Vorheriger Monat"
        AVAIL_MONTH_NEXT: "Nächster Monat"
        PROGRESS_BACK: "@:CORE.COMMON.BTN.BACK"
        DATE_NOT_SELECTED: "You need to select a date"
      }
      DEAL_LIST: {
        BASKET_GIFT_CERTIFICATE: "Geschenkgutscheine"
        BASKET_GIFT_CERTIFICATE_BUY: "Kaufen Geschenkgutscheine"
        BASKET_GIFT_CERTIFICATE_SELECTED: "Ausgewählte Geschenkgutscheine"
        ITEM: "@:CORE.COMMON.TERMINOLOGY.ITEM"
        ITEM_PRICE: "@:CORE.COMMON.TERMINOLOGY.PRICE"
        RECIPIENT_ADD: "Fügen Sie einen Empfänger"
        RECIPIENT_NAME: "Name"
        DETAILS_EMAIL: "E-Mail"
        PROGRESS_ADD: "Hinzufügen"
        RECIPIENT_NAME_VALIDATION_MSG: "Bitte geben Sie den vollständigen Namen des Empfängers ein"
        RECIPIENT_EMAIL_VALIDATION_MSG: "Bitte geben Sie eine gültige E-Mail-Adresse"
        RECIPIENT: "Empfänger"
        RECIPIENT_NAME: "Name"
        PROGRESS_BUY: "Kaufen"
        PROGRESS_BACK: "@:CORE.COMMON.BTN.BACK"
        CERTIFICATE_NOT_SELECTED_ALERT: 'You need to select at least one Gift Certificate to continue'
      }
      DURATION_LIST: {
        ITEM_FREE: "@:CORE.COMMON.TERMINOLOGY.PRICE_FREE"
        PROGRESS_SELECT: "@:CORE.COMMON.BTN.SELECT"
        PROGRESS_BACK: "@:CORE.COMMON.BTN.BACK"
        DURATON_NOT_SELECTED_ALERT: "You need to select a duration"
      }
      EVENT: {
        EVENT_DETAILS_TITLE: "Event-Details"
        DETAILS_TITLE: "Angaben zu Ihrer Person"
        DETAILS_FIRST_NAME: "@:CORE.COMMON.FORM.FIRST_NAME"
        DETAILS_FIRST_NAME_VALIDATION_MSG: "Bitte geben Sie Ihre Vorname"
        DETAILS_LAST_NAME: "@:CORE.COMMON.FORM.LAST_NAME"
        DETAILS_LAST_NAME_VALIDATION_MSG: "Bitte geben Sie Ihre Nachname"
        DETAILS_EMAIL: "E-Mail"
        DETAILS_EMAIL_VALIDATION_MSG: "Bitte geben Sie eine gültige E-Mail-Adresse"
        STORE_PHONE: "Telefon"
        DETAILS_PHONE_MOBILE_VALIDATION_MSG: "Please enter a valid mobile number"
        DETAILS_ADDRESS: "Adresse"
        DETAILS_ADDRESS_VALIDATION_MSG: "Bitte geben Sie Ihre Anschrift"
        DETAILS_TOWN: "Stadt"
        DETAILS_COUNTY: "County"
        DETAILS_POSTCODE: "PLZ"
        INVALID_POSTCODE: "Bitte GEBEN Sie eine Gültige Postleitzahl ein"
        DETAILS_VALIDATION_MSG: "Dieses Feld ist erforderlich"
        ATTENDEE_IS_YOU_QUESTION: "Sind Sie der Teilnehmer?"
        ATTENDEE_USE_MY_DETAILS: " Ja, verwenden Sie meine Daten"
        DETAILS_TERMS: " Ich akzeptiere die Geschäftsbedingungen."
        DETAILS_TERMS_VALIDATION_MSG: "Bitte stimmen Sie den Geschäftsbedingungen"
      }
      EVENT_GROUP_LIST: {
        PROGRESS_SELECT: "@:CORE.COMMON.BTN.SELECT"
      }
      EVENT_LIST: {
        EVENT_LOCATION: "Events an"
        FILTER: "@:CORE.COMMON.TERMINOLOGY.FILTER"
        FILTER_CATEGORY: "@:CORE.COMMON.TERMINOLOGY.CATEGORY"
        FILTER_ANY: "@:CORE.COMMON.TERMINOLOGY.ANY"
        ITEM_DATE: "@:CORE.COMMON.TERMINOLOGY.DATE"
        ITEM_PRICE: "@:CORE.COMMON.TERMINOLOGY.PRICE"
        EVENT_SOLD_OUT_HIDE: "Ausblenden Ausverkauft Events"
        EVENT_SOLD_OUT_SHOW: "Ausverkauft Events anzeigen"
        FILTER_RESET: "@:CORE.COMMON.TERMINOLOGY.RESET"
        FILTER_NONE: "Zeige alle Veranstaltungen"
        FILTER_FILTERED: "Zeige gefilterte Ereignisse"
        EVENT_WORD: "Events"
        EVENT_NO: "Keine Termine gefunden"
        EVENT_SPACE_WORD: "raum"
        EVENT_LEFT_WORD: "übrig"
        ITEM_FROM: "Von"
        PROGRESS_BOOK: "@:CORE.COMMON.BTN.BOOK"
        EVENT_SOLD_OUT: "Ausverkauft"
        EVENT_JOIN_WAITLIST: "Beitreten Warteliste"
      }
      MAIN: {
        POWERED_BY: "Buchungen bereitgestellt von"
      }
      MAP: {
        PROGRESS_SEARCH: "Suche"
        STORE_RESULT_TITLE: "{results, plural, =0{Keine Ergebnisse} one{1 Ergebnis} other{# Ergebnisse}} für Ausstellungsräume in der Nähe von {address}"
        HIDE_STORES: "Hide stores with no availability"
        SERVICE_UNAVAILABLE: "Sorry, but {{name}} is not available at this location"
        PROGRESS_SELECT: "@:CORE.COMMON.BTN.SELECT"
      }
      MEMBERSHIP_LEVELS: {
        MEMBERSHIP_TYPES: "Mitgliedschaftstypen"
        PROGRESS_SELECT: "@:CORE.COMMON.BTN.SELECT"
      }
      TIME: {
        AVAIL_DAY_PREVIOUS: "Vorheriger Tag"
        AVAIL_DAY_NEXT: "Nächster Tag"
        AVAIL_NO: "Kein Dienst vorhanden"
        PROGRESS_BACK: "@:CORE.COMMON.BTN.BACK"
        TIME_NOT_SELECTED_ALERT: "Please select a time slot"
        AVAIL_MORNING: "Morgens"
        AVAIL_AFTERNOON: "Nachmittags"
        AVAIL_EVENING: "Abends"
      }
      SURVEY: {
        SURVEY_THANK_YOU: "Vielen Dank für das Ausfüllen der Umfrage!"
        ITEM_SESSION: "@:CORE.COMMON.TERMINOLOGY.SESSION"
        ITEM_DATE: "@:CORE.COMMON.TERMINOLOGY.DATE"
        SURVEY_WORD: "Umfrage"
        DETAILS_QUESTIONS: "Fragen"
        SURVEY_SUBMIT: "Antworten abschicken"
        SURVEY_NO: "Keine Umfrage Fragen für diese Sitzung."
      }
      SERVICE_LIST: {
        ITEM_FREE: "@:CORE.COMMON.TERMINOLOGY.PRICE_FREE"
        PROGRESS_SELECT: "@:CORE.COMMON.BTN.SELECT"
        SERVICE_LIST_NO: "Keine Dienste Ihren Filterkriterien."
        PROGRESS_BACK: "@:CORE.COMMON.BTN.BACK"
      }
      RESOURCE_LIST: {
        PROGRESS_SELECT: "@:CORE.COMMON.BTN.SELECT"
        PROGRESS_BACK: "@:CORE.COMMON.BTN.BACK"
      }
      RESCHEDULE_REASONS:{
        MOVE_TITLE: "Move Appointment "
        MOVE_REASON: "Please select a reason for moving your appointment:"
        MOVE_BUTTON: "Move Appointment"
        }
      PURCHASE: {
        CANCEL_CONFIRMATION: "Ihre Buchung storniert wurde."
        CONFIRMATION_PURCHASE_TITLE: "Ihre {{ service_name }} reservierung"
        RECIPIENT_NAME: "Name"
        PRINT: "@:CORE.COMMON.TERMINOLOGY.PRINT"
        DETAILS_EMAIL: "E-Mail"
        ITEM_SERVICE: "@:CORE.COMMON.TERMINOLOGY.SERVICE"
        ITEM_WHEN: "@:CORE.COMMON.TERMINOLOGY.WHEN"
        ITEM_PRICE: "@:CORE.COMMON.TERMINOLOGY.PRICE"
        PROGRESS_CANCEL_BOOKING: "@:CORE.COMMON.BTN.CANCEL_BOOKING"
        PROGRESS_MOVE_BOOKING: "Verschieben Buchung"
        PROGRESS_BOOK_WAITLIST_ITEMS: "Buchen Warteliste Artikel"
      }
      PRINT_PURCHASE: {
        CONFIRMATION_BOOKING_TITLE: "Buchungsbestätigung"
        CONFIRMATION_BOOKING_SUBHEADER: "Danke {{member_name}}. Ihre Buchung ist jetzt bestätigt. Wir haben Ihnen die Angaben per E-Mail geschickt."
        CALENDAR_EXPORT_TITLE: " In den Kalender exportieren"
        PRINT: "@:CORE.COMMON.TERMINOLOGY.PRINT"
        AND: "@:CORE.COMMON.TERMINOLOGY.AND"
        ITEM: "@:CORE.COMMON.TERMINOLOGY.ITEM"
        ITEM_DATE: "@:CORE.COMMON.TERMINOLOGY.DATE"
        ITEM_QUANTITY: "Menge"
        BOOKING_REFERENCE: "Buchungsnummer"
        POWERED_BY: "Buchungen bereitgestellt von"
      }
      PERSON_LIST: {
        PROGRESS_SELECT: "@:CORE.COMMON.BTN.SELECT"
        PROGRESS_BACK: "@:CORE.COMMON.BTN.BACK"
      }
      MONTHLY_CALENDAR: {
        SELECT_DAY: "Select a day"
        WEEK_BEGINNING: "Week beginning"
        PICK_A_DATE: "Wählen Sie ein Datum"
        PREVIOUS_5_WEEKS: "Previous 5 Weeks"
        NEXT_5_WEEKS: "Next 5 Weeks"
        KEY: "Key"
        AVAILABLE: "{number, plural, =0{Keine verfügbar} one{1 verfügbar} other{# verfügbare}}"
        UNAVAILABLE: "Unavailable"
        PROGRESS_BACK: "@:CORE.COMMON.BTN.BACK"
      }
    }
  }

  $translateProvider.translations('de', translations)

  return