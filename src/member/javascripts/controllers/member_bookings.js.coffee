angular.module('BBMember').controller 'MemberBookings', ($scope, $modal, $log, MemberBookingService, $q, ModalForm, MemberPrePaidBookingService, $rootScope, AlertService, PurchaseService) ->

  $scope.getUpcomingBookings = () ->

    defer = $q.defer()

    now = moment()
    params =
      start_date: now.toISODate()
    getBookings(params).then (results) ->
      $scope.upcoming_bookings = results.filter (result) -> result.datetime.isAfter(now)
      defer.resolve($scope.upcoming_bookings)
    , (err) ->
      defer.reject([])

    return defer.promise


  $scope.getPastBookings = (num, type) ->

    defer = $q.defer()

    # default to year in the past if no amount is specified
    if num and type
      date = moment().subtract(num, type)
    else
      date = moment().subtract(1, 'year')
    params =
      start_date: date.format('YYYY-MM-DD')
      end_date: moment().add(1,'day').format('YYYY-MM-DD')
    getBookings(params).then (past_bookings) ->

      $scope.past_bookings = _.chain(past_bookings)
        .filter((b) -> b.datetime.isBefore(moment()))
        .sortBy((b) -> -b.datetime.unix())
        .value()

      defer.resolve(past_bookings)
    , (err) ->
      defer.reject([])

    return defer.promise


  $scope.flushBookings = () ->
    params =
      start_date: moment().format('YYYY-MM-DD')
    MemberBookingService.flush($scope.member, params)

  updateBookings = () ->
    $scope.getUpcomingBookings()

  getBookings = (params) ->
    $scope.notLoaded $scope
    defer = $q.defer()
    MemberBookingService.query($scope.member, params).then (bookings) ->
      $scope.setLoaded $scope
      defer.resolve(bookings)
    , (err) ->
      $log.error err.data
      $scope.setLoaded $scope
    return defer.promise


  $scope.cancelBooking = (booking) ->

    index = _.indexOf($scope.upcoming_bookings, booking)

    return false if index is -1

    $scope.upcoming_bookings.splice(index, 1)
    AlertService.raise('BOOKING_CANCELLED')

    MemberBookingService.cancel($scope.member, booking).then () ->
      $rootScope.$broadcast("booking:cancelled")
      # does a removeBooking method exist in the scope chain?
      $scope.removeBooking(booking) if $scope.removeBooking
    , (err) ->
      AlertService.raise('GENERIC')
      $scope.upcoming_bookings.splice(index, 0, booking)


  $scope.getPrePaidBookings = (params) ->
    
    defer = $q.defer()

    MemberPrePaidBookingService.query($scope.member, params).then (bookings) ->
      $scope.pre_paid_bookings = bookings
      defer.resolve(bookings)
    , (err) ->
      defer.reject([])
      $log.error err.data

    return defer.promise


  bookWaitlistSucces = () ->
    AlertService.raise('WAITLIST_ACCEPTED')
    updateBookings()


  openPaymentModal = (booking, total) ->
    modalInstance = $modal.open
      templateUrl: "booking_payment_modal.html"
      windowClass: "bbug"
      size: "lg"
      controller: ($scope, $rootScope, $modalInstance, booking, total, notLoaded, setLoaded) ->
        
        $scope.booking = booking
        $scope.total = total
        $scope.notLoaded = notLoaded
        $scope.setLoaded = setLoaded

        $scope.handlePaymentSuccess = () ->
          $modalInstance.close(booking)

        $scope.cancel = ->
          $modalInstance.dismiss "cancel"
    
      resolve:
        booking: -> booking
        total: -> total
        notLoaded: -> $scope.notLoaded
        setLoaded: -> $scope.setLoaded

    modalInstance.result.then (booking) ->
      bookWaitlistSucces()


  edit: (booking) ->
    booking.getAnswersPromise().then (answers) ->
      for answer in answers.answers
        booking["question#{answer.question_id}"] = answer.value
      ModalForm.edit
        model: booking
        title: 'Booking Details'
        templateUrl: 'edit_booking_modal_form.html'
        windowClass: 'member_edit_booking_form'
        success: updateBookings


  cancel: (booking) ->
    modalInstance = $modal.open
      templateUrl: "member_booking_delete_modal.html"
      windowClass: "bbug"
      controller: ($scope, $rootScope, $modalInstance, booking) ->
        $scope.controller = "ModalDelete"
        $scope.booking = booking

        $scope.confirm_delete = () ->
          $modalInstance.close(booking)

        $scope.cancel = ->
          $modalInstance.dismiss "cancel"
      resolve:
        booking: ->
          booking
    modalInstance.result.then (booking) ->
      $scope.cancelBooking(booking)


  book: (booking) ->
   
    $scope.notLoaded $scope

    params =
      purchase_id: booking.purchase_ref
      url_root: $rootScope.bb.api_url
      booking: booking

    PurchaseService.bookWaitlistItem(params).then (purchase_total) ->
      if purchase_total.due_now > 0 
        if purchase_total.$has('new_payment')
          openPaymentModal(booking, purchase_total)
        else
          $log.error "total is missing new_payment link, this is usually caused by online payment not being configured correctly"
      else
        bookWaitlistSucces()
    , (err) ->
      AlertService.raise('NO_WAITLIST_SPACES_LEFT')
    $scope.setLoaded $scope
