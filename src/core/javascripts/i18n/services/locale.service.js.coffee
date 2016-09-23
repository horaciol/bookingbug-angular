'use strict'

angular.module('BB.i18n').service 'bbLocale', (bbi18nOptions, $log, $translate, $window) ->
  'ngInject'

  _locale = null
  _localeCompanyUsed = false

  init = () ->
    defaultLocale = bbi18nOptions.default_language
    setLocale(defaultLocale, 'default locale')
    $translate.preferredLanguage getLocale()
    return

  determineLocale = () ->

    URIParamLocale = $window.getURIparam('locale')
    if URIParamLocale
      setLocale(URIParamLocale, 'URIParam locale')
      $translate.preferredLanguage getLocale()

    else if bbi18nOptions.use_browser_language
      browserLocale = $translate.negotiateLocale($translate.resolveClientLocale()) #browserLocale = $window.navigator.language;
      setLocale(browserLocale, 'browser locale')
      $translate.preferredLanguage getLocale()

    return

  ###
  # @param {String} locale
  # @param {String} setWith
  ###
  setLocale = (locale, setWith = '') ->
    if bbi18nOptions.available_languages.indexOf(locale) is -1
      return

    _locale = locale
    moment.locale _locale # TODO we need angular wrapper for moment
    $translate.use _locale
    console.info('bbLocale.locale = ', _locale, ', set with: ', setWith)
    return

  ###
  # @returns {String}
  ###
  getLocale = () ->
    return _locale

  ###
    # It's a hacky way to map country code to specific locale. Reason is moment default is set to en_US
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

  init()

  return {
    determineLocale: determineLocale
    getLocale: getLocale
    setLocale: setLocale
    setLocaleUsingCountryCode: setLocaleUsingCountryCode
  }
