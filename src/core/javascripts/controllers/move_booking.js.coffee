angular.module('BB.Directives').directive 'bbMoveBooking', ($q, $templateCache, $compile) ->
  restrict: 'AE'
  replace: true
  scope : true
  templateUrl: '_move_booking.html'
  controller : 'MoveBooking'

angular.module('BB.Controllers').controller 'MoveBooking', ($scope, $attrs, $rootScope,
  PurchaseBookingService, AlertService, BBModel, $translate, GeneralOptions, PurchaseService, LoadingService, AppService) ->

  loader = LoadingService.$loader($scope)

  ###**
  * @ngdoc method
  * @name confirMmove
  * @methodOf BB.Directives:bbMoveBooking
  * @description
  * Confirm move question information has been correctly entered here
  *
  * @param {string=} route A specific route to load
  ###
  $scope.confirmMove = (route) ->

    $scope.item ||= $scope.bb.current_item
    # we need to validate the question information has been correctly entered here
    $scope.item.setAskedQuestions()
    if $scope.item.ready
      loader.notLoaded()
      if AppService.moving_booking
        params =
          purchase: AppService.moving_booking
          bookings: $scope.bb.basket.items
        if $scope.bb.current_item.move_reason
          params.move_reason = $scope.bb.current_item.move_reason
        PurchaseService.update(params).then (purchase) ->
          AppService.purchase = purchase
          AppService.$getBookings().then (bookings)->
            $scope.purchase = purchase
            loader.setLoaded()
            $rootScope.$broadcast "booking:moved"
            $scope.decideNextPage(route)
            $scope.showMoveMessage(bookings[0].datetime)


        , (err) ->
           loader.setLoaded()
           AlertService.add("danger", { msg: "Failed to move booking. Please try again." })
      else
        if $scope.bb.current_item.move_reason
          $scope.item.move_reason = $scope.bb.current_item.move_reason
        PurchaseBookingService.update($scope.item).then (booking) ->
          b = new BBModel.Purchase.Booking(booking)

          if $scope.bb.purchase
            for oldb, _i in $scope.bb.purchase.bookings
              $scope.bb.purchase.bookings[_i] = b if oldb.id == b.id

          loader.setLoaded()
          $rootScope.$broadcast "booking:moved"
          $scope.decideNextPage(route)
          $scope.showMoveMessage(b.datetime)
         , (err) =>
          loader.setLoaded()
          AlertService.add("danger", { msg: "Failed to move booking. Please try again." })
    else
      $scope.decideNextPage(route)


  $scope.showMoveMessage = (datetime) ->
    # TODO remove whem translate enabled by default
    if GeneralOptions.use_i18n 
      $translate('MOVE_BOOKINGS_MSG', { datetime:datetime.format('LLLL') }).then (translated_text) ->
        AlertService.add("info", { msg: translated_text })
    else
      AlertService.add("info", { msg: "Your booking has been moved to #{datetime.format('LLLL')}" })