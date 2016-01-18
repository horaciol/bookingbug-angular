angular.module('BB.Services').factory "BulkPurchaseService", ($q, BBModel) ->

  query: (company) ->
    deferred = $q.defer()
    if !company.$has('bulk_purchases')
      deferred.reject("No bulk purchases found")
    else
      company.$get('bulk_purchases').then (bulk_purchase) ->
        bulk_purchase.$get('bulk_purchases').then (bulk_purchases) ->
          deferred.resolve(new BBModel.BulkPurchase(i) for i in bulk_purchases)
      , (err) =>
        deferred.reject(err)

    deferred.promise