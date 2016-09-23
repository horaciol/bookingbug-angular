'use strict'

angular.module('BBAdminDashboard.calendar.directives').directive 'bbResourceCalendar', (
    uiCalendarConfig, AdminCompanyService, $q, ModalForm, BBModel,
    AdminBookingPopup, AdminMoveBookingPopup, $window, $bbug, ColorPalette, Dialog,
    $timeout, $compile, $templateCache, PrePostTime, $filter) ->

  controller = ($scope, $rootScope, $attrs, BBAssets, ProcessAssetsFilter, $state, GeneralOptions, AdminCalendarOptions, CalendarEventSources, TitleAssembler, $translate) ->

    setTimeToMoment = (date, time)->
      newDate = moment(time,'HH:mm')
      newDate.set({
        'year'   : parseInt(date.get('year'))
        'month'  : parseInt(date.get('month'))
        'date'   : parseInt(date.get('date'))
        'second' : 0
      })
      newDate

    filters = {
      requestedAssets : ProcessAssetsFilter($state.params.assets)
    }

    $scope.showAll = true
    if filters.requestedAssets.length > 0
      $scope.showAll = false

    $scope.eventSources = [
      events: (start, end, timezone, callback) ->
        $scope.loading = true
        $scope.getCompanyPromise().then (company) ->
          options =
            labelAssembler         : if $scope.labelAssembler then $scope.labelAssembler else AdminCalendarOptions.bookings_label_assembler
            blockLabelAssembler    : if $scope.blockLabelAssembler then $scope.blockLabelAssembler else AdminCalendarOptions.block_label_assembler
            externalLabelAssembler : if $scope.externalLabelAssembler then $scope.externalLabelAssembler else AdminCalendarOptions.external_label_assembler
            noCache                : true
            showAll                : $scope.showAll
            selectedResources      : $scope.selectedResources.selected
            calendarView           : uiCalendarConfig.calendars.resourceCalendar.fullCalendar('getView').type

          CalendarEventSources.getAllCalendarEntries(company, start, end, options).then (results)->
            $scope.loading  = false
            return callback(results)
    ]

    $scope.options = $scope.$eval $attrs.bbResourceCalendar
    $scope.options ||= {}



    # height = if $scope.options.header_height
    #   $bbug($window).height() - $scope.options.header_height
    # else
    #   800

    if not $scope.options.min_time?
      $scope.options.min_time = GeneralOptions.calendar_min_time

    if not $scope.options.max_time?
      $scope.options.max_time = GeneralOptions.calendar_max_time

    if not $scope.options.cal_slot_duration?
      $scope.options.cal_slot_duration = GeneralOptions.calendar_slot_duration

    # @todo REPLACE ALL THIS WITH VAIABLES FROM THE GeneralOptions Service
    $scope.uiCalOptions =
      calendar:
        locale: $translate.use()
        schedulerLicenseKey: '0598149132-fcs-1443104297'
        eventStartEditable: false
        eventDurationEditable: false
        minTime: $scope.options.min_time
        maxTime: $scope.options.max_time
        height: 'auto'
        buttonText: {
          today: $translate.instant('ADMIN_DASHBOARD.CALENDAR_PAGE.TODAY')
        }
        header:
          left: 'today,prev,next'
          center: 'title'
          right: 'timelineDay,listDay,timelineDayThirty,agendaWeek,month'
        defaultView: 'timelineDay'
        views:
          listDay:
             buttonText: $translate.instant('ADMIN_DASHBOARD.CALENDAR_PAGE.AGENDA')
          agendaWeek:
            slotDuration: $filter('minutesToString')($scope.options.cal_slot_duration)
            buttonText: $translate.instant('ADMIN_DASHBOARD.CALENDAR_PAGE.WEEK')
            groupByDateAndResource: false
          month:
            eventLimit: 5
            buttonText: $translate.instant('ADMIN_DASHBOARD.CALENDAR_PAGE.MONTH')
          timelineDay:
            slotDuration: $filter('minutesToString')($scope.options.cal_slot_duration)
            eventOverlap: false
            slotWidth: 25
            buttonText: $translate.instant('ADMIN_DASHBOARD.CALENDAR_PAGE.DAY', {minutes: $scope.options.cal_slot_duration})
            resourceAreaWidth: '18%'
        resourceGroupField: 'group'
        resourceLabelText: ' '
        eventResourceEditable: true
        selectable: true
        lazyFetching: false
        columnFormat: AdminCalendarOptions.column_format
        resources: (callback) ->
          getCalendarAssets(callback)
        eventDragStop: (event, jsEvent, ui, view) ->
          event.oldResourceIds = event.resourceIds
        eventDrop: (event, delta, revertFunc) ->
          # we need a full move cal if either it has a person and resource, or they've dragged over multiple days
          if false && event.person_id && event.resource_id || delta.days() > 0
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

            $scope.getCompanyPromise().then (company) ->
              AdminMoveBookingPopup.open
                min_date: setTimeToMoment(start,$scope.options.min_time)
                max_date: setTimeToMoment(end,$scope.options.max_time)
                from_datetime: moment(start.toISOString())
                to_datetime: moment(end.toISOString())
                item_defaults: item_defaults
                company_id: company.id
                booking_id: event.id
                success: (model) =>
                  $scope.refreshBooking(event)
                fail: () ->
                  $scope.refreshBooking(event)
            return

            # if it's got a person and resource - then it
          Dialog.confirm
            title: $translate.instant('ADMIN_DASHBOARD.CALENDAR_PAGE.MOVE_MODAL_TITLE')
            model: event
            body: $translate.instant('ADMIN_DASHBOARD.CALENDAR_PAGE.MOVE_MODAL_BODY')
            success: (model) =>
              $scope.updateBooking(event)
            fail: () ->
              revertFunc()
        eventClick: (event, jsEvent, view) ->
          if event.$has('edit')
            $scope.editBooking(new BBModel.Admin.Booking(event))
        eventRender: (event, element) ->
          service = _.findWhere($scope.services, {id: event.service_id})
          if uiCalendarConfig.calendars.resourceCalendar.fullCalendar('getView').type == "listDay"
            link = $bbug(element.children()[2])
            if link
              a = link.children()[0]
              if a
                if event.person_name
                  a.innerHTML = event.person_name + " - " + a.innerHTML
          else if service
            element.css('background-color', service.color)
            element.css('color', service.textColor)
            element.css('border-color', service.textColor)
          element
        eventAfterRender: (event, elements, view) ->
          if not event.rendering? or event.rendering != 'background'
            PrePostTime.apply(event, elements, view, $scope)
        select: (start, end, jsEvent, view, resource) ->
          # For some reason clicking on the scrollbars triggers this event
          #  therefore we filter based on the jsEvent target
          if jsEvent.target.className == 'fc-scroller'
            return

          view.calendar.unselect()

          if isTimeRangeAvailable(start, end, resource) || (Math.abs(start.diff(end, 'days')) == 1 && dayHasAvailability(start))

            if Math.abs(start.diff(end, 'days')) > 0
              end.subtract(1,'days')
              end = setTimeToMoment(end,$scope.options.max_time)

            item_defaults =
              date: start.format('YYYY-MM-DD')
              time: (start.hour() * 60 + start.minute())

            if resource && resource.type == 'person'
              item_defaults.person = resource.id.substring(0, resource.id.indexOf('_'))
            else if resource && resource.type == 'resource'
              item_defaults.resource = resource.id.substring(0, resource.id.indexOf('_'))

            $scope.getCompanyPromise().then (company) ->
              AdminBookingPopup.open
                min_date: setTimeToMoment(start,$scope.options.min_time)
                max_date: setTimeToMoment(end,$scope.options.max_time)
                from_datetime: moment(start.toISOString())
                to_datetime: moment(end.toISOString())
                item_defaults: item_defaults
                first_page: "quick_pick"
                company_id: company.id
        viewRender: (view, element) ->
          date = uiCalendarConfig.calendars.resourceCalendar.fullCalendar('getDate')
          newDate = moment().tz(moment.tz.guess())
          newDate.set({
            'year'   : parseInt(date.get('year'))
            'month'  : parseInt(date.get('month'))
            'date'   : parseInt(date.get('date'))
            'hour' : 0
            'minute' : 0
            'second' : 0
          })
          $scope.currentDate = newDate.toDate()
        eventResize: (event, delta, revertFunc, jsEvent, ui, view) ->
          event.duration = event.end.diff(event.start, 'minutes')
          $scope.updateBooking(event)
        loading: (isLoading, view) ->
          $scope.calendarLoading = isLoading

    isTimeRangeAvailable = (start, end, resource) ->
      st =  moment(start.toISOString()).unix()
      en =  moment(end.toISOString()).unix()
      events = uiCalendarConfig.calendars.resourceCalendar.fullCalendar('clientEvents', (event)->
        event.rendering == 'background' && st >= event.start.unix() && event.end && en <= event.end.unix() && ((resource && parseInt(event.resourceId) == parseInt(resource.id)) || !resource)
      )

      events.length > 0

    dayHasAvailability = (start)->
      events = uiCalendarConfig.calendars.resourceCalendar.fullCalendar('clientEvents', (event)->
        event.rendering == 'background' && event.start.year() == start.year() && event.start.month() == start.month() && event.start.date() == start.date()
      )

      events.length > 0

    $scope.getCompanyPromise = () ->
      defer = $q.defer()
      if $scope.company
        defer.resolve($scope.company)
      else
        AdminCompanyService.query($attrs).then (company) ->
          $scope.company = company
          defer.resolve($scope.company)
      defer.promise

    # All optionassetss (resources, people) go to the same select
    $scope.assets = []
    $scope.selectedResources = {
      selected: []
    }

    $scope.changeSelectedResources = ()->
      if $scope.showAll
        $scope.selectedResources.selected = []

      uiCalendarConfig.calendars.resourceCalendar.fullCalendar('refetchResources')
      uiCalendarConfig.calendars.resourceCalendar.fullCalendar('refetchEvents')

    $scope.getCompanyPromise().then (company) ->
      $scope.loading = true

      BBAssets(company).then((assets)->
        for asset in assets
          asset.id = asset.identifier
        $scope.loading = false

        if $scope.options.type
          assets = _.filter assets, (a) -> a.type == $scope.options.type
        $scope.assets = assets

        # requestedAssets
        if filters.requestedAssets.length > 0
          angular.forEach($scope.assets, (asset)->
            isInArray = _.find(filters.requestedAssets, (id)->
              return id == asset.id
            )

            if typeof isInArray != 'undefined'
              $scope.selectedResources.selected.push asset
          )

          $scope.changeSelectedResources()
      )

    $scope.$watch 'selectedResources.selected', (newValue, oldValue) ->
      if newValue != oldValue
        assets = []
        angular.forEach(newValue, (asset)->
          assets.push asset.id
        )

        params = $state.params
        params.assets = assets.join()
        $state.go($state.current.name, params, { notify:false, reload:false})

    getCalendarAssets = (callback) ->
      $scope.loading = true

      $scope.getCompanyPromise().then (company) ->
        if $scope.showAll
          BBAssets(company).then((assets)->
            if $scope.options.type
              assets = _.filter assets, (a) -> a.type == $scope.options.type

            for asset in assets
              asset.id = asset.identifier
              asset.group = $translate.instant('ADMIN_DASHBOARD.CALENDAR_PAGE.' + asset.group.toUpperCase())

            $scope.loading = false
            callback(assets)
          )
        else
          $scope.loading = false
          callback($scope.selectedResources.selected)

    getBookingTitle = (booking)->
      labelAssembler      = if $scope.labelAssembler then $scope.labelAssembler else AdminCalendarOptions.bookings_label_assembler
      blockLabelAssembler = if $scope.blockLabelAssembler then $scope.blockLabelAssembler else AdminCalendarOptions.block_label_assembler

      if booking.status != 3 && labelAssembler
        return TitleAssembler.getTitle(booking, labelAssembler)
      else if booking.status == 3 && blockLabelAssembler
        return TitleAssembler.getTitle(booking, blockLabelAssembler)

      booking.title

    $scope.refreshBooking = (booking) ->

      booking.$refetch().then (response) ->
        booking.resourceIds = []
        booking.resourceId = null
        if booking.person_id?
          booking.resourceIds.push booking.person_id + '_p'
        if booking.resource_id?
          booking.resourceIds.push booking.resource_id + '_r'

        booking.title = getBookingTitle(booking)

        uiCalendarConfig.calendars.resourceCalendar.fullCalendar('updateEvent', booking)


    $scope.updateBooking = (booking) ->
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

        uiCalendarConfig.calendars.resourceCalendar.fullCalendar('updateEvent', booking)

    $scope.editBooking = (booking) ->
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
              item_defaults = {person:booking.person_id, resource:booking.resource_id}
              $scope.getCompanyPromise().then (company) ->
                AdminMoveBookingPopup.open
                  item_defaults: item_defaults
                  company_id: company.id
                  booking_id: booking.id
                  success: (model) =>
                    $scope.refreshBooking(booking)
                  fail: () ->
                    $scope.refreshBooking(booking)
          if response.is_cancelled
            uiCalendarConfig.calendars.resourceCalendar.fullCalendar('removeEvents', [response.id])
          else
            booking.title = getBookingTitle(booking)
            uiCalendarConfig.calendars.resourceCalendar.fullCalendar('updateEvent', booking)

    pusherBooking = (res) ->
      if res.id?
        booking = _.first(uiCalendarConfig.calendars.resourceCalendar.fullCalendar('clientEvents', res.id))
        if booking && booking.$refetch
          booking.$refetch().then () ->
            booking.title = getBookingTitle(booking)
            uiCalendarConfig.calendars.resourceCalendar.fullCalendar('updateEvent', booking)
        else
          uiCalendarConfig.calendars.resourceCalendar.fullCalendar('refetchEvents')

    $scope.pusherSubscribe = () =>
      if $scope.company
        pusher_channel = $scope.company.getPusherChannel('bookings')
        if pusher_channel
          pusher_channel.bind 'create', pusherBooking
          pusher_channel.bind 'update', pusherBooking
          pusher_channel.bind 'destroy', pusherBooking

    $scope.openDatePicker = ($event) ->
        $event.preventDefault()
        $event.stopPropagation()
        $scope.datePickerOpened = true

    $scope.updateDate = (date) ->
      if uiCalendarConfig.calendars.resourceCalendar
        assembledDate = moment.utc()
        assembledDate.set({
          'year': parseInt(date.getFullYear())
          'month': parseInt(date.getMonth())
          'date': parseInt(date.getDate())
          'hour': 0
          'minute': 0
          'second': 0,
        })

        uiCalendarConfig.calendars.resourceCalendar.fullCalendar('gotoDate', assembledDate)

    $scope.lazyUpdateDate = _.debounce($scope.updateDate, 400)

    $scope.datePickerOptions = {showButtonBar: false}

    $scope.$watch 'currentDate', (newDate, oldDate) ->
      if newDate != oldDate && oldDate?
        $scope.lazyUpdateDate(newDate)

    $scope.$on 'refetchBookings', () ->
      uiCalendarConfig.calendars.resourceCalendar.fullCalendar('refetchEvents')

    $scope.$on 'newCheckout', () ->
      uiCalendarConfig.calendars.resourceCalendar.fullCalendar('refetchEvents')

    $rootScope.$on 'BBLanguagePicker:languageChanged', () ->
      # Horrible hack refresh page because FUllcalendar doesnt have a rerender method
      #  we have to refresh the state to load new translation
      $state.go($state.current, {}, {reload: true})
      return

  link = (scope, element, attrs) ->

    scope.getCompanyPromise().then (company) ->
      company.$get('services').then (collection) ->
        collection.$get('services').then (services) ->
          scope.services = (new BBModel.Admin.Service(s) for s in services)
          ColorPalette.setColors(scope.services)

    scope.getCompanyPromise().then (company) ->
      scope.pusherSubscribe()

    $timeout () ->
      uiCalElement = angular.element(document.getElementById('uicalendar'))
      toolbarElement = angular.element(uiCalElement.children()[0])
      toolbarLeftElement = angular.element(toolbarElement.children()[0])
      datePickerElement = $compile($templateCache.get('calendar_date_picker.html'))(scope)
      toolbarLeftElement.append(datePickerElement)
    , 0

  {
    controller: controller
    link: link
    templateUrl: 'calendar/resource-calendar.html'
    replace: true
    scope :
      labelAssembler : '@'
      blockLabelAssembler: '@'
      externalLabelAssembler: '@'
  }

