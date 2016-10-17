'use strict'

angular.module('BB').directive 'bbProjectVersion', () ->
  'ngInject'

  return {
    controller: 'BbProjectVersionController'
    controllerAs: 'vmProjectVersion'
    restrict: 'A'
    templateUrl: 'core/project_version.html'
  }