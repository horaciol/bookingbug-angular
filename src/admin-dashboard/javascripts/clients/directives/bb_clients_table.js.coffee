'use strict'

angular.module('BBAdminDashboard.clients.directives').directive 'bbClientsTable', () ->
  restrict: 'AE'
  replace: true
  scope : true
  controller : 'TabletClients'
  link : (scope, element, attrs) ->
    return


angular.module('BBAdminDashboard.clients.directives').controller 'TabletClients', ($scope,  $rootScope, $q, AdminClientService, ClientDetailsService, AlertService) ->
  $scope.clientDef = $q.defer()
  $scope.clientPromise = $scope.clientDef.promise
  $scope.per_page = 15
  $scope.total_entries = 0
  $scope.clients = []
  
  $scope.getClients = (currentPage, filterBy, filterByFields, orderBy, orderByReverse) ->
    if filterByFields.name?
      filterByFields.name = filterByFields.name.replace(/\s/g, '')
    if filterByFields.mobile?
      mobile = filterByFields.mobile
      if mobile.indexOf('0') == 0
        filterByFields.mobile = mobile.substring(1)
      
    clientDef = $q.defer()

    # BusyService.notLoaded $scope
    AdminClientService.query({company_id:$scope.bb.company.id, per_page: $scope.per_page, page: currentPage+1, filter_by: filterBy, filter_by_fields: filterByFields, order_by: orderBy, order_by_reverse: orderByReverse    }).then (clients) =>
      $scope.clients = clients.items
      # BusyService.setLoaded $scope
      # BusyService.setPageLoaded()
      $scope.total_entries = clients.total_entries
      clientDef.resolve(clients.items)
    , (err) ->
      clientDef.reject(err)
      # BusyService.setLoadedAndShowError($scope, err, 'Sorry, something went wrong')
  
