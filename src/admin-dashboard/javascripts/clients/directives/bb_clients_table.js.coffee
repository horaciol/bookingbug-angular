'use strict'

angular.module('BBAdminDashboard.clients.directives').directive 'bbClientsTable', () ->
  restrict: 'AE'
  replace: true
  scope : true
  controller : 'TabletClients'
  link : (scope, element, attrs) ->
    return


angular.module('BBAdminDashboard.clients.directives').controller 'TabletClients', (
  $scope,  $rootScope, $q, BBModel, AlertService) ->

  $scope.clientDef = $q.defer()
  $scope.clientPromise = $scope.clientDef.promise
  $scope.per_page = 15
  $scope.total_entries = 0
  $scope.clients = []

  $scope.getClients = (currentPage, filterBy, filterByFields, orderBy, orderByReverse) ->
    fields = angular.copy(filterByFields)
 #   if fields.name?
  #    fields.name = fields.name.replace(/\s/g, '')
    if fields.mobile?
      mobile = fields.mobile
      if mobile.indexOf('0') == 0
        fields.mobile = mobile.substring(1)

    clientDef = $q.defer()

    params =
      company: $scope.bb.company
      per_page: $scope.per_page
      page: currentPage + 1
      filter_by: filterBy
      filter_by_fields: fields
      order_by: orderBy
      order_by_reverse: orderByReverse
    BBModel.Admin.Client.$query(params).then (clients) =>
      $scope.clients = clients.items
      $scope.total_entries = clients.total_entries
      clientDef.resolve(clients.items)
    , (err) ->
      console.log err
      clientDef.reject(err)

