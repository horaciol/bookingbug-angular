'use strict'

angular.module('BBAdminBooking').directive 'bbAdminMoveBooking', ($log,
  $compile, $q, PathSvc, $templateCache, $http, BBModel, $rootScope, LoadingService) ->

  getTemplate = (template) ->
    partial = if template then template else 'main'
    fromTemplateCache = $templateCache.get(partial)
    if fromTemplateCache
      fromTemplateCache
    else
      src = PathSvc.directivePartial(partial).$$unwrapTrustedValue()
      $http.get(src, {cache: $templateCache}).then (response) ->
        response.data

  renderTemplate = (scope, element, design_mode, template) ->
    $q.when(getTemplate(template)).then (template) ->
      element.html(template).show()
      element.append('<style widget_css scoped></style>') if design_mode
      $compile(element.contents())(scope)
      scope.decideNextPage("calendar")


  link = (scope, element, attrs) ->

    loader = LoadingService.$loader(scope);

    config = scope.$eval attrs.bbAdminMoveBooking
    config ||= {}
    config.no_route = true
    config.admin = true
    config.template ||= "main"
    unless attrs.companyId
      if config.company_id
        attrs.companyId = config.company_id
      else if scope.company
        attrs.companyId = scope.company.id
    if attrs.companyId
      BBModel.Admin.Company.$query(attrs).then (company) ->
        scope.initWidget(config)
        company.getBooking(config.booking_id).then (booking) ->
          scope.company = company
          scope.bb.moving_booking = booking
          scope.quickEmptybasket()
          proms = []
          new_item = new BBModel.BasketItem(booking, scope.bb)
          new_item.setSrcBooking(booking, scope.bb)
          new_item.clearDateTime()
          new_item.ready = false

          if booking.$has('client')
            client_prom = booking.$get('client')
            proms.push(client_prom)
            client_prom.then (client) =>
              scope.setClient(new BBModel.Client(client))

          Array::push.apply proms, new_item.promises
          scope.bb.basket.addItem(new_item)
          scope.setBasketItem(new_item)

          $q.all(proms).then () ->
            $rootScope.$broadcast "booking:move"
            loader.setLoaded()
            renderTemplate(scope, element, config.design_mode, config.template)
          , (err) ->
            loader.setLoaded()
            failMsg()


  {
    link: link
    controller: 'BBCtrl'
  }

