'use strict'

###**
* @ngdoc directive
* @name BB.Directives:bbPayment
* @restrict AE
* @scope true
*
* @description
*
* Renders payment iframe (where integrated payment has been configured) and handles payment success/failure.
*
* <pre>
* restrict: 'AE'
* replace: true
* scope: true
* </pre>
*
* @property {array} total The total of payment
####


angular.module('BB.Directives').directive 'bbPayment', ($window, $location,
  $sce, SettingsService, AlertService) ->

  restrict: 'AE'
  replace: true
  scope: true
  controller: 'Payment'
  link: (scope, element, attributes) ->

    error = (scope, message) ->
      scope.error(message)

    getHost = (url) ->
      a = document.createElement('a')
      a.href = url
      a['protocol'] + '//' +a['host']

    sendLoadEvent = (element, origin, scope) ->
      referrer = $location.protocol() + "://" + $location.host()
      if $location.port()
        referrer += ":" + $location.port()

      if scope.payment_options.custom_stylesheet
        if custom_stylesheet.match(/http/)
          # custom stylesheet as an absolute url, for ex. "http://bespoke.bookingbug.com/staging/custom-booking-widget.css"
          custom_stylesheet = scope.payment_options.custom_stylesheet
        else
          # custom stylesheet as a file, for ex. "custom-booking-widget.css"
          custom_stylesheet = $location.absUrl().match(/.+(?=#)/) + scope.payment_options.custom_stylesheet

      payload = JSON.stringify({
        'type': 'load',
        'message': referrer,
        'custom_partial_url': scope.bb.custom_partial_url,
        'custom_stylesheet' : custom_stylesheet,
        'scroll_offset'     : SettingsService.getScrollOffset()
      })

      element.find('iframe')[0].contentWindow.postMessage(payload, origin)

    scope.payment_options = scope.$eval(attributes.bbPayment) or {}
    scope.route_to_next_page = if scope.payment_options.route_to_next_page? then scope.payment_options.route_to_next_page else true

    element.find('iframe').bind 'load', (event) =>
      url = scope.bb.total.$href('new_payment') if scope.bb && scope.bb.total && scope.bb.total.$href('new_payment')
      origin = getHost(url)
      sendLoadEvent(element, origin, scope)
      scope.$apply ->
        scope.callSetLoaded()

    $window.addEventListener 'message', (event) =>
      if angular.isObject(event.data)
        data = event.data
      else if not event.data.match(/iFrameSizer/)
        data = JSON.parse event.data
      scope.$apply =>
        if data
          switch data.type
            when "submitting"
              scope.callNotLoaded()
            when "error"
              scope.$emit "payment:failed"
              scope.callNotLoaded()
              AlertService.raise('PAYMENT_FAILED')
              # reload the payment iframe
              document.getElementsByTagName("iframe")[0].src += ''
            when "payment_complete"
              scope.callSetLoaded()
              scope.paymentDone()

    , false


angular.module('BB.Controllers').controller 'Payment', ($scope,  $rootScope,
  $q, $location, $window, $sce, $log, $timeout, LoadingService) ->

  $scope.controller = "public.controllers.Payment"

  loader = LoadingService.$loader($scope).notLoaded()

  $scope.bb.total = $scope.purchase if $scope.purchase

  $rootScope.connection_started.then ->
    $scope.bb.total = $scope.total if $scope.total
    $scope.url = $sce.trustAsResourceUrl($scope.bb.total.$href('new_payment')) if $scope.bb and $scope.bb.total and $scope.bb.total.$href('new_payment')

  ###**
  * @ngdoc method
  * @name callNotLoaded
  * @methodOf BB.Directives:bbPayment
  * @description
  * Set not loaded state
  ###
  $scope.callNotLoaded = () =>
    loader.notLoaded()


  ###**
  * @ngdoc method
  * @name callSetLoaded
  * @methodOf BB.Directives:bbPayment
  * @description
  * Set loaded state
  ###
  $scope.callSetLoaded = () =>
    loader.setLoaded()


  ###**
  * @ngdoc method
  * @name paymentDone
  * @methodOf BB.Directives:bbPayment
  * @description
  * Handles payment success
  ###
  $scope.paymentDone = () ->
    $scope.bb.payment_status = "complete"
    $scope.$emit('payment:complete')
    $scope.decideNextPage() if $scope.route_to_next_page


  $scope.error = (message) ->
    $log.warn("Payment Failure: " + message)

