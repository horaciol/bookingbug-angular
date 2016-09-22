'use strict'

angular.module('BB.i18n').controller 'languagePickerController', (bbLocale, $locale, $rootScope, tmhDynamicLocale, $translate,
  TranslationOptions, $scope) ->
  'ngInject'

  ###jshint validthis: true ###
  vm = @

  vm.language = null
  vm.availableLanguages = []

  init = () ->
    seAvailableLanguages();
    setCurrentLanguage();
    $scope.$on 'BBLanguagePicker:refresh', setCurrentLanguage

    vm.pickLanguage = pickLanguage
    return

  seAvailableLanguages = () ->
    angular.forEach TranslationOptions.available_languages, (languageKey) ->
      vm.availableLanguages.push(createLanguage(languageKey))
    return

  setCurrentLanguage = () ->
    languageKey = $translate.use()
    if languageKey is 'undefined'
      languageKey = $translate.preferredLanguage()

    vm.language =
      selected: createLanguage(languageKey)

    if languageKey isnt $locale.id
      pickLanguage(languageKey)

    bbLocale.setLocale(languageKey)

    return

  ###
  # @param {String]
  ###
  createLanguage = (languageKey) ->
    return {
      identifier: languageKey
      label: 'COMMON.LANGUAGE.' + languageKey.toUpperCase()
    }

  ###
  # @param {String]
  ###
  pickLanguage = (languageKey) ->
    tmhDynamicLocale.set(languageKey).then () ->
      $translate.use languageKey
      $rootScope.$broadcast 'BBLanguagePicker:languageChanged'
      bbLocale.setLocale(languageKey)
      return
    return

  init();

  return
