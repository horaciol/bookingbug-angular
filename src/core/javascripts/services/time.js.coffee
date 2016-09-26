'use strict'

angular.module('BB.Services').factory "TimeService", ($q, BBModel, halClient,
  SettingsService, DateTimeUtilitiesService) ->

  query: (prms) ->

    deferred = $q.defer()

    start_date = null
    end_date   = null

    if prms.date
      prms.start_date = prms.date
    else if prms.cItem.date
      prms.start_date = prms.cItem.date.date
    else
      deferred.reject("No date set")
      return deferred.promise



    start_date = prms.start_date
    end_date   = prms.end_date if prms.end_date

    # Adjust time range based on UTC offset between company time zone and display time zone
    if SettingsService.getDisplayTimeZone() != SettingsService.getTimeZone()

      display_utc_offset = moment().tz(SettingsService.getDisplayTimeZone()).utcOffset()
      company_utc_offset = moment().tz(SettingsService.getTimeZone()).utcOffset()

      if company_utc_offset < display_utc_offset
        start_date = prms.start_date.clone().subtract(1, 'day')
      else if company_utc_offset > display_utc_offset and prms.end_date
        end_date = prms.end_date.clone().add(1, 'day')

      prms.time_zone = SettingsService.getDisplayTimeZone()

    # If there was no duration passed in get the default duration off the
    # current item
    if !prms.duration?
      prms.duration = prms.cItem.duration if prms.cItem && prms.cItem.duration

    item_link = prms.item_link

    if prms.cItem && prms.cItem.days_link && !item_link
      item_link = prms.cItem.days_link

    if item_link

      extra = {date: start_date.toISODate()}
      # extra.location = prms.client.addressCsvLine() if prms.client && prms.client.hasAddress()
      extra.location = prms.location if prms.location
      extra.event_id = prms.cItem.event_id if prms.cItem.event_id
      extra.person_id = prms.cItem.person.id if prms.cItem.person && !prms.cItem.anyPerson() && !item_link.event_id && !extra.event_id
      extra.resource_id = prms.cItem.resource.id if prms.cItem.resource && !prms.cItem.anyResource() && !item_link.event_id  && !extra.event_id
      extra.end_date = end_date.toISODate() if end_date
      extra.duration = prms.duration
      extra.resource_ids = prms.resource_ids
      extra.num_resources = prms.num_resources
      extra.time_zone = prms.time_zone if prms.time_zone
      extra.ignore_booking = prms.cItem.id if prms.cItem.id
      # if we have an event - the the company link - so we don't add in extra params
      item_link = prms.company if extra.event_id

      item_link.$get('times', extra).then (results) =>

        if results.$has('date_links')

          # it's a date range - we're expecting several dates - lets build up a hash of dates
          results.$get('date_links').then (all_days) =>

            date_times = {}
            all_days_def = []

            for day in all_days

              do (day) =>

                # there's several days - get them all
                day.elink = $q.defer()
                all_days_def.push(day.elink.promise)

                if day.$has('event_links')

                  day.$get('event_links').then (all_events) =>
                    times = @merge_times(all_events, prms.cItem.service, prms.cItem, day.date)
                    times = _.filter(times, (t) -> t.avail >= prms.available) if prms.available
                    day.elink.resolve(times)

                else if day.times

                  times = @merge_times([day], prms.cItem.service, prms.cItem, day.date)
                  times = _.filter(times, (t) -> t.avail >= prms.available) if prms.available
                  day.elink.resolve(times)

            $q.all(all_days_def).then (times) ->

              # build day/slot array ensuring slots are grouped by the display time zone
              date_times = _.chain(times)
                .flatten()
                .sortBy((slot) -> slot.datetime.unix())
                .groupBy((slot) -> slot.datetime.toISODate())
                .value()

              # add days back that don't have any availabiity and return originally requested range only
              new_date_times = {}
              d = prms.start_date.clone()
              while d <= prms.end_date
                key = d.toISODate()
                new_date_times[key] = if date_times[key] then date_times[key] else []
                d = d.clone().add(1, 'day')

              deferred.resolve(new_date_times)

        else if results.$has('event_links')

          # single day - but a list of bookable events
          results.$get('event_links').then (all_events) =>
            times = @merge_times(all_events, prms.cItem.service, prms.cItem, prms.start_date)
            times = _.filter(times, (t) -> t.avail >= prms.available) if prms.available

            # returns array of time slots
            deferred.resolve(times)

        else if results.times
          times = @merge_times([results], prms.cItem.service, prms.cItem, prms.start_date)
          times = _.filter(times, (t) -> t.avail >= prms.available) if prms.available

          # returns array of time slots
          deferred.resolve(times)
      , (err) ->
        deferred.reject(err)

    else
      deferred.reject("No day data")

    return deferred.promise


  # query a set of basket items for the same time data
  queryItems: (prms) ->

    defer = $q.defer()

    pslots = []

    for item in prms.items
      pslots.push(@query({
        company: prms.company
        cItem: item
        date: prms.start_date
        end_date: prms.end_date
        client: prms.client
        available: 1
      }))

    $q.all(pslots).then (res) ->
      defer.resolve(res)
    , (err) ->
      defer.reject()

    return defer.promise


  merge_times: (all_events, service, item, date) ->

    return [] if !all_events || all_events.length == 0

    all_events = _.shuffle(all_events)
    sorted_times = []
    for ev in all_events
      if ev.times
        for i in ev.times
          # set it not set, currently unavailable, or randomly based on the number of events
          if !sorted_times[i.time] || sorted_times[i.time].avail == 0 || (Math.floor(Math.random()*all_events.length) == 0 && i.avail > 0)
            i.event_id = ev.event_id
            sorted_times[i.time] = i
        # if we have an item - which an already booked item - make sure that it's the list of time slots we can select - i.e. that we can select the current slot
        @checkCurrentItem(item.held, sorted_times, ev) if item.held
        @checkCurrentItem(item, sorted_times, ev)

    times = []
    date_times = {}

    for i in sorted_times
      if i

        # add datetime if not provided by the API (versions < 1.5.4-1 )
        if !i.datetime
          i.datetime = DateTimeUtilitiesService.convertTimeSlotToMoment(moment(date), i)

        times.push(new BBModel.TimeSlot(i, service))

    times


  checkCurrentItem: (item, sorted_times, ev) ->
    if item && item.id && item.event_id == ev.event_id && item.time && !sorted_times[item.time.time] && item.date && item.date.date.toISODate() == ev.date
      # calculate the correct datetime for time slot
      item.time.datetime = DateTimeUtilitiesService.convertTimeSlotToMoment(item.date.date, item.time)
      sorted_times[item.time.time] = item.time
      # remote this entry from the cache - just in case - we know it has a held item in it so lets just not keep it in case that goes later!
      halClient.clearCache(ev.$href("self"))
    else if item && item.id && item.event_id == ev.event_id && item.time && sorted_times[item.time.time] && item.date && item.date.date.toISODate() == ev.date
      sorted_times[item.time.time].avail = 1

