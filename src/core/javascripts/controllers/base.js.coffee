'use strict'

###**
* @ngdoc directive
* @name BB.Directives:bbWidget
* @restrict A
* @scope
*   client: '=?'
*   apiUrl: '@?'
*   useParent:'='
* @description
*
* Loads a list of widgets for the currently in scope company
*
* <pre>
* restrict: 'A'
* scope:
*   client: '=?'
*   apiUrl: '@?'
*   useParent:'='
* transclude: true
* </pre>
*
* @param {hash} bbWidget A hash of options
* @property {string} pusher The pusher
* @property {string} pusher_channel The pusher channel
* @property {string} init_params Initialization of basic parameters
####


angular.module('BB.Directives').directive 'bbWidget', (PathSvc, $http, $log, $templateCache, $compile, $q, AppConfig, $timeout, $bbug, $rootScope) ->

  ###**
  * @ngdoc method
  * @name getTemplate
  * @methodOf BB.Directives:bbWidget
  * @description
  * Get template
  *
  * @param {object} template The template
  ###
  getTemplate = (template) ->
    partial = if template then template else 'main'
    fromTemplateCache = $templateCache.get(partial)
    if fromTemplateCache
      fromTemplateCache
    else
      src = PathSvc.directivePartial(partial).$$unwrapTrustedValue()
      $http.get(src, {cache: $templateCache}).then (response) ->
        response.data

  ###**
  * @ngdoc method
  * @name updatePartials
  * @methodOf BB.Directives:bbWidget
  * @description
  * Update partials
  *
  * @param {object} prms The parameter
  ###
  updatePartials = (scope, element, prms) ->
    $bbug(i).remove() for i in element.children() when $bbug(i).hasClass('custom_partial')
    appendCustomPartials(scope, element, prms).then () ->
      scope.$broadcast('refreshPage')

  ###**
  * @ngdoc method
  * @name setupPusher
  * @methodOf BB.Directives:bbWidget
  * @description
  * Push setup
  *
  * @param {object} prms The parameter
  ###
  setupPusher = (scope, element, prms) ->
    $timeout () ->
      scope.pusher = new Pusher('c8d8cea659cc46060608')
      scope.pusher_channel = scope.pusher.subscribe("widget_#{prms.design_id}")
      scope.pusher_channel.bind 'update', (data) ->
        updatePartials(scope, element, prms)

  ###**
  * @ngdoc method
  * @name appendCustomPartials
  * @methodOf BB.Directives:bbWidget
  * @description
  * Appent custom partials
  *
  * @param {object} prms The parameter
  ###
  appendCustomPartials = (scope, element, prms) ->
    defer = $q.defer()
    $http.get(prms.custom_partial_url).then (custom_templates) ->
      $compile(custom_templates.data) scope, (custom, scope) ->
        custom.addClass('custom_partial')
        style = (tag for tag in custom when tag.tagName == "STYLE")
        non_style = (tag for tag in custom when tag.tagName != "STYLE")
        $bbug("#widget_#{prms.design_id}").html(non_style)
        element.append(style)
        scope.bb.path_setup = true
        defer.resolve(style)
    defer.promise

  ###**
  * @ngdoc method
  * @name renderTemplate
  * @methodOf BB.Directives:bbWidget
  * @description
  * Render template
  *
  * @param {object} design_mode The design mode
  * @param {object} template The template
  ###
  renderTemplate = (scope, element, design_mode, template) ->
    $q.when(getTemplate(template)).then (template) ->
      element.html(template).show()
      element.append('<style widget_css scoped></style>') if design_mode
      $compile(element.contents())(scope)

  restrict: 'A'
  scope:
    client: '=?'
    apiUrl: '@?'
    useParent:'='
  transclude: true
  controller: 'BBCtrl'
  link: (scope, element, attrs, controller, transclude) ->
    scope.client = attrs.member if attrs.member?
    evaluator = scope
    if scope.useParent && scope.$parent?
      evaluator = scope.$parent
    init_params = evaluator.$eval(attrs.bbWidget)
    scope.initWidget(init_params)
    $rootScope.widget_started.then () =>
      prms = scope.bb
      if prms.custom_partial_url
        prms.design_id = prms.custom_partial_url.match(/^.*\/(.*?)$/)[1]
        $bbug("[ng-app='BB']").append("<div id='widget_#{prms.design_id}'></div>")
      if scope.bb.partial_url
        if init_params.partial_url
          AppConfig['partial_url'] = init_params.partial_url
        else
          AppConfig['partial_url'] = scope.bb.partial_url

      transclude scope, (clone) =>
        # if there's content or not whitespace
        scope.has_content = clone.length > 1 || (clone.length == 1 && (!clone[0].wholeText || /\S/.test(clone[0].wholeText)))
        if !scope.has_content
          if prms.custom_partial_url
            appendCustomPartials(scope, element, prms).then (style) ->
              $q.when(getTemplate()).then (template) ->
                element.html(template).show()
                $compile(element.contents())(scope)
                element.append(style)
                setupPusher(scope, element, prms) if prms.update_design
          else if prms.template
            renderTemplate(scope, element, prms.design_mode, prms.template)
          else
            renderTemplate(scope, element, prms.design_mode)
          scope.$on 'refreshPage', () ->
            renderTemplate(scope, element, prms.design_mode)
        else if prms.custom_partial_url
          appendCustomPartials(scope, element, prms)
          setupPusher(scope, element, prms) if prms.update_design
          scope.$on 'refreshPage', () ->
            scope.showPage scope.bb.current_page
        else
          element.html(clone).show()
          element.append('<style widget_css scoped></style>') if prms.design_mode


# a controller used for the main page contents - just in case we need one here
angular.module('BB.Controllers').controller 'bbContentController', ($scope) ->
  $scope.controller = "public.controllers.bbContentController"
  $scope.initPage = () =>
    $scope.setPageLoaded()
    $scope.setLoadingPage(false)



angular.module('BB.Controllers').controller 'BBCtrl', ($scope, $location, $rootScope,
  halClient, $window, $http, $q, $timeout, BasketService, LoginService, AlertService,
  $sce, $element, $compile, $sniffer, $uibModal, $log, BBModel, BBWidget, SSOService,
  ErrorService, AppConfig, QueryStringService, QuestionService, LocaleService,
  PurchaseService, $sessionStorage, $bbug, SettingsService, UriTemplate, LoadingService,
  $anchorScroll, $localStorage, $document, LoadingService) ->

  # dont change the cid as we use it in the app to identify this as the widget
  # root scope
  $scope.cid = "BBCtrl"
  $scope.controller = "public.controllers.BBCtrl"
  $scope.bb = new BBWidget()
  AppConfig.uid = $scope.bb.uid
  $scope.qs = QueryStringService
  $scope.company_api_path = '/api/v1/company/{company_id}{?embed,category_id}'
  $scope.company_admin_api_path = '/api/v1/admin/{company_id}/company{?embed,category_id}'

  loader = LoadingService.$loader($scope)

  if $scope.apiUrl
    $scope.bb ||= {}
    $scope.bb.api_url = $scope.apiUrl
  if $rootScope.bb && $rootScope.bb.api_url
    $scope.bb.api_url = $rootScope.bb.api_url
    unless $rootScope.bb.partial_url
#      $scope.bb.partial_url = "#{$scope.bb.api_url}/angular/"
      $scope.bb.partial_url = ""
    else
      $scope.bb.partial_url = $rootScope.bb.partial_url
  # if a custom port was used add that to the url
  if $location.port() isnt 80 and $location.port() isnt 443
    $scope.bb.api_url ||= $location.protocol() + "://" + $location.host() + ":" + $location.port()
    #$scope.bb.partial_url ||= $location.protocol() + "://" + $location.host() + ":" + $location.port() + '/angular/'
  else
    $scope.bb.api_url ||= $location.protocol() + "://" + $location.host()
    #$scope.bb.partial_url ||= $location.protocol() + "://" + $location.host() + '/angular/'


  $scope.bb.stacked_items = []
  # $scope.hide_page = false
  first_call = true
  con_started = $q.defer()
  $rootScope.connection_started = con_started.promise
  widget_started = $q.defer()
  $rootScope.widget_started = widget_started.promise
  moment.locale([LocaleService, "en"])

  $rootScope.Route =
    Company: 0
    Category: 1
    Service: 2
    Person: 3
    Resource: 4
    Duration: 5
    Date: 6
    Time: 7
    Client: 8
    Summary: 9
    Basket: 10
    Checkout: 11
    Slot: 12
    Event: 13
    Login: 14
    Questions: 15
  $scope.Route = $rootScope.Route


  $compile("<span bb-display-mode></span>") $scope, (cloned, scope) =>
    $bbug($element).append(cloned)

  # legacy (already!) delete by Feb 2014 ;-)
  $scope.set_company = (prms) =>
    $scope.initWidget(prms)

  $scope.initWidget = (prms = {}) =>

    @$init_prms = prms
    # remark the connection as starting again
    con_started = $q.defer()
    $rootScope.connection_started = con_started.promise

    if (($sniffer.webkit and $sniffer.webkit < 537) || ($sniffer.msie and $sniffer.msie <= 9)) && first_call

      # ie 8 hacks
      if $scope.bb.api_url
        url = document.createElement('a')
        url.href = $scope.bb.api_url
        if url.host == '' || url.host == $location.host() || url.host == "#{$location.host()}:#{$location.port()}"
          $scope.initWidget2()
          return
      if $rootScope.iframe_proxy_ready
        $scope.initWidget2()
        return
      else
        $scope.$on 'iframe_proxy_ready', (event, args) ->
          if args.iframe_proxy_ready
            $scope.initWidget2()
        return

    else
      $scope.initWidget2()
      return

  $scope.initWidget2 = () =>
    $scope.init_widget_started = true

    # Initialize the scope from params
    prms = @$init_prms

    # if we've been asked to load any values from the url - do so!
    if prms.query
      for k,v of prms.query
        prms[k] = QueryStringService(v)

    if prms.custom_partial_url
      $scope.bb.custom_partial_url = prms.custom_partial_url
      $scope.bb.partial_id = prms.custom_partial_url.substring(prms.custom_partial_url.lastIndexOf("/")+1)
      $scope.bb.update_design = prms.update_design if prms.update_design
    else if prms.design_mode
      $scope.bb.design_mode = prms.design_mode

    company_id = $scope.bb.company_id
    if prms.company_id
      company_id = prms.company_id

    if prms.affiliate_id
      $scope.bb.affiliate_id = prms.affiliate_id
      $rootScope.affiliate_id =  prms.affiliate_id

    if (prms.api_url)
      $scope.bb.api_url = prms.api_url
    if (prms.partial_url)
      $scope.bb.partial_url = prms.partial_url
    if (prms.page_suffix)
      $scope.bb.page_suffix = prms.page_suffix
    if (prms.admin)
      $scope.bb.isAdmin = prms.admin
    if (prms.auth_token) #temporary
      $sessionStorage.setItem("auth_token", prms.auth_token)
    $scope.bb.app_id = 1
    $scope.bb.app_key = 1
    $scope.bb.clear_basket = true

    if prms.basket
      $scope.bb.clear_basket = false
    if prms.clear_basket == false
      $scope.bb.clear_basket = false
    if $window.bb_setup || prms.client
      # if setup is defined - blank the member -a s we're probably setting it - unless specifically defined as false
      prms.clear_member ||= true
    $scope.bb.client_defaults = prms.client or {}

    if prms.client_defaults
      if prms.client_defaults.membership_ref
        $scope.bb.client_defaults.membership_ref = prms.client_defaults.membership_ref

    if $scope.bb.client_defaults && $scope.bb.client_defaults.name
      match = $scope.bb.client_defaults.name.match(/^(\S+)(?:\s(\S+))?/)
      if match
        $scope.bb.client_defaults.first_name =  match[1]
        $scope.bb.client_defaults.last_name = match[2] if match[2]?

    if prms.clear_member
      $scope.bb.clear_member = prms.clear_member
      $sessionStorage.removeItem('login')

    if prms.app_id
      $scope.bb.app_id = prms.app_id
    if prms.app_key
      $scope.bb.app_key = prms.app_key

    if prms.item_defaults
      $scope.bb.original_item_defaults = prms.item_defaults
      $scope.bb.item_defaults =  angular.copy($scope.bb.original_item_defaults)
    else if $scope.bb.original_item_defaults
      # possibly reset the defails (yes, the defails!)
      $scope.bb.item_defaults =  angular.copy($scope.bb.original_item_defaults)

    if $scope.bb.selected_service and $scope.bb.selected_service.company_id == company_id
      $scope.bb.item_defaults.service = $scope.bb.selected_service.id

    if prms.route_format
      $scope.bb.setRouteFormat(prms.route_format)
      # do we need to call anything else before continuing...
      if $scope.bb_route_init
        $scope.bb_route_init()

    if prms.locale
      moment.locale(prms.locale)

    if prms.use_local_time_zone
      SettingsService.setUseLocalTimeZone(prms.use_local_time_zone)

    if prms.hide == true
      $scope.hide_page = true
    else
      $scope.hide_page = false

    $scope.bb.from_datetime =  prms.from_datetime if prms.from_datetime
    $scope.bb.to_datetime =  prms.to_datetime if prms.to_datetime
    $scope.bb.min_date =  prms.min_date if prms.min_date
    $scope.bb.max_date =  prms.max_date if prms.max_date
    $scope.bb.hide_block =  prms.hide_block if prms.hide_block

    # say we've setup the path - so other partials that are relying on it at can trigger
    if !prms.custom_partial_url
      $scope.bb.path_setup = true

    if prms.extra_setup
      $scope.bb.extra_setup          = prms.extra_setup
      $scope.bb.starting_step_number = parseInt(prms.extra_setup.step) if prms.extra_setup.step
      $scope.bb.return_url           = prms.extra_setup.return_url if prms.extra_setup.return_url
      $scope.bb.destination          = prms.extra_setup.destination if prms.extra_setup.destination

    if prms.booking_settings
      $scope.bb.booking_settings = prms.booking_settings

    if prms.template
      $scope.bb.template = prms.template

    if prms.i18n
      SettingsService.enableInternationalizaton()

    if prms.login_required
      $scope.bb.login_required = true

    if prms.private_note
      $scope.bb.private_note = prms.private_note

    if prms.qudini_booking_id
      $scope.bb.qudini_booking_id = prms.qudini_booking_id

    # this is used by the bbScrollTo directive so that we can account of
    # floating headers that might reside on sites where the widget is embedded
    if prms.scroll_offset
      SettingsService.setScrollOffset(prms.scroll_offset)

    SettingsService.update_document_title = SettingsService.update_document_title or prms.update_document_title or false

    @waiting_for_conn_started_def = $q.defer()
    $scope.waiting_for_conn_started = @waiting_for_conn_started_def.promise

    if company_id || $scope.bb.affiliate_id
      $scope.waiting_for_conn_started = $rootScope.connection_started
    else
      @waiting_for_conn_started_def.resolve()

    widget_started.resolve()


    #########################################################
    # we're going to load a bunch of default stuff which we will vary by the widget
    # there can be two promise stages - a first pass - then a second set or promises which might be created as a results of the first lot being laoded
    # i.e. the active of reolving one promise, may need a second to be reoslved before the widget is created

    setup_promises2 = []
    setup_promises= []

    if $scope.bb.affiliate_id
      aff_promise = halClient.$get($scope.bb.api_url + '/api/v1/affiliates/' + $scope.bb.affiliate_id)
      setup_promises.push(aff_promise)
      aff_promise.then (affiliate) =>
        if $scope.bb.$wait_for_routing
          setup_promises2.push($scope.bb.$wait_for_routing.promise)
        $scope.setAffiliate(new BBModel.Affiliate(affiliate))
        $scope.bb.item_defaults.affiliate = $scope.affiliate
        if prms.company_ref
          comp_p = $q.defer()
          comp_promise = $scope.affiliate.getCompanyByRef(prms.company_ref)
          setup_promises2.push(comp_p.promise)
          comp_promise.then (company) ->
            $scope.setCompany(company, prms.keep_basket).then (val) ->
              comp_p.resolve(val)
            , (err) ->
              comp_p.reject(err)
          , (err) ->
            comp_p.reject(err)


    # load the company

    if company_id
      embed_params = prms.embed if prms.embed
      embed_params ||= null
      comp_category_id = null

      if $scope.bb.item_defaults.category?
        if $scope.bb.item_defaults.category.id?
          comp_category_id = $scope.bb.item_defaults.category.id
        else
          comp_category_id = $scope.bb.item_defaults.category

      comp_def = $q.defer()
      comp_promise = comp_def.promise
      options = {}
      options.auth_token = $sessionStorage.getItem('auth_token') if $sessionStorage.getItem('auth_token')
      if $scope.bb.isAdmin
        comp_url = new UriTemplate($scope.bb.api_url + $scope.company_admin_api_path).fillFromObject({company_id: company_id, category_id: comp_category_id, embed: embed_params})
        halClient.$get(comp_url, options).then (company) ->
          comp_def.resolve(company)
        , (err) ->
          # try non admin if admin failed
          comp_url = new UriTemplate($scope.bb.api_url + $scope.company_api_path).fillFromObject({company_id: company_id, category_id: comp_category_id, embed: embed_params})
          halClient.$get(comp_url, options).then (company) ->
            comp_def.resolve(company)
          , (err) ->
            comp_def.reject(err)

      else
        comp_url = new UriTemplate($scope.bb.api_url + $scope.company_api_path).fillFromObject({company_id: company_id, category_id: comp_category_id, embed: embed_params})
        halClient.$get(comp_url, options).then (company) ->
          if company
            comp_def.resolve(company)
          else
            comp_def.reject("Invalid company ID #{company_id}")
        , (err) ->
          comp_def.reject(err)

      setup_promises.push(comp_promise)
      comp_promise.then (company) =>

        if $scope.bb.$wait_for_routing
          setup_promises2.push($scope.bb.$wait_for_routing.promise)
        comp = new BBModel.Company(company)
        # if there's a default company - and this is a parent - maybe we want to preselect one of children
        cprom = $q.defer()
        setup_promises2.push(cprom.promise)
        child = null
        if comp.companies && $scope.bb.item_defaults.company
          child = comp.findChildCompany($scope.bb.item_defaults.company)
        if child
          parent_company = comp
          halClient.$get($scope.bb.api_url + '/api/v1/company/' + child.id).then (company) ->
            comp = new BBModel.Company(company)
            setupDefaults(comp.id)
            $scope.bb.parent_company = parent_company
            $scope.setCompany(comp, prms.keep_basket).then () ->
              cprom.resolve()
            , (err) ->
              cprom.reject()
          , (err) ->
            cprom.reject()
        else
          setupDefaults(comp.id)
          $scope.setCompany(comp, prms.keep_basket).then () ->
            cprom.resolve()
          , (err) ->
            cprom.reject()

    # an array of promises we want resolves before we'll show a widget - there could be a number of set up calls
    # setup_promises = [comp_promise]

      if prms.member_sso
        params =
          company_id: company_id
          root: $scope.bb.api_url
          member_sso: prms.member_sso
        sso_member_login = SSOService.memberLogin(params).then (client) ->
            $scope.setClient(client)
        setup_promises.push sso_member_login
      if prms.admin_sso
        params =
          company_id: if prms.parent_company_id then prms.parent_company_id else company_id
          root: $scope.bb.api_url
          admin_sso: prms.admin_sso
        sso_admin_login = SSOService.adminLogin(params).then (admin) ->
          $scope.bb.admin = admin
        setup_promises.push sso_admin_login

      if $scope.bb.item_defaults and $scope.bb.item_defaults.long_id
        total_id = $scope.bb.item_defaults.long_id
      else total_id = QueryStringService('total_id')

      if total_id
        params =
          purchase_id: total_id
          url_root: $scope.bb.api_url
        get_total = PurchaseService.query(params).then (total) ->
          $scope.bb.total = total
          if total.paid > 0
            $scope.bb.payment_status = 'complete'
        setup_promises.push get_total

    $scope.isLoaded = false

    $q.all(setup_promises).then () ->
      $q.all(setup_promises2).then () ->
        if !$scope.bb.basket
          $scope.bb.basket ||= new BBModel.Basket(null, $scope.bb)
        if !$scope.client
          $scope.clearClient()

        # set up other stuff!
        def_clear = $q.defer()
        clear_prom = def_clear.promise
        if !$scope.bb.current_item
          clear_prom = $scope.clearBasketItem()
        else
          def_clear.resolve()
        clear_prom.then () ->
          if !$scope.client_details
            $scope.client_details = new BBModel.ClientDetails()
          if !$scope.bb.stacked_items
            $scope.bb.stacked_items = []
          if $scope.bb.company || $scope.bb.affiliate
            # onyl start if the company is valid
            con_started.resolve()
            $scope.done_starting = true
            if !prms.no_route
              page = null
              # does the routing have a first step ? use this as long as we've not set explicit 'when' routes
              page = $scope.bb.firstStep if first_call && $bbug.isEmptyObject($scope.bb.routeSteps)
              page = prms.first_page if prms.first_page

              first_call = false
              $scope.decideNextPage(page)
      , (err) ->
        con_started.reject("Failed to start widget")
        loader.setLoadedAndShowError(err, 'Sorry, something went wrong')
    , (err) ->
      con_started.reject("Failed to start widget")
      loader.setLoadedAndShowError(err, 'Sorry, something went wrong')


  setupDefaults = (company_id) =>
    def = $q.defer()

    if first_call || ($scope.bb.orginal_company_id && $scope.bb.orginal_company_id != company_id)
      # if this is the first call - or we've switch companies
      $scope.bb.orginal_company_id = company_id
      $scope.bb.default_setup_promises = []
      # deal with query versions - load any query vals frm the url
      if $scope.bb.item_defaults.query
        for k,v of $scope.bb.item_defaults.query
          $scope.bb.item_defaults[k] = QueryStringService(v)

      if $scope.bb.item_defaults.resource
        if $scope.bb.isAdmin
          resource = halClient.$get($scope.bb.api_url + '/api/v1/admin/' + company_id + '/resources/' + $scope.bb.item_defaults.resource )
        else
          resource = halClient.$get($scope.bb.api_url + '/api/v1/' + company_id + '/resources/' + $scope.bb.item_defaults.resource )
        $scope.bb.default_setup_promises.push(resource)
        resource.then (res) =>
          $scope.bb.item_defaults.resource = new BBModel.Resource(res)

      if $scope.bb.item_defaults.person
        if $scope.bb.isAdmin
          person = halClient.$get($scope.bb.api_url + '/api/v1/admin/' + company_id + '/people/' + $scope.bb.item_defaults.person )
        else
          person = halClient.$get($scope.bb.api_url + '/api/v1/' + company_id + '/people/' + $scope.bb.item_defaults.person )
        $scope.bb.default_setup_promises.push(person)
        person.then (res) =>
          $scope.bb.item_defaults.person = new BBModel.Person(res)

      if $scope.bb.item_defaults.person_ref
        if $scope.bb.isAdmin
          person = halClient.$get($scope.bb.api_url + '/api/v1/admin/' + company_id + '/people/find_by_ref/' + $scope.bb.item_defaults.person_ref )
        else
          person = halClient.$get($scope.bb.api_url + '/api/v1/' + company_id + '/people/find_by_ref/' + $scope.bb.item_defaults.person_ref)

        $scope.bb.default_setup_promises.push(person)
        person.then (res) =>
          $scope.bb.item_defaults.person = new BBModel.Person(res)

      if $scope.bb.item_defaults.service
        if $scope.bb.isAdmin
          service = halClient.$get($scope.bb.api_url + '/api/v1/admin/' + company_id + '/services/' + $scope.bb.item_defaults.service )
        else
          service = halClient.$get($scope.bb.api_url + '/api/v1/' + company_id + '/services/' + $scope.bb.item_defaults.service )
        $scope.bb.default_setup_promises.push(service)
        service.then (res) =>
          $scope.bb.item_defaults.service = new BBModel.Service(res)

      if $scope.bb.item_defaults.service_ref
        if $scope.bb.isAdmin
          service = halClient.$get($scope.bb.api_url + '/api/v1/admin/' + company_id + '/services?api_ref=' + $scope.bb.item_defaults.service_ref )
        else
          service = halClient.$get($scope.bb.api_url + '/api/v1/' + company_id + '/services?api_ref=' + $scope.bb.item_defaults.service_ref )
        $scope.bb.default_setup_promises.push(service)
        service.then (res) =>
          $scope.bb.item_defaults.service = new BBModel.Service(res)

      if $scope.bb.item_defaults.event_group
        if $scope.bb.isAdmin
          event_group = halClient.$get($scope.bb.api_url + '/api/v1/admin/' + company_id + '/event_groups/' + $scope.bb.item_defaults.event_group )
        else
          event_group = halClient.$get($scope.bb.api_url + '/api/v1/' + company_id + '/event_groups/' + $scope.bb.item_defaults.event_group )
        $scope.bb.default_setup_promises.push(event_group)
        event_group.then (res) =>
          $scope.bb.item_defaults.event_group = new BBModel.EventGroup(res)

      if $scope.bb.item_defaults.event
        if $scope.bb.isAdmin
          event = halClient.$get($scope.bb.api_url + '/api/v1/admin/' + company_id + '/event_chains/' + $scope.bb.item_defaults.event_chain + '/events/' + $scope.bb.item_defaults.event )
        else
          event = halClient.$get($scope.bb.api_url + '/api/v1/' + company_id + '/events/' + $scope.bb.item_defaults.event )
        $scope.bb.default_setup_promises.push(event)
        event.then (res) =>
          $scope.bb.item_defaults.event = new BBModel.Event(res)

      if $scope.bb.item_defaults.event_chain
        if $scope.bb.isAdmin
          event_chain = halClient.$get($scope.bb.api_url + '/api/v1/admin/' + company_id + '/event_chains/' + $scope.bb.item_defaults.event_chain )
        else
          event_chain = halClient.$get($scope.bb.api_url + '/api/v1/' + company_id + '/event_chains/' + $scope.bb.item_defaults.event_chain )
        $scope.bb.default_setup_promises.push(event_chain)
        event_chain.then (res) =>
          $scope.bb.item_defaults.event_chain = new BBModel.EventChain(res)

      if $scope.bb.item_defaults.category
        category = halClient.$get($scope.bb.api_url + '/api/v1/' + company_id + '/categories/' + $scope.bb.item_defaults.category )
        $scope.bb.default_setup_promises.push(category)
        category.then (res) =>
          $scope.bb.item_defaults.category = new BBModel.Category(res)

      if $scope.bb.item_defaults.clinic
        clinic = halClient.$get($scope.bb.api_url + '/api/v1/' + company_id + '/clinics/' + $scope.bb.item_defaults.clinic )
        $scope.bb.default_setup_promises.push(clinic)
        clinic.then (res) =>
          $scope.bb.item_defaults.clinic = new BBModel.Clinic(res)

      if $scope.bb.item_defaults.duration
        $scope.bb.item_defaults.duration = parseInt($scope.bb.item_defaults.duration)

      $q.all($scope.bb.default_setup_promises)['finally'] () ->
        def.resolve()
    else
      def.resolve()
    def.promise


  ######################
  # set if a page is loaded yet or now helps prevent double loading
  $scope.setLoadingPage = (val) =>
    $scope.loading_page = val

  $scope.isLoadingPage = () =>
    $scope.loading_page


  # $locationChangeStart is broadcast before a URL will change
  $scope.$on '$locationChangeStart', (angular_event, new_url, old_url) ->

    # don't react to URL changes if we're not in control of the URL
    return if !$scope.bb.routeFormat

    # don't load any steps if route is being updated or a modal is open
    if !$scope.bb.routing or SettingsService.isModalOpen()
      # Get the step number to load
      step_number = $scope.bb.matchURLToStep()
      # Load next page
      if step_number? and step_number > $scope.bb.current_step
        $scope.loadStep(step_number)
      else
        $scope.loadPreviousStep('locationChangeStart')

    $scope.bb.routing = false

  $scope.showPage = (route, dont_record_page) =>

    $scope.bb.updateRoute(route)
    $scope.jumped = false


    # don't load a new page if we are still loading an old one - helps prevent double clicks
    return if $scope.isLoadingPage()

    $scope.setLoadingPage(true)
    if $scope.bb.current_page == route
      $scope.bb_main = ""
      setTimeout () ->
        $scope.bb_main = $sce.trustAsResourceUrl($scope.bb.pageURL(route))
        $scope.$apply()
      , 0
    else
      AlertService.clear() # clear any alerts as part of loading a new page
      $scope.bb.current_page = route
      $scope.bb.recordCurrentPage() if !dont_record_page
      loader.notLoaded()
      $scope.bb_main = $sce.trustAsResourceUrl($scope.bb.pageURL(route))

    $rootScope.$broadcast "page:loaded"

  $scope.jumpToPage = (route) =>
    $scope.current_page = route
    $scope.jumped = true
    $scope.bb_main = $sce.trustAsResourceUrl($scope.partial_url  + route + $scope.page_suffix)


  $scope.clearPage = () ->
    $scope.bb_main = ""

  $scope.getPartial = (file) ->
    $scope.bb.pageURL(file)

  #TODO can this method be removed?
  $scope.setPageLoaded = () ->
    loader.setLoaded()


  $scope.setPageRoute = (route) =>
    $scope.bb.current_page_route = route
    if $scope.bb.routeSteps && $scope.bb.routeSteps[route]
      $scope.showPage($scope.bb.routeSteps[route])
      return true
    return false


  $scope.decideNextPage = (route) ->
    if route
      if route == 'none'
        return
      else
        if $scope.bb.total && $scope.bb.payment_status == 'complete'
          $scope.showPage('confirmation')
        else
          return $scope.showPage(route)

    # do we have a pre-set route...
    if $scope.bb.nextSteps && $scope.bb.current_page && $scope.bb.nextSteps[$scope.bb.current_page] && !$scope.bb.routeSteps
      return $scope.showPage($scope.bb.nextSteps[$scope.bb.current_page])
    if !$scope.client.valid() && LoginService.isLoggedIn()
      # make sure we set the client to the currently logged in member
      # we should also just check the logged in member is  a member of the company they are currently booking with
      $scope.client = new BBModel.Client(LoginService.member()._data)

    if ($scope.bb.company && $scope.bb.company.companies) || (!$scope.bb.company && $scope.affiliate)
      return if $scope.setPageRoute($rootScope.Route.Company)
      return $scope.showPage('company_list')
    else if $scope.bb.total && $scope.bb.payment_status == "complete"
      return $scope.showPage('confirmation')

    else if ($scope.bb.total && $scope.bb.payment_status == "pending")
      return $scope.showPage('payment')

    else if ($scope.bb.company.$has('event_groups') && !$scope.bb.current_item.event_group && !$scope.bb.current_item.service && !$scope.bb.current_item.product && !$scope.bb.current_item.deal) or
            ($scope.bb.company.$has('events') && $scope.bb.current_item.event_group && !$scope.bb.current_item.event? && !$scope.bb.current_item.product && !$scope.bb.current_item.deal)
      return if $scope.setPageRoute($rootScope.Route.Event)
      return $scope.showPage('event_list')
    else if ($scope.bb.company.$has('events') && $scope.bb.current_item.event && !$scope.bb.current_item.num_book && (!$scope.bb.current_item.tickets || !$scope.bb.current_item.tickets.qty) && !$scope.bb.current_item.product && !$scope.bb.current_item.deal)
      return $scope.showPage('event')
    else if ($scope.bb.company.$has('services') && !$scope.bb.current_item.service && !$scope.bb.current_item.event? && !$scope.bb.current_item.product && !$scope.bb.current_item.deal)
      return if $scope.setPageRoute($rootScope.Route.Service)
      return $scope.showPage('service_list')
    else if ($scope.bb.company.$has('resources') && !$scope.bb.current_item.resource && !$scope.bb.current_item.event? && !$scope.bb.current_item.product && !$scope.bb.current_item.deal)
      return if $scope.setPageRoute($rootScope.Route.Resource)
      return $scope.showPage('resource_list')
    else if ($scope.bb.company.$has('people') && !$scope.bb.current_item.person && !$scope.bb.current_item.event? && !$scope.bb.current_item.product && !$scope.bb.current_item.deal)
      return if $scope.setPageRoute($rootScope.Route.Person)
      return $scope.showPage('person_list')
    else if (!$scope.bb.current_item.duration && !$scope.bb.current_item.event? && !$scope.bb.current_item.product && !$scope.bb.current_item.deal)
      return if $scope.setPageRoute($rootScope.Route.Duration)
      return $scope.showPage('duration_list')
    else if ($scope.bb.current_item.days_link && !$scope.bb.current_item.date && !$scope.bb.current_item.event? && !$scope.bb.current_item.deal)
      if $scope.bb.company.$has('availability_slots')
        return if $scope.setPageRoute($rootScope.Route.Slot)
        return $scope.showPage('slot_list')
      else
        return if $scope.setPageRoute($rootScope.Route.Date)
        # if we're an admin and we've pre-selected a time - route to that instead
        return $scope.showPage('calendar')
    else if ($scope.bb.current_item.days_link && !$scope.bb.current_item.time && !$scope.bb.current_item.event? && (!$scope.bb.current_item.service || $scope.bb.current_item.service.duration_unit != 'day') && !$scope.bb.current_item.deal)
      return if $scope.setPageRoute($rootScope.Route.Time)
      return $scope.showPage('time')
    else if ($scope.bb.moving_booking && (!$scope.bb.current_item.ready || !$scope.bb.current_item.move_done))
      return $scope.showPage('check_move')
    else if (!$scope.client.valid())
      return if $scope.setPageRoute($rootScope.Route.Client)
      return $scope.showPage('client')
    else if ($scope.bb.current_item.item_details && $scope.bb.current_item.item_details.hasQuestions && !$scope.bb.current_item.asked_questions)
      return if $scope.setPageRoute($rootScope.Route.Questions)
      return $scope.showPage('check_items')
    else if $scope.bb.moving_booking && $scope.bb.basket.itemsReady()
      return $scope.showPage('purchase')
    else if !$scope.bb.basket.readyToCheckout()
      return if $scope.setPageRoute($rootScope.Route.Summary)
      return $scope.showPage('basket_summary')
    else if ($scope.bb.usingBasket && (!$scope.bb.confirmCheckout || $scope.bb.company_settings.has_vouchers || $scope.bb.company.$has('coupon')))
      return if $scope.setPageRoute($rootScope.Route.Basket)
      return $scope.showPage('basket')
    else if ($scope.bb.basket.readyToCheckout() && $scope.bb.payment_status == null && !$scope.bb.basket.waiting_for_checkout)
      return if $scope.setPageRoute($rootScope.Route.Checkout)
      return $scope.showPage('checkout')
    # else if ($scope.bb.total && $scope.bb.payment_status == "pending")
    #   return $scope.showPage('payment')
    else if $scope.bb.payment_status == "complete"
      return $scope.showPage('confirmation')


  $scope.showCheckout = ->
    $scope.bb.current_item.ready


  # add the current item to the basket service
  $scope.addItemToBasket = ->
    add_defer = $q.defer()

    if !$scope.bb.current_item.submitted && !$scope.bb.moving_booking
      $scope.moveToBasket()
      $scope.bb.current_item.submitted = $scope.updateBasket()
      $scope.bb.current_item.submitted.then (basket) ->
        add_defer.resolve(basket)
      , (err) ->
        if err.status == 409
          # unavailable item - remove the time, person and resource and resete teh service
          $scope.bb.current_item.person = null
          $scope.bb.current_item.resource = null
          $scope.bb.current_item.setTime(null)
          if $scope.bb.current_item.service
            $scope.bb.current_item.setService($scope.bb.current_item.service)

        $scope.bb.current_item.submitted = null
        add_defer.reject(err)
    else if $scope.bb.current_item.submitted
      return $scope.bb.current_item.submitted
    else
      add_defer.resolve()
    add_defer.promise


  # add several items at once
  $scope.updateBasket = () ->

    # save the current item ref so that we can restore the current item after the basket has been updated
    current_item_ref = $scope.bb.current_item.ref

    add_defer = $q.defer()
    params = {member_id: $scope.client.id, member: $scope.client, items: $scope.bb.basket.items, bb: $scope.bb }
    BBModel.Basket.$updateBasket($scope.bb.company, params).then (basket) ->
      for item in basket.items
        item.storeDefaults($scope.bb.item_defaults)
      # clear the currently cached time date
      halClient.clearCache("time_data")
      halClient.clearCache("events")
      basket.setSettings($scope.bb.basket.settings)

      $scope.setBasket(basket)

      # restore the current item using the ref
      current_item = _.find basket.items, (item) -> item.ref is current_item_ref
      # use last item if there is no ref
      current_item = _.last basket.items if !current_item

      $scope.setBasketItem(current_item)

      # check if item has been added to the basket
      if !$scope.bb.current_item
        # not added to basket, clear the item
        $scope.clearBasketItem().then () ->
          add_defer.resolve(basket)
      else
        add_defer.resolve(basket)
    , (err) ->
      add_defer.reject(err)
      # handle item conflict
      if err.status == 409
        # clear the currently cached time date
        halClient.clearCache("time_data")
        halClient.clearCache("events")
        $scope.bb.current_item.person = null
        error_modal = $uibModal.open
          appendTo: angular.element($document[0].getElementById('bb'))
          templateUrl: $scope.getPartial('_error_modal')
          controller: ($scope, $uibModalInstance) ->
            $scope.message = ErrorService.getError('ITEM_NO_LONGER_AVAILABLE').msg
            $scope.ok = () ->
              $uibModalInstance.close()
        error_modal.result.finally () ->
          if $scope.bb.nextSteps
            # either go back to the Date/Event routes or load the previous step
            if $scope.setPageRoute($rootScope.Route.Date)
              # already routed
            else if $scope.setPageRoute($rootScope.Route.Event)
              # already routed
            else
              $scope.loadPreviousStep()
          else
            $scope.decideNextPage()
    add_defer.promise


  $scope.emptyBasket = ->
    return if !$scope.bb.basket.items or ($scope.bb.basket.items and $scope.bb.basket.items.length is 0)

    defer = $q.defer()

    BBModel.Basket.$empty($scope.bb).then (basket) ->
      if $scope.bb.current_item.id
        delete $scope.bb.current_item.id
      $scope.setBasket(basket)
      defer.resolve()
    , (err) ->
      defer.reject()

    return defer.promise


  $scope.deleteBasketItem = (item) ->
    BBModel.Basket.$deleteItem(item, $scope.bb.company, {bb: $scope.bb}).then (basket) ->
      $scope.setBasket(basket)


  $scope.deleteBasketItems = (items) ->
    for item in items
      BBModel.Basket.$deleteItem(item, $scope.bb.company, {bb: $scope.bb}).then (basket) ->
        $scope.setBasket(basket)


  $scope.clearBasketItem = ->
    def = $q.defer()
    $scope.setBasketItem(new BBModel.BasketItem(null, $scope.bb))
    if $scope.bb.default_setup_promises
      $q.all($scope.bb.default_setup_promises).finally () ->
        $scope.bb.current_item.setDefaults($scope.bb.item_defaults)
        $q.all($scope.bb.current_item.promises).finally () ->
          def.resolve()
    else
      $scope.bb.current_item.setDefaults({})
      def.resolve()
    return def.promise


  $scope.setBasketItem = (item) ->
    $scope.bb.current_item = item
    # for now also set a variable in the scope - for old views that we've not tidied up yet
    $scope.current_item = $scope.bb.current_item


  # say that the basket is ready to checkout
  $scope.setReadyToCheckout = (ready) ->
    $scope.bb.confirmCheckout = ready


  $scope.moveToBasket = ->
    $scope.bb.basket.addItem($scope.bb.current_item)


  $scope.quickEmptybasket = (options) ->
    preserve_stacked_items = if options && options.preserve_stacked_items then true else false
    if !preserve_stacked_items
      $scope.bb.stacked_items = []
      $scope.setBasket(new BBModel.Basket(null, $scope.bb))
      $scope.clearBasketItem()
    else
      $scope.bb.basket = new BBModel.Basket(null, $scope.bb)
      $scope.basket    = $scope.bb.basket
      $scope.bb.basket.company_id = $scope.bb.company_id
      def = $q.defer()
      def.resolve()
      def.promise

  $scope.setBasket = (basket) ->
    $scope.bb.basket = basket
    $scope.basket = basket
    $scope.bb.basket.company_id = $scope.bb.company_id
    # were there stacked items - if so reset the stack items to the basket contents
    if $scope.bb.stacked_items
      $scope.bb.setStackedItems(basket.timeItems())


  # clear the user and logout
  $scope.logout = (route) ->
    if $scope.client && $scope.client.valid()
      LoginService.logout({root: $scope.bb.api_url}).then ->
        $scope.client =  new BBModel.Client()
        $scope.decideNextPage(route)
    else if $scope.member
      LoginService.logout({root: $scope.bb.api_url}).then ->
        $scope.member =  new BBModel.Member.Member()
        $scope.decideNextPage(route)


  $scope.setAffiliate = (affiliate) ->
    $scope.bb.affiliate_id = affiliate.id
    $scope.bb.affiliate = affiliate
    # for now also set a scope varaible for company - we should remove this as soon as all partials are moved over
    $scope.affiliate = affiliate
    $scope.affiliate_id = affiliate.id


  restoreBasket = () ->
    restore_basket_defer = $q.defer()
    $scope.quickEmptybasket().then () ->
      auth_token = $localStorage.getItem('auth_token') or $sessionStorage.getItem('auth_token')
      href = $scope.bb.api_url +
        '/api/v1/status{?company_id,affiliate_id,clear_baskets,clear_member}'
      params =
        company_id: $scope.bb.company_id
        affiliate_id: $scope.bb.affiliate_id
        clear_baskets: if $scope.bb.clear_basket then '1' else null
        clear_member: if $scope.bb.clear_member then '1' else null
      uri = new UriTemplate(href).fillFromObject(params)
      status = halClient.$get(uri, {"auth_token": auth_token, "no_cache": true})
      status.then (res) =>
        if res.$has('client')
          res.$get('client').then (client) =>
            $scope.client = new BBModel.Client(client) if !$scope.client or ($scope.client and !$scope.client.valid())
        if res.$has('member')
          res.$get('member').then (member) =>
            # HACK check if client_type is not contact
            if member.client_type != 'Contact'
              member = LoginService.setLogin(member)
              $scope.setClient(member)
        if $scope.bb.clear_basket
          restore_basket_defer.resolve()
        else
          if res.$has('baskets')
            res.$get('baskets').then (baskets) =>
              basket = _.find(baskets, (b) ->
                parseInt(b.company_id) == $scope.bb.company_id)
              if basket
                basket = new BBModel.Basket(basket, $scope.bb)
                basket.$get('items').then (items) ->
                  items = (new BBModel.BasketItem(i) for i in items)
                  basket.addItem(i) for i in items
                  $scope.setBasket(basket)

                  promises = [].concat.apply([], (i.promises for i in items))
                  $q.all(promises).then () ->
                    if basket.items.length > 0
                      $scope.setBasketItem(basket.items[0])
                    restore_basket_defer.resolve()
              else
                restore_basket_defer.resolve()
          else
            restore_basket_defer.resolve()
      , (err) ->
        restore_basket_defer.resolve()
    restore_basket_defer.promise


  $scope.setCompany = (company, keep_basket) ->
    defer = $q.defer()
    $scope.bb.company_id = company.id
    $scope.bb.company = company
    # for now also set a scope vbaraible for company - we should remove this as soon as all partials are moved over
    $scope.company = company

    $scope.bb.item_defaults.company = $scope.bb.company

    SettingsService.setCountryCode(company.country_code)
    SettingsService.setCurrency(company.currency_code)
    SettingsService.setTimeZone(company.timezone)

    if company.$has('settings')
      company.getSettings().then (settings) =>
        # setup some useful info
        $scope.bb.company_settings = settings
        $scope.bb.item_defaults.merge_resources = true if $scope.bb.company_settings.merge_resources
        $scope.bb.item_defaults.merge_people = true if $scope.bb.company_settings.merge_people
        $rootScope.bb_currency = $scope.bb.company_settings.currency
        $scope.bb.currency = $scope.bb.company_settings.currency
        $scope.bb.has_prices = $scope.bb.company_settings.has_prices

        if !$scope.bb.basket || ($scope.bb.basket.company_id != $scope.bb.company_id && !keep_basket)
          restoreBasket().then () ->
            defer.resolve()
            $scope.$emit 'company:setup'
        else
          defer.resolve()
          $scope.$emit 'company:setup'
    else
      if !$scope.bb.basket || ($scope.bb.basket.company_id != $scope.bb.company_id && !keep_basket)
        restoreBasket().then () ->
          defer.resolve()
          $scope.$emit 'company:setup'
      else
        defer.resolve()
        $scope.$emit 'company:setup'
    defer.promise


  ############################################################################################
  # Breadcrumbs
  ############################################################################################

  # record a step in the checkout process
  $scope.recordStep = (step, title) ->
    $scope.bb.recordStep(step, title)


  # set the title fo the current step
  $scope.setStepTitle = (title) ->
    $scope.bb.steps[$scope.bb.current_step-1].title = title


  $scope.getCurrentStepTitle = ->
    steps = $scope.bb.steps

    if !_.compact(steps).length or steps.length == 1 and steps[0].number != $scope.bb.current_step
      steps = $scope.bb.allSteps

    if $scope.bb.current_step
        return steps[$scope.bb.current_step-1].title


  # conditionally set the title of the current step - if it doesn't have one
  $scope.checkStepTitle = (title) ->
    if $scope.bb.steps[$scope.bb.current_step-1] and !$scope.bb.steps[$scope.bb.current_step-1].title
      $scope.setStepTitle(title)


  # reload a step
  $scope.loadStep = (step) ->
    return if step == $scope.bb.current_step
    $scope.bb.calculatePercentageComplete(step)
    # so actually use the data from the "next" page if there is one - but show the correct page
    # this means we load the completed data from that page
    # if there isn't a next page - then try the select one
    st = $scope.bb.steps[step]
    prev_step =  $scope.bb.steps[step-1]
    prev_step = st if st && !prev_step
    st = prev_step if !st
    if st && !$scope.bb.last_step_reached
      $scope.bb.stacked_items = [] if !st.stacked_length ||  st.stacked_length == 0
      $scope.bb.current_item.loadStep(st.current_item)
      if $scope.bb.steps.length > 1
        $scope.bb.steps.splice(step, $scope.bb.steps.length-step)
      $scope.bb.current_step = step
      $scope.showPage(prev_step.page, true)
    if $scope.bb.allSteps
      for step in $scope.bb.allSteps
        step.active = false
        step.passed = step.number < $scope.bb.current_step
      if $scope.bb.allSteps[$scope.bb.current_step-1]
        $scope.bb.allSteps[$scope.bb.current_step-1].active = true

  ###**
  * @ngdoc method
  * @name loadPreviousStep
  * @methodOf BB.Directives:bbWidget
  * @description
  * Loads the previous unskipped step
  *
  * @param {integer} steps_to_go_back: The number of steps to go back
  * @param {string} caller: The method that called this function
  ###
  $scope.loadPreviousStep = (caller) ->

    past_steps = _.reject($scope.bb.steps, (s) -> s.number >= $scope.bb.current_step)

    # Find the last unskipped step
    step_to_load = 0

    while past_steps[0]
      last_step = past_steps.pop()
      if !last_step
        break
      if !last_step.skipped
        step_to_load = last_step.number
        break

    # Remove pages from browser history (sync browser history with routing)
    if $scope.bb.routeFormat

      pages_to_remove_from_history = if step_to_load is 0 then $scope.bb.current_step + 1 else ($scope.bb.current_step - step_to_load)

      # -------------------------------------------------------------------------
      # Reduce number of pages to remove from browser history by one if this
      # method was triggered by Angular's $locationChangeStart broadcast
      # In this instance we can assume that the browser back button was used
      # and one page has already been removed from the history by the browser
      # -------------------------------------------------------------------------
      pages_to_remove_from_history-- if caller is "locationChangeStart"

      window.history.go(pages_to_remove_from_history*-1) if pages_to_remove_from_history > 0

    $scope.loadStep(step_to_load) if step_to_load > 0


  $scope.loadStepByPageName = (page_name) ->
    for step in $scope.bb.allSteps
      if step.page == page_name
        return $scope.loadStep(step.number)
    return $scope.loadStep(1)


  $scope.reset = () ->
    $rootScope.$broadcast 'clear:formData'
    $rootScope.$broadcast 'widget:restart'
    $scope.setLastSelectedDate(null)
    $scope.client =  new BBModel.Client() if !LoginService.isLoggedIn()
    $scope.bb.last_step_reached = false
    # This is to remove the current step you are on.
    $scope.bb.steps.splice(1)


  $scope.restart = () ->
    $scope.reset()
    $scope.loadStep(1)
    # TODO clear current item?


  # setup full route data
  $scope.setRoute = (rdata) ->
    $scope.bb.setRoute(rdata)


  # set basic step path only
  $scope.setBasicRoute = (routes) ->
    $scope.bb.setBasicRoute(routes)


  ###**
  * @ngdoc method
  * @name skipThisStep
  * @methodOf BB.Directives:bbWidget
  * @description
  * Marks the current step as skipped
  ###
  $scope.skipThisStep = () ->
    $scope.bb.steps[$scope.bb.steps.length - 1].skipped = true if $scope.bb.steps[$scope.bb.steps.length - 1]


  #############################################################

  $scope.setUsingBasket = (usingBasket) =>
    $scope.bb.usingBasket = usingBasket

  $scope.setClient = (client) =>
    $scope.client = client
    $scope.bb.postcode = client.postcode if client.postcode && !$scope.bb.postcode

  $scope.clearClient = () =>
    $scope.client = new BBModel.Client()
    if $window.bb_setup
      $scope.client.setDefaults($window.bb_setup)
    if $scope.bb.client_defaults
      $scope.client.setDefaults($scope.bb.client_defaults)

  $scope.parseDate = (d) =>
    moment(d)

  $scope.getUrlParam = (param) =>
    $window.getURIparam param

  $scope.base64encode = (param) =>
    $window.btoa(param)

  $scope.setLastSelectedDate = (date) =>
    $scope.last_selected_date = date


  # TODO: Get rid of these 'scope loading' methods when they are no longer
  # TODO can this method be removed?
  # called from the scopes
  $scope.setLoaded = (cscope) ->
    LoadingService.setLoaded(cscope)

  #TODO can this method be removed?
  $scope.setLoadedAndShowError = (scope, err, error_string) ->
    LoadingService.setLoadedAndShowError(scope, err, error_string)


  # go around schild scopes - return false if *any* child scope is marked as
  # isLoaded = false
  $scope.areScopesLoaded = (cscope) ->
    LoadingService.areScopesLoaded(cscope)

  #set scope not loaded...
  #TODO can this method be removed?
  $scope.notLoaded = (cscope) ->
    LoadingService.notLoaded(cscope)


  $scope.broadcastItemUpdate = () =>
    $scope.$broadcast("currentItemUpdate", $scope.bb.current_item)

  # do you show the page.
  $scope.hidePage = () ->
    $scope.hide_page = true

  $scope.bb.company_set =() ->
    $scope.bb.company_id?

  $scope.isAdmin = () ->
    $scope.bb.isAdmin

  $scope.isAdminIFrame = () ->
    if !$scope.bb.isAdmin
      return false

    try
      location = $window.parent.location.href
      if location && $window.parent.reload_dashboard
        return true
      else
        return false
    catch err
      return false

  $scope.reloadDashboard = ->
    $window.parent.reload_dashboard()

  $scope.$debounce = (tim) ->
    return false if $scope._debouncing
    tim ||= 100
    $scope._debouncing = true
    $timeout ->
      $scope._debouncing = false
    , tim

  $scope.supportsTouch = () ->
    Modernizr.touch


  $rootScope.$on 'show:loader', () ->
    $scope.loading = true
  $rootScope.$on 'hide:loader', () ->
    $scope.loading = false

  $scope.isMemberLoggedIn = () ->
    return LoginService.isLoggedIn()


  $scope.scrollTo = (id) ->
    $location.hash(id)
    $anchorScroll()


  $scope.redirectTo = (url) ->
    $window.location.href = url

