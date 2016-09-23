'use strict'

angular.module('BB.Services').factory 'SettingsService', ($uibModalStack, bbLocale) ->
  i18n = false
  scroll_offset = 0
  country_code = null
  use_local_time_zone = false
  currency = null
  company_time_zone = null
  display_time_zone = null

  update_document_title: false

  enableInternationalizaton: () ->
    i18n = true

  isInternationalizatonEnabled: () ->
    return i18n

  setScrollOffset: (value) ->
    scroll_offset = parseInt(value)

  getScrollOffset: () ->
    return scroll_offset

  setCountryCode: (value) ->

    country_code = value
    bbLocale.setLocaleUsingCountryCode(country_code)

    return


  getCountryCode: () ->
    return country_code

  setUseLocalTimeZone: (value) ->
    use_local_time_zone = value
    display_time_zone  = moment.tz.guess()

  getUseLocalTimeZone: ->
    use_local_time_zone

  setCurrency: (value) ->
    currency = value

  getCurrency: ->
    currency

  setTimeZone: (value) ->
    company_time_zone = value

  getTimeZone: ->
    company_time_zone

  setDisplayTimeZone: (value) ->
    display_time_zone = value

  getDisplayTimeZone: ->
    if display_time_zone
      display_time_zone
    else
      company_time_zone

  isModalOpen: ->
    !!$uibModalStack.getTop()
