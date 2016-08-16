'use strict';


###**
* @ngdoc service
* @name BB.Models:BBWidget
*
* @description
* Representation of an BBWidget Object
*
* @property {integer} uid The unique id of the widget
* @property {string} page_suffix Widget page suffix
* @property {array} steps The widget steps
* @property {array} allSteps The all steps of the widget
* @property {object} item_defaults Widget defaults item
* @property {boolean} Checks if widget using basket or not
* @property {boolean} confirmCheckout Checks if widget confirm is checkout or not
* @property {boolean} isAdm,in Verify if user is admin
* @property {string} payment_status The payment status
####


# This class contrains handy functions and variables used in building and displaying a booking widget

angular.module('BB.Models').factory "BBWidget", ($q, BBModel, BasketService, $urlMatcherFactory, $location, BreadcrumbService, $window, $rootScope, PathHelper, SettingsService ) ->


  class Widget


    constructor: () ->
      # uid used to store form data for user journeys
      @uid = _.uniqueId 'bbwidget_'
      @page_suffix = ""
      @steps = []
      @allSteps = []
      @item_defaults = {}
      @usingBasket = false  # bu defalt we're not going to use a basket
      @confirmCheckout = false
      @isAdmin = false
      @payment_status = null


    ###**
    * @ngdoc method
    * @name pageURL
    * @methodOf BB.Models:BBWidget
    * @description
    * Get page url in according of route
    *
    * @returns {object} The returned the page url
    ###
    pageURL: (route) ->
      route + '.html'

    ###**
    * @ngdoc method
    * @name updateRoute
    * @methodOf BB.Models:BBWidget
    * @description
    * Update page route
    *
    * @returns {string} The returned the url
    ###
    updateRoute: (page) ->
      return if !@routeFormat

      page ||= @current_page
      pattern = $urlMatcherFactory.compile(@routeFormat)
      service_name = "-"
      event_group = "-"
      event = "-"
      if @current_item
        service_name = @convertToDashSnakeCase(@current_item.service.name) if @current_item.service
        event_group = @convertToDashSnakeCase(@current_item.event_group.name) if @current_item.event_group
        event =  @current_item.event.id if @current_item.event
        date = @current_item.date.date.toISODate() if @current_item.date
        time = @current_item.time.time if @current_item.time
        company = @convertToDashSnakeCase(@current_item.company.name) if @current_item.company
      prms = angular.copy(@route_values) if @route_values
      prms ||= {}
      angular.extend(prms,{page: page, company: company, service: service_name, event_group: event_group, date: date, time: time, event: event})
      url = pattern.format(prms)
      url = url.replace(/\/+$/, "")
      $location.path(url)
      @routing = true

      return url

    ###**
    * @ngdoc method
    * @name setRouteFormat
    * @methodOf BB.Models:BBWidget
    * @description
    * Set route format
    *
    * @returns {object} The returned the match
    ###
    setRouteFormat: (route) ->
      @routeFormat = route
      return if !@routeFormat

      @routing = true

      match = PathHelper.matchRouteToPath(@routeFormat)

      if match
        @item_defaults.company = decodeURIComponent(match.company) if match.company
        @item_defaults.service = decodeURIComponent(match.service) if match.service && match.service != "-"
        @item_defaults.event_group = match.event_group if match.event_group && match.event_group != "-"
        @item_defaults.event = decodeURIComponent(match.event) if match.event && match.event != "-"
        @item_defaults.person = decodeURIComponent(match.person) if match.person
        @item_defaults.resource = decodeURIComponent(match.resource) if match.resource
        @item_defaults.resources = decodeURIComponent(match.resoures) if match.resources
        @item_defaults.date = match.date if match.date
        @item_defaults.time = match.time if match.time
        @route_matches = match


    ###**
    * @ngdoc method
    * @name matchURLToStep
    * @methodOf BB.Models:BBWidget
    * @description
    * Match url to step
    *
    * @returns {integer} Returns the step number
    ###

    matchURLToStep: () ->

      page = PathHelper.matchRouteToPath(@routeFormat, 'page')
      step = _.findWhere(@allSteps, {page: page})

      if step
        return step.number
      else
        return null

    ###**
    * @ngdoc method
    * @name convertToDashSnakeCase
    * @methodOf BB.Models:BBWidget
    * @description
    * Convert to dash snake case in according of str parameter
    *
    * @returns {string} The returned str
    ###
    convertToDashSnakeCase: (str) ->
        str = str.toLowerCase();
        str = $.trim(str)
        # replace all punctuation and special chars
        str = str.replace(/[\-\[\]\/\{\}\(\)\*\+\?\.\\\^\$\|'’!<>;:,.~`=+-@£&%"]/g, '')
        # replace any double or more spaces
        str = str.replace(/\s{2,}/g, ' ')
        # convert to sanke case
        str = str.replace(/\s/g, '-')
        return str

    ###**
    * @ngdoc method
    * @name recordCurrentPage
    * @methodOf BB.Models:BBWidget
    * @description
    * Records the current page and determines the current step from either the predefined steps or the steps that have been passed already
    *
    * @returns {string} The returned record step
    ###
    recordCurrentPage: () =>

      setDocumentTitle = (title) ->
        document.title = title if SettingsService.update_document_title and title

      if !@current_step
        @current_step = 0
      match = false
      # can we find a match for this step against either previous or existing steps?
      # first check the pre-defined steps
      if @allSteps
        for step in @allSteps
          if step.page == @current_page
            @current_step = step.number
            setDocumentTitle(step.title)
            match = true
      # now check the previously visited steps
      if !match
        for step in @steps
          if step && step.page == @current_page
            @current_step = step.number
            setDocumentTitle(step.title)
            match = true
      # if still not found - assume it's a new 'next' page and add 1 to the step count
      if !match
        @current_step += 1

      title = ""
      if @allSteps
        for step in @allSteps
          step.active = false
          step.passed = step.number < @current_step
        if @allSteps[@current_step-1]
          @allSteps[@current_step-1].active = true
          title = @allSteps[@current_step-1].title
      @recordStep(@current_step, title)

    ###**
    * @ngdoc method
    * @name recordStep
    * @methodOf BB.Models:BBWidget
    * @description
    * Record step in according of step and title parameters. Calculate percentile complete
    *
    * @returns {boolean} If is the last step or not
    ###
    recordStep: (step_number, title) =>

      @steps[step_number-1] = {
        url: @updateRoute(@current_page),
        current_item: @current_item.getStep(),
        page: @current_page,
        number: step_number,
        title: title,
        stacked_length: @stacked_items.length
      }

      BreadcrumbService.setCurrentStep(step_number)

      for step in @steps

        if step
          step.passed = step.number < @current_step
          step.active = step.number == @current_step

        if step and step.number is step_number
          @calculatePercentageComplete(step.number)

      # check if we're at the last step
      if (@allSteps && @allSteps.length == step_number ) || @current_page == 'checkout'
        @last_step_reached = true
      else
        @last_step_reached = false

    ###**
    * @ngdoc method
    * @name calculatePercentageComplete
    * @methodOf BB.Models:BBWidget
    * @description
    * Calculate percentage complete in according of step number parameter
    *
    * @returns {integer} The returned percentage complete
    ###
    calculatePercentageComplete: (step_number) =>
      @percentage_complete = if step_number && @allSteps then step_number / @allSteps.length * 100 else 0

    ###**
    * @ngdoc method
    * @name setRoute
    * @methodOf BB.Models:BBWidget
    * @description
    * Set route data
    *
    * @returns {object} The returned route set
    ###
    # setup full route data
    setRoute: (rdata) =>
      @allSteps.length = 0
      @nextSteps = {}
      @firstStep = rdata[0].page unless rdata is undefined || rdata is null || rdata[0] is undefined
      for step, i in rdata
        @disableGoingBackAtStep = i+1 if step.disable_breadcrumbs
        if rdata[i+1]
          @nextSteps[step.page] = rdata[i+1].page
        @allSteps.push({number: i+1, title: step.title, page: step.page})
        if step.when
          @routeSteps ||= {}
          for route in step.when
            @routeSteps[route] = step.page
      if @$wait_for_routing
        @$wait_for_routing.resolve()

    ###**
    * @ngdoc method
    * @name setBasicRoute
    * @methodOf BB.Models:BBWidget
    * @description
    * Set basic route in according of routes parameter
    *
    * @returns {object} The returned route set
    ###
    setBasicRoute: (routes) =>
      @nextSteps = {}
      @firstStep = routes[0]
      for step, i in routes
        @nextSteps[step] = routes[i+1]
      if @$wait_for_routing
        @$wait_for_routing.resolve()

    ###**
    * @ngdoc method
    * @name waitForRoutes
    * @methodOf BB.Models:BBWidget
    * @description
    * Wait for route
    *
    * @returns {object}  The returned waiting route
    ###
    waitForRoutes: () =>
      if !@$wait_for_routing
        @$wait_for_routing = $q.defer()


    ###############################################################
    # stacking items

    ###**
    * @ngdoc method
    * @name stackItem
    * @methodOf BB.Models:BBWidget
    * @description
    * Push item in stacked items in according of item parameter
    *
    * @returns {array} The returned sorted stacked items
    ###
    stackItem: (item) =>
      @stacked_items.push(item)
      @sortStackedItems()
      @current_item = item if @stacked_items.length is 1

    ###**
    * @ngdoc method
    * @name setStackedItems
    * @methodOf BB.Models:BBWidget
    * @description
    * Set stacket items in according of items parameter
    *
    * @returns {array} The returned sorted stacked items
    ###
    setStackedItems: (items) =>
      @stacked_items = items
      @sortStackedItems()

    ###**
    * @ngdoc method
    * @name sortStackedItems
    * @methodOf BB.Models:BBWidget
    * @description
    * Sort stacked items
    *
    * @returns {array} The returned sorted stacked items
    ###
    sortStackedItems: =>
      # make sure all of the cats resolved
      arr = []
      for item in @stacked_items
        arr = arr.concat(item.promises)

      $q.all(arr)['finally'] () =>
        @stacked_items = @stacked_items.sort (a, b) =>
          if a.time && b.time
            a.time.time > b.time.time ? 1 : -1
          else if a.service.category && !b.service.category
            1
          else if b.service.category && !a.service.category
            -1
          else if !b.service.category && !a.service.category
            1
          else
            a.service.category.order > b.service.category.order ? 1 : -1

    ###**
    * @ngdoc method
    * @name deleteStackedItem
    * @methodOf BB.Models:BBWidget
    * @description
    * Delete stacked item in according of item parameter
    *
    * @returns {array} The returned stacked items
    ###
    deleteStackedItem: (item) =>
      if item && item.id
        BasketService.deleteItem(item, @company, {bb: @})

      @stacked_items = @stacked_items.filter (i) -> i isnt item

    ###**
    * @ngdoc method
    * @name removeItemFromStack
    * @methodOf BB.Models:BBWidget
    * @description
    * Remove item from stack in according of item parameter
    *
    * @returns {array} The returned stacked items
    ###
    removeItemFromStack: (item) =>
      @stacked_items = @stacked_items.filter (i) -> i isnt item

    ###**
    * @ngdoc method
    * @name deleteStackedItemByService
    * @methodOf BB.Models:BBWidget
    * @description
    * Delete stacked item bu service in according of item parameter
    *
    * @returns {array} The returned stacked items
    ###
    deleteStackedItemByService: (item) =>
      for i in @stacked_items
        if i && i.service && i.service.self == item.self && i.id
          BasketService.deleteItem(i, @company, {bb: @})
      @stacked_items = @stacked_items.filter (i) -> (i && i.service && i.service.self isnt item.self)

    ###**
    * @ngdoc method
    * @name emptyStackedItems
    * @methodOf BB.Models:BBWidget
    * @description
    * Empty stacked items
    *
    * @returns {array} The returned stacked items empty
    ###
    emptyStackedItems: () =>
      @stacked_items = []

    ###**
    * @ngdoc method
    * @name pushStackToBasket
    * @methodOf BB.Models:BBWidget
    * @description
    * Push stack to basket
    *
    * @returns {array} The returned stacked items
    ###
    pushStackToBasket: () ->
      @basket ||= new new BBModel.Basket(null, @)
      for i in @stacked_items
        @basket.addItem(i)
      @emptyStackedItems()

    ###**
    * @ngdoc method
    * @name totalStackedItemsDuration
    * @methodOf BB.Models:BBWidget
    * @description
    * Total stacked items duration
    *
    * @returns {array} The returned duration
    ###
    totalStackedItemsDuration: ->
      duration = 0
      for item in @stacked_items
        duration += item.service.listed_duration if item.service and item.service.listed_duration
      return duration

    ###**
    * @ngdoc method
    * @name clearStackedItemsDateTime
    * @methodOf BB.Models:BBWidget
    * @description
    * Clear stacked items date and time
    *
    * @returns {array} The returned item with date and time clear
    ###
    clearStackedItemsDateTime: ->
      for item in @stacked_items
        item.clearDateTime()

    ###**
    * @ngdoc method
    * @name clearAddress
    * @methodOf BB.Models:BBWidget
    * @description
    * Clear address
    *
    * @returns {string} The returned address clear
    ###
    # Address methods
    clearAddress: () =>
      delete @address1
      delete @address2
      delete @address3
      delete @address4
      delete @address5
