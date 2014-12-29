'use strict'

angular.module('BB.Directives').directive 'bbEvent', () ->
  restrict: 'AE'
  replace: true
  scope : true
  controller : 'Event'


angular.module('BB.Controllers').controller 'Event', ($scope,  $rootScope, EventService, $q, PageControllerService, BBModel) ->
  $scope.controller = "public.controllers.Event"
  $scope.notLoaded $scope
  angular.extend(this, new PageControllerService($scope, $q))

  $rootScope.connection_started.then ->
    if $scope.bb.company
      $scope.init($scope.bb.company)
  , (err) ->  $scope.setLoadedAndShowError($scope, err, 'Sorry, something went wrong')


  $scope.init = (comp) ->
    $scope.event = $scope.bb.current_item.event
    $scope.event.prepEvent().then () =>
      for ticket in $scope.event.tickets
        ticket.qty = 0
      $scope.setLoaded $scope
    , (err) ->  $scope.setLoadedAndShowError($scope, err, 'Sorry, something went wrong')


  $scope.selectTickets = () ->
    # process the selected tickets - this may mean adding multiple basket items - add them all to the basket
    $scope.notLoaded $scope
    $scope.bb.emptyStackedItems()
    $scope.setBasket(new BBModel.Basket(null, $scope.bb))
    base_item = $scope.current_item
    for ticket in $scope.event.tickets
      if ticket.qty
        if $scope.event.chain.ticket_type == "single_space"
          for c in [1..ticket.qty]
            item = new BBModel.BasketItem()
            angular.extend(item, base_item)
            item.tickets = angular.copy(ticket)
            item.tickets.qty = 1

            $scope.bb.stackItem(item)
    # ok so we have them as stacked items
    # now push teh stacked items to a basket
    if $scope.bb.stacked_items.length == 0
      $scope.setLoaded $scope
      return

    $scope.bb.pushStackToBasket()
    $scope.updateBasket().then () =>
      # basket has been saved
      $scope.setLoaded $scope
      $scope.selected_tickets = true
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
    