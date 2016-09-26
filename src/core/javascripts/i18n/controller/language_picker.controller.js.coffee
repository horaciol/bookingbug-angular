'use strict'

angular.module('BB.i18n').controller 'bbLanguagePickerController', (bbLocale, $locale, $rootScope, tmhDynamicLocale, $translate,
  bbi18nOptions, $scope) ->
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
    angular.forEach bbi18nOptions.available_languages, (languageKey) ->
      vm.availableLanguages.push(createLanguage(languageKey))
    return

  setCurrentLanguage = () ->
    vm.language =
      selected: createLanguage(bbLocale.getLocale())

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
      bbLocale.setLocale(languageKey, 'bbLanguagePicker.pickLanguage')

      return
    return

  init();

  return
