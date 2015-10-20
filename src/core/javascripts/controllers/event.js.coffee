'use strict'

angular.module('BB.Directives').directive 'bbEvent', () ->
  restrict: 'AE'
  replace: true
  scope : true
  controller : 'Event'


angular.module('BB.Controllers').controller 'Event', ($scope, $attrs, $rootScope, EventService, $q, PageControllerService, BBModel, ValidatorService) ->
  $scope.controller = "public.controllers.Event"
  $scope.notLoaded $scope
  angular.extend(this, new PageControllerService($scope, $q))

  $scope.validator = ValidatorService
  $scope.event_options = $scope.$eval($attrs.bbEvent) or {}

  $rootScope.connection_started.then ->
    if $scope.bb.company
      $scope.init($scope.bb.company)
  , (err) ->  $scope.setLoadedAndShowError($scope, err, 'Sorry, something went wrong')


  $scope.init = (comp) ->
    $scope.event = $scope.bb.current_item.event

    promises = [
      $scope.current_item.event_group.getImagesPromise(),
      $scope.event.prepEvent()
    ]

    promises.push $scope.getPrePaidsForEvent($scope.client, $scope.event) if $scope.client

    $q.all(promises).then (result) ->
      if result[0] and result[0].length > 0
        image = result[0][0]
        image.background_css = {'background-image': 'url(' + image.url + ')'}
        $scope.event.image = image
        # TODO pick most promiment image
        # colorThief = new ColorThief()
        # colorThief.getColor image.url

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
      $scope.setLoaded $scope

    , (err) -> $scope.setLoadedAndShowError($scope, err, 'Sorry, something went wrong')


  $scope.selectTickets = () ->
    # process the selected tickets - this may mean adding multiple basket items - add them all to the basket
    $scope.notLoaded $scope
    $scope.bb.emptyStackedItems()
    #$scope.setBasket(new BBModel.Basket(null, $scope.bb)) # we might already have a basket!!
    base_item = $scope.current_item
    for ticket in $scope.event.tickets
      if ticket.qty
        switch ($scope.event.chain.ticket_type)
          when "single_space"
            for c in [1..ticket.qty]
              item = new BBModel.BasketItem()
              angular.extend(item, base_item)
              delete item.id
              item.tickets = angular.copy(ticket)
              item.tickets.qty = 1
              $scope.bb.stackItem(item)
          when "multi_space"
            item = new BBModel.BasketItem()
            angular.extend(item, base_item)
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
      $scope.tickets = (item.tickets for item in $scope.bb.basket.items)
      $scope.$watch 'bb.basket.items', (items, olditems) ->
        $scope.bb.basket.total_price = $scope.bb.basket.totalPrice()
        item.tickets.price = item.totalPrice()
      , true
    , (err) ->  $scope.setLoadedAndShowError($scope, err, 'Sorry, something went wrong')


  $scope.selectItem = (item, route) =>
    if $scope.$parent.$has_page_control
      $scope.event = item
      return false
    else
      $scope.bb.current_item.setEvent(item)
      $scope.bb.current_item.ready = false
      $scope.decideNextPage(route)
      return true


  $scope.setReady = () =>
    $scope.bb.event_details = {
      name         : $scope.event.chain.name,
      image        : $scope.event.image,
      address      : $scope.event.chain.address,
      datetime     : $scope.event.date,
      end_datetime : $scope.event.end_datetime,
      duration     : $scope.event.duration
      tickets      : $scope.event.tickets
    }

    return $scope.updateBasket()


  $scope.getPrePaidsForEvent = (client, event) ->
    defer = $q.defer()
    params = {event_id: event.id}
    client.getPrePaidBookingsPromise(params).then (prepaids) ->
      $scope.pre_paid_bookings = prepaids
      defer.resolve(prepaids)
    , (err) ->
      defer.reject(err)
    defer.promise

