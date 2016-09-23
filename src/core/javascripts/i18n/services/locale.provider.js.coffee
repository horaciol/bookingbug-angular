'use strict'

angular.module('BB.i18n').provider 'bbLocale', ($windowProvider) ->
  'ngInject'

  _locale = 'en' # moment defaults to en-US
  _localeCompanyUsed = false

  determineLocale = () ->
    $window = $windowProvider.$get()
    localeURIParam = $window.getURIparam('locale')
    localeBrowser = $window.navigator.language;

    calledWith = 'default'
    if localeURIParam
      _locale = localeURIParam
      calledWith = 'URIParam locale'
    else if localeBrowser
      _locale = localeBrowser
      calledWith = 'browser locale'

    setLocale(_locale, calledWith)
    return

  ###
  # @param {String} locale
  # @param {String} calledWith
  ###
  setLocale = (locale, calledWith = '') ->
    _locale = locale
    moment.locale locale
    console.info('bbLocale.locale = ', _locale, ', called with: ', calledWith)
    console.log $windowProvider.$get()
    return

  getLocale = () ->
    return _locale

  $get = () ->
    'ngInject'

    ###
    # It's a hacky way to map country code to specific locale.
    # @param {String} countryCode
    ###
    setLocaleUsingCountryCode = (countryCode) ->
      if _localeCompanyUsed
        return #can be set only once
      _localeCompanyUsed = true

      if countryCode and countryCode.match /^(gb|au)$/
        locale = 'en-' + countryCode
        setLocale locale, 'countryCode'
      return

    return {
      getLocale: getLocale
      setLocale: setLocale
      setLocaleUsingCountryCode: setLocaleUsingCountryCode
    }

  return {
    determineLocale: determineLocale
    getLocale: getLocale
    setLocale: setLocale
    $get: $get
  }
