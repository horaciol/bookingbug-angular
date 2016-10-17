'use strict'

angular.module('BB').controller 'BbConfigController', (bbConfig) ->
  'ngInject'

  ### jshint validthis: true ###
  vm = @
  vm.config = bbConfig
  return