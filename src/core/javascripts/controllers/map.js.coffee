'use strict'


###**
* @ngdoc directive
* @name BB.Directives:bbMap
* @restrict AE
* @scope true
*
* @description
*
* Loads a list of maps for the currently in scope company
*
* <pre>
* restrict: 'AE'
* replace: true
* scope: true
* </pre>
*
* @param {hash}  bbMap A hash of options
* @property {object} mapLoaded The map has been loaded
* @property {object} mapReady The maps has been ready
* @property {object} map_init The initialization the map
* @property {object} range_limit The range limit
* @property {boolean} showAllMarkers Display or not all markers
* @property {array} mapMarkers The map markers
* @property {array} shownMarkers Display the markers
* @property {integer} numberedPin The numbered pin
* @property {integer} defaultPin The default pin
* @proeprty {boolean} hide_not_live_stores Hide or not the live stores
* @property {object} address The address
* @property {object} error_msg The error message
* @property {object} alert The alert service - see {@link BB.Services:Alert Alert Service}
####


angular.module('BB.Directives').directive 'bbMap', () ->
  restrict: 'A'
  replace: true
  scope : true
  controller : 'MapCtrl'

angular.module('BB.Controllers').controller 'MapCtrl', ($scope, $element,
  $attrs, $rootScope, AlertService, FormDataStoreService, LoadingService, $q,
  $window, $timeout, SettingsService) ->

  $scope.controller = "public.controllers.MapCtrl"

  FormDataStoreService.init 'MapCtrl', $scope, [
    'address'
    'selectedStore'
    'search_prms'
  ]

  # init vars
  $scope.options = $scope.$eval($attrs.bbMap) or {}

  $scope.num_search_results = $scope.options.num_search_results or 6
  $scope.range_limit = $scope.options.range_limit or Infinity
  $scope.hide_not_live_stores = $scope.options.hide_not_live_stores or false
  $scope.can_filter_by_service = $scope.options.filter_by_service or false # If set to true then the checkbox toggle for showing stores with/without the selected service will be shown in the template
  $scope.filter_by_service = $scope.options.filter_by_service or false # The aforementioned checkbox is bound to this value which can be true or false depending on checked state, hence why we cannot use filter_by_service to show/hide the checkbox
  $scope.default_zoom = $scope.options.default_zoom or 6

  cc = SettingsService.getCountryCode()
  if _.contains ["gb", "us", "jp"], cc
    du = "miles"
  else
    du = "km"
  $scope.distance_unit = du

  map_ready_def               = $q.defer()
  $scope.mapLoaded            = $q.defer()
  $scope.mapReady             = map_ready_def.promise
  $scope.map_init             = $scope.mapLoaded.promise
  $scope.showAllMarkers       = false
  $scope.mapMarkers           = []
  $scope.shownMarkers         = $scope.shownMarkers or []
  $scope.numberedPin          ||= null
  $scope.defaultPin           ||= null
  $scope.address              = $scope.$eval $attrs.bbAddress if !$scope.address and $attrs.bbAddress
  loader = LoadingService.$loader($scope).notLoaded()

  # setup geolocation shim
  webshim.setOptions({'waitReady': false, 'loadStyles': false})
  webshim.polyfill("geolocation")

  $rootScope.connection_started.then ->
    loader.setLoaded() if !$scope.selectedStore
    if $scope.bb.company.companies
      $rootScope.parent_id = $scope.bb.company.id
    else if $rootScope.parent_id
      $scope.initWidget(
        company_id:$rootScope.parent_id
        first_page: $scope.bb.current_page
        keep_basket:true
        item_defaults: if $scope.bb.item_defaults then $scope.bb.item_defaults else {}
      )
      return
    else
      $scope.initWidget({company_id:$scope.bb.company.id, first_page: null})
      return

    $scope.companies = $scope.bb.company.companies
    if !$scope.companies or $scope.companies.length is 0
      $scope.companies = [$scope.bb.company]

    if $scope.bb.current_item.service and $scope.options and $scope.options.filter_by_service
      loader.notLoaded()

      filterByService().then ->
        $scope.map_init.then ->
          mapInit()
    else
      $scope.map_init.then ->
        mapInit()

    $scope.mapBounds = new google.maps.LatLngBounds()
    for comp in $scope.companies
      if comp.address and comp.address.lat and comp.address.long
        latlong = new google.maps.LatLng(comp.address.lat,comp.address.long)
        $scope.mapBounds.extend(latlong)

    $scope.mapOptions =  {
        center: $scope.mapBounds.getCenter(),
        zoom: $scope.default_zoom,
        mapTypeId: google.maps.MapTypeId.ROADMAP,
      mapTypeControl:true,
      mapTypeControlOptions: {
          style: window.google.maps.MapTypeControlStyle.DROPDOWN_MENU
      }
    }

    if $scope.options and $scope.options.map_options
      for key, value of $scope.options.map_options
        $scope.mapOptions[key] = value

    map_ready_def.resolve(true)

  , (err) -> loader.setLoadedAndShowError(err, 'Sorry, something went wrong')


  ###**
  * @ngdoc method
  * @name filterByService
  * @methodOf BB.Directives:bbMap
  * @description
  * Set the has_service property and the service object on all companies
  * so companies can be filtered by service
  ###
  filterByService = () ->
    deferred = $q.defer()
    if $scope.bb.selected_service.$has('all_children')
      $scope.bb.selected_service.$get('all_children').then (resource) ->
        resource.$get('services').then (services) ->
          company_ids = _.map services, (service) ->
            service.company_id

          for company in $scope.companies
            company.has_service = _.contains(company_ids, company.id)
            service = _.find services, (service) ->
              service.company_id == company.id
            company.service = service

            deferred.resolve()
    else
      deferred.resolve()
    return deferred.promise

  ###**
  * @ngdoc method
  * @name $scope.filterByService
  * @methodOf BB.Directives:bbMap
  * @description
  * Set $scope.shownMarkers to include / exclude
  * companies without the selected service
  ###
  $scope.filterByService = () ->

    for marker in $scope.shownMarkers
      marker.setMap null

    if $scope.options and $scope.filter_by_service
      $scope.shownMarkers = $scope.shown_markers_with_services
    else
      $scope.shownMarkers = $scope.shown_markers

    $timeout ->
      setMarkers()

  mapInit = () ->
    for comp in $scope.companies
      if comp.address and comp.address.lat and comp.address.long
        latlong = new google.maps.LatLng(comp.address.lat,comp.address.long)
        marker = new google.maps.Marker({
          map: $scope.myMap
          position: latlong
          visible: $scope.showAllMarkers
          icon: $scope.defaultPin
        })
        marker.company = comp
        $scope.mapMarkers.push(marker) unless $scope.hide_not_live_stores and !comp.live

    $timeout ->
      $scope.myMap.fitBounds($scope.mapBounds)
      $scope.myMap.setZoom(15)
      if $scope.bb.current_item.service and $scope.options and $scope.filter_by_service
        loader.setLoaded()
    checkDataStore()

  ###**
  * @ngdoc method
  * @name checkDataStore
  * @methodOf BB.Directives:bbMap
  * @description
  * If the user has clicked back to the map then display it.
  ###
  checkDataStore = ->
    if $scope.selectedStore
      loader.notLoaded()
      if $scope.search_prms
        $scope.searchAddress $scope.search_prms
      else
        $scope.geolocate()
      google.maps.event.addListenerOnce($scope.myMap, 'idle', ->
        _.each $scope.mapMarkers, (marker) ->
          if $scope.selectedStore.id is marker.company.id
            google.maps.event.trigger(marker, 'click')
      )

  ###**
  * @ngdoc method
  * @name title
  * @methodOf BB.Directives:bbMap
  * @description
  * Create title for the map selection step
  ###
  # create title for the map selection step
  $scope.title = ->
    ci = $scope.bb.current_item
    if ci.category and ci.category.description
      p1 = ci.category.description
    else
      p1 = $scope.bb.company.extra.department

    return p1 + ' - ' + $scope.$eval('getCurrentStepTitle()')

  ###**
  * @ngdoc method
  * @name searchAddress
  * @methodOf BB.Directives:bbMap
  * @description
  * Search address in according of prms parameter
  *
  * @param {object} prms The parameters of the address
  ###
  $scope.searchAddress = (prms) ->

    # if a reverse geocode has been performed and the address
    # is no  different to one the entered, abort the search
    return false if $scope.reverse_geocode_address and $scope.reverse_geocode_address == $scope.address

    delete $scope.geocoder_result
    prms = {} if !prms
    $scope.search_prms = prms
    $scope.map_init.then () ->
      address = $scope.address
      address = prms.address if prms.address

      if address
        req = {address : address}
        req.region = prms.region if prms.region
        req.componentRestrictions = prms.componentRestrictions if prms.componentRestrictions

        if prms.bounds
          sw = new google.maps.LatLng(prms.bounds.sw.x, prms.bounds.sw.y)
          ne = new google.maps.LatLng(prms.bounds.ne.x, prms.bounds.ne.y)
          req.bounds = new google.maps.LatLngBounds(sw, ne)

        new google.maps.Geocoder().geocode req, (results, status) ->

          $scope.geocoder_result = results[0] if results.length > 0 and status is 'OK'

          if !$scope.geocoder_result or ($scope.geocoder_result and $scope.geocoder_result.partial_match)
            searchPlaces(req)
            return
          else if $scope.geocoder_result
            searchSuccess($scope.geocoder_result)
          else
            searchFailed()
          loader.setLoaded()

    loader.setLoaded()

  ###**
  * @ngdoc method
  * @name searchPlaces
  * @methodOf BB.Directives:bbMap
  * @description
  * Search places in according of prms parameter
  *
  * @param {object} prms The parameters of the places
  ###
  searchPlaces = (prms) ->

    req = {
      query : prms.address
      types: ['shopping_mall', 'store', 'embassy']
    }

    req.bounds = prms.bounds if prms.bounds

    service = new google.maps.places.PlacesService($scope.myMap)
    service.textSearch req, (results, status) ->
      if results.length > 0 and status is 'OK'
        searchSuccess(results[0])
      else if $scope.geocoder_result
        searchSuccess($scope.geocoder_result)
      else
        searchFailed()

  ###**
  * @ngdoc method
  * @name searchSuccess
  * @methodOf BB.Directives:bbMap
  * @description
  * Search has been succeeded, and return
  *
  * @param {object} result The result of the search
  ###
  searchSuccess = (result) ->
    AlertService.clear()
    $scope.search_failed = false
    $scope.loc           = result.geometry.location
    $scope.myMap.setCenter $scope.loc
    $scope.myMap.setZoom 15
    $scope.showClosestMarkers $scope.loc
    $rootScope.$broadcast "map:search_success"

  ###**
  * @ngdoc method
  * @name searchFailed
  * @methodOf BB.Directives:bbMap
  * @description
  * Search failed and displayed an error
  ###
  searchFailed = () ->
    $scope.search_failed = true
    AlertService.raise('LOCATION_NOT_FOUND')
    # need to call apply to update bindings as geocode callback is outside angular library
    $rootScope.$apply()

  ###**
  * @ngdoc method
  * @name validateAddress
  * @methodOf BB.Directives:bbMap
  * @description
  * Validate the address using form
  *
  * @param {object} form The form where address has been validate
  ###
  $scope.validateAddress = (form) ->
    return false if !form
    if form.$error.required
      AlertService.clear()
      AlertService.raise('MISSING_LOCATION')
      return false
    else
      return true

  haversine = (latlong, marker) ->

    pi = Math.PI
    R = 6371  #equatorial radius

    lat1 = latlong.lat()
    lon1 = latlong.lng()

    lat2 = marker.position.lat()
    lon2 = marker.position.lng()

    chLat = lat2-lat1
    chLon = lon2-lon1

    dLat = chLat*(pi/180)
    dLon = chLon*(pi/180)

    rLat1 = lat1*(pi/180)
    rLat2 = lat2*(pi/180)

    a = Math.sin(dLat/2) * Math.sin(dLat/2) +
            Math.sin(dLon/2) * Math.sin(dLon/2) * Math.cos(rLat1) * Math.cos(rLat2)
    c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1-a))
    d = R * c

  ###**
  * @ngdoc method
  * @name showClosestMarkers
  * @methodOf BB.Directives:bbMap
  * @description
  * Display the closest markers
  *
  * @param {array} latlong Using for determinate the closest markers
  ###
  $scope.showClosestMarkers = (latlong) ->

    distances = []
    distances_with_services = []

    for marker in $scope.mapMarkers

      km = haversine(latlong, marker)

      if !$scope.showAllMarkers
        marker.setVisible false

      # set distance to kilometres or convert to miles
      marker.distance = km
      marker.distance *= 0.621371192 if $scope.distance_unit == "miles"

      if marker.distance < $scope.range_limit
        distances.push marker
        distances_with_services.push marker if marker.company.has_service
    distances.sort (a, b) ->
      a.distance - b.distance
    distances_with_services.sort (a, b) ->
      a.distance - b.distance

    $scope.shown_markers = distances.slice(0, $scope.num_search_results)
    $scope.shown_markers_with_services = distances_with_services.slice(0, $scope.num_search_results)

    if $scope.options and $scope.filter_by_service
      $scope.shownMarkers = $scope.shown_markers_with_services
    else
      $scope.shownMarkers = $scope.shown_markers

    $timeout ->
      setMarkers()

  setMarkers = () ->

    latlong = $scope.loc

    localBounds = new google.maps.LatLngBounds()
    localBounds.extend(latlong)
    index = 1

    for marker in $scope.shownMarkers
      if $scope.numberedPin
        iconPath = $window.sprintf($scope.numberedPin, index)
        marker.setIcon(iconPath)

      marker.setVisible true
      marker.setMap $scope.myMap
      localBounds.extend(marker.position)
      index += 1

    $scope.$emit 'map:shown_markers_updated', $scope.shownMarkers

    google.maps.event.trigger($scope.myMap, 'resize')
    $scope.myMap.fitBounds(localBounds)

    open_marker_index = 0
    open_marker = _.find $scope.shownMarkers, (obj) ->
      open_marker_index++
      obj.company.id == $scope.bb.current_item.company.id
    if open_marker
      open_marker_index--
    else
      open_marker_index = 0
    $scope.shownMarkers[open_marker_index].is_open = true
    $scope.openMarkerInfo $scope.shownMarkers[open_marker_index]

  ###**
  * @ngdoc method
  * @name openMarkerInfo
  * @methodOf BB.Directives:bbMap
  * @description
  * Display marker information on the map
  *
  * @param {object} marker The marker
  ###
  $scope.openMarkerInfo = (marker) ->
    $timeout ->
      $scope.currentMarker = marker
      $scope.myInfoWindow.open($scope.myMap, marker)
    , 250

  ###**
  * @ngdoc method
  * @name selectItem
  * @methodOf BB.Directives:bbMap
  * @description
  * Select an item from map
  *
  * @param {array} item The Map or BookableItem to select
  * @param {string=} route A specific route to load
  ###
  $scope.selectItem = (company, route) ->
    return if !$scope.$debounce(1000)

    if !company
      AlertService.warning(ErrorService.getError('STORE_NOT_SELECTED'))
      return

    loader.notLoaded()

    # if the selected store changes, emit an event. the form data store uses
    # this to clear data, but it can be used to action anything.
    if $scope.selectedStore and $scope.selectedStore.id isnt company.id
      $scope.$emit 'change:storeLocation'

    $scope.selectedStore = company

    # Add answers object to the item_defaults if questions have already been asked before the map step
    if $scope.bb.current_item.item_details and $scope.bb.current_item.item_details.questions
      setAnswers()

    if company.service
      $scope.bb.item_defaults.service = company.service.id

    init_obj =
      company_id: company.id
      item_defaults: $scope.bb.item_defaults
    init_obj.first_page = route if route

    $scope.initWidget init_obj

  setAnswers = ->
    answers = {}
    for q in $scope.bb.current_item.item_details.questions
      answers["q_" + q.name] = q.answer
    $scope.bb.item_defaults.answers = answers if !_.isEmpty answers

  ###**
  * @ngdoc method
  * @name roundNumberUp
  * @methodOf BB.Directives:bbMap
  * @description
  * Calculate the round number up
  *
  * @param {integer} num The number of places
  * @param {object} places The places
  ###
  $scope.roundNumberUp = (num, places) ->
    Math.round(num * Math.pow(10, places)) / Math.pow(10, places)

  ###**
  * @ngdoc method
  * @name geolocate
  * @methodOf BB.Directives:bbMap
  * @description
  * Get geolocation information
  ###
  $scope.geolocate = () ->
    return false if !navigator.geolocation || ($scope.reverse_geocode_address and $scope.reverse_geocode_address == $scope.address)

    loader.notLoaded()

    webshim.ready 'geolocation', ->
      # set timeout as 5 seconds and max age as 1 hour
      options = {timeout: 5000, maximumAge: 3600000}
      navigator.geolocation.getCurrentPosition(reverseGeocode, geolocateFail, options)

  ###**
  * @ngdoc method
  * @name geolocateFail
  * @methodOf BB.Directives:bbMap
  * @description
  * Geolocation fail and display an error message
  *
  * @param {object} error The error
  ###
  geolocateFail = (error) ->
    switch error.code
      # if the geocode failed because the position was unavailable or the request timed out, raise an alert
      when 2, 3
        loader.setLoaded()
        AlertService.raise('GEOLOCATION_ERROR')
      else
        loader.setLoaded()
    $scope.$apply()

  ###**
  * @ngdoc method
  * @name reverseGeocode
  * @methodOf BB.Directives:bbMap
  * @description
  * Reverse geocode in according of position parameter
  *
  * @param {object} positon The postion get latitude and longitude from google maps api
  ###
  reverseGeocode = (position) ->
    lat    = parseFloat(position.coords.latitude)
    long   = parseFloat(position.coords.longitude)
    latlng = new google.maps.LatLng(lat, long)

    new google.maps.Geocoder().geocode {'latLng': latlng}, (results, status) ->
      if results.length > 0 and status is 'OK'
        $scope.geocoder_result = results[0]

        for ac in $scope.geocoder_result.address_components
          $scope.reverse_geocode_address = ac.long_name if ac.types.indexOf("route") >= 0
          $scope.reverse_geocode_address += ', ' + ac.long_name if ac.types.indexOf("locality") >= 0
          $scope.address = $scope.reverse_geocode_address
        searchSuccess($scope.geocoder_result)
      loader.setLoaded()


  ###**
  * @ngdoc method
  * @name increaseRange
  * @methodOf BB.Directives:bbMap
  * @description
  * Increase range, the range limit is infinity
  ###
  $scope.increaseRange = () ->
    $scope.range_limit = Infinity
    $scope.searchAddress($scope.search_prms)

  # look for change in display size to determine if the map needs to be refreshed
  $scope.$watch 'display.xs', (new_value, old_value) =>
    if new_value != old_value and $scope.loc
      $scope.myInfoWindow.close()
      $scope.myMap.setCenter $scope.loc
      $scope.myMap.setZoom 15
      $scope.showClosestMarkers $scope.loc


  $rootScope.$on 'widget:restart', () ->
    $scope.loc = null
    $scope.reverse_geocode_address = null
    $scope.address = null

