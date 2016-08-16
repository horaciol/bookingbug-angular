'use strict'


###**
* @ngdoc directive
* @name BB.Directives:bbEvents
* @restrict AE
* @scope true
*
* @description
*
* Loads a list of events for the currently in scope company
*
* <pre>
* restrict: 'AE'
* replace: true
* scope: true
* </pre>
*
* @param {hash}  bbEvents A hash of options
* @property {integer} total_entries The event total entries
* @property {array} events The events array

####


angular.module('BB.Directives').directive 'bbEvents', () ->
  restrict: 'AE'
  replace: true
  scope : true
  controller : 'EventList'

  link : (scope, element, attrs) ->

    scope.summary = attrs.summary?
    scope.events_options = scope.$eval(attrs.bbEvents) or {}

    # set the mode
    # 0 = Event summary (gets year summary and loads events a day at a time)
    # 1 = Next 100 events (gets next 100 events)
    # 2 = Next 100 events and event summary (gets event summary, loads next 100 events, and gets more events if requested)
    scope.mode = if scope.events_options and scope.events_options.mode then scope.events_options.mode else 0
    scope.mode = 0 if scope.summary

    # set the total number of events loaded?
    scope.per_page = scope.events_options.per_page if scope.events_options and scope.events_options.per_page

    return


angular.module('BB.Controllers').controller 'EventList', ($scope, $rootScope, EventService, EventChainService, $q, PageControllerService, FormDataStoreService, $filter, BBModel, $timeout) ->

  $scope.controller = "public.controllers.EventList"
  $scope.notLoaded $scope
  angular.extend(this, new PageControllerService($scope, $q))
  $scope.pick = {}
  $scope.start_date = moment()
  $scope.end_date = moment().add(2, 'year')
  $scope.filters = {hide_sold_out_events: false}
  $scope.pagination = BBModel.Pagination({page_size: 10, max_size: 5, request_page_size: 100})
  $scope.events = {}
  $scope.fully_booked = false
  $scope.event_data_loaded = false

  FormDataStoreService.init 'EventList', $scope, [
    'selected_date',
    'event_group_id',
    'event_group_manually_set'
  ]

  $rootScope.connection_started.then ->
    if $scope.bb.company

      # if there's a default event, skip this step
      if $scope.bb.current_item.defaults and $scope.bb.current_item.defaults.event
        $scope.skipThisStep()
        $scope.decideNextPage()
        return
      else if $scope.bb.company.$has('parent') && !$scope.bb.company.$has('company_questions')
        $scope.bb.company.getParentPromise().then (parent) ->
          $scope.company_parent = parent
          $scope.initialise()
        , (err) -> $scope.setLoadedAndShowError($scope, err, 'Sorry, something went wrong')
      else
        $scope.initialise()

  , (err) -> $scope.setLoadedAndShowError($scope, err, 'Sorry, something went wrong')


  $scope.initialise = () ->

    $scope.notLoaded $scope

    delete $scope.selected_date if $scope.mode != 0

    # has the event group been manually set (i.e. in the step before)
    if !$scope.event_group_manually_set and !$scope.current_item.event_group?
      $scope.event_group_manually_set = if !$scope.event_group_manually_set? and $scope.current_item.event_group? then true else false

    # clear current item
    if $scope.bb.current_item.event
      event_group = $scope.current_item.event_group
      $scope.clearBasketItem()
      # TODO only remove the basket items added in this session
      $scope.emptyBasket()
      $scope.current_item.setEventGroup(event_group) if $scope.event_group_manually_set

    promises = []

    # company question promise
    if $scope.bb.company.$has('company_questions')
      promises.push($scope.bb.company.getCompanyQuestionsPromise())
    else if $scope.company_parent? && $scope.company_parent.$has('company_questions')
      promises.push($scope.company_parent.getCompanyQuestionsPromise())
    else
      promises.push($q.when([]))
      $scope.has_company_questions = false

    # event group promise
    if !$scope.current_item.event_group and $scope.bb.company.$has('event_groups')
      promises.push($scope.bb.company.getEventGroupsPromise())
    else
      promises.push($q.when([]))

    # event summary promise
    if $scope.mode is 0 or $scope.mode is 2
      promises.push($scope.loadEventSummary())
    else
      promises.push($q.when([]))

    # event data promise
    # TODO - always load some event data?
    if $scope.mode is 1 or $scope.mode is 2

      comp = $scope.bb.company
      params = 
        page_group_to_load   : 1

      promises.push($scope.loadEventData(comp, params))
    else
      promises.push($q.when([]))


    $q.all(promises).then (result) ->
      company_questions = result[0]
      event_groups      = result[1]
      event_summary     = result[2]
      event_data        = result[3]

      $scope.has_company_questions = company_questions? && company_questions.length > 0
      buildDynamicFilters(company_questions) if company_questions
      $scope.event_groups = event_groups

      # Add EventGroup to Event so we don't have to make network requests using item.getGroup() from the view
      event_groups_collection = _.indexBy(event_groups, 'id')
      if $scope.items
        for item in $scope.items
          item.group = event_groups_collection[item.service_id]

      # Remove loading icon
      $scope.setLoaded $scope

    , (err) -> $scope.setLoadedAndShowError($scope, err, 'Sorry, something went wrong')

  ###**
  * @ngdoc method
  * @name loadEventSummary
  * @methodOf BB.Directives:bbEvents
  * @description
  * Load event summary
  ###
  $scope.loadEventSummary = () ->
    
    deferred = $q.defer()
    current_event = $scope.current_item.event

    # de-select the event chain if there's one already picked - as it's hiding other events in the same group
    if $scope.bb.current_item && ($scope.bb.current_item.event_chain_id || $scope.bb.current_item.event_chain)
      delete $scope.bb.current_item.event_chain
      delete $scope.bb.current_item.event_chain_id

    comp = $scope.bb.company

    params = 
      item       : $scope.bb.current_item
      start_date : $scope.start_date.toISODate()
      end_date   : $scope.end_date.toISODate()
    
    params.event_chain_id = $scope.bb.item_defaults.event_chain.id if $scope.bb.item_defaults.event_chain

    EventService.summary(comp, params).then (items) ->

      if items and items.length > 0

        item_dates = []
        for item in items
          d = moment(item)
          item_dates.push({
            date   : d,
            idate  : parseInt(d.format("YYYYDDDD")),
            count  : 1,
            spaces : 1,
          })

        $scope.item_dates = item_dates.sort (a,b) -> (a.idate - b.idate)

        # TODO clear the selected date if the event group has changed (but only when event group has been explicity set)
        # if $scope.current_item? and $scope.current_item.event_group?
        #   if $scope.current_item.event_group.id != $scope.event_group_id
        #     $scope.showDay($scope.item_dates[0].date)
        #   $scope.event_group_id = $scope.current_item.event_group.id

        # if the selected date is within range of the dates loaded, show it, else show the first day loaded
        if $scope.mode is 0
          if ($scope.selected_date and ($scope.selected_date.isAfter($scope.item_dates[0].date) or $scope.selected_date.isSame($scope.item_dates[0].date)) and ($scope.selected_date.isBefore($scope.item_dates[$scope.item_dates.length-1].date) || $scope.selected_date.isSame($scope.item_dates[$scope.item_dates.length-1].date)))
            $scope.showDay($scope.selected_date)
          else
            $scope.showDay($scope.item_dates[0].date)

      deferred.resolve($scope.item_dates)

    , (err) -> deferred.reject()

    return deferred.promise


  ###**
  * @ngdoc method
  * @name loadEventChainData
  * @methodOf BB.Directives:bbEvents
  * @description
  * Load event chain data in according of comp parameter
  *
  * @param {array} comp The company
  ###
  $scope.loadEventChainData = (comp, params) ->

    deferred = $q.defer()

    if $scope.bb.item_defaults.event_chain
      deferred.resolve([])
    else
      comp ||= $scope.bb.company

      params =
        item       : $scope.bb.current_item
        start_date : if params and params.start_date then params.start_date else $scope.start_date.toISODate()
        end_date   : if params and params.end_date then params.end_date else $scope.end_date.toISODate()
        
      params.embed = $scope.events_options.embed if $scope.events_options.embed

      EventChainService.query(comp, params).then (event_chains) ->

        deferred.resolve(event_chains)
      , (err) ->  deferred.reject()

    return deferred.promise

  ###**
  * @ngdoc method
  * @name loadEventData
  * @methodOf BB.Directives:bbEvents
  * @description
  * Load event data. De-select the event chain if there's one already picked - as it's hiding other events in the same group
  *
  * @param {array} comp The company parameter
  ###
  $scope.loadEventData = (comp, params) ->

    $scope.notLoaded $scope

    $scope.event_data_loaded = false

    # clear the items when in summary mode
    delete $scope.items if $scope.mode is 0

    deferred = $q.defer()

    current_event = $scope.current_item.event

    comp ||= $scope.bb.company

    # de-select the event chain if there's one already picked - as it's hiding other events in the same group
    if $scope.bb.current_item && ($scope.bb.current_item.event_chain_id || $scope.bb.current_item.event_chain)
      delete $scope.bb.current_item.event_chain
      delete $scope.bb.current_item.event_chain_id

    params =
      item                 : $scope.bb.current_item
      start_date           : if params and params.start_date then params.start_date.toISODate() else $scope.start_date.toISODate()
      end_date             : if params and params.end_date then params.end_date.toISODate() else $scope.end_date.toISODate()
      page                 : 1
      per_page             : if params and params.page_group_to_load then ($scope.pagination.page_size * $scope.pagination.max_size * params.page_group_to_load) + 1 else 100
      include_non_bookable : if params and params.include_non_bookable then params.include_non_bookable else true

    params.event_chain_id = $scope.bb.item_defaults.event_chain.id if $scope.bb.item_defaults.event_chain

    params.per_page = $scope.per_page if $scope.per_page

    chains = $scope.loadEventChainData(comp, params)
    $scope.events = {}

    EventService.query(comp, params).then (events) ->

      # Flatten events array
      $scope.items = _.flatten(events)

      # Add spaces_left prop - so we don't need to use ng-init="spaces_left = getSpacesLeft()" in the html template
      for item in $scope.items
        item.spaces_left = item.getSpacesLeft()

      # Add address prop from the company to the item
      if $scope.bb.company.$has('address')
        $scope.bb.company.getAddressPromise().then (address) ->
          for item in $scope.items
            item.address = address

      # TODO make this behave like the frame timetable
      # get all data then process events
      chains.then () ->

        # get more event details
        for item in $scope.items
          item.prepEvent {embed: 'events'}
          # check if the current item already has the same event selected
          if $scope.mode is 0 and current_event and current_event.self == item.self
            item.select()
            $scope.event = item

        # only build item_dates if we're in 'next 100 event' mode
        if $scope.mode is 1
          item_dates = {}
          if items.length > 0
            for item in items
              item.getDuration()
              idate = parseInt(item.date.format("YYYYDDDD"))
              item.idate = idate
              if !item_dates[idate]
                item_dates[idate] = {date:item.date, idate: idate, count:0, spaces:0}
              item_dates[idate].count  += 1
              item_dates[idate].spaces += item.num_spaces
            $scope.item_dates = []
            for x,y of item_dates
              $scope.item_dates.push(y)
            $scope.item_dates = $scope.item_dates.sort (a,b) -> (a.idate - b.idate)
          else
            idate = parseInt($scope.start_date.format("YYYYDDDD"))
            $scope.item_dates = [{date:$scope.start_date, idate: idate, count:0, spaces:0}]

        # determine if all events are fully booked
        $scope.isFullyBooked()

        $scope.filtered_items = $scope.items

        # run the filters to ensure any default filters get applied
        $scope.filterChanged()

        # update the paging
        $scope.pagination.update()

        $scope.setLoaded $scope
        $scope.event_data_loaded = true

        deferred.resolve($scope.items)

      , (err) ->  deferred.reject()
    , (err) ->  deferred.reject()
    return deferred.promise

  ###**
  * @ngdoc method
  * @name isFullyBooked
  * @methodOf BB.Directives:bbEvents
  * @description
  * Verify if the items from event list are be fully booked
  ###
  $scope.isFullyBooked = () ->
    full_events = []
    for item in $scope.items
      full_events.push(item) if item.num_spaces == item.spaces_booked
    return $scope.fully_booked = true if full_events.length == $scope.items.length

  ###**
  * @ngdoc method
  * @name showDay
  * @methodOf BB.Directives:bbEvents
  * @description
  * Selects a day or filters events by day selected
  *
  * @param {moment} the day to select or filter by
  ###
  $scope.showDay = (date) ->

    return if !moment.isMoment(date)

    if $scope.mode is 0
      # unselect the event if it's not on the day being selected
      delete $scope.event if $scope.event and !$scope.selected_date.isSame(date, 'day')
      new_date = date
    else
      new_date = date if !$scope.selected_date or !date.isSame($scope.selected_date, 'day')

    if new_date
      $scope.selected_date = new_date
      $scope.filters.date  = new_date.toDate()

      comp = $scope.bb.company
      params = 
        page_group_to_load   : 1
        start_date : moment(date)
        end_date : moment(date)
      $scope.loadEventData(comp, params)

    else
      delete $scope.selected_date
      delete $scope.filters.date

    $scope.filterChanged()


  $scope.$watch 'pick.date', (new_val, old_val) =>
    if new_val
      comp = $scope.bb.company
      params = 
        start_date : moment(new_val)
        end_date : moment(new_val)
      $scope.loadEventData(comp, params)


  ###**
  * @ngdoc method
  * @name selectItem
  * @methodOf BB.Directives:bbEvents
  * @description
  * Select an item into the current event list in according of item and route parameters
  *
  * @param {array} item The Event or BookableItem to select
  * @param {string=} route A specific route to load
  ###
  $scope.selectItem = (item, route) =>
    return false unless (item.getSpacesLeft() <= 0 && $scope.bb.company.settings.has_waitlists) || item.hasSpace()
    $scope.notLoaded $scope
    if $scope.$parent.$has_page_control
      $scope.event.unselect() if $scope.event
      $scope.event = item
      $scope.event.select()
      $scope.setLoaded $scope
      return false
    else
      if $scope.bb.moving_purchase
        i.setEvent(item) for i in $scope.bb.basket.items
      $scope.bb.current_item.setEvent(item)
      $scope.bb.current_item.ready = false
      $q.all($scope.bb.current_item.promises).then () ->
        $scope.decideNextPage(route)
      , (err) ->  $scope.setLoadedAndShowError($scope, err, 'Sorry, something went wrong')
      return true


  ###**
  * @ngdoc method
  * @name setReady
  * @methodOf BB.Directives:bbEvents
  * @description
  * Set this page section as ready - see {@link BB.Directives:bbPage Page Control}
  ###
  $scope.setReady = () ->
    return false if !$scope.event
    $scope.bb.current_item.setEvent($scope.event)
    return true


  ###**
  * @ngdoc method
  * @name filterEvents
  * @methodOf BB.Directives:bbEvents
  * @description
  * Filter events from the event list in according of item parameter
  *
  * @param {array} item The Event or BookableItem to select
  ###
  $scope.filterEvents = (item) ->
    result = (moment($scope.filters.date).isSame(item.date, 'day') or !$scope.filters.date?) and
      (($scope.filters.event_group and item.service_id == $scope.filters.event_group.id) or !$scope.filters.event_group?) and
      (($scope.filters.price? and (item.price_range.from <= $scope.filters.price)) or !$scope.filters.price?) and
      (($scope.filters.hide_sold_out_events and item.bookable) or !$scope.filters.hide_sold_out_events) and
      $scope.filterEventsWithDynamicFilters(item)
    return result


  $scope.filterEventsWithDynamicFilters = (item) ->

    return true if !$scope.has_company_questions or !$scope.dynamic_filters

    result = true

    for type in $scope.dynamic_filters.question_types
      if type is 'check'
        for dynamic_filter in $scope.dynamic_filters['check']
          name = dynamic_filter.name.parameterise('_')
          filter = false
          if item.chain and item.chain.extra[name]
            for i in item.chain.extra[name]
              filter = ($scope.dynamic_filters.values[dynamic_filter.name] and i is $scope.dynamic_filters.values[dynamic_filter.name].name) or !$scope.dynamic_filters.values[dynamic_filter.name]?
              break if filter
          else if (item.chain.extra[name] is undefined && (_.isEmpty($scope.dynamic_filters.values) || !$scope.dynamic_filters.values[dynamic_filter.name]?))
            filter = true;
          result = result and filter
      else
        for dynamic_filter in $scope.dynamic_filters[type]
          name = dynamic_filter.name.parameterise('_')
          filter = ($scope.dynamic_filters.values[dynamic_filter.name] and item.chain.extra[name] is $scope.dynamic_filters.values[dynamic_filter.name].name) or !$scope.dynamic_filters.values[dynamic_filter.name]?
          result = result and filter
    return result


  ###**
  * @ngdoc method
  * @name filterDateChanged
  * @methodOf BB.Directives:bbEvents
  * @description
  * Filtering data exchanged from the list of events
  ###
  $scope.filterDateChanged = (options = {reset: false}) ->
    if $scope.filters.date
      date = moment($scope.filters.date)
      $scope.$broadcast "event_list_filter_date:changed", date
      $scope.showDay(date)
      if options.reset == true || !$scope.selected_date?
        $timeout () ->
          delete $scope.filters.date
        , 250


  ###**
  * @ngdoc method
  * @name resetFilters
  * @methodOf BB.Directives:bbEvents
  * @description
  * Reset the filters
  ###
  $scope.resetFilters = () ->
    $scope.filters = {}
    $scope.dynamic_filters.values = {} if $scope.has_company_questions
    comp = $scope.bb.company
    params = 
      page_group_to_load   : 1
    $scope.loadEventData(comp, params)
    $scope.filterChanged()


  # build dynamic filters using company questions
  buildDynamicFilters = (questions) ->
    $scope.dynamic_filters                = _.groupBy(questions, 'question_type')
    $scope.dynamic_filters.question_types = _.uniq(_.pluck(questions, 'question_type'))
    $scope.dynamic_filters.values         = {}


  # TODO build price filter by determiniug price range, if range is large enough, display price filter
  # buildPriceFilter = () ->
  #   for item in items


  sort = () ->
   # TODO allow sorting by price/date (default)


  ###**
  * @ngdoc method
  * @name filterChanged
  * @methodOf BB.Directives:bbEvents
  * @description
  * Change filter of the event list
  ###
  $scope.filterChanged = () ->
    if $scope.items
      $scope.filtered_items = $filter('filter')($scope.items, $scope.filterEvents)
      $scope.pagination.num_items = $scope.filtered_items.length
      $scope.filter_active = $scope.filtered_items.length != $scope.items.length
      $scope.pagination.update()

  ###**
  * @ngdoc method
  * @name pageChanged
  * @methodOf BB.Directives:bbEvents
  * @description
  * Change page of the event list
  ###
  $scope.pageChanged = () ->

    if $scope.pagination.current_page is $scope.pagination.num_pages
      comp = $scope.bb.company

      params = 
        page_group_to_load : Math.ceil($scope.pagination.current_page / $scope.pagination.max_size)

      $scope.loadEventData(comp, params)


    $scope.pagination.update()
    $rootScope.$broadcast "page:changed"


  # TODO load more events when end of initial collection is reached/next collection is requested/data is loaded when no event data is present
  # $scope.$on 'month_picker:month_changed', (event, month, last_month_shown) ->
  #   return if !$scope.items or $scope.mode is 0
  #   last_event = _.last($scope.items).date
  #   # if the last event is in the same month as the last one shown, get more events
  #   if last_month_shown.start_date.isSame(last_event, 'month')
  #     $scope.start_date = last_month_shown.start_date
  #     $scope.loadEventData()
