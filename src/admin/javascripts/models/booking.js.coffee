'use strict'

angular.module('BB.Models').factory "AdminBookingModel", ($q, BBModel,
  BaseModel, BookingCollections, $window) ->

  class Admin_Booking extends BaseModel

    constructor: (data) ->
      super
      @datetime = moment(@datetime)
      @start = @datetime
      @end = @end_datetime
      @end ||= @datetime.clone().add(@duration, 'minutes')
      @title = @full_describe
      @time = @start.hour()* 60 + @start.minute()
#      @startEditable  = false
#      @durationEditable  = false
      # set to all day if it's a 24 hours span
      @allDay = false
      @allDay = true if (@duration_span && @duration_span == 86400)
      if @status == 3
        @startEditable  = true
        @durationEditable  = true
        @className = "status_blocked"
      else if @status == 4
        @className = "status_booked"
      else if @status == 0
        @className = "status_available"
      if @multi_status
        for k,v of @multi_status
          @className += " status_" + k


    useFullTime: () ->
      @using_full_time = true
      @start = @datetime.clone().subtract(@pre_time, 'minutes') if @pre_time
      @end = @datetime.clone().add(@duration + @post_time, 'minutes') if @post_time

    getPostData: () ->
      data = {}
      if @date && @time
        data.date = @date.date.toISODate()
        data.time = @time.time
        if @time.event_id
          data.event_id = @time.event_id
        else if @time.event_ids # what's this about?
          data.event_ids = @time.event_ids
      else
        @datetime = @start.clone()
        if (@using_full_time)
          # we need to make sure if @start has changed - that we're adjusting for a possible pre-time
          @datetime.add(@pre_time, 'minutes')
        data.date = @datetime.format("YYYY-MM-DD")
        data.time = @datetime.hour() * 60 + @datetime.minute()
      data.duration = @duration
      data.id = @id
      data.pre_time = @pre_time
      data.post_time = @post_time
      data.person_id = @person_id
      data.resource_id = @resource_id
      data.child_client_ids = @child_client_ids
      data.people_ids = @people_ids
      if @questions
        data.questions = (q.getPostData() for q in @questions)
      data

    hasStatus: (status) ->
      @multi_status[status]?

    statusTime: (status) ->
      if @multi_status[status]
        moment(@multi_status[status])
      else
        null

    sinceStatus: (status) ->
      s = @statusTime(status)
      return 0 if !s
      return Math.floor((moment().unix() - s.unix()) / 60)

    sinceStart: (options) ->
      start = @datetime.unix()
      if !options
        return Math.floor((moment().unix() - start) / 60)
      if options.later
        s = @statusTime(options.later).unix()
        if s > start
          return Math.floor((moment().unix() - s) / 60)
      if options.earlier
        s = @statusTime(options.earlier).unix()
        if s < start
          return Math.floor((moment().unix() - s) / 60)
      return Math.floor((moment().unix() - start) / 60)

    answer: (q) ->
      if @answers_summary
        for a in @answers_summary
          if a.name == q
            return a.answer
      return null

    $update: (data) ->
      defer = $q.defer()
      if data
        data.datetime = moment(data.datetime)
        data.datetime.tz()
        data.datetime = data.datetime.format()
      data ||= @getPostData()
      @$put('self', {}, data).then (res) =>
        @constructor(res)
        if @using_full_time
          @useFullTime()
        BookingCollections.checkItems(@)
        defer.resolve(@)
      , (err) ->
        defer.reject(err)
      defer.promise

    $refetch: () ->
      defer = $q.defer()
      @$flush('self')
      @$get('self').then (res) =>
        @constructor(res)
        if @using_full_time
          @useFullTime()
        BookingCollections.checkItems(@)
        defer.resolve(@)
      , (err) ->
        defer.reject(err)
      defer.promise

    @$query: (params) ->
      if params.slot
        params.slot_id = params.slot.id
      if params.date
        params.start_date = params.date
        params.end_date = params.date
      if params.company
        company = params.company
        delete params.company
        params.company_id = company.id
      params.per_page = 1024 if !params.per_page?
      params.include_cancelled = false if !params.include_cancelled?
      defer = $q.defer()
      existing = BookingCollections.find(params)
      if existing  && !params.skip_cache
        defer.resolve(existing)
      else
        src = company
        src ||= params.src
        delete params.src if params.src
        if params.skip_cache
          BookingCollections.delete(existing) if existing
          src.$flush('bookings', params)

        src.$get('bookings', params).then (resource) ->
          if resource.$has('bookings')
            resource.$get('bookings').then (bookings) ->
              models = (new BBModel.Admin.Booking(b) for b in bookings)
              spaces = new $window.Collection.Booking(resource, models, params)
              BookingCollections.add(spaces)
              defer.resolve(spaces)
            , (err) ->
              defer.reject(err)
          else
            booking = new BBModel.Admin.Booking(resource)
            defer.resolve(booking)

        , (err) ->
          defer.reject(err)
      defer.promise

