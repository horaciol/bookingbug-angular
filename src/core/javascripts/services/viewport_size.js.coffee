'use strict'

###
* @ngdoc service
* @name BB.Services.service:ViewportSize
*
* @description
* Stores the current screen size breakpoint. 
###
angular.module('BB.Services').factory 'ViewportSize', ['$rootScope',($rootScope) ->

  viewport_size = null

  setViewportSize: (size) ->
    if size != viewport_size
      viewport_size = size
      $rootScope.$broadcast 'ViewportSize:changed'

  getViewportSize: () ->
    return viewport_size
]
  
