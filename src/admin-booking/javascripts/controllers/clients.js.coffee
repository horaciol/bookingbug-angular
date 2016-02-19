'use strict';

angular.module('BBAdminBooking').directive 'bbAdminBookingClients', () ->
  restrict: 'AE'
  replace: true
  scope : true
  controller : 'adminBookingClients'


angular.module('BBAdminBooking').controller 'adminBookingClients', ($scope,  $rootScope, $q, AdminClientService, ClientDetailsService, AlertService, ClientService, ValidatorService, ErrorService, $log) ->

  $scope.validator = ValidatorService
  $scope.clientDef = $q.defer()
  $scope.clientPromise = $scope.clientDef.promise
  $scope.per_page = 20
  $scope.total_entries = 0
  $scope.clients = []
  $scope.search_clients = false
  $scope.newClient = false
  $scope.no_clients = false
  $scope.search_error = false
  $scope.search_text = null


  $scope.showSearch = () =>
    $scope.search_clients = true
    $scope.newClient = false


  $scope.showClientForm = () =>
    $scope.search_error = false
    $scope.no_clients = false
    $scope.search_clients = false
    $scope.newClient = true
    # clear the client if one has already been selected
    $scope.clearClient()


  $scope.selectClient = (client, route) =>
    $scope.search_error = false
    $scope.no_clients = false
    $scope.setClient(client)
    $scope.client.setValid(true)
    $scope.decideNextPage(route)


  $scope.checkSearch = () =>
    if $scope.search_text and $scope.search_text.length >= 3
      $scope.search_error = false
      return true
    else
      $scope.search_error = true
      return false


  $scope.createClient = (route) =>
    $scope.notLoaded $scope

    # we need to validate the client information has been correctly entered here
    if $scope.bb && $scope.bb.parent_client
      $scope.client.parent_client_id = $scope.bb.parent_client.id
    $scope.client.setClientDetails($scope.client_details) if $scope.client_details

    ClientService.create_or_update($scope.bb.company, $scope.client).then (client) =>
      $scope.setLoaded $scope
      $scope.selectClient(client, route)
    , (err) -> $scope.setLoadedAndShowError($scope, err, 'Sorry, something went wrong')


  $scope.getClients = (currentPage, filterBy, filterByFields, orderBy, orderByReverse) ->
    AlertService.clear()
    $scope.no_clients = false
    $scope.search_error = false
    clientDef = $q.defer()
    params =
      company: $scope.bb.company
      per_page: $scope.per_page
      filter_by: if filterBy? then filterBy else $scope.search_text
      filter_by_fields: filterByFields
      order_by: orderBy
      order_by_reverse: orderByReverse
    params.page = currentPage+1 if currentPage
    $rootScope.connection_started.then ->
      $scope.notLoaded $scope
      $rootScope.bb.api_url = $scope.bb.api_url if !$rootScope.bb.api_url && $scope.bb.api_url
      AdminClientService.query(params).then (clients) =>
        $scope.clients = clients.items
        $scope.setLoaded $scope
        $scope.setPageLoaded()
        $scope.total_entries = clients.total_entries
        clientDef.resolve(clients.items)
      , (err) ->
        $scope.setLoadedAndShowError($scope, err, 'Sorry, something went wrong')
        clientDef.reject(err)


  $scope.searchClients = (search_text) ->
    clientDef = $q.defer()
    params =
      filter_by: search_text
      company: $scope.bb.company
    AdminClientService.query(params).then (clients) =>
      clientDef.resolve(clients.items)
      clients.items
    return clientDef.promise

  $scope.typeHeadResults = ($item, $model, $label) ->
    item = $item
    model = $model
    label = $label
    $scope.client = item
    return

  $scope.edit = (item) ->
    $log.info("not implemented")
