angular.module('BB.Services').factory "UnwrapService", () ->

  unwrapCollectionSimple = (model, key) ->
    deferred = $q.defer()
    resource.$get(key).then (items) =>
      models = []
      for i in items
        models.push(new model(i))
      deferred.resolve(models)
    , (err) =>
      deferred.reject(err)

    deferred.promise

  unwrapCollection: (model, key) ->
    deferred = $q.defer()

     # if the resource is embedded, return the array of models
    if angular.isArray(resource)

      models = (new model(service) for service in resource)
      deferred.resolve(models)

    else

      resource.$get(key).then (items) =>
        models = []
        for i in items
          models.push(new model(i))
        deferred.resolve(models)
      , (err) =>
        deferred.reject(err)

    deferred.promise


  unwrapResource: (model) ->
    return new model(resource)

angular.module('BB.Services').factory "BB.Service.address", ($q, BBModel) ->
  unwrap: (resource) ->
    unwrapResource(BBModel.Address)


angular.module('BB.Services').factory "BB.Service.person", ($q, BBModel) ->
  unwrap: (resource) ->
    unwrapResource(BBModel.Person)


angular.module('BB.Services').factory "BB.Service.people", ($q, BBModel) ->
  promise: true
  unwrap: (resource) ->
    unwrapCollectionSimple(BBModel.Person, 'people')

angular.module('BB.Services').factory "BB.Service.resource", ($q, BBModel) ->
  unwrap: (resource) ->
    unwrapResource(BBModel.Resource)


angular.module('BB.Services').factory "BB.Service.resources", ($q, BBModel) ->
  promise: true
  unwrap: (resource) ->
    unwrapCollectionSimple(BBModel.Resource, 'resources')

angular.module('BB.Services').factory "BB.Service.service", ($q, BBModel) ->
  unwrap: (resource) ->
    unwrapResource(BBModel.Service)

angular.module('BB.Services').factory "BB.Service.services", ($q, BBModel) ->
  promise: true
  unwrap: (resource) ->
    unwrapCollection(BBModel.Service, 'services')

angular.module('BB.Services').factory "BB.Service.package_item", ($q, BBModel) ->
  unwrap: (resource) ->
    unwrapResource(BBModel.PackageItem)


angular.module('BB.Services').factory "BB.Service.package_items", ($q, BBModel) ->
  promise: true
  unwrap: (resource) ->
    unwrapCollectionSimple(BBModel.PackageItem, 'package_items')

angular.module('BB.Services').factory "BB.Service.bulk_purchase", ($q, BBModel) ->
  unwrap: (resource) ->
    unwrapResource(BBModel.BulkPurchase)


angular.module('BB.Services').factory "BB.Service.bulk_purchases", ($q, BBModel) ->
  promise: true
  unwrap: (resource) ->
    unwrapCollection(BBModel.BulkPurchase, 'bulk_purchases')

angular.module('BB.Services').factory "BB.Service.event_group", ($q, BBModel) ->
  unwrap: (resource) ->
    unwrapResource(BBModel.EventGroup)


angular.module('BB.Services').factory "BB.Service.event_groups", ($q, BBModel) ->
  promise: true
  unwrap: (resource) ->
    unwrapResource(BBModel.EventGroup, 'event_groups')


angular.module('BB.Services').factory "BB.Service.event_chain", ($q, BBModel) ->
  unwrap: (resource) ->
    unwrapResource(BBModel.EventChain)


angular.module('BB.Services').factory "BB.Service.event_chains", ($q, BBModel) ->
  unwrap: (resource) ->
    unwrapResource(BBModel.EventChain)


angular.module('BB.Services').factory "BB.Service.category", ($q, BBModel) ->
  unwrap: (resource) ->
    unwrapResource(BBModel.Category)


angular.module('BB.Services').factory "BB.Service.categories", ($q, BBModel) ->
  promise: true
  unwrap: (resource) ->
    unwrapCollectionSimple(BBModel.Category, 'categories')

angular.module('BB.Services').factory "BB.Service.client", ($q, BBModel) ->
  unwrap: (resource) ->
    unwrapResource(BBModel.Client)


angular.module('BB.Services').factory "BB.Service.child_clients", ($q, BBModel) ->
  promise: true
  unwrap: (resource) ->
    unwrapCollectionSimple(BBModel.Client, 'clients')

angular.module('BB.Services').factory "BB.Service.clients", ($q, BBModel) ->
  promise: true
  unwrap: (resource) ->
    unwrapCollectionSimple(BBModel.Client, 'clients')

angular.module('BB.Services').factory "BB.Service.questions", ($q, BBModel) ->
  unwrap: (resource) ->
    if resource.questions
      (new BBModel.Question(i) for i in resource.questions)
    else if resource.$has('questions')
      defer = $q.defer()
      resource.$get('questions').then (items) ->
        defer.resolve((new BBModel.Question(i) for i in items))
      , (err) ->
        defer.reject(err)
      defer.promise
    else
      (new BBModel.Question(i) for i in resource)


angular.module('BB.Services').factory "BB.Service.question", ($q, BBModel) ->
  unwrap: (resource) ->
    unwrapResource(BBModel.Question)


angular.module('BB.Services').factory "BB.Service.answers", ($q, BBModel) ->
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


angular.module('BB.Services').factory "BB.Service.administrators", ($q, BBModel) ->
  unwrap: (items) ->
    new BBModel.Admin.User(i) for i in items


angular.module('BB.Services').factory "BB.Service.company", ($q, BBModel) ->
  unwrap: (resource) ->
    unwrapResource(BBModel.Company)


angular.module('BB.Services').factory "BB.Service.parent", ($q, BBModel) ->
  unwrap: (resource) ->
    unwrapResource(BBModel.Company)


angular.module('BB.Services').factory "BB.Service.company_questions", ($q, BBModel) ->
  promise: true
  unwrap: (resource) ->
    unwrapCollectionSimple(BBModel.BusinessQuestion, 'company_questions')

angular.module('BB.Services').factory "BB.Service.company_question", ($q, BBModel) ->
  unwrap: (resource) ->
    unwrapResource(BBModel.BusinessQuestion)


angular.module('BB.Services').factory "BB.Service.images", ($q, BBModel) ->
  promise: true
  unwrap: (resource) ->
    unwrapCollectionSimple(BBModel.Image, 'images')

angular.module('BB.Services').factory "BB.Service.bookings", ($q, BBModel) ->
  promise: true
  unwrap: (resource) ->
    unwrapCollectionSimple(BBModel.Member.Booking, 'bookings')

angular.module('BB.Services').factory "BB.Service.wallet", ($q, BBModel) ->
  unwrap: (resource) ->
    unwrapResource(BBModel.Member.Wallet)


angular.module('BB.Services').factory "BB.Service.product", ($q, BBModel) ->
  unwrap: (resource) ->
    unwrapResource(BBModel.Product)


angular.module('BB.Services').factory "BB.Service.products", ($q, BBModel) ->
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


angular.module('BB.Services').factory "BB.Service.pre_paid_booking", ($q, BBModel) ->
  unwrap: (resource) ->
    unwrapResource(BBModel.PrePaidBooking)


angular.module('BB.Services').factory "BB.Service.pre_paid_bookings", ($q, BBModel) ->
  promise: true
  unwrap: (resource) ->
    unwrapCollection(BBModel.PrePaidBooking, 'pre_paid_bookings')

angular.module('BB.Services').factory "BB.Service.external_purchase", ($q, BBModel) ->
  unwrap: (resource) ->
    unwrapResource(BBModel.ExternalPurchase)


angular.module('BB.Services').factory "BB.Service.external_purchases", ($q, BBModel) ->
  promise: true
  unwrap: (resource) ->
    unwrapCollection(BBModel.ExternalPurchase, 'external_purchases')

angular.module('BB.Services').factory "BB.Service.purchase_item", ($q, BBModel) ->
  unwrap: (resource) ->
    unwrapResource(BBModel.PurchaseItem)


angular.module('BB.Services').factory "BB.Service.purchase_items", ($q, BBModel) ->
  promise: true
  unwrap: (resource) ->
    unwrapCollection(BBModel.PurchaseItem, 'purchase_items')

angular.module('BB.Services').factory "BB.Service.events", ($q, BBModel) ->
  promise: true
  unwrap: (resource) ->
    unwrapCollection(BModel.Event, 'events')
