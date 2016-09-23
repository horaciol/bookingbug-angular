'use strict'

angular.module('BB.i18n').run (bbi18nOptions, bbLocale, RuntimeTranslate, $translate) ->
  'ngInject'

  RuntimeTranslate.registerAvailableLanguageKeys(
    bbi18nOptions.available_languages,
    bbi18nOptions.available_language_associations
  )

  bbLocale.determineLocale()

  return
