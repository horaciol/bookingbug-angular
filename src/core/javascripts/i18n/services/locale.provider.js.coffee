'use strict'

###
# NOTE locale from widget parameters is not in use anymore - use this provider in bespoke project instead
# @TODO use company country code to set locale - it cannot be done BBCtrl as it
###
angular.module('BB.i18n').provider 'bbLocale', ($windowProvider) ->
  'ngInject'

  locale = 'en' # US a default locale
  localeCompanyUsed = false

  determineLocale = () ->
    $window = $windowProvider.$get()
    localeURIParam = $window.getURIparam('locale')
    localeBrowser = $window.navigator.language;

    if localeURIParam
      setLocale(localeURIParam)
    else if localeBrowser
      setLocale(localeBrowser)
    return

  setLocale = (localeParam, isDeterminedOfCompanyCountryCode = false) ->

    if isDeterminedOfCompanyCountryCode && localeCompanyUsed
      return # you can set company provider only once
    else
      localeCompanyUsed = true

    console.info('locale set to', localeParam)
    locale = localeParam
    moment.locale localeParam

    #moment.locale 'en-' + country_code if country_code and country_code.match /^(gb|au)$/ #TODO that's hacky way to use comapany country code
    return

  getLocale = () ->
    return locale

  $get = () ->
    'ngInject'

    return {
      getLocale: getLocale
      setLocale: setLocale
    }

  return {
    determineLocale: determineLocale
    getLocale: getLocale
    setLocale: setLocale
    $get: $get
  }






