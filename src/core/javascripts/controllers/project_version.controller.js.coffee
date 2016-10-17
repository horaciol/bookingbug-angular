'use strict'

angular.module('BB').controller 'BbProjectVersionController', (bbConfig) ->
  'ngInject'

  ### jshint validthis: true ###
  vm = @
  vm.sdkVersion = bbConfig.SDK_VERSION
  vm.projectVersion = bbConfig.DEPLOY_VERSION
  vm.showVersion = bbConfig.SHOW_VERSION
  return