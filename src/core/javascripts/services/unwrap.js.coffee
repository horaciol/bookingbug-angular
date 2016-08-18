angular.module('BB.Services').factory "UnwrapService", ($q, BBModel) ->

  unwrapCollection: (model, key, resource) ->
    deferred = $q.defer()

     # if the resource is embedded, return the array of models
    if angular.isArray(resource)

      models = (new model(service) for service in resource)
      deferred.resolve(models)

    else if resource.$has(key)
      resource.$get(key).then (items) =>
        models = []
        for i in items
          models.push(new model(i))
        deferred.resolve(models)
      , (err) =>
        deferred.reject(err)

    deferred.promise

  unwrapResource: (model, resource) ->
    return new model(resource)

angular.module('BB.Services').factory "BB.Service.address", ($q, BBModel, UnwrapService) ->
  unwrap: (resource) ->
    UnwrapService.unwrapResource(BBModel.Address, resource)


angular.module('BB.Services').factory "BB.Service.person", ($q, BBModel, UnwrapService) ->
  unwrap: (resource) ->
    UnwrapService.unwrapResource(BBModel.Person, resource)


angular.module('BB.Services').factory "BB.Service.people", ($q, BBModel, UnwrapService) ->
  promise: true
  unwrap: (resource) ->
    UnwrapService.unwrapCollection(BBModel.Person, 'people', resource)

angular.module('BB.Services').factory "BB.Service.resource", ($q, BBModel, UnwrapService) ->
  unwrap: (resource) ->
    UnwrapService.unwrapResource(BBModel.Resource, resource)


angular.module('BB.Services').factory "BB.Service.resources", ($q, BBModel, UnwrapService) ->
  promise: true
  unwrap: (resource) ->
    UnwrapService.unwrapCollection(BBModel.Resource, 'resources', resource)

angular.module('BB.Services').factory "BB.Service.service", ($q, BBModel, UnwrapService) ->
  unwrap: (resource) ->
    UnwrapService.unwrapResource(BBModel.Service, resource)

angular.module('BB.Services').factory "BB.Service.services", ($q, BBModel, UnwrapService) ->
  promise: true
  unwrap: (resource) ->
    UnwrapService.unwrapCollection(BBModel.Service, 'services', resource)

angular.module('BB.Services').factory "BB.Service.package_item", ($q, BBModel, UnwrapService) ->
  unwrap: (resource) ->
    UnwrapService.unwrapResource(BBModel.PackageItem, resource)


angular.module('BB.Services').factory "BB.Service.package_items", ($q, BBModel, UnwrapService) ->
  promise: true
  unwrap: (resource) ->
    UnwrapService.unwrapCollection(BBModel.PackageItem, 'package_items', resource)

angular.module('BB.Services').factory "BB.Service.bulk_purchase", ($q, BBModel, UnwrapService) ->
  unwrap: (resource) ->
    UnwrapService.unwrapResource(BBModel.BulkPurchase, resource)


angular.module('BB.Services').factory "BB.Service.bulk_purchases", ($q, BBModel, UnwrapService) ->
  promise: true
  unwrap: (resource) ->
    UnwrapService.unwrapCollection(BBModel.BulkPurchase, 'bulk_purchases', resource)

angular.module('BB.Services').factory "BB.Service.event_group", ($q, BBModel, UnwrapService) ->
  unwrap: (resource) ->
    UnwrapService.unwrapResource(BBModel.EventGroup, resource)


angular.module('BB.Services').factory "BB.Service.event_groups", ($q, BBModel, UnwrapService) ->
  promise: true
  unwrap: (resource) ->
    UnwrapService.unwrapCollection(BBModel.EventGroup, 'event_groups', resource)


angular.module('BB.Services').factory "BB.Service.event_chain", ($q, BBModel, UnwrapService) ->
  unwrap: (resource) ->
    UnwrapService.unwrapResource(BBModel.EventChain, resource)


angular.module('BB.Services').factory "BB.Service.event_chains", ($q, BBModel, UnwrapService) ->
  unwrap: (resource) ->
    UnwrapService.unwrapResource(BBModel.EventChain, resource)


angular.module('BB.Services').factory "BB.Service.category", ($q, BBModel, UnwrapService) ->
  unwrap: (resource) ->
    UnwrapService.unwrapResource(BBModel.Category, resource)


angular.module('BB.Services').factory "BB.Service.categories", ($q, BBModel, UnwrapService) ->
  promise: true
  unwrap: (resource) ->
    UnwrapService.unwrapCollection(BBModel.Category, 'categories', resource)

angular.module('BB.Services').factory "BB.Service.client", ($q, BBModel, UnwrapService) ->
  unwrap: (resource) ->
    UnwrapService.unwrapResource(BBModel.Client, resource)


angular.module('BB.Services').factory "BB.Service.child_clients", ($q, BBModel, UnwrapService) ->
  promise: true
  unwrap: (resource) ->
    UnwrapService.unwrapCollection(BBModel.Client, 'clients', resource)

angular.module('BB.Services').factory "BB.Service.clients", ($q, BBModel, UnwrapService) ->
  promise: true
  unwrap: (resource) ->
    UnwrapService.unwrapCollection(BBModel.Client, 'clients', resource)

angular.module('BB.Services').factory "BB.Service.questions", ($q, BBModel, UnwrapService) ->
  unwrap: (resource) ->
    unwrapCollection(BBModel.Question, 'questions', resource)

angular.module('BB.Services').factory "BB.Service.question", ($q, BBModel, UnwrapService) ->
  unwrap: (resource) ->
    UnwrapService.unwrapResource(BBModel.Question, resource)


angular.module('BB.Services').factory "BB.Service.answers", ($q, BBModel, UnwrapService) ->
  promise: false
  unwrap: (items) ->
    models = []
    for i in items
      models.push(new BBModel.Answer(i))
    answers =
      answers: models

      getAnswer: (question) ->
        for a in @answers
          return a.value if a.question_text is question or a.question_id is question

    return answers


angular.module('BB.Services').factory "BB.Service.administrators", ($q, BBModel, UnwrapService) ->
  unwrap: (items) ->
    new BBModel.Admin.User(i) for i in items


angular.module('BB.Services').factory "BB.Service.company", ($q, BBModel, UnwrapService) ->
  unwrap: (resource) ->
    UnwrapService.unwrapResource(BBModel.Company, resource)


angular.module('BB.Services').factory "BB.Service.parent", ($q, BBModel, UnwrapService) ->
  unwrap: (resource) ->
    UnwrapService.unwrapResource(BBModel.Company, resource)


angular.module('BB.Services').factory "BB.Service.company_questions", ($q, BBModel, UnwrapService) ->
  promise: true
  unwrap: (resource) ->
    UnwrapService.unwrapCollection(BBModel.BusinessQuestion, 'company_questions', resource)

angular.module('BB.Services').factory "BB.Service.company_question", ($q, BBModel, UnwrapService) ->
  unwrap: (resource) ->
    UnwrapService.unwrapResource(BBModel.BusinessQuestion, resource)


angular.module('BB.Services').factory "BB.Service.images", ($q, BBModel, UnwrapService) ->
  promise: true
  unwrap: (resource) ->
    UnwrapService.unwrapCollection(BBModel.Image, 'images', resource)

angular.module('BB.Services').factory "BB.Service.bookings", ($q, BBModel, UnwrapService) ->
  promise: true
  unwrap: (resource) ->
    UnwrapService.unwrapCollection(BBModel.Member.Booking, 'bookings', resource)

angular.module('BB.Services').factory "BB.Service.wallet", ($q, BBModel, UnwrapService) ->
  unwrap: (resource) ->
    UnwrapService.unwrapResource(BBModel.Member.Wallet, resource)


angular.module('BB.Services').factory "BB.Service.product", ($q, BBModel, UnwrapService) ->
  unwrap: (resource) ->
    UnwrapService.unwrapResource(BBModel.Product, resource)


angular.module('BB.Services').factory "BB.Service.products", ($q, BBModel, UnwrapService) ->
  promise: true
  unwrap: (resource) ->
    deferred = $q.defer()
    resource.$get('products').then (items) =>
      models = []
      for i, index in items
        cat = new BBModel.Product(i)
        cat.order ||= index
        models.push(cat)
      deferred.resolve(models)
    , (err) =>
      deferred.reject(err)

    deferred.promise


angular.module('BB.Services').factory "BB.Service.pre_paid_booking", ($q, BBModel, UnwrapService) ->
  unwrap: (resource) ->
    UnwrapService.unwrapResource(BBModel.PrePaidBooking, resource)


angular.module('BB.Services').factory "BB.Service.pre_paid_bookings", ($q, BBModel, UnwrapService) ->
  promise: true
  unwrap: (resource) ->
    UnwrapService.unwrapCollection(BBModel.PrePaidBooking, 'pre_paid_bookings', resource)

angular.module('BB.Services').factory "BB.Service.external_purchase", ($q, BBModel, UnwrapService) ->
  unwrap: (resource) ->
    UnwrapService.unwrapResource(BBModel.ExternalPurchase, resource)


angular.module('BB.Services').factory "BB.Service.external_purchases", ($q, BBModel, UnwrapService) ->
  promise: true
  unwrap: (resource) ->
    UnwrapService.unwrapCollection(BBModel.ExternalPurchase, 'external_purchases', resource)

angular.module('BB.Services').factory "BB.Service.purchase_item", ($q, BBModel, UnwrapService) ->
  unwrap: (resource) ->
    UnwrapService.unwrapResource(BBModel.PurchaseItem, resource)


angular.module('BB.Services').factory "BB.Service.purchase_items", ($q, BBModel, UnwrapService) ->
  promise: true
  unwrap: (resource) ->
    unwrapCollection(BBModel.PurchaseItem, 'purchase_items', resource)

angular.module('BB.Services').factory "BB.Service.events", ($q, BBModel, UnwrapService) ->
  promise: true
  unwrap: (resource) ->
    unwrapCollection(BModel.Event, 'events', resource)

angular.module('BB.Services').factory "BB.Service.all_children", ($q, BBModel, UnwrapService) ->
  promise: true
  unwrap: (resource) ->
    UnwrapService.unwrapCollection(BBModel.Service, 'services', resource)

angular.module('BB.Services').factory "BB.Service.child_services", ($q, BBModel, UnwrapService) ->
  promise: true
  unwrap: (resource) ->
    UnwrapService.unwrapCollection(BBModel.Service, 'child_services', resource)
