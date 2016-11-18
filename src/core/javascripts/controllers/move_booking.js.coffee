angular.module('BB.Directives').directive 'bbMoveBooking', () ->
  templateUrl: '_move_booking.html'
  scope: {
    booking: '='
    bookings: '='
  }
  controller : 'MoveBooking'
  controllerAs: 'vm'

angular.module('BB.Controllers').controller 'MoveBooking', ($scope, $attrs, $rootScope,
  PurchaseBookingService, AlertService, BBModel, $translate, GeneralOptions, PurchaseService, LoadingService, AppService) ->

  vm = @
  loader = LoadingService.$loader($scope)
  vm.item = $scope.booking
  vm.items = $scope.bookings

  ###** 
  * @ngdoc method
  * @name confirmMove
  * @methodOf BB.Directives:bbMoveBooking
  * @description
  * Confirm move question information has been correctly entered here
  *
  * @param {string=} route A specific route to load
  ###
  $scope.confirmMove = (route) ->
    console.log vm

    vm.item.moved_booking = false
    # we need to validate the question information has been correctly entered here
    vm.item.setAskedQuestions() if vm.item.setAskedQuestions()?
    if vm.item.ready
      loader.notLoaded()
      if AppService.moving_purchase
        params =
          purchase: AppService.moving_purchase
          bookings: vm.items
        if vm.item.move_reason
          params.move_reason = vm.item.move_reason
        PurchaseService.update(params).then (purchase) ->
          AppService.purchase = purchase
          AppService.purchase.$getBookings().then (bookings)->
            vm.purchase = purchase
            loader.setLoaded()
            $rootScope.$broadcast "booking:moved"
            $scope.$parent.decideNextPage(route)
            AppService.moving_booking = null
            vm.showMoveMessage(bookings[0].datetime)


        , (err) ->
           loader.setLoaded()
           AlertService.add("danger", { msg: "Failed to move booking. Please try again." })
      else
        # if $scope.booking.move_reason
        #   $scope.item.move_reason = $scope.bb.current_item.move_reason
        PurchaseBookingService.update(vm.item).then (booking) ->
          b = new BBModel.Purchase.Booking(booking)

          if AppService.purchase
            for oldb, _i in AppService.purchase.bookings
              AppService.bookings[_i] = b if oldb.id is b.id

          loader.setLoaded()
          vm.item.moved_booking = booking
          vm.item.move_done = true
          $rootScope.$broadcast "booking:moved"
          $scope.$parent.decideNextPage(route)
          AppService.moving_booking = null
          vm.showMoveMessage(b.datetime)
          console.log vm
         , (err) =>
          loader.setLoaded()
          AlertService.add("danger", { msg: "Failed to move booking. Please try again." })
    else
      $scope.$parent.decideNextPage(route)


  vm.showMoveMessage = (datetime) ->
    # TODO remove whem translate enabled by default
    if GeneralOptions.use_i18n 
      $translate('MOVE_BOOKINGS_MSG', { datetime:datetime.format('LLLL') }).then (translated_text) ->
        AlertService.add("info", { msg: translated_text })
    else
      AlertService.add("info", { msg: "Your booking has been moved to #{datetime.format('LLLL')}" })