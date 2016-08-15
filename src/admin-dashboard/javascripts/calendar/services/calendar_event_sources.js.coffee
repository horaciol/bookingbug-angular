'use strict'

###
* @ngdoc service
* @name BBAdminDashboard.calendar.services.service:CalendarEventSources
*
* @description
* This services exposes methods to get all event-type information to be shown in the calendar
###
angular.module('BBAdminDashboard.calendar.services').factory 'CalendarEventSources', [
  '$exceptionHandler', '$q', 'TitleAssembler', 'AdminBookingService', 'AdminScheduleService'
  ($exceptionHandler, $q, TitleAssembler, AdminBookingService, AdminScheduleService) ->

    bookingBelongsToSelectedResources = (resources, booking)->
      belongs = false
      _.each resources, (asset) ->
        if _.contains(booking.resourceIds, asset.id)
          belongs = true

      return belongs


    ###
    * @ngdoc method
    * @name getBookingsAndBlocks
    * @methodOf BBAdminDashboard.calendar.services.service:CalendarEventSources
    * @description
    * Returns all bookings and blocks for a certain period of time,
    * filtered by a list of resources if one is provided through the options
    *
    * @param {object} company  The company to be queried for bookings and blocks
    * @param {Moment} start    Moment object containing the start of the requested period
    * @param {Moment} end      Moment object containing the end of the requested period
    * @param {object} options  Object which contains usefull flags and params
                               The relevant ones for this method are:
                               - {boolean} noCache              skips the cache
                               - {boolean} showAll              skip the filter by resource filter
                               - {array}   selectedResources    array of selected resource to filter against
                               - {string}  labelAssembler       the pattern to use for bookings (see TitleAssembler)
                               - {string}  blockLabelAssembler  the pattern to use for blocks (see TitleAssembler)

    * @returns {Promise} Promise which once resolved returns an array of bookings and blocks
    ###
    getBookingsAndBlocks: (company, start, end, options = {})->
      deferred = $q.defer()

      params =
        company    : company
        start_date : start.format('YYYY-MM-DD')
        end_date   : end.format('YYYY-MM-DD')
        skip_cache : if options.noCache? and options.noCache then true else false

      AdminBookingService.query(params).then (bookings) ->
        filteredBookings = []

        for booking in bookings.items
          booking.resourceIds = []
          if booking.person_id?
            booking.resourceIds.push booking.person_id + '_p'
          if booking.resource_id?
            booking.resourceIds.push booking.resource_id + '_r'

          # Add to returned results is no specific resources where requested
          # or event belongs to one of the selected resources
          if not options.showAll? || (options.showAll? && options.showAll) || bookingBelongsToSelectedResources(options.selectedResources, booking)
            booking.useFullTime()
            booking.startEditable = true if booking.$has('edit')

            if booking.status != 3 && options.labelAssembler?
              booking.title = TitleAssembler.getTitle(booking, options.labelAssembler)

            else if booking.status == 3 && options.blockLabelAssembler?
              booking.title = TitleAssembler.getTitle(booking, options.blockLabelAssembler)

            filteredBookings.push booking

        deferred.resolve filteredBookings

      , (err)->
        # Handle errors
        deferred.reject err

      deferred.promise

    ###
    * @ngdoc method
    * @name getExternalBookings
    * @methodOf BBAdminDashboard.calendar.services.service:CalendarEventSources
    * @description
    * Returns all external bookings for a certain period of time
    *
    * @param {object} company  The company to be queried for bookings and blocks
    * @param {Moment} start    Moment object containing the start of the requested period
    * @param {Moment} end      Moment object containing the end of the requested period
    * @param {object} options  Object which contains usefull flags and params
                               The relevant ones for this method are:
                               - {string}  externalLabelAssembler  the pattern to use for the title (see TitleAssembler)

    * @returns {Promise} Promise which once resolved returns an array of bookings
    ###
    getExternalBookings: (company, start, end, options = {})->
      deferred = $q.defer()

      if company.$has('external_bookings')
        params =
          start    : start.format()
          end      : end.format()
          no_cache : if options.noCache? and options.noCache then true else false

        company.$get('external_bookings', params).then (collection) ->
          collection.$get('external_bookings').then (bookings) ->
            for booking in bookings
              booking.resourceIds = []
              if booking.person_id?
                booking.resourceIds.push booking.person_id + '_p'

              if booking.resource_id?
                booking.resourceIds.push booking.resource_id  + '_r'

              if options.externalLabelAssembler?
                booking.title = TitleAssembler.getTitle(booking, options.externalLabelAssembler)

              booking.className = 'status_external'
              booking.type      = 'external'

            deferred.resolve bookings
          , (err)->
            # Handle errors
            deferred.reject err
        , (err)->
          # Handle errors
          deferred.reject err
      else
        deferred.resolve []

      deferred.promise

    ###
    * @ngdoc method
    * @name getAvailabilityBackground
    * @methodOf BBAdminDashboard.calendar.services.service:CalendarEventSources
    * @description
    * Returns all availability for a certain period of time,
    * filtered by a list of resources if one is provided through the options,
    * and grouped per calendar day if in week or month view
    *
    * @param {object} company  The company to be queried for bookings and blocks
    * @param {Moment} start    Moment object containing the start of the requested period
    * @param {Moment} end      Moment object containing the end of the requested period
    * @param {object} options  Object which contains usefull flags and params
                               The relevant ones for this method are:
                               - {boolean} noCache              skips the cache
                               - {boolean} showAll              skip the filter by resource filter
                               - {array}   selectedResources    array of selected resource to filter against
                               - {string}  calendarView         identifies which view the calendar is curently displaying (enum: 'timelineDay', 'agendaWeek', 'month')

    * @returns {Promise} Promise which once resolved returns an array of availability background events
    ###
    getAvailabilityBackground: (company, start, end, options = {})->
      deferred = $q.defer()

      AdminScheduleService.getAssetsScheduleEvents(company, start, end, !options.showAll, options.selectedResources).then (availabilities) ->
        if options.calendarView == 'timelineDay'
          deferred.resolve availabilities
        else
          overAllAvailabilities = []

          angular.forEach availabilities, (availability, index)->
            dayAvailability = _.filter overAllAvailabilities, (overAllAvailability)->
              if moment(overAllAvailability.start).dayOfYear() == moment(availability.start).dayOfYear()
                return true
              return false

            if dayAvailability.length > 0
              if moment(availability.start).unix() < moment(dayAvailability[0].start).unix()
                 dayAvailability[0].start = availability.start

              if moment(availability.end).unix() > moment(dayAvailability[0].end).unix()
                dayAvailability[0].end = availability.end
            else
              overAllAvailabilities.push {
                start     : availability.start
                end       : availability.end
                rendering : "background"
                title     : "Joined availability " + moment(availability.start).format('YYYY-MM-DD')
                allDay    : if options.calendarView == 'month' then true else false
              }
          deferred.resolve overAllAvailabilities
      , (err)->
        # Handle errors
        deferred.reject err

      deferred.promise

    ###
    * @ngdoc method
    * @name getAllCalendarEntries
    * @methodOf BBAdminDashboard.calendar.services.service:CalendarEventSources
    * @description
    * Returns all event type information to be displayed in the calendar
    *
    * @param {object} company  The company to be queried for bookings and blocks
    * @param {Moment} start    Moment object containing the start of the requested period
    * @param {Moment} end      Moment object containing the end of the requested period
    * @param {object} options  Object which contains usefull flags and params (see above methodds for details)
    *
    * @returns {Promise} Promise which once resolved returns an array of availability background events
    ###
    getAllCalendarEntries: (company, start, end, options = {})->
      deferred = $q.defer()

      promises = [
        @getBookingsAndBlocks(company, start, end, options),
        @getExternalBookings(company, start, end, options),
        @getAvailabilityBackground(company, start, end, options),
      ]

      $q.all(promises).then (resolutions)->
        allResults = []
        angular.forEach resolutions, (results, index)->
          allResults = allResults.concat results

        deferred.resolve allResults
      , (err)->
        # Handle errors
        deferred.reject err

      deferred.promise
]
