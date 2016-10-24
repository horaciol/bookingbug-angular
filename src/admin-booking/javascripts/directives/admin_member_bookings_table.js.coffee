angular.module('BBAdminBooking').directive 'bbAdminMemberBookingsTable', ($uibModal, $log, $rootScope, $compile, $templateCache, ModalForm, BBModel, Dialog, AdminMoveBookingPopup) ->

  controller = ($document, $scope, $uibModal) ->

    $scope.loading = true

    $scope.fields ||= ['date_order', 'details']

    $scope.$watch 'member', (member) ->
      getBookings($scope, member) if member?

    $scope.edit = (id) ->
      booking = _.find $scope.booking_models, (b) -> b.id == id
      booking.$getAnswers().then (answers) ->
        for answer in answers.answers
          booking["question#{answer.question_id}"] = answer.value
        ModalForm.edit
          model: booking
          title: 'Booking Details'
          templateUrl: 'edit_booking_modal_form.html'
          success: (response) ->
            if typeof response == 'string'
              if response == "move"
                item_defaults = {person:booking.person_id, resource:booking.resource_id}
                AdminMoveBookingPopup.open
                  item_defaults: item_defaults
                  company_id: booking.company_id
                  booking_id: booking.id
                  success: (model) =>
                    updateBooking(booking)
                  fail: (model) =>
                    updateBooking(booking)
            else
              updateBooking(booking)


    updateBooking = (b) ->
      b.$refetch().then (b) ->
        b = new BBModel.Admin.Booking(b)
        i =_.indexOf($scope.booking_models, (b) -> b.id == id)
        $scope.booking_models[i] = b
        $scope.setRows()

    $scope.cancel = (id) ->
      booking = _.find $scope.booking_models, (b) -> b.id == id

      modalInstance = $uibModal.open
        templateUrl: 'member_bookings_table_cancel_booking.html'
        controller: ($scope, $uibModalInstance, booking) ->
          $scope.booking = booking
          $scope.booking.notify = true
          $scope.ok = () ->
            $uibModalInstance.close($scope.booking)
          $scope.close = () ->
            $uibModalInstance.dismiss()
        scope: $scope
        resolve:
          booking: () -> booking

      modalInstance.result.then (booking) ->
        $scope.loading = true
        params =
          notify: booking.notify
        booking.$post('cancel', params).then () ->
          i =_.findIndex($scope.booking_models, (b) -> console.log(b); b.id == booking.id)
          $scope.booking_models.splice(i, 1)
          $scope.setRows()
          $scope.loading = false

    $scope.setRows = () ->
      $scope.bookings = _.map $scope.booking_models, (booking) ->
        id: booking.id
        date: moment(booking.datetime).format('YYYY-MM-DD')
        date_order: moment(booking.datetime).format('x')
        datetime: moment(booking.datetime)
        details: booking.full_describe

    getBookings = ($scope, member) ->
      params =
        start_date : $scope.startDate.format('YYYY-MM-DD')
        start_time : $scope.startTime.format('HH:mm') if $scope.startTime
        end_date   : $scope.endDate.format('YYYY-MM-DD') if $scope.endDate
        end_time   : $scope.endTime.format('HH:mm') if $scope.endTime
        company    : $rootScope.bb.company
        url        : $rootScope.bb.api_url
        client_id  : member.id
        skip_cache : true


      BBModel.Admin.Booking.$query(params).then (bookings) ->
        now = moment().unix()
        if $scope.period && $scope.period == "past"
          $scope.booking_models = _.filter bookings.items, (x) ->
            x.datetime.unix() < now
        else if $scope.period && $scope.period == "future"
          $scope.booking_models = _.filter bookings.items, (x) ->
            x.datetime.unix() > now
        else
          $scope.booking_models = bookings.items
        $scope.setRows()
        $scope.loading = false
      , (err) ->
        $log.error err.data
        $scope.loading = false

    $scope.startDate ||= moment()

    $scope.orderBy = $scope.defaultOrder
    if not $scope.orderBy?
      $scope.orderBy = 'date_order'

    $scope.now = moment()

    getBookings($scope, $scope.member) if $scope.member

  {
    controller: controller
    templateUrl: 'admin_member_bookings_table.html'
    scope:
      apiUrl:       '@'
      fields:       '=?'
      member:       '='
      startDate:    '=?'
      startTime:    '=?'
      endDate:      '=?'
      endTime:      '=?'
      defaultOrder: '=?'
      period:       '@'
  }
