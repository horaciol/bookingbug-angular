'use strict'

angular.module('BB.Models').factory "AdminCompanyModel", (CompanyModel, AdminCompanyService, BookingCollections, $q, BBModel) ->

  class Admin_Company extends CompanyModel

    constructor: (data) ->
      super(data)

    getBooking: (id) ->
      defer = $q.defer()
      @$get('bookings', {id: id}).then (booking) ->
        model = new BBModel.Admin.Booking(booking)
        BookingCollections.checkItems(model)
        defer.resolve(model)
      , (err) ->
        defer.reject(err)
      defer.promise

    @$query: (params) ->
      AdminCompanyService.query(params)

