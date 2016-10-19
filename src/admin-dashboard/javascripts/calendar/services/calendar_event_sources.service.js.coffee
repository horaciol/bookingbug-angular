'use strict'

###
* @ngdoc service
* @name BBAdminDashboard.calendar.services.service:CalendarEventSources
*
* @description
* This services exposes methods to get all event-type information to be shown in the calendar
###
angular.module('BBAdminDashboard.calendar.services').service 'CalendarEventSources', (AdminScheduleService, BBModel,
  $exceptionHandler, $q, TitleAssembler, $translate) ->
  'ngInject'

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
  getBookingsAndBlocks = (company, start, end, options = {})->
    deferred = $q.defer()

    params =
      company: company
      start_date: start.format('YYYY-MM-DD')
      end_date: end.format('YYYY-MM-DD')
      skip_cache: if options.noCache? and options.noCache then true else false

    BBModel.Admin.Booking.$query(params).then (bookings) ->
      filteredBookings = []

      for booking in bookings.items

        booking.service_name = $translate.instant(booking.service_name)

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

          ## if we're limiting to peopel or resoures - check this is correct
          if !options.type || (options.type == "resource" && booking.resource_id ) || (options.type == "person" && booking.person_id )
            filteredBookings.push booking

      deferred.resolve filteredBookings

    , (err)->
      deferred.reject err

    return deferred.promise

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
  getExternalBookings = (company, start, end, options = {})->
    deferred = $q.defer()
    if company.$has('external_bookings')
      params =
        start: start.format()
        end: end.format()
        no_cache: if options.noCache? and options.noCache then true else false
      company.$get('external_bookings', params).then (collection) ->
        bookings = collection.external_bookings
        if bookings
          for booking in bookings
            booking.resourceIds = []
            if booking.person_id?
              booking.resourceIds.push booking.person_id + '_p'

            if booking.resource_id?
              booking.resourceIds.push booking.resource_id + '_r'

            booking.title ||= "Blocked"
            if options.externalLabelAssembler?
              booking.title = TitleAssembler.getTitle(booking, options.externalLabelAssembler)

            booking.className = 'status_external'
            booking.type = 'external'
            booking.editable = false
            booking.startEditable = false
            booking.durationEditable = false
            booking.resourceEditable = false

          deferred.resolve bookings
        else
          deferred.resolve []
      , (err)->
        deferred.reject err
    else
      deferred.resolve []
    return deferred.promise

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
  getAvailabilityBackground = (company, start, end, options = {})->
    deferred = $q.defer()

    AdminScheduleService.getAssetsScheduleEvents(company, start, end, !options.showAll, options.selectedResources).then (availabilities) ->
      if options.calendarView == 'timelineDay'
        deferred.resolve availabilities
      else
        overAllAvailabilities = []

     
        for avail in availabilities
          avail.unix_start = moment(avail.start).unix()
          avail.unix_end = moment(avail.end).unix()
          avail.delete_me = false


        sorted = _.sortBy availabilities, (x) -> moment(x.start).unix()

        id = 0
        test_id = 1

        while test_id < (sorted.length)
          src = sorted[id]
          test = sorted[test_id]
          console.log(id, test_id, src)
          if !src.delete_me
            if test.unix_end > src.unix_end && test.unix_start < src.unix_end
              src.end = test.end
              src.unix_end = test.unix_end
              test.delete_me = true
              test_id += 1
            else if test.unix_end <= src.unix_end 
              # it's inside - just delete it
              test.delete_me = true
              test_id +=1
            else
              id +=1
              test_id +=1
          else
            id +=1
            test_id = id+1


        for availability in sorted
          if !availability.delete_me
            overAllAvailabilities.push {
              start: availability.start
              end: availability.end
              rendering: "background"
              title: "Joined availability " + moment(availability.start).format('YYYY-MM-DD')
              allDay: if options.calendarView == 'month' then true else false
            }


        console.log overAllAvailabilities


        deferred.resolve overAllAvailabilities
    , (err)->
      deferred.reject err

    return deferred.promise

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
  getAllCalendarEntries = (company, start, end, options = {})->
    deferred = $q.defer()

    promises = [
      getBookingsAndBlocks(company, start, end, options),
      getExternalBookings(company, start, end, options),
      getAvailabilityBackground(company, start, end, options),
    ]

    $q.all(promises).then (resolutions)->
      allResults = []
      angular.forEach resolutions, (results, index)->
        allResults = allResults.concat results

      deferred.resolve allResults
    , (err)->
      deferred.reject err

    return deferred.promise

  return {
    getBookingsAndBlocks: getBookingsAndBlocks
    getExternalBookings: getExternalBookings
    getAvailabilityBackground: getAvailabilityBackground
    getAllCalendarEntries: getAllCalendarEntries
  }

