'use strict'

###*
 * @ngdoc directive
 * @name BBAdminDashboard.directive:adminIframe
 * @scope
 * @restrict A
 *
 * @description
 * Ensures iframe size is based on iframe content and that the iframe src is whitelisted
 *
 * @param {string}   path         A string that contains the iframe url
 * @param {string}   apiUrl       A string that contains the ApiUrl
 * @param {boolean}  fullHeight   A boolean that enables the iframe to take all available hight in the content area
 * @param {object}   extraParams  An object that contains extra params for the url (optional)
 * @param {function} onLoad       A callback function to be called after the iframed has finished loading (optional)
###
angular.module('BBAdminDashboard').directive 'adminIframe', ['$window', '$timeout', ($window, $timeout) ->
  {
    restrict: 'A'
    scope:
      path:        '='
      apiUrl:      '='
      fullHeight:  '=?'
      extraParams: '=?'
      onLoad:      '=?'
    templateUrl: 'core/admin-iframe.html'
    controller: ['$scope', '$sce', ($scope, $sce) ->
      $scope.frameSrc = $sce.trustAsResourceUrl($scope.apiUrl + '/' + unescape($scope.path) + "?whitelabel=adminlte&uiversion=aphid&#{$scope.extraParams if $scope.extraParams}")
    ]
    link: (scope, element, attrs) ->
      calculateFullHeight = (containerHeight)->

        heightToConsider = 0
        # Make sure we include the content container's padding in the calculation
        contentSection = angular.element(document.querySelectorAll('section.content'))
        if contentSection.length
          contentSection   = contentSection[0]
          heightToConsider = heightToConsider + parseInt($window.getComputedStyle(contentSection,null).getPropertyValue('padding-top'))
          heightToConsider = heightToConsider + parseInt($window.getComputedStyle(contentSection,null).getPropertyValue('padding-bottom'))

        return (containerHeight - heightToConsider)

      # Callback onload of the iframe
      element.find('iframe')[0].onload = () ->
        scope.$emit 'iframeLoaded',{}
        if typeof scope.onLoad == 'function'
          scope.onLoad()


      if scope.fullHeight
        # first load attempt
        element.find('iframe').height( calculateFullHeight(angular.element(document.querySelector('#content-wrapper')).height()) + 'px')

        # This will listen for resize events
        scope.$on 'content.changed', (event, data) ->
          element.find('iframe').height( calculateFullHeight(data.height) + 'px')

      else
        $window.addEventListener 'message', (event) ->
          if event.data.height
            element.find('iframe').height(event.data.height + 'px')
      return
  }
]
