'use strict'

###*
 * @ngdoc directive
 * @name BBAdminDashboard.directive:adminLanguagePicker
 * @scope
 * @restrict A
 *
 * @description
 * Responsible for providing a ui representation of available translations
 *
###
angular.module('BBAdminDashboard').directive 'adminLanguagePicker', [() ->
  {
    restrict: 'A'
    templateUrl: 'core/admin-language-picker.html'
    controller: ['$scope', '$translate', 'AdminCoreOptions', '$rootScope', ($scope, $translate, AdminCoreOptions, $rootScope) ->
      $scope.availableLanguages = []
      $scope.language = {
        selected: {
          identifier: $translate.use()
          label: 'LANGUAGE_' + $translate.use().toUpperCase()
        }
      }

      angular.forEach AdminCoreOptions.available_languages, (language,index) ->
        $scope.availableLanguages.push {
          identifier: language
          label: 'LANGUAGE_' + language.toUpperCase()
        }

      $scope.pickLanguage = (language) ->
        $translate.use language
        $rootScope.$broadcast 'LanguagePicker:changeLanguage'
    ]
    link: (scope, element, attrs) ->
      # hide language picker if only one language is available
      if scope.availableLanguages.length <= 1
        angular.element(element).addClass 'hidden'
  }
]
