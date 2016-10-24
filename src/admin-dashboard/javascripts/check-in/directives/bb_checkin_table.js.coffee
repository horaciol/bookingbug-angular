'use strict'

angular.module('BBAdminDashboard.check-in.directives').directive 'bbCheckinTable', () ->
  restrict: 'AE'
  replace: false
  scope : true
  templateUrl: 'check-in/checkin-table.html'
  controller : 'CheckinsController'
  link : (scope, element, attrs) ->
    return

angular.module('BBAdminDashboard.check-in.directives').controller 'CheckinsController', (
  $scope,  $rootScope, BusyService, $q, $filter, AdminTimeService, ModalForm,
  AdminSlotService, $timeout, AlertService, BBModel) ->

  $scope.$on 'refetchCheckin', (event, res) ->
    $scope.getAppointments(null, null, null, null, null  ,true)


  $scope.getAppointments = (currentPage, filterBy, filterByFields, orderBy, orderByReverse, skipCache = true) ->
    if filterByFields && filterByFields.name?
      filterByFields.name = filterByFields.name.replace(/\s/g, '')
    if filterByFields && filterByFields.mobile?
      mobile = filterByFields.mobile
      if mobile.indexOf('0') == 0
        filterByFields.mobile = mobile.substring(1)
    defer = $q.defer()
    params =
      company: $scope.company
      date: moment().format('YYYY-MM-DD')
      url: $scope.bb.api_url

    params.skip_cache = true if skipCache
    params.filter_by = filterBy if filterBy
    params.filter_by_fields = filterByFields if filterByFields
    params.order_by = orderBy if orderBy
    params.order_by_reverse = orderByReverse if orderByReverse

    BBModel.Admin.Booking.$query(params).then (res) =>
      $scope.booking_collection = res
      $scope.bookings = []
      $scope.bmap = {}
      for item in res.items
        if item.status != 3 # not blocked
          $scope.bookings.push(item.id)
          $scope.bmap[item.id] = item
      # update the items if they've changed
      $scope.booking_collection.addCallback $scope, (booking, status) =>
        $scope.bookings = []
        $scope.bmap = {}
        for item in $scope.booking_collection.items
          if item.status != 3 # not blocked
            $scope.bookings.push(item.id)
            $scope.bmap[item.id] = item
      defer.resolve($scope.bookings)
    , (err) ->
      defer.reject(err)
    defer.promise

  $scope.setStatus = (booking, status) =>
    clone = _.clone(booking)
    clone.current_multi_status = status
    booking.$update(clone).then (res) ->
      $scope.booking_collection.checkItem(res)
    , (err) ->
      AlertService.danger({msg: 'Something went wrong'})

  $scope.edit = (booking) ->
    booking.$getAnswers().then (answers) ->
      for answer in answers.answers
        booking["question#{answer.question_id}"] = answer.value
      ModalForm.edit
        model: booking
        title: 'Booking Details'
        templateUrl: 'edit_booking_modal_form.html'
        success: (b) ->
          b = new BBModel.Admin.Booking(b)
          $scope.bmap[b.id] = b

  # Make sure everytime we enter this view we skip the
  # cache to get the latest state of appointments
  $scope.getAppointments(null, null, null, null, null  ,true)
