'use strict'

angular.module('BB').directive 'bbProjectVersion', () ->
  'ngInject'

  return {
    controller: 'BbProjectVersionController'
    controllerAs: 'vm_project_version'
    restrict: 'A'
    templateUrl: 'core/project_version.html'
  }