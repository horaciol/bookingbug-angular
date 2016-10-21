'use strict'

angular.module('BB').controller 'BbProjectVersionController', (bbConfig) ->
  'ngInject'

  ### jshint validthis: true ###
  vm = @
  vm.sdk_version = bbConfig.BUILD.SDK_VERSION
  vm.project_version = bbConfig.BUILD.DEPLOY_VERSION
  vm.show_version = bbConfig.BUILD.SHOW_VERSION

  return