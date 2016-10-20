'use strict';

angular.module('BBAdminDashboard.calendar.controllers').controller 'bbResourceCalendarController', (AdminBookingPopup,
  AdminCalendarOptions, AdminCompanyService, AdminMoveBookingPopup, $attrs, BBAssets, BBModel, $bbug, CalendarEventSources,
  ColorPalette, Dialog, $filter, GeneralOptions, ModalForm, PrePostTime, ProcessAssetsFilter, $q, $rootScope, $scope,
  $state, TitleAssembler, $translate, $window, uiCalendarConfig) ->
  'ngInject'

  ###jshint validthis: true ###
  vm = @

  filters = null

  company = null
  companyServices = []

  calOptions = []

  vm.assets = [] # All options sets (resources, people) go to the same select

  vm.selectedResources = {
    selected: []
  }

  init = () ->
    applyFilters()

    prepareCalOptions()
    prepareEventSources()
    prepareUiCalOptions()

    $scope.$watch 'selectedResources.selected', selectedResourcesListener
    $scope.$watch 'currentDate', currentDateListener

    $scope.$on 'refetchBookings', refetchBookingsHandler
    $scope.$on 'newCheckout', newCheckoutHandler
    $rootScope.$on 'BBLanguagePicker:languageChanged', languageChangedHandler

    getCompanyPromise().then(companyListener)

    vm.changeSelectedResources = changeSelectedResources
    return

  applyFilters = () ->
    filters = {
      requestedAssets: ProcessAssetsFilter($state.params.assets)
    }

    vm.showAll = true
    if filters.requestedAssets.length > 0
      vm.showAll = false

    return

  setTimeToMoment = (date, time)->
    newDate = moment(time, 'HH:mm')
    newDate.set({
      'year': parseInt(date.get('year'))
      'month': parseInt(date.get('month'))
      'date': parseInt(date.get('date'))
      'second': 0
    })
    return newDate

  prepareEventSources = () ->
    vm.eventSources = [
      events: getEvents
    ]
    return

  getEvents = (start, end, timezone, callback) ->
    vm.loading = true
    getCompanyPromise().then (company) ->
      options =
        labelAssembler: if $scope.labelAssembler then $scope.labelAssembler else AdminCalendarOptions.bookings_label_assembler
        blockLabelAssembler: if $scope.blockLabelAssembler then $scope.blockLabelAssembler else AdminCalendarOptions.block_label_assembler
        externalLabelAssembler: if $scope.externalLabelAssembler then $scope.externalLabelAssembler else AdminCalendarOptions.external_label_assembler
        noCache: true
        showAll: vm.showAll
        type: calOptions.type
        selectedResources: vm.selectedResources.selected
        calendarView: uiCalendarConfig.calendars[vm.calendar_name].fullCalendar('getView').type

      if $scope.model
        options.showAll = false
        options.selectedResources = [$scope.model]

      CalendarEventSources.getAllCalendarEntries(company, start, end, options).then (results)->
        vm.loading = false
        return callback(results)
    return

  prepareCalOptions = () ->
    calOptions = $scope.$eval $attrs.bbResourceCalendar
    calOptions ||= {}

    if !calOptions.defaultView
      if $scope.model
        calOptions.defaultView = 'agendaWeek'
      else
        calOptions.defaultView = 'timelineDay'

    if !calOptions.views
      if $scope.model
        calOptions.views = 'listDay,timelineDayThirty,agendaWeek,month'
      else
        calOptions.views = 'timelineDay,listDay,timelineDayThirty,agendaWeek,month'

    # height = if calOptions.header_height
    #   $bbug($window).height() - calOptions.header_height
    # else
    #   800

    if calOptions.name
      vm.calendar_name = calOptions.name
    else
      vm.calendar_name = "resourceCalendar"

    if not calOptions.min_time?
      calOptions.min_time = GeneralOptions.calendar_min_time

    if not calOptions.max_time?
      calOptions.max_time = GeneralOptions.calendar_max_time

    if not calOptions.cal_slot_duration?
      calOptions.cal_slot_duration = GeneralOptions.calendar_slot_duration

    return

  prepareUiCalOptions = () ->
    vm.uiCalOptions = # @todo REPLACE ALL THIS WITH VAIABLES FROM THE GeneralOptions Service
      calendar:
        locale: $translate.use()
        schedulerLicenseKey: '0598149132-fcs-1443104297'
        eventStartEditable: false
        eventDurationEditable: false
        minTime: calOptions.min_time
        maxTime: calOptions.max_time
        height: 'auto'
        buttonText: {
          today: $translate.instant('ADMIN_DASHBOARD.CALENDAR_PAGE.TODAY')
        }
        header:
          left: 'today,prev,next'
          center: 'title'
          right: calOptions.views
        defaultView: calOptions.defaultView
        views:
          listDay:
            buttonText: $translate.instant('ADMIN_DASHBOARD.CALENDAR_PAGE.AGENDA')
          agendaWeek:
            slotDuration: $filter('minutesToString')(calOptions.cal_slot_duration)
            buttonText: $translate.instant('ADMIN_DASHBOARD.CALENDAR_PAGE.WEEK')
            groupByDateAndResource: false
          month:
            eventLimit: 5
            buttonText: $translate.instant('ADMIN_DASHBOARD.CALENDAR_PAGE.MONTH')
          timelineDay:
            slotDuration: $filter('minutesToString')(calOptions.cal_slot_duration)
            eventOverlap: false
            slotWidth: 25
            buttonText: $translate.instant('ADMIN_DASHBOARD.CALENDAR_PAGE.DAY', {minutes: calOptions.cal_slot_duration})
            resourceAreaWidth: '18%'
        resourceGroupField: 'group'
        resourceLabelText: ' '
        eventResourceEditable: true
        selectable: true
        lazyFetching: false
        columnFormat: AdminCalendarOptions.column_format
        resources: fcResources
        eventDragStop: fcEventDragStop
        eventDrop: fcEventDrop
        eventClick: fcEventClick
        eventRender: fcEventRender
        eventAfterRender: fcEventAfterRender
        select: fcSelect
        viewRender: fcViewRender
        eventResize: fcEventResize
        loading: fcLoading
    return

  fcResources = (callback) ->
    getCalendarAssets(callback)

  fcEventDragStop = (event, jsEvent, ui, view) ->
    event.oldResourceIds = event.resourceIds

  fcEventDrop = (event, delta, revertFunc) -> # we need a full move cal if either it has a person and resource, or they've dragged over multiple days

    # not blocked and is a change in person/resource, or over multiple days
    if event.status !=3 && (event.person_id && event.resource_id || delta.days() > 0)
      start = event.start
      end = event.end
      item_defaults =
        date: start.format('YYYY-MM-DD')
        time: (start.hour() * 60 + start.minute())

      if event.resourceId
        newAssetId = event.resourceId.substring(0, event.resourceId.indexOf('_'))
        if event.resourceId.indexOf('_p') > -1
          item_defaults.person = newAssetId
          orginal_resource = "" + event.person_id + "_p"
        else if event.resourceId.indexOf('_r') > -1
          item_defaults.resource = newAssetId
          orginal_resource = "" + event.resource_id + "_r"

      getCompanyPromise().then (company) ->
        AdminMoveBookingPopup.open
          min_date: setTimeToMoment(start, calOptions.min_time)
          max_date: setTimeToMoment(end, calOptions.max_time)
          from_datetime: moment(start.toISOString())
          to_datetime: moment(end.toISOString())
          item_defaults: item_defaults
          company_id: company.id
          booking_id: event.id
          success: (model) =>
            refreshBooking(event)
          fail: () ->
            refreshBooking(event)
            revertFunc()
      return

    # if it's got a person and resource - then it
    Dialog.confirm
      title: $translate.instant('ADMIN_DASHBOARD.CALENDAR_PAGE.MOVE_MODAL_TITLE')
      model: event
      body: $translate.instant('ADMIN_DASHBOARD.CALENDAR_PAGE.MOVE_MODAL_BODY')
      success: (model) =>
        updateBooking(event)
      fail: () ->
        revertFunc()

  fcEventClick = (event, jsEvent, view) ->
    if event.$has('edit')
      editBooking(new BBModel.Admin.Booking(event))

  fcEventRender = (event, element) ->
    type = uiCalendarConfig.calendars[vm.calendar_name].fullCalendar('getView').type
    service = _.findWhere(companyServices, {id: event.service_id})
    if !$scope.model  # if not a single item view
      if type == "listDay"
        link = $bbug(element.children()[2])
        if link
          a = link.children()[0]
          if a
            if event.person_name && (!calOptions.type || calOptions.type == "person")
              a.innerHTML = event.person_name + " - " + a.innerHTML
            else if event.resource_name && calOptions.type == "resource"
              a.innerHTML = event.resource_name + " - " + a.innerHTML
      else if type == "agendaWeek" || type == "month"
        link = $bbug(element.children()[0])
        if link
          a = link.children()[1]
          if a
            if event.person_name && (!calOptions.type || calOptions.type == "person")
              a.innerHTML = event.person_name + "<br/>" + a.innerHTML
            else if event.resource_name && calOptions.type == "resource"
              a.innerHTML = event.resource_name + "<br/>" + a.innerHTML
    if service && type != "listDay"
      element.css('background-color', service.color)
      element.css('color', service.textColor)
      element.css('border-color', service.textColor)
    element

  fcEventAfterRender = (event, elements, view) ->
    if not event.rendering? or event.rendering != 'background'
      PrePostTime.apply(event, elements, view, $scope)

  fcSelect = (start, end, jsEvent, view, resource) -> # For some reason clicking on the scrollbars triggers this event therefore we filter based on the jsEvent target
    if jsEvent.target.className == 'fc-scroller'
      return

    view.calendar.unselect()

    if !calOptions.enforce_schedules || (isTimeRangeAvailable(start, end, resource) || (Math.abs(start.diff(end, 'days')) == 1 && dayHasAvailability(start)))
      if Math.abs(start.diff(end, 'days')) > 0
        end.subtract(1, 'days')
        end = setTimeToMoment(end, calOptions.max_time)

      item_defaults =
        date: start.format('YYYY-MM-DD')
        time: (start.hour() * 60 + start.minute())

      if resource && resource.type == 'person'
        item_defaults.person = resource.id.substring(0, resource.id.indexOf('_'))
      else if resource && resource.type == 'resource'
        item_defaults.resource = resource.id.substring(0, resource.id.indexOf('_'))

      getCompanyPromise().then (company) ->
        AdminBookingPopup.open
          min_date: setTimeToMoment(start, calOptions.min_time)
          max_date: setTimeToMoment(end, calOptions.max_time)
          from_datetime: moment(start.toISOString())
          to_datetime: moment(end.toISOString())
          item_defaults: item_defaults
          first_page: "quick_pick"
          on_conflict: "cancel()"
          company_id: company.id

  fcViewRender = (view, element) ->
    date = uiCalendarConfig.calendars[vm.calendar_name].fullCalendar('getDate')
    newDate = moment().tz(moment.tz.guess())
    newDate.set({
      'year': parseInt(date.get('year'))
      'month': parseInt(date.get('month'))
      'date': parseInt(date.get('date'))
      'hour': 0
      'minute': 0
      'second': 0
    })
    $scope.currentDate = newDate.toDate() #TODO other directive expect this variable on scope

  fcEventResize = (event, delta, revertFunc, jsEvent, ui, view) ->
    event.duration = event.end.diff(event.start, 'minutes')
    updateBooking(event)

  fcLoading = (isLoading, view) ->
    vm.calendarLoading = isLoading

  $scope.openDatePicker = ($event) -> #TODO other directive expect this method on scope
    $event.preventDefault()
    $event.stopPropagation()
    $scope.datePickerOpened = true

  isTimeRangeAvailable = (start, end, resource) ->
    st = moment(start.toISOString()).unix()
    en = moment(end.toISOString()).unix()
    events = uiCalendarConfig.calendars[vm.calendar_name].fullCalendar('clientEvents', (event)->
      event.rendering == 'background' && st >= event.start.unix() && event.end && en <= event.end.unix() && ((resource && parseInt(event.resourceId) == parseInt(resource.id)) || !resource)
    )
    return events.length > 0

  dayHasAvailability = (start)->
    events = uiCalendarConfig.calendars[vm.calendar_name].fullCalendar('clientEvents', (event)->
      event.rendering == 'background' && event.start.year() == start.year() && event.start.month() == start.month() && event.start.date() == start.date()
    )

    return events.length > 0

  selectedResourcesListener = (newValue, oldValue) ->
    if newValue != oldValue
      assets = []
      angular.forEach(newValue, (asset)->
        assets.push asset.id
      )

      params = $state.params
      params.assets = assets.join()
      $state.go($state.current.name, params, {notify: false, reload: false})
    return

  getCalendarAssets = (callback) ->
    if $scope.model
      callback([$scope.model])
      return

    vm.loading = true

    getCompanyPromise().then (company) ->
      if vm.showAll
        BBAssets(company).then((assets)->
          if calOptions.type
            assets = _.filter assets, (a) -> a.type == calOptions.type

          for asset in assets
            asset.id = asset.identifier
            asset.group = $translate.instant('ADMIN_DASHBOARD.CALENDAR_PAGE.' + asset.group.toUpperCase())

          vm.loading = false
          callback(assets)
        )
      else
        vm.loading = false
        callback(vm.selectedResources.selected)
      return

    return


  getBookingTitle = (booking)->
    labelAssembler = if $scope.labelAssembler then $scope.labelAssembler else AdminCalendarOptions.bookings_label_assembler
    blockLabelAssembler = if $scope.blockLabelAssembler then $scope.blockLabelAssembler else AdminCalendarOptions.block_label_assembler

    if booking.status != 3 && labelAssembler
      return TitleAssembler.getTitle(booking, labelAssembler)
    else if booking.status == 3 && blockLabelAssembler
      return TitleAssembler.getTitle(booking, blockLabelAssembler)

    return booking.title

  refreshBooking = (booking) ->
    booking.$refetch().then (response) ->
      booking.resourceIds = []
      booking.resourceId = null
      if booking.person_id?
        booking.resourceIds.push booking.person_id + '_p'
      if booking.resource_id?
        booking.resourceIds.push booking.resource_id + '_r'

      booking.title = getBookingTitle(booking)

      uiCalendarConfig.calendars[vm.calendar_name].fullCalendar('updateEvent', booking)
    return

  updateBooking = (booking) ->
    if booking.resourceId
      newAssetId = booking.resourceId.substring(0, booking.resourceId.indexOf('_'))
      if booking.resourceId.indexOf('_p') > -1
        booking.person_id = newAssetId
      else if booking.resourceId.indexOf('_r') > -1
        booking.resource_id = newAssetId

    booking.$update().then (response) ->
      booking.resourceIds = []
      booking.resourceId = null
      if booking.person_id?
        booking.resourceIds.push booking.person_id + '_p'
      if booking.resource_id?
        booking.resourceIds.push booking.resource_id + '_r'

      booking.title = getBookingTitle(booking)

      uiCalendarConfig.calendars[vm.calendar_name].fullCalendar('updateEvent', booking)
    return

  editBooking = (booking) ->
    if booking.status == 3
      templateUrl = 'edit_block_modal_form.html'
      title = 'Edit Block'
    else
      templateUrl = 'edit_booking_modal_form.html'
      title = 'Edit Booking'
    ModalForm.edit
      templateUrl: templateUrl
      model: booking
      title: title
      params:
        locale: $translate.use()
      success: (response) =>
        if typeof response == 'string'
          if response == "move"
            item_defaults = {person: booking.person_id, resource: booking.resource_id}
            getCompanyPromise().then (company) ->
              AdminMoveBookingPopup.open
                item_defaults: item_defaults
                company_id: company.id
                booking_id: booking.id
                success: (model) =>
                  refreshBooking(booking)
                fail: () ->
                  refreshBooking(booking)
        if response.is_cancelled
          uiCalendarConfig.calendars[vm.calendar_name].fullCalendar('removeEvents', [response.id])
        else
          booking.title = getBookingTitle(booking)
          uiCalendarConfig.calendars[vm.calendar_name].fullCalendar('updateEvent', booking)
    return

  pusherBooking = (res) ->
    if res.id?
      booking = _.first(uiCalendarConfig.calendars[vm.calendar_name].fullCalendar('clientEvents', res.id))
      if booking && booking.$refetch
        booking.$refetch().then () ->
          booking.title = getBookingTitle(booking)
          uiCalendarConfig.calendars[vm.calendar_name].fullCalendar('updateEvent', booking)
      else
        uiCalendarConfig.calendars[vm.calendar_name].fullCalendar('refetchEvents')
    return

  pusherSubscribe = () =>
    if company
      pusher_channel = company.getPusherChannel('bookings')
      if pusher_channel
        pusher_channel.bind 'create', pusherBooking
        pusher_channel.bind 'update', pusherBooking
        pusher_channel.bind 'destroy', pusherBooking
    return

  updateDate = (date) ->
    if uiCalendarConfig.calendars[vm.calendar_name]
      assembledDate = moment.utc()
      assembledDate.set({
        'year': parseInt(date.getFullYear())
        'month': parseInt(date.getMonth())
        'date': parseInt(date.getDate())
        'hour': 0
        'minute': 0
        'second': 0,
      })

      uiCalendarConfig.calendars[vm.calendar_name].fullCalendar('gotoDate', assembledDate)
    return

  lazyUpdateDate = _.debounce(updateDate, 400)

  currentDateListener = (newDate, oldDate) ->
    if newDate != oldDate && oldDate?
      lazyUpdateDate(newDate)
    return

  refetchBookingsHandler = () ->
    uiCalendarConfig.calendars[vm.calendar_name].fullCalendar('refetchEvents')
    return

  newCheckoutHandler = () ->
    uiCalendarConfig.calendars[vm.calendar_name].fullCalendar('refetchEvents')
    return

  languageChangedHandler = () ->
    $state.go($state.current, {}, {reload: true}) # Horrible hack refresh page because FUllcalendar doesnt have a rerender method  we have to refresh the state to load new translation
    return

  getCompanyPromise = () ->
    defer = $q.defer()
    if company
      defer.resolve(company)
    else
      AdminCompanyService.query($attrs).then (_company) ->
        company = _company
        defer.resolve(company)
    return defer.promise

  changeSelectedResources = ()->
    if vm.showAll
      vm.selectedResources.selected = []

    uiCalendarConfig.calendars[vm.calendar_name].fullCalendar('refetchResources')
    uiCalendarConfig.calendars[vm.calendar_name].fullCalendar('refetchEvents')
    return

  assetsListener = (assets)->
    for asset in assets
      asset.id = asset.identifier
    vm.loading = false

    if calOptions.type
      assets = _.filter assets, (a) -> a.type == calOptions.type
    vm.assets = assets

    # requestedAssets
    if filters.requestedAssets.length > 0
      angular.forEach(vm.assets, (asset)->
        isInArray = _.find(filters.requestedAssets, (id)->
          return id == asset.id
        )

        if typeof isInArray != 'undefined'
          vm.selectedResources.selected.push asset
      )

      changeSelectedResources()
    return

  ###*
  # {Object} company
  ###
  companyListener = (company) ->
    vm.loading = true

    BBAssets(company).then(assetsListener)

    company.$get('services').then(collectionListener)

    pusherSubscribe()
    return

  ###*
  # {Object} baseResourceCollection
  ###
  collectionListener = (collection) ->
    collection.$get('services').then servicesListener
    return

  ###*
  # {Array.<Object>} services
  ###
  servicesListener = (services) ->
    companyServices = (new BBModel.Admin.Service(service) for service in services)
    ColorPalette.setColors(companyServices)
    return

  init()
  return