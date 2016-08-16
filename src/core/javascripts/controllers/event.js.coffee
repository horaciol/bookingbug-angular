'use strict'


###**
* @ngdoc directive
* @name BB.Directives:bbEvent
* @restrict AE
* @scope true
*
* @description
* Loads a list of event for the currently in scope company
*
* <pre>
* restrict: 'AE'
* replace: true
* scope: true
* </pre>
*
* @property {integer} total_entries The total entries of the event
* @property {array} events The events array
* @property {object} validator The validator service - see {@link BB.Services:Validator Validator Service}
####


angular.module('BB.Directives').directive 'bbEvent', () ->
  restrict: 'AE'
  replace: true
  scope : true
  controller : 'Event'


angular.module('BB.Controllers').controller 'Event', ($scope, $attrs, $rootScope, EventService, $q, PageControllerService, BBModel, ValidatorService, FormDataStoreService) ->

  $scope.controller = "public.controllers.Event"
  $scope.notLoaded $scope
  angular.extend(this, new PageControllerService($scope, $q))

  $scope.validator = ValidatorService
  $scope.event_options = $scope.$eval($attrs.bbEvent) or {}

  ticket_refs = []

  FormDataStoreService.init 'Event', $scope, [
    'selected_tickets',
    'event_options'
  ]

  $rootScope.connection_started.then ->
    init($scope.bb.company) if $scope.bb.company
  , (err) -> $scope.setLoadedAndShowError($scope, err, 'Sorry, something went wrong')


  init = (comp) ->

    # clear selected tickets if there are no stacked items (i.e. because a new event has been selected)
    delete $scope.selected_tickets if $scope.bb.stacked_items and $scope.bb.stacked_items.length is 0

    $scope.event = $scope.bb.current_item.event

    $scope.event_options.use_my_details = if !$scope.event_options.use_my_details? then true else $scope.event_options.use_my_details

    promises = [
      $scope.bb.current_item.event_group.getImagesPromise(),
      $scope.event.prepEvent()
    ]

    promises.push $scope.getPrePaidsForEvent($scope.client, $scope.event) if $scope.client

    $q.all(promises).then (result) ->

      images   = result[0] if result[0] and result[0].length > 0
      event    = result[1]
      prepaids = result[2] if result[2] and result[2].length > 0

      $scope.event = event

      initImage(images) if images

      if $scope.bb.current_item.tickets and $scope.bb.current_item.tickets.qty > 0
        
        # flag that we're editing tickets already in the basket so that view can indicate this
        $scope.edit_mode = true

        # already added to the basket
        $scope.setLoaded $scope
        $scope.selected_tickets = true
        
        # set tickets and current tickets items as items with the same event id
        $scope.current_ticket_items = _.filter $scope.bb.basket.timeItems(), (item) ->
          item.event_id is $scope.event.id

        $scope.tickets = (item.tickets for item in $scope.current_ticket_items)

        $scope.$watch 'current_ticket_items', (items, olditems) ->
          $scope.bb.basket.total_price = $scope.bb.basket.totalPrice()
        , true
        return

      else

        initTickets()

      $scope.$broadcast "bbEvent:initialised"

      $scope.setLoaded $scope

    , (err) -> $scope.setLoadedAndShowError($scope, err, 'Sorry, something went wrong')



  ###**
  * @ngdoc method
  * @name selectTickets
  * @methodOf BB.Directives:bbEvent
  * @description
  * Processes the selected tickets and adds them to the basket
  ###
  $scope.selectTickets = () ->

    $scope.notLoaded $scope
    $scope.bb.emptyStackedItems()
    # NOTE: basket is not cleared here as we might already have one!

    base_item = $scope.bb.current_item

    for ticket in $scope.event.tickets
      if ticket.qty
        switch ($scope.event.chain.ticket_type)
          when "single_space"
            for c in [1..ticket.qty]
              item = new BBModel.BasketItem()
              ref = item.ref
              angular.extend(item, base_item)
              item.ref = ref
              ticket_refs.push(item.ref)
              delete item.id
              item.tickets = angular.copy(ticket)
              item.tickets.qty = 1
              $scope.bb.stackItem(item)
          when "multi_space"
            item = new BBModel.BasketItem()
            ref = item.ref
            angular.extend(item, base_item)
            item.ref = ref
            ticket_refs.push(item.ref)
            item.tickets = angular.copy(ticket)
            delete item.id
            item.tickets.qty = ticket.qty
            $scope.bb.stackItem(item)

    # ok so we have them as stacked items
    # now push the stacked items to a basket
    if $scope.bb.stacked_items.length == 0
      $scope.setLoaded $scope
      return

    $scope.bb.pushStackToBasket()

    $scope.updateBasket().then () =>

      # basket has been saved
      $scope.setLoaded $scope
      $scope.selected_tickets = true
      $scope.stopTicketWatch()

      # set tickets and current tickets items as the newly created basket items
      $scope.current_ticket_items = _.filter $scope.bb.basket.timeItems(), (item) ->
        _.contains(ticket_refs, item.ref)

      $scope.tickets = (item.tickets for item in $scope.current_ticket_items)
            
      # watch the basket items so the price is updated
      $scope.$watch 'current_ticket_items', (items, olditems) ->
        $scope.bb.basket.total_price = $scope.bb.basket.totalPrice()
      , true

    , (err) -> $scope.setLoadedAndShowError($scope, err, 'Sorry, something went wrong')


  ###**
  * @ngdoc method
  * @name selectItem
  * @methodOf BB.Directives:bbEvent
  * @description
  * Select an item event in according of item and route parameter
  *
  * @param {array} item The Event or BookableItem to select
  * @param {string=} route A specific route to load
  ###
  $scope.selectItem = (item, route) =>
    if $scope.$parent.$has_page_control
      $scope.event = item
      return false
    else
      $scope.bb.current_item.setEvent(item)
      $scope.bb.current_item.ready = false
      $scope.decideNextPage(route)
      return true


  ###**
  * @ngdoc method
  * @name setReady
  * @methodOf BB.Directives:bbEvent
  * @description
  * Set this page section as ready
  ###
  $scope.setReady = () =>

    item.setEvent($scope.event) for item in $scope.current_ticket_items

    $scope.bb.event_details = {
      name         : $scope.event.chain.name,
      image        : $scope.event.image,
      address      : $scope.event.chain.address,
      datetime     : $scope.event.date,
      end_datetime : $scope.event.end_datetime,
      duration     : $scope.event.duration
      tickets      : $scope.event.tickets
    }

    if $scope.event_options.suppress_basket_update
      return true
    else
      return $scope.updateBasket()



  ###**
  * @ngdoc method
  * @name getPrePaidsForEvent
  * @methodOf BB.Directives:bbEvent
  * @description
  * Get pre paids for event in according of client and event parameter
  *
  * @param {array} client The client
  * @param {array} event The event
  ###
  $scope.getPrePaidsForEvent = (client, event) ->
    defer = $q.defer()
    params = {event_id: event.id}
    client.getPrePaidBookingsPromise(params).then (prepaids) ->
      $scope.pre_paid_bookings = prepaids
      defer.resolve(prepaids)
    , (err) ->
      defer.reject(err)
    defer.promise



  initImage = (images) ->
    image = images[0]
    if image
      image.background_css = {'background-image': 'url(' + image.url + ')'}
      $scope.event.image = image
      # TODO pick most promiment image
      # colorThief = new ColorThief()
      # colorThief.getColor image.url


  initTickets = () ->

    # no need to init tickets if some have been selected already
    return if $scope.selected_tickets

    # if a default number of tickets is provided, set only the first ticket type to that default
    $scope.event.tickets[0].qty = if $scope.event_options.default_num_tickets then $scope.event_options.default_num_tickets else 0

    # for multiple ticket types (adult entry/child entry etc), default all to zero except for the first ticket type
    if $scope.event.tickets.length > 1
      for ticket in $scope.event.tickets.slice(1)
        ticket.qty = 0

    # lock the ticket number dropdown box if only 1 ticket is available to puchase at a time (one-on-one training etc)
    $scope.selectTickets() if $scope.event_options.default_num_tickets and $scope.event_options.auto_select_tickets and $scope.event.tickets.length is 1 and $scope.event.tickets[0].max_num_bookings is 1

    $scope.tickets = $scope.event.tickets
    $scope.bb.basket.total_price = $scope.bb.basket.totalPrice()
    $scope.stopTicketWatch = $scope.$watch 'tickets', (tickets, oldtickets) ->
      $scope.bb.basket.total_price = $scope.bb.basket.totalPrice()
      $scope.event.updatePrice()
    , true

