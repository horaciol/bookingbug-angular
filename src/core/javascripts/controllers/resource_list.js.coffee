'use strict';


###**
* @ngdoc directive
* @name BB.Directives:bbResources
* @restrict AE
* @scope true
*
* @description
* Loads a list of resources for the currently in scope company
*
* <pre>
* restrict: 'AE'
* replace: true
* scope: true
* </pre>
*
* @param {hash}  bbResources   A hash of options
* @property {array} items An array of all resources
* @property {array} bookable_items An array of all BookableItems - used if the current_item has already selected a services or person
* @property {array} bookable_resources An array of Resources - used if the current_item has already selected a services or person
* @property {resource} resource The currectly selected resource
####



angular.module('BB.Directives').directive 'bbResources', () ->
  restrict: 'AE'
  replace: true
  scope : true
  controller : 'ResourceList'


angular.module('BB.Controllers').controller 'ResourceList',
($scope,  $rootScope, $attrs, PageControllerService, ResourceService, ItemService, $q, BBModel, ResourceModel) ->
  $scope.controller = "public.controllers.ResourceList"
  $scope.notLoaded $scope

  angular.extend(this, new PageControllerService($scope, $q))


  $scope.options = $scope.$eval($attrs.bbResources) or {}

  $rootScope.connection_started.then () =>
    loadData()

  loadData = () =>
    # do nothing if nothing has changed
    unless ($scope.bb.steps && $scope.bb.steps[0].page == "resource_list") or $scope.options.resource_first
      if !$scope.bb.current_item.service || $scope.bb.current_item.service == $scope.change_watch_item
        # if there's no service - we have to wait for one to be set - so we're kind of done loadig for now!
        if !$scope.bb.current_item.service
          $scope.setLoaded $scope
        return

    $scope.change_watch_item = $scope.bb.current_item.service
    $scope.notLoaded $scope

    rpromise = ResourceService.query($scope.bb.company)
    rpromise.then (resources) =>
      if $scope.bb.current_item.group  # check they're part of any currently selected group
        resources = resources.filter (x) -> !x.group_id || x.group_id == $scope.bb.current_item.group
      $scope.all_resources = resources

    params =
      company: $scope.bb.company
      cItem: $scope.bb.current_item
      wait: rpromise
      item: 'resource'
    ItemService.query(params).then (items) =>
      promises = []
      if $scope.bb.current_item.group # check they're part of any currently selected group
        items = items.filter (x) -> !x.group_id || x.group_id == $scope.bb.current_item.group

      for i in items
        promises.push(i.promise)

      $q.all(promises).then (res) =>
        resources = []
        for i in items
          resources.push(i.item)
          if $scope.bb.current_item && $scope.bb.current_item.resource && $scope.bb.current_item.resource.self == i.item.self
            $scope.resource = i.item

        if resources.length == 1
          if !$scope.selectItem(items[0].item, $scope.nextRoute, true)
            $scope.bookable_resources = resources
            $scope.bookable_items = items
        else
          $scope.bookable_resources = resources
          $scope.bookable_items = items
        $scope.setLoaded $scope
      , (err) ->
        $scope.setLoadedAndShowError($scope, err, 'Sorry, something went wrong')
    , (err) ->
      unless err == "No service link found" and (($scope.bb.steps and $scope.bb.steps[0].page == 'resource_list') or $scope.options.resource_first)
        $scope.setLoadedAndShowError($scope, err, 'Sorry, something went wrong')
      else
        $scope.setLoaded $scope

  ###**
  * @ngdoc method
  * @name getItemFromResource
  * @methodOf BB.Directives:bbResources
  * @description
  * Get item from resource in according of resource parameter
  *
  * @param {object} resource The resource 
  ###
  getItemFromResource = (resource) =>
    if (resource instanceof  ResourceModel)
      if $scope.bookable_items
        for item in $scope.bookable_items
          if item.item.self == resource.self
            return item
    return resource

  ###**
  * @ngdoc method
  * @name selectItem
  * @methodOf BB.Directives:bbResources
  * @description
  * Select an item into the current booking journey and route on to the next page dpending on the current page control
  *
  * @param {array} item The Service or BookableItem to select
  * @param {string=} route A specific route to load
  * @param {string=} skip_step The skip_step has been set to false
  ###
  $scope.selectItem = (item, route, skip_step = false) =>
    if $scope.$parent.$has_page_control
      $scope.resource = item
      return false
    else
      $scope.bb.current_item.setResource(getItemFromResource(item))
      if skip_step
        $scope.skipThisStep()
      $scope.decideNextPage(route)
      return true

  $scope.$watch 'resource',(newval, oldval) =>
    if $scope.resource
      $scope.bb.current_item.setResource(getItemFromResource($scope.resource))
      $scope.broadcastItemUpdate()
    else if newval != oldval
      $scope.bb.current_item.setResource(null)
      $scope.broadcastItemUpdate()

  $scope.$on "currentItemUpdate", (event) ->
    loadData()

    ###**
    * @ngdoc method
    * @name setReady
    * @methodOf BB.Directives:bbResources
    * @description
    * Set this page section as ready
    ###
   $scope.setReady = () =>
    if $scope.resource
      $scope.bb.current_item.setResource(getItemFromResource($scope.resource))
      return true
    else
      $scope.bb.current_item.setResource(null)
      return true

