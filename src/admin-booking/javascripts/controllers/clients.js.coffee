'use strict';

angular.module('BBAdminBooking').directive 'bbAdminBookingClients', () ->
  restrict: 'AE'
  replace: true
  scope : true
  controller : 'adminBookingClients'


angular.module('BBAdminBooking').controller 'adminBookingClients', ($scope,  $rootScope, $q, AdminClientService, ClientDetailsService, AlertService, ClientService, ValidatorService, ErrorService, $log, BBModel, PaginationService, LoadingService) ->

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
  $scope.pagination = PaginationService.initialise({page_size: 10, max_size: 5})
  loader = LoadingService.$loader($scope)

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
    loader.notLoaded()

    # we need to validate the client information has been correctly entered here
    if $scope.bb && $scope.bb.parent_client
      $scope.client.parent_client_id = $scope.bb.parent_client.id
    $scope.client.setClientDetails($scope.client_details) if $scope.client_details

    BBModel.Client.$create_or_update($scope.bb.company, $scope.client).then (client) =>
      loader.setLoaded()
      $scope.selectClient(client, route)
    , (err) -> loader.setLoadedAndShowError(err, 'Sorry, something went wrong')

  $scope.getClients = (currentPage, filterBy, filterByFields, orderBy, orderByReverse) ->
    AlertService.clear()
    $scope.search_triggered = true
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
      loader.notLoaded()
      $rootScope.bb.api_url = $scope.bb.api_url if !$rootScope.bb.api_url && $scope.bb.api_url
      AdminClientService.query(params).then (clients) =>
        $scope.clients = clients.items
        loader.setLoaded()
        $scope.setPageLoaded()
        $scope.total_entries = clients.total_entries
        PaginationService.update($scope.pagination, $scope.clients.length)
        clientDef.resolve(clients.items)
      , (err) ->
        loader.setLoadedAndShowError(err, 'Sorry, something went wrong')
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

  $scope.clearSearch = () ->
    $scope.clients = null
    $scope.search_triggered = false

  $scope.edit = (item) ->
    $log.info("not implemented")


