'use strict'

angular.module('BB.i18n').service 'bbLocale', (bbi18nOptions, $log, $translate, $window) ->
  'ngInject'

  _localeCompanyUsed = false

  determineLocale = () ->

    if $translate.use() isnt 'undefined' && angular.isDefined($translate.use()) && isAvailable($translate.use())
      setLocale($translate.use(), '$translate.use() locale')
    else
      browserLocale = $translate.negotiateLocale($translate.resolveClientLocale()) #browserLocale = $window.navigator.language;
      defaultLocale = bbi18nOptions.default_language
      URIParamLocale = $window.getURIparam('locale')

      if URIParamLocale and isAvailable(URIParamLocale)
        setLocale(URIParamLocale, 'URIParam locale')
      else if bbi18nOptions.use_browser_language and isAvailable(browserLocale)
        setLocale(browserLocale, 'browser locale')
      else
        setLocale(defaultLocale, 'default locale')

    $translate.preferredLanguage getLocale()

    return

  ###
  # @param {String} locale
  # @param {String} setWith
  ###
  setLocale = (locale, setWith = '') ->
    if !isAvailable(locale)
      return

    moment.locale(locale) # TODO we need angular wrapper for moment
    $translate.use(locale)

    #console.info('bbLocale.locale = ', locale, ', set with: ', setWith)

    if locale isnt moment.locale() || locale isnt $translate.use()
      console.error('could not set locale properly, preferredLocale = ' + locale + ', moment.locale() = ', moment.locale(), '$translate.use() = ', $translate.use())

    return

  ###
  # {String} locale
  ###
  isAvailable = (locale) ->
    return bbi18nOptions.available_languages.indexOf(locale) isnt -1

  ###
  # @returns {String}
  ###
  getLocale = () ->
    return $translate.use()

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
      setLocale(locale, 'countryCode')
    return

  return {
    determineLocale: determineLocale
    getLocale: getLocale
    setLocale: setLocale
    setLocaleUsingCountryCode: setLocaleUsingCountryCode
  }
