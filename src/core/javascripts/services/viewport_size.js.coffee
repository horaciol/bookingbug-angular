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
    # console.log viewport_size, "viewport_size"
    # console.log size, "size"
    num = 1 if viewport_size == 'xs'
    num = 3 if viewport_size == 'sm'
    num = 5 if viewport_size == 'md'
    num = 7 if viewport_size == 'lg'
    num2 = 1 if size == 'xs'
    num2 = 3 if size == 'sm'
    num2 = 5 if size == 'md'
    num2 = 7 if size == 'lg'
    console.log num2
    console.log num
    if num < num2 or !num
      console.log "asdasdjkaskhjdaskhj"
      viewport_size = size
      $rootScope.$broadcast 'ViewportSize:changed'

  getViewportSize: () ->
    return viewport_size
]
