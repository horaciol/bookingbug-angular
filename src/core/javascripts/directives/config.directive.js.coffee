'use strict'

angular.module('BB').directive 'bbConfig', () ->
  'ngInject'

  return {
    controller: 'BbConfigController'
    controllerAs: 'vmConfig'
    restrict: 'A'
  }