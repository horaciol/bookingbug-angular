'use strict'

angular.module('BBAdminBooking').directive 'bbAdminBookingClients', () ->
  restrict: 'AE'
  replace: false
  scope : true
  controller : 'adminBookingClients'
  templateUrl: 'admin_booking_clients.html'


angular.module('BBAdminBooking').controller 'adminBookingClients', ($scope,
  $rootScope, $q, AlertService, ValidatorService, ErrorService, $log, BBModel,
  $timeout, LoadingService) ->

  $scope.validator  = ValidatorService
  $scope.clients = new BBModel.Pagination({page_size: 10, max_size: 5, request_page_size: 10})
  loader = LoadingService.$loader($scope)

  $scope.sort_by_options = [
    {key: 'first_name', name: 'First Name'},
    {key: 'last_name', name: 'Last Name'},
    {key: 'email', name: 'Email'}
  ]

  $scope.sort_by = $scope.sort_by_options[0].key


  $rootScope.connection_started.then () ->
    $scope.clearClient()

  $scope.selectClient = (client, route) =>
    $scope.setClient(client)
    $scope.client.setValid(true)
    $scope.decideNextPage(route)


  $scope.createClient = (route) =>

    loader.notLoaded()

    # we need to validate the client information has been correctly entered here
    if $scope.bb && $scope.bb.parent_client
      $scope.client.parent_client_id = $scope.bb.parent_client.id

    $scope.client.setClientDetails($scope.client_details) if $scope.client_details

    BBModel.Client.$create_or_update($scope.bb.company, $scope.client).then (client) =>
      loader.setLoaded()
      $scope.selectClient(client, route)
    , (err) ->

      if err.data and err.data.error is "Please Login"
        loader.setLoaded()
        AlertService.raise('EMAIL_ALREADY_REGISTERED_ADMIN')
      else if err.data and err.data.error is "Sorry, it appears that this phone number already exists"
        loader.setLoaded()
        AlertService.raise('PHONE_NUMBER_ALREADY_REGISTERED_ADMIN')
      else
        loader.setLoadedAndShowError($scope, err, 'Sorry, something went wrong')


  $scope.getClients = (params, options = {}) ->

    $scope.search_triggered = true

    $timeout ->
      $scope.search_triggered = false
    , 1000

    return if !params or (params and !params.filter_by)

    $scope.params =
      company: params.company or $scope.bb.company
      per_page: params.per_page or $scope.clients.request_page_size
      filter_by: params.filter_by
      search_by_fields: params.search_by_fields or 'phone,mobile'
      order_by: params.order_by or $scope.sort_by
      order_by_reverse: params.order_by_reverse
      page: params.page or 1

    loader.notLoaded()

    BBModel.Admin.Client.$query($scope.params).then (result) ->

      $scope.search_complete = true

      if options.add
        $scope.clients.add(params.page, result.items)
      else
        $scope.clients.initialise(result.items, result.total_entries)

      loader.setLoaded()


  $scope.searchClients = (search_text) ->
    defer = $q.defer()
    params =
      filter_by: search_text
      company: $scope.bb.company
    BBModel.Admin.Client.$query(params).then (clients) =>
      defer.resolve(clients)
    defer.promise


  $scope.typeHeadResults = ($item, $model, $label) ->

    item          = $item
    model         = $model
    label         = $label
    $scope.client = item

    $scope.selectClient($item)


  $scope.clearSearch = () ->
    $scope.clients.initialise()
    $scope.typehead_result = null
    $scope.search_complete = false


  $scope.edit = (item) ->
    $log.info("not implemented")


  $scope.pageChanged = () ->

    [items_present, page_to_load] = $scope.clients.update()

    if !items_present
      $scope.params.page = page_to_load
      $scope.getClients($scope.params, {add: true})


  $scope.sortChanged = (sort_by) ->
    $scope.params.order_by = sort_by
    $scope.params.page = 1
    $scope.getClients($scope.params)

