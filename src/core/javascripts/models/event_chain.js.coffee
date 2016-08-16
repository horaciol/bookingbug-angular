

'use strict';


###**
* @ngdoc service
* @name BB.Models:EventChain
*
* @description
* Representation of an EventChain Object
* 
* @property {integer} id The id of event chain
* @property {string} name Name of the event chain
* @property {string} description The description of the event
* @property {integer} capacity_view The capacity view
* @property {date} start_date Event chain start date
* @property {date} finish_date Event chain finish date
* @property {integer} price The price of the event chain
* @property {string} ticket_type Type of the ticket
* @property {boolean} course Verify is couse exist or not
####


angular.module('BB.Models').factory "EventChainModel", ($q, BBModel, BaseModel) ->

  class EventChain extends BaseModel

    constructor: (data) ->
      super
      @capacity_view = setCapacityView(@capacity_view)
      @start_date = moment(@start_date) if @start_date
      @end_date = moment(@end_date) if @end_date

    name: () ->
      @_data.name

    ###**
    * @ngdoc method
    * @name isSingleBooking
    * @methodOf BB.Models:EventChain
    * @description
    * Verify if is a single booking
    *
    * @returns {array} If maximum number of bookings is equal with 1 and not have an ticket sets
    ###
    isSingleBooking: () ->
      return @max_num_bookings == 1 and !@$has('ticket_sets')

    ###**
    * @ngdoc method
    * @name hasTickets
    * @methodOf BB.Models:EventChain
    * @description
    * Checks if this is considered a valid tickets
    *
    * @returns {boolean} If this have an ticket sets
    ###
    hasTickets: () ->
      @$has('ticket_sets')

    ###**
    * @ngdoc method
    * @name getTickets
    * @methodOf BB.Models:EventChain
    * @description
    * Get the tickets of the event
    *
    * @returns {promise} A promise for the tickets
    ###
    getTickets: () ->
      def = $q.defer()
      if @tickets
        def.resolve(@tickets)
      else
        if @$has('ticket_sets')
          @$get('ticket_sets').then (tickets) =>
            @tickets = []
            for ticket in tickets
              # mark that this ticket is part of ticket set so that the range can be calculated correctly
              ticket.ticket_set = true
              @tickets.push(new BBModel.EventTicket(ticket))
            @adjustTicketsForRemaining()
            def.resolve(@tickets)
        else
          @tickets = [new BBModel.EventTicket(
            name: "Admittance"
            min_num_bookings: 1
            max_num_bookings: @max_num_bookings
            type: "normal"
            price: @price
          )]
          @adjustTicketsForRemaining()
          def.resolve(@tickets)
      return def.promise

    ###**
    * @ngdoc method
    * @name adjustTicketsForRemaining
    * @methodOf BB.Models:EventChain
    * @description
    * Adjust the number of tickets that can be booked due to changes in the number of remaining spaces for each ticket set
    *
    * @returns {object} The returned adjust tickets for remaining
    ###
    adjustTicketsForRemaining: () ->
      if @tickets
        for @ticket in @tickets
          @ticket.max_spaces = @spaces


    ###**
    * @ngdoc method
    * @name setCapacityView
    * @methodOf BB.Models:EventChain
    * @description
    * Sets the capacity_view (referred to as the "spaces view" in admin console) to a more helpful String
    * @returns {String} code for the capacity_view
    ###
    setCapacityView = (capacity_view) ->
      switch capacity_view
        when 0 then capacity_view_str = "DO_NOT_DISPLAY"
        when 1 then capacity_view_str = "NUM_SPACES"
        when 2 then capacity_view_str = "NUM_SPACES_LEFT"
        when 3 then capacity_view_str = "NUM_SPACES_AND_SPACES_LEFT"
        else capacity_view_str = "NUM_SPACES_AND_SPACES_LEFT"
      return capacity_view_str
